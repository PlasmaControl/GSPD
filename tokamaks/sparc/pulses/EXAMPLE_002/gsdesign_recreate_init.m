function [spec,config,eq] = gsdesign_recreate_init(init,tok_data_struct);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  USAGE:   [spec,config] = gsdesign_recreate_init(init,tok_data_struct)
%           [spec,config,eq] = gsdesign_recreate_init(init,tok_data_struct)
%
%  PURPOSE: Create inputs spec and config that make
%           init == gsdesign(spec, init, config)
%
%  INPUTS:  init, an equilibrium to recreate
%           tok_data_struct, TokSys description of the tokamak
%
%  OUTPUTS: spec, a specification of targets to use as input to gsdesign
%           config, configuration data to use as third input to gsdesign
%           eq = gsdesign(spec,init,config), equilibrium resembling init
%
%  RESTRICTIONS: spec does NOT specify circuit constraints
%                run gsdesign without inputs for full documentation
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%
%  WRITTEN BY:  Anders Welander ON 2015-09-25
%
%  MODIFICATION HISTORY:			
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1
  help gsdesign_recreate_init
  return
elseif nargin < 2
  disp('Both init and tok_data_struct are required inputs')
  return
end

% Load tokamak into config
config = tok_data_struct;

% Constrain profiles to three degrees of freedom
config.constraints = 1;

% Take profile details from init
% config.pres0 = init.pres;
% config.fpol0 = init.fpol;

% A generous number of knots ensures the profile can be made in gsdesign
config.psikn = (0:config.nr-1)/(config.nr-1);

% To uniquely specify the equilibrium it will now suffice to specify:
% boundary, boundary flux, total current, li, betap

% Set the target boundary
spec.targets.rsep = init.rbbbs(1:init.nbbbs);
spec.targets.zsep = init.zbbbs(1:init.nbbbs);
spec.weights.sep = ones(1,init.nbbbs);

% Set the target boundary flux
spec.targets.psibry = init.psibry;
spec.weights.psibry = 10;

% Set the target total current
spec.targets.cpasma = init.cpasma;
spec.weights.cpasma = 1e-3;

% Set the target li
if isfield(init,'li')
  spec.targets.li = init.li;
else
  gs_configure
  gs_initialize
  gs_eq_analysis
  spec.targets.li = li;
end
spec.weights.li = 10;

% Set the target betap
if isfield(init,'betap')
  spec.targets.betap = init.betap;
elseif exist('betap','var')
  spec.targets.betap = betap;
else
  gs_configure
  gs_initialize
  gs_eq_analysis
  spec.targets.betap = betap;
end
spec.weights.betap = 10;

if nargout > 2
  eq = gsdesign(spec,init,config);
end
