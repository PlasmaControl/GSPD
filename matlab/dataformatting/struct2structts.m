% convert struct of timeseries-like (each field is a struct with Time and
% Data subfield) into a struct of timeseries. 
%
% Example
% t = linspace(0, 2*pi);
% a.Time = t;
% a.Data = sin(t);
% b.Time = t;
% b.Data = cos(t);
% s = variables2struct(a,b);
% s = structtslike2structts(s)

function s = structtslike2structts(s)

snew = struct;
for i = 1:length(fdnames)  
  fd = fdnames{i};
  if isfield(s.(fd), 'Time') || isprop(s.(fd), 'Time')
    snew.(fd) = interp1(s.(fd).Time, s.(fd).Data, time(:), 'linear', 'extrap');  
  end
end

