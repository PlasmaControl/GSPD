% define various settings for the optimization including:
% 
%   timebase for optimization
%   which targets to explicitly control
%   voltage and current constraints
%   vessel mode compression
%   etc. 

function settings = define_optimization_settings(tok)

% time base for optimization
s.t0 = 0;                         % start time
s.tf = 2.7;                       % end time
s.N = 50;                         % number of timepoints (equilibria), more than 100 takes a while
s.t = linspace(s.t0, s.tf, s.N)'; % timebase
s.dt = mean(diff(s.t));           % time step


% number of Grad-Shafranov iterations to perform
s.niter = 3;  


% relaxation factor for updating the plasma current each iteration. It is 
% generally stable with c_relax=1, but can be decreased if solution is not 
% converging. (range 0-1)
s.c_relax = 1;


% Compress vessel elements (recommended for computational speedup if tok.nv
% is large). Vessel modes are computed using a balanced realization on the
% vessel currents, see mpc_config.m
s.compress_vessel_elements = 1;  % whether or not to compress vessels                                 
s.nvessmodes = 40;               % number of modes to retain


% If 1, target psibry is specified directly (via targs.psibry.Time,
% targs.psibry.Data). If 0 (recommended for most uses), psibry is 
% computed to be consistent with the Ip,Rp,shape evolution. 
% See compute_psibry.m
s.specify_psibry_directly = 1;


% fds2control are the variables that will be explicitly controlled by
% the optimization algorithm. See measure_ys.m and output_model.m for how
% each is modeled and measured:
%
% ic                  - current in coils
% diff_psicp_psix     - flux error at control points vs x-point
% diff_psicp_psitouch - flux error at control points vs touch point
% psibry              - flux at boundary defining point
% psix_r              - flux derivative wrt r at target x-point
% psix_z              - flux derivative wrt z at target x-point

s.fds2control = {'ic', 'diff_psicp_psix', 'psibry', 'psix_r', 'psix_z'}';

d.ic                  = 'current in coils';
d.diff_psicp_psix     = 'flux error at control points vs x-point';
d.psibry              = 'flux at boundary defining point';
d.psix_r              = 'flux derivative wrt r at target x-point';
d.psix_z              = 'flux derivative wrt z at target x-point';
s.fds2control_descriptions = d;


% all of the coils are active
s.active_coils = 1:19;  

% power supply voltage limits
s.enforce_voltage_limits = 1;
s.vmax = [2.6 2.6 1 1 1 1 1 1 1 1 2.6 2.6 2.6 2.6 0.55 0.55 0.55 0.55 1.1]' * 1e3; 
s.vmin = -s.vmax;

% power supply current limits
s.enforce_current_limits = 1;
s.ic_max = [45*ones(1,14) 32*ones(1,4) 10]' * 1000;
s.ic_min = -s.ic_max;


% basis functions for FF' and P' in the Grad-Shafranov equation. Used in
% gs_update_psipla.m. Currently only limited basis function options are
% supported. Must define 1 basis function for P' and 2 basis functions for
% FF'. Not recommended to alter the basis functions much unless you know what
% you are doing. 
psin = linspace(0,1,tok.nr)'; % normalized flux
s.basis = struct;
s.basis.psin = psin;
s.basis.info = "basis functions for the Grad-Shafranov P' and FF' profiles";

% basis function for P' - this is a linear basis function that was used in
% kstar rtEFIT
s.basis.pprime1 = 1 - psin;  

% basis function for P' - this is a quadratic basis function that was used
% nstxu EFIT01
% s.basis.pprime1 = -4 * (-(psin-0.5).^2 + 0.25);  


% first and second basis functions for FF'
s.basis.ffprim1 = -polyval([0.54 -0.08 -1.46 1], psin) * 1e-6;   
s.basis.ffprim2 = -ones(size(psin)) * 1e-6;                      

settings = s;



























