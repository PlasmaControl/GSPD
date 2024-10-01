% Sets up and solves an MPC-like quadratic program for creating
% Grad-Shafranov equilibria according to the target shape evolution. 
% 
% Inputs: see GSpulse.m and pulse.m in the EXAMPLE folder
% Outputs: mpcsoln - struct with timeseries data on the currents and flux
%                    errors and flux evolution          

function [mpcsoln, targs] = mpc_update_psiapp(iter, pcurrt, config, tok, shapes, ...
  plasma_scalars, init, settings, targs, weights, opts)


% read parameters
fds2control = settings.fds2control;
Nlook = settings.N;
t = settings.t;
dt = settings.dt;
wts = weights.wts;
dwts = weights.dwts;
d2wts = weights.d2wts;
cv = config.cv;
nu = config.nu;
nx = config.nx;
E = config.E;
F = config.F;
Fw = config.Fw;
Cmats = config.Cmats;
Chat = blkdiag(Cmats{:});


% map plasma current -> plasma flux
psipla = tok.mpp * pcurrt;


% % find the targ.psibry that is consistent with targ.ip
% psiapp0 = tok.mpc*init.ic + tok.mpv*init.iv;
% psi0 = psiapp0 + psipla(:,1);
% psi0 = reshape(psi0, tok.nz, tok.nr);
% ref = structts2struct(shapes, {'rb','zb'}, t(1));
% psibry0 = mean(bicubicHermite(tok.rg, tok.zg, psi0, ref.rb, ref.zb));
% % targs.psibry = psibry_dynamics(tok, settings, shapes, plasma_scalars,...
% %   psibry0, psipla);
% targs.psibry.Time = t(:);
% targs.psibry.Data = ones(N,1)*psibry0;


% find the targs.psibry that is consistent with targs.ip
if ~settings.specify_psibry_directly   
 targs.psibry = compute_psibry(init, tok, settings, shapes, ...
  plasma_scalars, psipla);
end


% measure y
yks = measure_ys(psipla, fds2control, shapes, tok);
ykhat = vertcat(yks{:});

% target y and error 
rhat = structts2vec(targs, fds2control, t);
dytarghat = rhat - ykhat;
ny = length(yks{1});


% initial state
uprev = init.v;
xk = [init.ic; init.iv];
xk = config.bal.Tx * xk;   
x0 = zeros(size(xk));
dxk = xk;
x0hat = repmat(x0, Nlook, 1);


% initial error
rk = structts2vec(targs, fds2control, t(1));
ykpla = yks{1};
C = Cmats{1};
ek = rk - ykpla - C*xk;


% plasma-coupling term
w = plasma_coupling(settings.dt, tok, pcurrt);
w = config.bal.Tx * w;
[~,wd] = c2d(config.Ar, w, dt);
wd = wd(:);


% weights
q = structts2vec(wts, fds2control, t);
dq = structts2vec(dwts, fds2control, t);
r = structts2vec(wts, {'v'}, t);
dr = structts2vec(dwts, {'v'}, t);


% filter out any nans
i = isnan(dytarghat);
dytarghat(i) = 0;
q(i) = 0;
Chat(i,:) = 0;


% make sparse format
Q = spdiags(q, 0, length(q), length(q));
dQ = spdiags(dq, 0, length(dq), length(dq));
R = spdiags(r, 0, length(r), length(r));
dR = spdiags(dr, 0, length(dr), length(dr));


% Prediction model and cost matrices (note: ehat = M*duhat + d)
% see accompanying paper for definitions and derivations
M = -Chat*F;
d = dytarghat - Chat * (E*dxk + Fw*wd);

% J1
H1 = M'*Q*M;
f1 = M'*Q*d;

% J3
H3 = R;
f3 = 0;

% J4
m = tridiag(-1, 1, 0, Nlook);
Su = kron(m, eye(nu));
Su = sparse(Su);

H4 = Su' * dR * Su;
f4 = -Su' * dR(:,1:nu) * uprev;


% J5
m = tridiag(-1, 1, 0, Nlook);
Se = kron(m, eye(ny));
Se = sparse(Se);
N = Se*M;
I = sparse(eye(Nlook*ny,ny));
g = Se*d - I*ek;
H5 = N' * dQ * N;
f5 = N' * dQ * g;


% J6
m = tridiag(-1,2,-1,Nlook);
m([1 end], :) = [];
S2e = kron(m,eye(ny));
S2e = sparse(S2e);
d2q = structts2vec(d2wts, fds2control, t(2:end-1));
d2Q = spdiags(d2q, 0, length(d2q), length(d2q));
H6 = M'*S2e'*d2Q*S2e*M;
f6 = M'*S2e'*d2Q*S2e*d;




% J total
f = f1 + f3 + f4 + f5 + f6;
H = H1 + H3 + H4 + H5 + H6;
H = (H+H')/2;


% no equality constraints
Aeq = [];
beq = [];

% Inequality constraints

% voltage limits
if settings.enforce_voltage_limits
  ub = repmat(settings.vmax, Nlook, 1);
  lb = repmat(settings.vmin, Nlook, 1);
else
  ub = [];
  lb = [];
end

% current limits
if settings.enforce_current_limits
  ymin = -inf(ny,1);
  ymax = inf(ny,1);
  ymin(cv.iy.ic) = settings.ic_min;
  ymax(cv.iy.ic) = settings.ic_max;
  yminhat = repmat(ymin, Nlook, 1);
  ymaxhat = repmat(ymax, Nlook, 1);
  Aineq = [-M; M];
  bineq = [ymaxhat + d - rhat; -yminhat - d + rhat];
  i = isinf(bineq);
  Aineq(i,:) = [];
  bineq(i,:) = [];
else
  Aineq = [];
  bineq = [];
end


% solve quadratic program
duhat0 = -H\f;
qpopts = optimoptions('quadprog', 'algorithm', 'active-set', 'Display', 'off');
duhat = quadprog(H,f,Aineq, bineq, Aeq, beq, lb, ub, duhat0, qpopts);


% extract predictions
ehat = M*duhat + d;
dxhat = E*dxk + F*duhat + Fw*wd;
dyhat = dytarghat - ehat;
yhat = dyhat + ykhat;
xhat = dxhat + x0hat;
    
y = vec2structts(yhat, fds2control, cv.iy, t);
x = vec2structts(xhat, fields(cv.ix), cv.ix, t);
u = vec2structts(duhat, fields(cv.iu), cv.iu, t);
y = copyfields(y,x,[],0);
y = copyfields(y,u,[],0);

psiapp = [tok.mpc tok.mpv] * config.bal.Txi * [x.ic.Data'; x.ivb.Data'];
psizr = psiapp + psipla;

y.psizr.Time = t;
y.psiapp.Data = t;
y.psipla.Data = t;

y.psizr.Data = psizr';
y.psiapp.Data = psiapp';
y.psipla.Data = psiapp';

y.iv = y.ivb;
y.iv.Data = y.ivb.Data * config.bal.Tvi';

mpcsoln = y;

% plot timetraces
if (opts.plotlevel >= 2) || (opts.plotlevel >= 1 && iter==settings.niter)
  h = plot_structts(y, fds2control, 2);
  plot_structts(targs, fds2control, 2, h, '--r');
  legend('Actual', 'Target', 'fontsize', 16)
  drawnow
 
  ic = targs.ic.Data';
  xr = vec2structts(ic(:), tok.ccnames, cv.ix, t);
  h = plot_structts(x, tok.ccnames, 2);
  plot_structts(xr, tok.ccnames, 2, h, '--r');
  legend('Actual', 'Target', 'fontsize', 16)
  drawnow
end





































