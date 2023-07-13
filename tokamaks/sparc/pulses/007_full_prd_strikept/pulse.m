clear all; clc; close all

% done:
% - adaptive stepping
% - 1500 series
% 
% todo:
% - penalties on 2nd derivative of voltage
% - strike sweep
% - error handling, trace contour
% - XPT scenario
% - start/stop capability
% - refine initial condition


%% Initialization
opts = struct;
opts.plotlevel = 0;  % 0=no plots, 1=minimal plots, 2=lotsa plots

tok              = load_tok();
shapes           = define_shapes(opts, tok);
plasma_scalars   = define_plasma_scalars(opts);
init             = define_init;
settings         = define_optimization_settings(tok);
targs            = define_optimization_targets(shapes, tok, settings, opts);
weights          = define_optimization_weights(targs, settings, opts);


%% Solve Grad-Shafanov  circuit dynamics
soln = GSPD(tok, shapes, plasma_scalars, init, settings, ...
  targs, weights, opts);

save('soln','soln')

%% Plot results
if opts.plotlevel >= 1
  summary_soln_plot(settings.t, shapes, soln.eqs, tok);  % plots shapes
  
  plot_structts(soln.mpcsoln, tok.ccnames(1:2:end), 3);           % plots individual coil currents
  sgtitle('Coil currents')
  
  plot_structts(soln.mpcsoln, {'v'});                    % plots power supply voltages   
  sgtitle('Power supply voltages')

  plot_structts(soln.mpcsoln, {'iv'});                    % plots power supply voltages   
  sgtitle('Vessel currents')

  h = plot_structts(soln.mpcsoln, {'psibry'});           % plot boundary flux
  h = plot_structts(soln.targs, {'psibry'}, 1, h, '--r');
  legend('Actual', 'Target', 'fontsize', 14)
end

% figure
% hold on
% plot(soln.settings.t, soln.mpcsoln.diff_psicp_psix2.Data(:,end-3:end))
% plot(soln.settings.t, soln.mpcsoln.diff_psicp_psix1.Data(:,end-3:end))






































