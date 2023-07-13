% Define time-dependent targets for each of the settings.fds2control 
%
% Most of these are zero. In each case the error to be minimized is this
% target value minus the value at the equilibrium. 
%
% To view a summary plot of the weights, set opts.plotlevel>=2

function targs = define_optimization_targets(shapes, tok, settings, opts)

t = settings.t(:);
N = settings.N;
ncp = size(shapes.rb.Data,2);   % number of shape control points

% flux gradient at target x-point
targs.psix_r.Data = zeros(N,1);
targs.psix_r.Time = t;

% flux gradient at target x-point
targs.psix_z.Data = zeros(N,1);
targs.psix_z.Time = t;

% flux error - control points vs x-point
targs.diff_psicp_psix.Data = zeros(N,ncp);
targs.diff_psicp_psix.Time = t;

% flux error - control points vs touch point
targs.diff_psicp_psitouch.Data = zeros(N,ncp);
targs.diff_psicp_psitouch.Time = t;

% coil currents - target is to hold them constant at initial values
targs.ic.Data = ones(N,1) * load('sweep_init').eq.ic';
targs.ic.Time = t;


% psibry target will be computed automatically to satisfy Ip in
% mpc_update_psiapp.m
targs.psibry.Data = ones(size(t)) * 1.00;  
targs.psibry.Time = t;

targs = check_structts_dims(targs);

if opts.plotlevel >= 2
  h = plot_structts(targs, settings.fds2control, 3, [], 'linewidth', 1.5);
  sgtitle('targs', 'fontsize', 14); drawnow
end





































