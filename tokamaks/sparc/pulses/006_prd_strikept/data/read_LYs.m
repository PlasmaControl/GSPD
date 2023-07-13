clc; clear; close all

G = load('L').L.G;


for kk = 1:31
  
  % LY = LYs{kk};
  
  tmp = num2str(1500+kk-1);
  fn = ['./1500_series_LY/' tmp '/LY_' tmp '.mat'];
  LY = load(fn);

  G.rg = G.rx;
  G.zg = G.zx;
  G.limdata = [G.zl G.rl]';
  G.nr = length(G.rg);
  G.nz = length(G.zg);
  psizr = LY.Fx;
  eq = find_bry(psizr, G, 0);
  
  sp = strikepoints(G.rg, G.zg, eq.psizr, eq.psibry);
  eq.rstrike = sp.r;
  eq.zstrike = sp.z;
  if eq.islimited
    eq.rstrike = eq.rstrike*nan;
    eq.zstrike = eq.zstrike*nan;
  end

  

  
  r = eq.rbbbs;
  z = eq.zbbbs;

  [r,z] = interparc(r, z, 200, 1, 0);
  [r,z] = sort_ccw(r, z, 1.85, 0.02);

  % zoom in on upper x-point
  [~,i] = max(z);
  [eq.rxup, eq.zxup] = isoflux_xpFinder(G.rx, G.zx, LY.Fx, r(i), z(i));

  % zoom in on lower x-point
  [~,i] = min(z);
  [eq.rxlo, eq.zxlo] = isoflux_xpFinder(G.rx, G.zx, LY.Fx, r(i), z(i));


%   figure
%   hold on
%   plot(r,z)
%   scatter(r(1),z(1),100,'g','filled')
%   scatter(r(2),z(2),100,'b','filled')
%   plot(eq.rxlo, eq.zxlo, 'bx', 'linewidth', 5)
%   plot(eq.rxup, eq.zxup, 'rx', 'linewidth', 5)
%   plot(G.rl, G.zl, 'k')
%   axis equal
%   axis([1 2.5 -2 2])
%   set(gcf, 'Position', [302 238 357 525])
%   drawnow

%   fig = figure;
%   fig.Position = [447 148 444 729];
%   plot_eq(eq, G)
%   scatter(eq.rstrike, eq.zstrike, 'r', 'filled')
%   drawnow

  eqs{kk} = eq;

  LYs{kk} = LY;
end

save('eqs','eqs')
save('LYs', 'LYs')













