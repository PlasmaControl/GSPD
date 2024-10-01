% convert a struct of timeseries data to a struct, can be used for
% evaluating struct of timeseries data for a particular time vector. 
%
% Example:
%
% t = linspace(0,2*pi, 500)';
% s.sig1 = timeseries(sin(t), t);
% s.sig2 = timeseries(cos(t), t);
% fdnames = {'sig1', 'sig2'};
% teval = 0; 
% snew = structts2struct(s, fdnames, teval)

function snew = structts2struct(s, fdnames, time)

snew = struct;
for i = 1:length(fdnames)  
  fd = fdnames{i};
  if isfield(s.(fd), 'Time') || isprop(s.(fd), 'Time')
    snew.(fd) = interp1(s.(fd).Time, s.(fd).Data, time(:), 'linear', 'extrap');  
  end
end









