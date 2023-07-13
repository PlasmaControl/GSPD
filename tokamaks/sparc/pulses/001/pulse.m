clear all; clc; close all

%% Initialization
opts = struct;
opts.plotlevel = 2;  % 0=no plots, 1=minimal plots, 2=lotsa plots

tok              = load_tok('sparc_tok');
shapes           = define_shapes(opts);
plasma_scalars   = define_plasma_scalars(opts);
init             = define_init;
settings         = define_optimization_settings(tok);
targs            = define_optimization_targets(shapes, tok, settings, opts);
weights          = define_optimization_weights(targs, settings, opts);



%% Solve Grad-Shafanov + circuit dynamics
soln = GSPD(tok, shapes, plasma_scalars, init, settings, ...
  targs, weights, opts);



%% Plot results
if opts.plotlevel >= 1
  summary_soln_plot(settings.t, shapes, soln.eqs, tok);  % plots shapes
  plot_structts(soln.mpcsoln, tok.ccnames, 4);  % plots individual coil currents
  sgtitle('Coil currents')
  plot_structts(soln.mpcsoln, {'v'});        % plots power supply voltages   
  sgtitle('Power supply voltages')
end

