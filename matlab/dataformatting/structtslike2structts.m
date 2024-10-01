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

s = check_structts_dims(s);

fdnames = fields(s);
for i = 1:length(fdnames)  
  fd = fdnames{i};
  if isfield(s.(fd), 'Time') && isfield(s.(fd), 'Data')
    s.(fd) = timeseries(s.(fd).Data, s.(fd).Time);
  end
end

