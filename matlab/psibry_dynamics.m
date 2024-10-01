% The governing equation is:
%
%   -psibrydot = Rp*Ip + 1/Ip * [ d/dt( 0.5 * Li * Ip^2)]
%
% Purpose: integrate this equation to find target psibry consistent with
% Ip, Rp, and Li evolution
%
% Method: use given target shaping to solve for W=0.5*Li*Ip^2, 
%         then use targ.Rp, targ.Ip to integrate equation.

function psibrytarg = psibry_dynamics(tok, settings, shapes, ...
  plasma_scalars, psibry0, psizr)


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


for i = 1:N
  psi = reshape(psizr(:,i), nz, nr);
  rb = shapes.rb.Data(i,:)';
  zb = shapes.zb.Data(i,:)';
  [Li(i), Wmag(i)] = internal_inductance(ip.Data(i), psi, rb, zb, rg, zg);
end


Wmagdot = gradient(Wmag, t);
psibrydot = -Rp.Data .* ip.Data - 1./ip.Data .* Wmagdot(:);
psibry = psibry0 + cumtrapz(t, psibrydot);

psibrytarg.Time = t(:);
psibrytarg.Data = psibry(:);























