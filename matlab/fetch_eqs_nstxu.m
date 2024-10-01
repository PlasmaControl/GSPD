% Import an equilibrium for nstxu from the mdsplus tree
%
% This builds off the function read_eq.m included with Toksys, but also fetches
% the coil current and modifies a few fields so that the coil current 
% vectors are consistent with geometry. If times = 'all' or [], then
% fetches all available efit times. 
%
% Josiah Wai, 9/6/2021


% EXAMPLE:
% shot = 204660;
% times = [0.2 0.3];
% % times = 'all';
% tree = 'EFIT01';
% tokamak = 'nstxu';
% server = 'skylark.pppl.gov:8501';
% opts.cache_it = 1;
% opts.cache_dir = [pwd '/cache/'];
% opts.plotit = 1;
% opts.force_mds_load = 1;
% eqs = fetch_eqs_nstxu(shot, times, tree, tokamak, server, opts)


function eqs = fetch_eqs_nstxu(shot, times, tree, tokamak, server, opts)

if ~exist('opts','var'), opts = struct; end
if ~isfield(opts, 'cache_it'), opts.cache_it = 0; end
if ~isfield(opts, 'plotit'), opts.plotit = 0; end   
if ~isfield(opts, 'cache_dir'), opts.cache_dir = nan; end   
if ~isfield(opts, 'force_mds_load'), opts.force_mds_load = 0; end

eq_fn = [opts.cache_dir '/eqs' num2str(shot) '.mat'];

% load from cache
if ~opts.force_mds_load
  try    
    eqs = load(eq_fn).eqs;
    neq = length(eqs.time);
    load_from_mds = 0;
    disp('Equilibrium was loaded from cache. (To force new load, ')
    disp('set opts.force_mds_load = true.)')     
  catch
    load_from_mds = 1;
  end
else
  load_from_mds = 1;
end

% load from mds
if load_from_mds      
  
  eqs = read_eq(shot,'all',tree,tokamak,server);
  coils = fetch_coilcurrents_nstxu(shot, eqs.time);

  % The coil current vector eq.cc is confusing and dependent on geometry in
  % arcane ways. Instead of inverting eq.cc to eq.ic, we will load ic directly
  % from mds, define our geometry here, and calculate what eq.cc is for
  % our geometry.  
  tok_data_struct = load('nstxu_obj_config2016_6565.mat').tok_data_struct;
  circ = nstxu2016_circ(tok_data_struct);

  % copy circuit information into eq
  neq = length(eqs.time);
  for i = 1:neq
    eqs.gdata(i).ecturn = tok_data_struct.ecnturn;
    eqs.gdata(i).ecid   = ones(size(tok_data_struct.ecnturn));
    eqs.gdata(i).turnfc = tok_data_struct.fcnturn';
    eqs.gdata(i).fcturn = circ.fcfrac;
    eqs.gdata(i).fcid = circ.fccirc';
  end
  
  % Convert from ic to cc:
  % The ic vector already represents coil currents in toksys format. Use a
  % hack to convert from ic to efit format, so that gs codes can convert
  % back from efit format to toksys.
  idiot = eqs.gdata(1);
  ncc = tok_data_struct.nc;
  for j = 1:ncc
    idiot.cc = zeros(ncc,1);
    idiot.cc(j) = 1;
    equil_I = cc_efit_to_tok(tok_data_struct,idiot);
    iccc(:,j) = equil_I.cc0t;
  end
  piccc = pinv(iccc);
  coils.cc = piccc * coils.ic;
  
  
  for i = 1:neq
    % copy coil currents to eq
    eqs.gdata(i).ic = coils.ic(:,i);
    eqs.gdata(i).iv = coils.iv(:,i);
    eqs.gdata(i).icx = coils.icx(:,i);
    eqs.gdata(i).ivx = coils.ivx(:,i);
    eqs.gdata(i).cc = coils.cc(:,i);
    
    k = eqs.gdata(i).rbbbs==0 & eqs.gdata(i).zbbbs==0;
    eqs.gdata(i).rbbbs(k) = [];
    eqs.gdata(i).zbbbs(k) = [];    
    
    % store everything in double precision
    fnames = fieldnames(eqs.gdata(i));
    for j = 1:length(fnames)
      if isnumeric(eqs.gdata(i).(fnames{j}))
        eqs.gdata(i).(fnames{j}) = double(eqs.gdata(i).(fnames{j}));
      end
    end
  end
  
  % error check - convert cc back to ic
  eq = eqs.gdata(ceil(neq/2));
  equil_I = cc_efit_to_tok(tok_data_struct, eq);
  ic_check = equil_I.cc0t;

  if max(abs(ic_check - eq.ic)) > sqrt(eps)
    error('Something is wrong with coil current vectors.')
  end
  
  if opts.cache_it 
    try
      if ~exist(opts.cache_dir, 'dir'), mkdir(opts.cache_dir); end
      save(eq_fn, 'eqs')
    catch
      disp('Could not save file to cache')
    end
  end
  
end

% return only eqs corresponding to desired times
if strcmp(times, 'all') || isempty(times) || ~isnumeric(times), times = eqs.time; end
[~,ikeep] = min(abs(times(:)' - eqs.time(:)));
% eqs.adata = eqs.adata(ikeep);
% eqs.gdata = eqs.gdata(ikeep);
% eqs.tms = eqs.tms(ikeep);
% eqs.time = eqs.time(ikeep);

idelete = setdiff(1:neq, ikeep);
eqs.adata(idelete) = [];
eqs.gdata(idelete) = [];
eqs.tms(idelete) = [];
eqs.time(idelete) = [];

  
% remove some zero-padding, oft causes trouble
for i = 1:length(eqs.gdata) 
  k = eqs.gdata(i).rbbbs==0 & eqs.gdata(i).zbbbs==0;
  eqs.gdata(i).rbbbs(k) = [];
  eqs.gdata(i).zbbbs(k) = [];  
end


% plot it
if opts.plotit
  eq = eqs.gdata(ceil(length(eqs.time) / 2));
  figure
  plot_eq(eq)
  title(eq.time)
end



























