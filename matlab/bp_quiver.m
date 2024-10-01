% plots vector arrows of the poloidal magnetic field Bp at the (r,z)
% locations
function [Br, Bz, r, z] = bp_quiver(psizr, tok_data_struct, opts, varargin)

if nargin < 3, opts = struct; end
% if ~exist('opts', 'var') || isempty(opts), opts = struct; end
if ~isfield(opts, 'normalize'), opts.normalize = 0; end
if ~isfield(opts, 'r'), opts.r = [1.4 1.7 2.0 2.3 1.7 1.7 1.7 1.7 1.9 1.9 1.9 1.9 1.9]; end
if ~isfield(opts, 'z'), opts.z = [0 0 0 0 0.4 0.6 -0.4 -0.6 -0.6 -0.4 0 0.4 0.6]; end
if ~isfield(opts, 'bpsign'), opts.bpsign = 1; end  



r = opts.r(:);
z = opts.z(:);

rg = tok_data_struct.rg;
zg = tok_data_struct.zg;

[~, psi_r, psi_z] = bicubicHermite(rg, zg, psizr, r, z);

Br = -opts.bpsign * 1./(2*pi*r)  .* psi_z;
Bz = opts.bpsign * 1 ./ (2*pi*r) .* psi_r;

if opts.normalize
  scale = sqrt(Br.^2 + Bz.^2);
  Br = Br ./ scale;
  Bz = Bz ./ scale;
end

quiver(r, z, Br, Bz, 0.7, varargin{:}, 'Alignment', 'center');
% scatter(r, z, 'k','filled');






