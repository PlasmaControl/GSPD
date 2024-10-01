% converts a struct of data to a struct of timeseries
function snew = datastruct2structts(s, t)

fds = fields(s);
snew = struct;
for i = 1:length(fds)  
  y = s.(fds{i}); 
  if isnumeric(y)
    snew.(fds{i}).Time = t;
    snew.(fds{i}).Data = y;
    % snew.(fds{i}) = timeseries(y, t, 'name', fds{i});
  end
end

  









