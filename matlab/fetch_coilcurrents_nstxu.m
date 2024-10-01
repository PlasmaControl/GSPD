
% set times=[] to get data for all available times
%
% EXAMPLE:
% shot = 204660;
% times = [];
% opts.plotit = 1;
% coils = fetch_coilcurrents_nstxu(shot, times, opts)

function coils = fetch_coilcurrents_nstxu(shot, times, opts)

if nargin == 2, opts.plotit = 0; end

tree = 'EFIT01';

signal = mds_fetch_signal(shot, tree, times, '.RESULTS.AEQDSK:ECCURT', opts.plotit);  % OH
ecefit = double(signal.sigs);

signal = mds_fetch_signal(shot, tree, times, '.RESULTS.AEQDSK:CCBRSP', opts.plotit); % PF coils + vessel 
ccefit = double(signal.sigs);

signal = mds_fetch_signal(shot, tree, times, '.RESULTS.AEQDSK:IPMEAS', opts.plotit); % Ip
ip = double(signal.sigs);


times = signal.times;
N = length(times);
icx = zeros(13,N);

icx(1,:) = ecefit;    % OH
icx(2,:) = ccefit(1,:); % PF1AU
icx(3,:) = ccefit(2,:); % PF1BU
icx(4,:) = ccefit(3,:); % PF1CU
icx(5,:) = ccefit(4,:); % PF2U
icx(6,:) = ccefit(5,:); % PF3U
icx(7,:) = (ccefit(6,:)+ccefit(9,:))/2.0;  % PF4
icx(8,:) = (ccefit(7,:)+ccefit(8,:))/2.0;  % PF5
icx(9,:) = ccefit(10,:);  % PF3L
icx(10,:) = ccefit(11,:); % PF2L
icx(11,:) = ccefit(12,:); % PF1CL
icx(12,:) = ccefit(13,:); % PF1BL
icx(13,:) = ccefit(14,:); % PF1AL

ivx = ccefit(15:end,:);


tok_data_struct = load('nstxu_obj_config2016_6565.mat').tok_data_struct;
circ = nstxu2016_circ(tok_data_struct);

ic = circ.Pcc * icx;
iv = circ.Pvv * ivx;

coils = variables2struct(times, ic, iv, ip, icx, ivx);
























