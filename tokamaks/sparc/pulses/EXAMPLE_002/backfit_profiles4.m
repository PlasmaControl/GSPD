function backfit_profiles4(eq, tok)

ng = 10;

in = inpolygon(tok.rgg, tok.zgg, eq.rbbbs, eq.zbbbs);

psin_grid = (eq.psizr - eq.psibry) / (eq.psimag - eq.psibry);
psin_grid(psin_grid<=0) = sqrt(eps);
psin_grid(psin_grid>=1) = 1-sqrt(eps);
psin_grid(~in) = nan;
psin = linspace(0,1,ng);

mu0 = pi*4e-7;

% M will hold the piecewise interpolants
M = zeros(tok.nz*tok.nr, ng);
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
A = [r*M ri*M];

if isfield(eq, 'jphi')
  jphi = eq.jphi(:) * 1e6;
else
  da = mean(diff(tok.rg)) * mean(diff(tok.zg));
  jphi = eq.pcurrt(:) / da;
end

pff = A \ jphi;
pprime = pff(1:ng);
ffprim = pff(ng+1:end);


% plot the fits
if 1
  fig = figure;
  fig.Position = [439 381 895 416];
  
  subplot(221)
  hold on
  plot(flip(psin), pprime, 'linewidth', 1.5)
  scatter(linspace(0,1,tok.nr), eq.pprime, 25, 'r', 'filled')
  legend('Fit', 'Eq')
  title("P'")
  
  subplot(222)
  hold on
  plot(flip(psin), ffprim, 'linewidth', 1.5)
  scatter(linspace(0,1,tok.nr), eq.ffprim/mu0,  25, 'r', 'filled')
  title("FF'")
  legend('Fit', 'Eq')

  jphi_fit = A*pff;
  jphi_fit_pprime = A(:,1:ng)*pprime;
  jphi_fit_ffprim = A(:,ng+1:end)*ffprim;
  
  jphi_ffprim = jphi - jphi_fit_pprime;
  ffprim_grid = r * jphi_ffprim;
  
  jphi_pprime = jphi - jphi_fit_ffprim;
  pprime_grid = ri * jphi_pprime;
  
  subplot(223)
  hold on
  plot(psin, pprime, '.-b', 'linewidth', 4)
  scatter(psin_grid(:), pprime_grid(:), 10, 'r', 'filled')
  legend('Fit', 'Eq')
  title("P'")
  
  subplot(224)
  hold on
  plot(psin, ffprim, '.-b', 'linewidth', 4)
  scatter(psin_grid(:), ffprim_grid(:), 10, 'r', 'filled')
  title("FF'")
end





























