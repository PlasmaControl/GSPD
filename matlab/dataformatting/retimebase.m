% interpolate a struct of timeseries (or timeseries-like) onto new
% timebase, t
%
% Example:
% t = linspace(0,2*pi,100)';
% s.sig1 = timeseries(sin(t), t);
% s.sig2 = timeseries(cos(t), t);
% tnew = t(1:5:end);
% s = retimebase(s, t)


function s = retimebase(s, t)

% interpolate onto new timebase
fds = fields(s);
for i = 1:length(fds)
  fd = fds{i};

  if isstruct(s.(fd)) && isfield(s.(fd), 'Data')
    s.(fd).Data = interp1hold(s.(fd).Time, s.(fd).Data, t);
    s.(fd).Time = t;
  elseif isa(s.(fd), 'timeseries')
    s.(fd) = resample(s.(fd), t);
  end

end
