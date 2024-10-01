
function plot_eq(eq, tok, varargin)


try
  plot_nstxu_geo(tok)
catch
  if size(tok.limdata,1) ~= 2, tok.limdata = tok.limdata'; end
  plot(tok.limdata(2,:), tok.limdata(1,:), 'k')
end

try
  rg = eq.rg;
  zg = eq.zg;
catch
  rg = tok.rg;
  zg = tok.zg;
end

hold on
psizr = eq.psizr;
psibry = eq.psibry;
levels = linspace(eq.psibry, eq.psimag, 4);
contour(rg,zg,psizr, levels, 'color', [1 1 1]*0.5, 'linewidth', 0.5);
contour(rg,zg,psizr,[psibry psibry], varargin{:});
axis equal
axis([min(tok.rg) max(tok.rg) min(tok.zg) max(tok.zg)])












