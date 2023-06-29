% function fit_profiles(eq, tok)
clear; clc; close all

% load('eq_gspd')
load('eq')
load('tok')

in = inpolygon(tok.rgg, tok.zgg, eq.rbbbs, eq.zbbbs);

psin_grid = (eq.psizr - eq.psibry) / (eq.psimag - eq.psibry);
psin_grid(~in) = nan;
psin = linspace(0,1,tok.nr);

mu0 = pi*4e-7;

% M will hold the piecewise interpolants
M = zeros(tok.nz*tok.nr, tok.nr);
for k = 1:tok.nz*tok.nr
  x = psin_grid(k);
  idx = find(psin > x, 1);
  a = (psin(idx) - x) / (psin(2) - psin(1));
  M(k, idx) = 1-a;
  M(k, idx-1) = a;
end


% solve jphi = A * [pprime; ffprim]
r = sparse(diag(tok.rgg(:)));
ri = sparse(diag(1./tok.rgg(:)));
A = [r*M ri*M/mu0];

if isfield(eq, 'jphi')
  jphi = eq.jphi(:) * 1e6;
else
  da = mean(diff(tok.rg)) * mean(diff(tok.zg));
  jphi = eq.pcurrt(:) / da;
end

pff = A \ jphi;
pprime = pff(1:tok.nr);
ffprim = pff(tok.nr+1:end);


figure
subplot(211)
hold on
plot(flip(psin), pprime, 'linewidth', 1.5)
scatter(psin, eq.pprime, 15, 'r', 'filled')

subplot(212)
hold on
plot(flip(psin), ffprim, 'linewidth', 1.5)
scatter(psin, eq.ffprim, 15, 'r', 'filled')


% subplot(212)
% hold on
% plot(flip(psin), ffprim, 'linewidth', 1.5)
% scatter(psin, -eq.ffprim*2*pi, 15, 'r', 'filled'z
% load('eq')
% plot(psin, eq.ffprim, 'g')



































