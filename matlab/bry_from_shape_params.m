
% Ref: Geometric formulas for system codes including the effect of 
% negative triangularity -  O. Sauter


% INPUTS: shape: struct with fields -- tritop, tribot, xi_ou, xi_ol, xi_iu, xi_il, a,
% kappa, R0, Z0 -- which is the top and bottom triangularity, outer/inner &
% upper/lower squareness, minor radius, elongation, and (R,Z) of geometric center

% EXAMPLE 1: recreate a shot
% load('eq204653_950.mat')
% load('nstxu_obj_config2016_6565.mat')
% shape = shape_analysis(eq, tok_data_struct);
% opts.plotit = 1;
% [rbbbs, zbbbs] = bry_from_shape_params(shape, opts);


% EXAMPLE 2: negative triangularity
% shape.a = 0.594;
% shape.kappa = 1.62;
% shape.R0 = .9306;
% shape.Z0 = -.06;
% shape.tritop = -.1;
% shape.tribot = -.1;
% shape.xi_ou = -.1;
% shape.xi_ol = -.1;
% shape.xi_iu = -.15;
% shape.xi_il = -.15;
% opts.plotit = 1;
% [rbbbs, zbbbs] = bry_from_shape_params(shape, opts)


function [rbbbs, zbbbs] = bry_from_shape_params(shape, opts)

if ~exist('opts','var'), opts = struct; end
if ~isfield(opts, 'plotit'), opts.plotit = 0; end
if ~isfield(opts, 'N'), opts.N = 100; end

struct_to_ws(shape);
tritop = shape.tritop;

N = opts.N;
theta = linspace(0, 2*pi, N)';

if mod(N, 4) ~= 0
  warning('bry_from_shape_params.m: opts.N must be divisible by 4.')
end

% For this boundary formula to match known boundaries, need to scale the
% squareness as calculated by measure_squareness.m. If wanting to change 
% squareness, should adjust the values in the shape struct, not these 
% scaling parameters. 
xi_ou = xi_ou * 0.15;
xi_ol = xi_ol * 0.15;
xi_iu = xi_iu * 0.6;
xi_il = xi_il * 0.6;


xi = ones(N/4,1) * [xi_ou xi_iu xi_il xi_ol];
xi = xi(:);

tri = ones(N/2,1) * [tritop tribot];
tri = tri(:);

rbbbs = R0 + a * cos(theta + tri.*sin(theta) - xi.*sin(2*theta));
zbbbs = Z0 + kappa * a * sin(theta + xi .* sin(2*theta));

if opts.plotit  
  hold on
%   try
%     plot_eq(shape)
%   catch
%   end
  plot(rbbbs, zbbbs, '-k')
end
















