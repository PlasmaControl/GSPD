% Get a very rough estimate of the plasma current distribution jphi based
% on the target boundary (rb,zb) and target Ip. The plasma current 
% distribution is estimated as jphi = jhat * (1 - x^a)^b, 
% where x is the distance ratio from centroid to boundary (0 at centroid, 
% 1 at boundary), a and b are constants, and jhat is a constant scaled 
% to match the target Ip. 
% 
% Inputs: 
%   (rb,zb) - plasma boundary 
%   Ip - plasma current
%   (rg,zg) - grid for the current distribution
%
% Outputs:
%   jphi   - plasma current density distribution on the (rg,zg) grid
%   pcurrt - plasma current on the grid

% Example:
% rb = 1 + 0.3 * cos(linspace(0,2*pi));
% zb = 0 + 0.5 * sin(linspace(0,2*pi));
% Ip = 1e6;
% rg = linspace(0.2, 1.6, 33);
% zg = linspace(-0.8, 0.8, 33);
% opts.plotit = 1;
% [jphi, pcurrt] = jphi_estimate(rb, zb, Ip, rg, zg, opts)


function [jphi, pcurrt] = jphi_estimate(rb, zb, Ip, rg, zg, opts)


if ~exist('opts','var'), opts = struct; end
if ~isfield(opts, 'a'),  opts.a = 1.87; end
if ~isfield(opts, 'b'),  opts.b = 1.5; end
if ~isfield(opts, 'plotit'), opts.plotit = false; end


[rgg, zgg] = meshgrid(rg,zg);
dr = mean(diff(rg));
dz = mean(diff(zg));
nz = length(zg);
nr = length(rg);

P = polyshape(rb, zb);
[rc, zc] = centroid(P);


% at each grid point, find normalized distance between centroid and
% boundary
rgridc = rgg + dr/2;
zgridc = zgg + dz/2;
dist2cent = sqrt((rgridc(:)-rc).^2 + (zgridc(:)-zc).^2);
[~, dist2bry] = distance2curve([rb(:) zb(:)], [rgridc(:) zgridc(:)]);
x = dist2cent ./ (dist2cent + dist2bry);
in = inpolygon(rgridc(:), zgridc(:), P.Vertices(:,1), P.Vertices(:,2));
in = reshape(in, nz, nr);
in = in | circshift(in,1,1) | circshift(in,-1,1) | circshift(in,1,2) | circshift(in,-1,2);
x(~in) = nan;
x = reshape(x, nr, nz);
x(x>1) = 1;


% solve for current
j0 = (1 - x.^opts.a) .^ opts.b;
jhat = Ip / (nansum(j0(:)) * dr * dz);
jphi = j0 * jhat;
jphi(isnan(jphi)) = 0;
pcurrt = jphi * dr * dz;


% plot shit
if opts.plotit
  figure
  subplot(3,1,1)
  x = linspace(0,1);
  y = (1 - x.^opts.a) .^ opts.b;
  plot(x, y)

  subplot(3,1,2:3)
  contourf(rg, zg, jphi)
  hold on
  plot(rb, zb, 'r', 'linewidth', 1)
  colorbar
  axis equal
end












