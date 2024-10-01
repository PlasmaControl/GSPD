% Form the grouping circuits for the coils and vacuum vessel elements. 
% 
% cccirc is coil circuit connections. For example: [1 -1 2 2 2 3] says that
% coils 1 and 2 are connected in antiseries, coils 3-5 are connected in
% series, and coil 6 is independent. 
%
% vvgroup and vvcirc are similar, but subtly different. vvgroup = [1 1 2 3]
% says that elements 1 and 2 are lumped together (in parallel though!) into
% group 1, elements 3 = group 2, and element 4 = group 3. vvcirc = [1 2 2]
% now applies on the groups, and says that group 1 is independent and
% groups 2 and 3 are connected in series. However, there are almost never 
% series connections in the vessel groupings ==> vvcirc = 1:max(vvgroup); 
%
% Pcc, Pvv, and Pxx are transition maps from connected to unconnected
% circuits. Let ic, iv be unconnected coil and vessel current vectors. 
% Let icx, ivx be connected coil circuit and vessel circuit vectors. Let 
% is := [ic; iv; ip] with ip=plasma current, isx = [icx; ivx; ip]. 
%
% Then:  ic  = Pcc * icx
%        icx = pinv(Pcc) * ic
%        iv  = Pvv * ivx
%        ivx = pinv(Pvv) * iv
%        is  = Pxx * isx
%        isx = pinv(Pxx) * is
%
% ccfrac / vvfrac / fcfrac := fraction of the circuit current carried by 
%   that coil. Coils are connected in series, so ccfrac is proportional 
%   to # of loops. Vessel elements are connected in parallel, so vvfrac 
%   is related through the vessel resistances (1/R_tot = sum(1/R_i))
% 
% Also defines a lot of indices for indexing into the current and circuit
% vectors. 
%
% Josiah Wai - 2/9/2021


function circ = nstxu2016_circ(tok_data_struct)

% Circuit connection vectors
cccirc = [1 2 3 4 5 5 6 6 6 6 7 7 7 7 7 7 8 8 8 8 9 9 9 9 10 10 11 12 13];

fccirc = cccirc(2:end)' - 1;

vvgroup = [1  1  2  2  3  4  5  5  5  6  6  6  6  6  6  6  6  6  6  6 ...
     6  6  6  6  7  7  7  7  7  8  8  8  8  9  9  9  9  9  9  9  9  9 ...
     9  9  9  9  9  9  9  9  9  9  9  9  9  9  9 10 10 10 11 11 11 11 ...
    11 12 12 13 13 13 14 15 16 17 18 18 18 19 19 20 20 20 20 20 21 21 ...
    21 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 ...
    22 22 22 23 23 23 23 24 24 24 24 24 25 25 25 25 25 25 25 25 25 25 ...
    25 25 25 25 25 26 26 26 27 28 29 29 30 30 31 31 32 32 33 34 35 36 ...
    37 38 39 40];
  
vvcirc = 1:max(vvgroup);

% Current fraction vectors
% f-coils serial connection, current fraction propto # of turns
fcnturn = tok_data_struct.fcnturn(:)';
fcfrac = zeros(size(fcnturn));
for icirc = 1:max(fccirc)
  icoils = find(fccirc == icirc);
  fcfrac(icoils) = fcnturn(icoils) / sum(fcnturn(icoils));  
end

ccfrac = [1 fcfrac];

% vessel parallel connection, current fraction related to resistance
resv = tok_data_struct.resv;
vvfrac = zeros(size(vvcirc));
for icirc = 1:max(vvcirc)
  icond = find(vvcirc == icirc);
  sum_rinv = sum(1./resv(icond));
  vvfrac(icond) = 1./resv(icond)/sum_rinv;
end


% =================
% Indices and names
% =================
vvnames = {  ...
    'VS1U',   ...
    'VS2U',   ...
    'VS3U',   ...
    'VS4U',   ...
    'VS5U',   ...
    'VS6U',   ...
    'VS7U',   ...
    'VS8U',   ...
    'VS9U',   ...
    'VS10U',  ...
    'VS11U',  ...
    'VS12U',  ...
    'VS13U',  ...
    'VS14U',  ...
    'VS15U',  ...
    'VS15L',  ...
    'VS14L',  ...
    'VS13L',  ...
    'VS12L',  ...
    'VS11L',  ...
    'VS10L',  ...
    'VS9L',   ...
    'VS8L',   ...
    'VS7L',   ...
    'VS6L',   ...
    'VS5L',   ...
    'VS4L',   ...
    'VS3L',   ...
    'VS2L',   ...
    'VS1L',   ...
    'DPU1',   ...
    'DPL1',   ...
    'PPSIUU', ...
    'PPSIUL', ...
    'PPPOUU', ...
    'PPPOUL', ...
    'PPPOLU', ...
    'PPPOLL', ...
    'PPSILL', ...
    'PPSILU'
};

