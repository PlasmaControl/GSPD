clear all; clc; close all

%% Initialization
opts = struct;
opts.plotlevel = 0;  % 0=no plots, 1=minimal plots, 2=lotsa plots

load('/Users/jwai/Research/rampup_nstxu/fetch/cache/eqs204660.mat')

tok              = load_tok('nstxu_tok');
shapes           = define_shapes(tok, eqs, opts);
plasma_scalars   = define_plasma_scalars(opts);
init             = define_init;
settings         = define_optimization_settings(tok);
targs            = define_optimization_targets(shapes, tok, settings, opts);
weights          = define_optimization_weights(targs, settings, opts);


load('/Users/jwai/Research/rampup_nstxu/fetch/cache/eqs204660.mat')
t = double(eqs.time);
ic = [eqs.gdata(:).icx]';
targs.ic.Data = interp1(t,ic,targs.ic.Time);



%% Solve Grad-Shafanov + circuit dynamics
opts.plotlevel = 2;
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
