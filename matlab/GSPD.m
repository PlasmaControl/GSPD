function soln = GSPD(tok, shapes, plasma_scalars, init, settings, ...
  targs, weights, opts)

% put everthing on same timebase
t = settings.t;
shapes         = retimebase(shapes, t);
targs          = retimebase(targs, t);
plasma_scalars = retimebase(plasma_scalars, t);
weights.wts    = retimebase(weights.wts, t);
weights.dwts   = retimebase(weights.dwts, t);

% consistency of vessel modes
if ~settings.compress_vessel_elements
  settings.nvessmodes = tok.nv; 
end

% dynamics model and any mpc stuff that can be precomputed 
config = mpc_config(tok, shapes, targs, settings);  


% initialize with estimate of plasma current distribution
pcurrt = initialize_pcurrt(tok, shapes, plasma_scalars);


% perform iterations between dynamics optimization and Grad Shafranov 
for iter = 1:settings.niter

  fprintf('\nGrad-Shafranov iteration %d of %d\n', iter, settings.niter)


  % dynamics optimization
  fprintf('  computing coil trajectories...\n\n')
  [mpcsoln, targs] = mpc_update_psiapp(iter, pcurrt, config, tok, shapes, ...
    plasma_scalars, init, settings, targs, weights, opts);
  

  % Grad-Shafranov iteration
  [eqs, eqs0, pcurrt] = gs_update_psipla(mpcsoln, pcurrt, tok,...
    plasma_scalars, settings);

end

% final boundary tracing
fprintf('\nPerforming final boundary trace\n\n')
for i = 1:settings.N
  fprintf('  Tracing boundary: %d of %d ...\n', i, settings.N);
  eq = find_bry(eqs{i}.psizr, tok, 0);  
  eqs{i} = copyfields(eqs{i}, eq, [], 1);
end


% save outputs
soln = variables2struct(eqs, mpcsoln, config, shapes, targs, ...
  plasma_scalars, weights, settings);
