ccnames = {'OH', 'PF1AU', 'PF1BU', 'PF1CU', 'PF2U', 'PF3U', 'PF4', ...
      'PF5', 'PF3L', 'PF2L', 'PF1CL', 'PF1BL', 'PF1AL'};

ccvvnames = [ccnames vvnames];
    
remove_coils = {'PF1BU', 'PF1BL', 'PF1CU', 'PF1CL', 'PF4'};
iremove = zeros(size(ccnames));
for i = 1:length(remove_coils)
  iremove = iremove | strcmp(ccnames, remove_coils{i});
end
ikeep = find(~iremove);
iremove = find(iremove);

keep_coils = ccnames(ikeep);
    
unipolar_coils = {'PF1AU','PF2U','PF2L','PF1AL'};
for k = 1:length(unipolar_coils)      
  ii_unipolar(k) = find(strcmp(ccnames, unipolar_coils{k}));
end    

ic_remove = [3,4,11:16,27,28];

nc = tok_data_struct.nc;  % num coils
nv = tok_data_struct.nv;  % num vessel elements
np = 1;                   % 1 plasma current
ns = nc + nv + np;        % total num of conducting elements

ncx = max(cccirc);        % num coil circuits
nvx = max(vvcirc);        % num vessel circuits
nx = ncx + nvx + np;      % total num of circuits

iic = 1:nc;               % index of coils
iiv = (nc+1):(nc+nv);     % index of vessel elements
iip = ns;                 % index of plasma circuit
iis = 1:ns;               % index of all conducting elements

iicx = 1:ncx;             % index of coil circuits
iivx = (ncx+1):(ncx+nvx); % index of vessel circuits
iipx = nx;                % index of plasma circuit
iisx = 1:nx;              % index of all circuits

nu = ncx;                 % num of control inputs (==num of indep circuits)
iiu = 1:ncx;              % index of control inputs

iicx_keep = ikeep;
iicx_remove = iremove;
ncx_keep = length(iicx_keep);
nu_keep  = ncx_keep;
nxx_keep = ncx_keep + nvx + np;

% ================
% TRANSITION MAPS
% ================

% series connections, 1-turn coil currents for coils in a series connection
% are equal
Pcc = zeros(length(cccirc), max(cccirc));  
for i = 1:max(cccirc)
  Pcc(cccirc == i,i) = 1;
  Pcc(cccirc == -i,i) = -1;  
end

% parallel connections, current fraction determined by vessel resistance
Pvv = zeros(length(vvcirc), max(vvcirc)); 
for ii=1:max(vvcirc)
  idx1=find(vvgroup==ii);
  sum_rinv = sum(1./resv(idx1));
  vvfrac(idx1) = 1./resv(idx1)/sum_rinv;  
  Pvv(idx1,ii)=vvfrac(idx1);  
end

Pxx = blkdiag(Pcc, Pvv, 1);
Pss = blkdiag(Pcc, Pvv);

Pss2 = Pss;
Pss2(:,[iremove iivx([9 22])]) = [];

% map from all coils to kept coils
Pcc_keep = zeros(length(iicx_keep), ncx);
for i = 1:length(iicx_keep), Pcc_keep(i,iicx_keep(i)) = 1; end
Pxx_keep = blkdiag(Pcc_keep, eye(nvx), 1);

% current limits
limits.ic(1:tok_data_struct.nc,1) = [-20 0 0 -8 0 0 -13 -13 -13 ...
    -13 0 0 0 0 0 0 -24 -24 -24 -24 -13 -13 -13 -13 0 0 -8 0 0]'*1000;

limits.ic(1:tok_data_struct.nc,2) = [20 15 0 13.5 15 15 8 8 8 8 ...
    13 13 13 13 13 13 0 0 0 0 8 8 8 8 15 15 13.5 0 15]'*1000;

for i = 1:length(ccnames)
  iy.(ccnames{i}) = i;
end

circ = variables2struct(cccirc, fccirc, vvcirc, vvgroup, ccfrac, fcfrac, ...
  vvfrac, vvnames, ccnames, ccvvnames, remove_coils, keep_coils, unipolar_coils, ...
  ikeep, iremove, ii_unipolar, iicx_keep, iicx_remove, nc, nv, ...
  np, ns, ncx, nvx, nx, iic, iiv, iip, iis, iicx, iivx, iipx, iisx, nu, ...
  iiu, Pcc, Pvv, Pxx, Pcc_keep, Pxx_keep, ncx_keep, nu_keep, nxx_keep, ...
  limits, ic_remove, iy, Pss, Pss2);


































