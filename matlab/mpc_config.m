% builds dynamic model and some MPC stuff that can be precomputed

function config = mpc_config(tok, shapes, targs, settings)


%% build dynamics and output models

% build the dynamics model A,B matrices
M = [tok.mcc tok.mcv; tok.mcv' tok.mvv];
M = (M + M') /  2;
R = diag([tok.resc; tok.resv]);                   
Minv = inv(M);
A = -Minv * R;
B = Minv(:,settings.active_coils);


% build the output C matrices
dpsizrdx = [tok.mpc tok.mpv];
Cmats = output_model(dpsizrdx, tok, shapes, settings);



%% compress model to use fewer vessel modes

if settings.compress_vessel_elements

  % perform a balanced realization on the vessel currents
  % step1: compute balancing transformation matrices
  ivess = tok.nc + (1:tok.nv);
  Avess = A(ivess,ivess);
  Bvess = B(ivess,:);
  Cvess = eye(tok.nv, tok.nv);
  Pvess = ss(Avess,Bvess,Cvess,0);
  [~,~,Tv,~] = balreal(Pvess);
  Tvi = inv(Tv);
  iuse = 1:settings.nvessmodes;
  Tv = Tv(iuse,:);
  Tvi = Tvi(:,iuse);
  Tx = blkdiag(eye(tok.nc), Tv);
  Txi = blkdiag(eye(tok.nc), Tvi);  
else  
  Tx = eye(tok.nc + tok.nv);
  Txi = eye(tok.nc + tok.nv);  
  Tv = eye(tok.nv);
  Tvi = eye(tok.nv);
end
info = ['Balanced realization transformations for compressing vessel' ...
  ' elements. Let x=[ic;iv], xb=[ic;ivb] with ivb the compressed vessel ' ...
  'elements. Transformations are: xb=Tx*x, x=Txi*xb, ivb=Tv*iv, iv=Tvi*ivb'];
bal = variables2struct(info, Tx, Txi, Tv, Tvi);

% step2: reduce models
for i = 1:length(Cmats)
  Cmats{i} = Cmats{i} * Txi;
end
Ar = Tx*A*Txi;
Br = Tx*B;
[nx, nu] = size(Br);

%% Build the MPC prediction model

% discretize model
[Ad, Bd] = c2d(Ar,Br,settings.dt);


% Prediction model used in MPC. See published paper for definitions.
Nlook = settings.N;
nw = nx;
E = [];
F  = [];
Fw = [];
Apow  = eye(nx);
F_row = zeros(nx, Nlook*nu);
Fw_row = zeros(nx, Nlook*nw);

for i = 1:Nlook

  idx = (nu*(i-1)+1):(nu*i);
  F_row = Ad * F_row;
  F_row(:,idx) = Bd;
  F = [F; F_row];

  idx = (nw*(i-1)+1):(nw*i);
  Fw_row = Ad * Fw_row;
  Fw_row(:,idx) = eye(nx);
  Fw = [Fw; Fw_row];
  
  Apow = Ad * Apow;
  E = [E; Apow];
end



%% define data indices
% cv will hold indices of the outputs (y), states (x), and inputs (u). 
% Useful for organizing data.
cv = struct;

% the outputs y are defined by fds2control
cv.ynames = settings.fds2control;
idx = 0;
for k = 1:length(cv.ynames)    
  varname = cv.ynames{k};
  n = size(targs.(varname).Data, 2);  
  idx = idx(end)+1:idx(end)+n;  
  cv.iy.(varname) = idx;
end 

% the states x are the coil currents and vessel current modes
cv.xnames = {'ic', 'ivb'}';
cv.ix.ic = 1:tok.nc;
cv.ix.ivb = tok.nc + (1:settings.nvessmodes);
for i = 1:tok.nc
  cv.ix.(tok.ccnames{i}) = i;  
end
cv.xdesc.ic = 'Coil currents.';
cv.xdesc.ivb = 'Vessel currents (compressed format)';

% the inputs are the voltages on the active coils (subset of the coils)
cv.unames = {'v'};
nu = length(settings.active_coils);
for i = 1:nu
  nam = tok.ccnames{settings.active_coils(i)};
  cv.iu.(nam) = i;
end
cv.iu.v = 1:nu;
cv.udesc.v = 'Voltage in the active coil circuits.';


%% write descriptions
d.cv    = '(c)ontrolled (v)ariables struct that holds info on data indices';
d.nx    = 'number of states in state space model';
d.nu    = 'number of actuators in state space model';
d.A     = 'vacuum circuit dynamics A matrix (uncompressed)';
d.B     = 'vacuum circuit dynamics B matrix (uncompressed)';
d.Cmats = 'output C matrices of the state-space model';
d.Ar    = 'vacuum circuit dynamics A matrix (reduced)';
d.Br    = 'vacuum circuit dynamics B matrix (reduced)';
d.Ad    = 'vacuum circuit dynamics A matrix (reduced then discretized)';
d.Bd    = 'vacuum circuit dynamics B matrix (reduced then discretized)';
d.M     = 'mutual inductance matrix in circuit model';
d.Minv  = 'inverse of M';
d.R     = 'resistance matrix in circuit model';
d.E     = 'E matrix in MPC prediction model (influence of initial state)';
d.F     = 'F matrix in MPC prediction model (influence of actuator voltages)';
d.Fw    = 'E matrix in MPC prediction model (influence of plasma current distribution)';
d.bal   = 'info on balanced realization used to compress vessel elements';


%% save config
config = variables2struct(cv,nx,nu,A,B,Ar,Br,Ad,Bd,M,Minv,R,E,F,Fw,Cmats,bal);

fds = sort(fields(d));
config = reorderstructure(config, fds{:});
config.descriptions = reorderstructure(d, fds{:});









































































