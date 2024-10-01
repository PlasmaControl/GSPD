% Helper function used in mpc_update_psiapp.m
%
% This is not a general-purpose function, its only used with
% mpc_update_psiapp.m so see that for info on the inputs and outputs. 
%
% Purpose: compute psibry that is consistent with initial condition, and
% Rp, Li, Ip evolution. The governing equation is:
%
%   -psibrydot = Rp*Ip + 1/Ip * [ d/dt( 0.5 * Li * Ip^2)]
%
% Method: use given target shaping to solve for W=0.5*Li*Ip^2, 
%         then use targ.Rp, targ.Ip to integrate equation.
%

function psibrytarg = compute_psibry(init, tok, settings, shapes, ...
  plasma_scalars, psipla)


% compute the initial psibry (initial condition for the integration)
psiapp0 = tok.mpc*init.ic + tok.mpv*init.iv;
psi0 = psiapp0(:) + psipla(:,1);
psi0 = reshape(psi0, tok.nz, tok.nr);
ref = structts2struct(shapes, {'rb','zb'}, settings.t(1));
psibry0 = mean(bicubicHermite(tok.rg, tok.zg, psi0, ref.rb, ref.zb));
  

% read parameters
N = settings.N;
t = settings.t;
nz = tok.nz;
nr = tok.nr;
rg = tok.rg;
zg = tok.zg;
Li = [];
Wmag = [];
Rp = plasma_scalars.Rp;
ip = plasma_scalars.ip;


% compute Wmag
for i = 1:N
  psi = reshape(psipla(:,i), nz, nr);
  rb = shapes.rb.Data(i,:)';
  zb = shapes.zb.Data(i,:)';
  [Li(i), Wmag(i)] = internal_inductance(ip.Data(i), psi, rb, zb, rg, zg);
end


% integrate equation
Wmagdot = gradient(Wmag, t);
psibrydot = -Rp.Data .* ip.Data - 1./ip.Data .* Wmagdot(:);
psibry = psibry0 + cumtrapz(t, psibrydot);

psibrytarg.Time = t(:);
psibrytarg.Data = psibry(:);













