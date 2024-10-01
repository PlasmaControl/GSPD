% plots vector arrows of the poloidal magnetic field Bp at the (r,z)
% locations
function bp_quiver2(psizr, tok_data_struct, opts, varargin)

if ~exist('opts', 'var') || isempty(opts), opts = struct; end
if ~isfield(opts, 'normalize'), opts.normalize = 0; end
if ~isfield(opts, 'bpsign'), opts.bpsign = 1; end 


r1 = [1.2 1.4 1.6 1.8 2.0 2.2 2.4]';
z1 = zeros(size(r1));

z2 = linspace(-1, 1, 7)';
r2 = 1.7 * ones(size(z2));


rg = tok_data_struct.rg;
zg = tok_data_struct.zg;

[~, psi_r, psi_z] = bicubicHermite(rg, zg, psizr, r1, z1);
Br1 = -opts.bpsign * 1./(2*pi*r1)  .* psi_z;
Bz1 = opts.bpsign * 1 ./ (2*pi*r1) .* psi_r;

[~, psi_r, psi_z] = bicubicHermite(rg, zg, psizr, r2, z2);
Br2 = -opts.bpsign * 1./(2*pi*r2)  .* psi_z;
Bz2 = opts.bpsign * 1 ./ (2*pi*r2) .* psi_r;


if opts.normalize
  scale = sqrt(Br1.^2 + Bz1.^2);
  Br1 = Br1 ./ scale;
  Bz1 = Bz1 ./ scale;

  scale = sqrt(Br2.^2 + Bz2.^2);
  Br2 = Br2 ./ scale;
  Bz2 = Bz2 ./ scale;
end

quiver(r1, z1, 0*Br1, Bz1, 0.5, varargin{:}, 'Alignment', 'center')
quiver(r2, z2, Br2, 0*Bz2, 0.5, varargin{:}, 'Alignment', 'center')

scatter([r1; r2], [z1; z2], 'k','filled') 


% dbzdr = gradient(Bz1.*r1, r1); 
% dbzdr ./ r1




