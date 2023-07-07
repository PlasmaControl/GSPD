%FBTSPARC  FBT configuration parameters
% P = FBTPSPARC(SHOT,'PAR',VAL,...) returns a structure P with configuration
% parameters for SPARC tokamak, optionally replacing or adding
% parameters with specified values. See also FBTP.
%
% [+FreeBoundaryTokamakEquilibrium+] Sw+ssPlasmaCenter EPF+Lausanne
function P = fbtpsparc(shot,P)
 
 % defaults for SPARC
 P = meqpsparc(shot);

 P.dissi   = 1e-17;
 P.dipol   = 1e-11;
 P.tol     = 1e-7;    % Solution tolerance
 P.niter = 50;        % Maximum number of equilibrium solution iterations

 %% Basis functions
 P.bfct = @bf3imex;
 P.agfitfct = @meqfit3;

 n=41; % number of points
 FN = linspace(0,1,n); % normalized flux grid

 %   P' function
 pprime = linspace(1,0.38,n);  %1 at core, 0 at edge
 pprime(n-2:n-1) = 2;

 %   TT' function
 ttprime = 1 - tanh((FN-.5)*6.);

 GN = [pprime',ttprime',linspace(1,1,n)']; % three basis functions
 
 IGN = flipud(cumtrapz(flipud(FN'),flipud(GN))); % their integral using trapeze integration
 
 FP = [1;0;0]; % first basis function for p;'
 FT = [0;1;1]; % second and third for TT'
 mybfp = struct('gNg',GN,'IgNg',IGN,'fPg',FP,'fTg',FT);
 
 P.bfp  = mybfp;

 % Simple alternative
 %P.bfct = @bfabmex;
 %P.bfp  = [1 2];

 %% Current limits modified from defaults
 na=19; % Hard coded number
 P.limm = 0.85*ones(na,1); % Max and Min x 0.9

 %% Device description files
 P.geo_dir = '20230407';  % Geo directory with saved Green's table
end
