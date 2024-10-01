% Interpolates and hold end point values
%
% (With interp1, the only way to hold endpoint values is to use the
% 'nearest' method, which also affects the interior.) 
%
% This has only been robustly tested for scalar signals. 
% 
% Example: 
% x = 1:1:10;
% v = sin(x);
% xq = -1:0.1:12;
% vq = interp1hold(x, v, xq, 'spline'); % spline interpolation for interior
% plot(xq,vq,x,v,'.','markersize', 40)

function vq = interp1hold(x,v,xq,varargin)

xq1 = xq(xq < min(x));
xq2 = xq(xq >= min(x) & xq <= max(x));
xq3 = xq(xq > max(x));

vq1 = interp1(x,v,xq1,'nearest','extrap');
vq2 = interp1(x,v,xq2, varargin{:});
vq3 = interp1(x,v,xq3, 'nearest','extrap');

sz1 = size(vq1);
sz2 = size(vq2);
sz3 = size(vq3);

dim = find((sz1 ~= sz2) & (sz2 ~= sz3));
if isempty(dim), dim = 1; end
vq = cat(dim(1), vq1, vq2, vq3);