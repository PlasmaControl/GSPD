% First traces the boundary of the equilibria to extract flux distribution.
% Then updates the plasma current distribution according to the Grad
% Shafranov equation and evolution of plasma_scalars (Ip, Wmhd, li)
%
% Inputs: many, see GSpulse.m and pulse.m in the EXAMPLE folder
% Outputs: 
%          eqs1 - updated equilibria with new plasma current distribution
%                 (note that if equilibria is not converged, some of the
%                 equilibrium parameters, e.g. x-point locations, may not
%                 be self-consistent with the flux). 
% 
%          eqs0 - previous iteration of equilibria, after performing
%                 boundary tracing. x-points and other parameters should be
%                 self-consistent with the flux distribution. (but will not 
%                 be a Grad-Shafranov current distribution if not converged) 
%
%          pcurrt - plasma current distribution for all equilibria

function [eqs1, eqs0, pcurrt] = gs_update_psipla(...
  mpcsoln, pcurrt_prev, tok, plasma_scalars, settings)


% read inputs
N = settings.N;
psizr = mpcsoln.psizr.Data';
psiapp = mpcsoln.psiapp.Data';
nz = tok.nz;
nr = tok.nr;
mpp = tok.mpp;
b = settings.basis;


% trace boundary
eqs0 = cell(N,1);
for i = 1:N
  fprintf('  Tracing boundary: %d of %d ...\n', i, N);
  psizr_i = reshape(psizr(:,i), tok.nz, tok.nr);
  eqs0{i} = find_bry(psizr_i, tok, 0);
end


eqs1 = cell(N,1);
pcurrt = zeros(nz*nr,N);
for i = 1:N

  eq = eqs0{i};
  ip = plasma_scalars.ip.Data(i);
  wmhd = plasma_scalars.wmhd.Data(i);
  li = plasma_scalars.li.Data(i);
  
  psibry = eq.psibry;
  psimag = eq.psimag;
  
  [rgg, zgg] = meshgrid(tok.rg, tok.zg);
  dr = mean(diff(tok.rg));
  dz = mean(diff(tok.zg));
  dA = dr*dz;
  
  in = inpolygon(rgg, zgg, eq.rbbbs, eq.zbbbs);
  psinzr = (eq.psizr - eq.psimag) / (eq.psibry - eq.psimag);
  psinzr(~in) = nan;
  
  mu0 = pi*4e-7;
  psin = linspace(0,1,tok.nr)';

  
  % pressure basis
  b.pres = cumtrapz(psin, b.pprime1);  
  b.pres = b.pres-b.pres(end);
  b.preszr = interp1(psin, b.pres, psinzr(:));
  in = ~isnan(b.preszr);
  b.preszr(~in) = 0;
  
  % pprime basis
  b.pprime = b.pprime1 * 2*pi/(psibry-psimag);
  b.pprimezr = interp1(psin, b.pprime1, psinzr(:)) * 2*pi/(psibry-psimag);
  b.pprimezr(~in) = 0;
  
  % ffprim basis
  b.ffprim = [b.ffprim1 b.ffprim2] * 2*pi/(psibry-psimag);
  b.ffprimzr = interp1(psin, [b.ffprim1 b.ffprim2], psinzr(:)) * 2*pi/(psibry-psimag);
  b.ffprimzr([~in ~in]) = 0;
  
  % set up the equations:  [Ip; wmhd; li] = H * [cp1; cf1; cf2]; 
  % then this can be solved for [cp1; cf1; cf2] the P' and FF' coefficients
  H = zeros(3);
  R = rgg(:);
  
  H(1,:) = [R'*b.pprimezr  1./(mu0 * R') * b.ffprimzr] * dA;
  H(2,1) = 3*pi*R'*b.preszr*dA;
  
  % this equation for li is a bit hand-wavy see accompanying paper (it is 
  % actually specifying the ratio of the cf1 and cf2 coefficients, not li).
  % Future work will improve this. 
  alpha = interp1([0.5 1.2], [-4 -10], li, 'linear', 'extrap');
  H(3,:) = [0 1 alpha];
  
  c = H \ [ip; wmhd; 0];
  
  jphi = [R.*b.pprimezr  1./(mu0 * R).*b.ffprimzr] * c;
  jphi = reshape(jphi, nz, nr);
  pcurrt_i = jphi * dA;
  
  
  eq.pcurrt = pcurrt_i;
  eq.psiapp = reshape(psiapp(:,i), nz, nr);
  eq.psipla = mpp * pcurrt_i(:);
  eq.psipla = reshape(eq.psipla, nz, nr);
  eq.psizr = eq.psiapp + eq.psipla;
  eq.pprime = b.pprime * c(1);
  eq.ffprim = b.ffprim1*c(2) + b.ffprim2*c(3);
  eq.psin = b.psin;

  eqs1{i} = eq;
  pcurrt(:,i) = pcurrt_i(:);
end


% relaxed update of pcurrt
pcurrt = settings.c_relax*pcurrt + (1-settings.c_relax) * pcurrt_prev;























