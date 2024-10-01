% plots a quiver plot of the forces
%
function fquiver(icx, iv, tok_data_struct, opts, varargin)

if isempty(iv), iv = zeros(tok_data_struct.nv,1); end
if ~exist('opts', 'var') || isempty(opts), opts = struct; end
if ~isfield(opts, 'normalize'), opts.normalize = 0; end
if ~isfield(opts, 'bpsign'), opts.bpsign = -1; end  % for SPARC (and all machines?), bpsign=-1

circ = sparc_circ(tok_data_struct);
struct_to_ws(tok_data_struct);

r1 = [1.2 1.4 1.6 1.8 2.0 2.2 2.4]';
z1 = zeros(size(r1));

z2 = linspace(-0.8, 0.8, 5)';
r2 = ones(size(z2));
z2 = [z2; z2; z2];
r2 = [1.6*r2; 1.8*r2; 2*r2];



% Frgrid = opts.bpsign * (gfrpc*circ.Pcc*icx + gfrpv*iv);
% Frgrid = reshape(Frgrid, nz, nr);

Bzgrid = opts.bpsign * (gbz2c*circ.Pcc*icx + gbz2v*iv);
Bzgrid = reshape(Bzgrid, nz, nr);
Frgrid = -Bzgrid .* (2*pi*rgg);


Fzgrid = opts.bpsign * (gfzpc*circ.Pcc*icx + gfzpv*iv);
Fzgrid = reshape(Fzgrid, nz, nr);

[Fr, dfrdr] = bicubicHermite(rg, zg, Frgrid, r1, z1);
[Fz, ~, dfzdz] = bicubicHermite(rg, zg, Fzgrid, r2, z2);

% quiver(r1, z1, Fr, 0*Fr, 0.4, 'Alignment', 'center')
% quiver(r2, z2, 0*Fz, Fz, 0.5, 'Alignment', 'center')


quiver(r1, z1, Fr, 0*Fr, 0.35, varargin{:}, 'Alignment', 'center')
quiver(r2, z2, 0*Fz, Fz, 0.45, varargin{:}, 'Alignment', 'center')

scatter([r1; r2], [z1; z2], 'k','filled') 

% dfrdr
% dfzdz
% Fr
% Fz


