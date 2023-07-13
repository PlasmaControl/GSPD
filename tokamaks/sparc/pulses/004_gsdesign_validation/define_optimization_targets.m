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

% coil currents
targs.ic.Data = zeros(N,tok.nc);
targs.ic.Time = t;

% psibry target will be computed automatically to satisfy Ip in
% mpc_update_psiapp.m
targs.psibry.Data = nan(size(t));  
targs.psibry.Time = t;

if opts.plotlevel >= 2
  h = plot_structts(targs, settings.fds2control, 3, [], 'linewidth', 1.5);
  sgtitle('targs', 'fontsize', 14); drawnow
end





































