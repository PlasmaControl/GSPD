% Remaps all the {matrices/greens funs, etc} in tok to be in terms of
% circuit currents, not coil currents. The circuit connections and other 
% info on the circuits is specified by circ. 
%
% circ must contain: Pcc, ccnames

function ctok = connect_tok(tok, circ)

ctok = tok;
Pcc = circ.Pcc;


% things to post-multiply by Pcc
x = {'gbc', 'mpc', 'mhc', 'msc', 'gbr2c', 'gbz2c', 'mlc', 'gfrvc', ...
  'gfzvc', 'gfrpc', 'gfzpc'};

for i = 1:length(x)
  try  
    ctok.(x{i}) = ctok.(x{i}) * Pcc;
  catch
  end
end


% things to pre-multiply by Pcc'
x = {'mcv', 'mct', 'gfrcv', 'gfzcv'};

for i = 1:length(x)
  try
    ctok.(x{i}) = Pcc' * ctok.(x{i});
  catch
  end
end


% things to post- and pre-multiply by Pcc
x = {'mcc', 'gfrcc', 'gfzcc'};

for i = 1:length(x)  
  try
    ctok.(x{i}) = Pcc' * ctok.(x{i}) * Pcc;
  catch
  end
end


%% other stuff that changes

% number of turns - I hate how gs divides this shit into E and F coils and
% makes separate categories for <ecnturn, fcnturn, ccnturn = [ecnturn;
% fcnturn]>. The below snippet removes ecnturn, and makes fcnturn and
% ccnturn identical and referring to all coils. 

if isfield(ctok, 'ecnturn')
  ecnturn = ctok.ecnturn;
  ctok = rmfield(ctok, 'ecnturn');
else
  ecnturn = [];
end
ccnturn = [ecnturn(:); ctok.fcnturn(:)];
ccnturn = abs(Pcc') * ccnturn;  % coils --> circuits
ctok.fcnturn = ccnturn;
ctok.ccnturn = ccnturn;

% resistance
ctok.resc = diag(Pcc' * diag(ctok.resc) * Pcc);

% number and names of circuits
ctok.nc = size(Pcc,2);
ctok.ccnames = circ.ccnames;
ctok.fcnames = circ.ccnames;

% stuff that doesnt make sense to retain, or there's not a good 
% coil-to-circuit transformation ==> just delete it
% x = {'fcsignals', 'fcdata', 'ecdata', 'ecnames'};
x = {'fcsignals', 'ecdata', 'ecnames'};

for i = 1:length(x)
  if isfield(ctok, x{i})
    ctok.(x{i}) = [];
  end
end






















