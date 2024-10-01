% Helper function for data formatting
%
% s is a struct with fields that have Data and Time subfields
%    s.fd1.Data = ...
%    s.fd1.Time = ...
%
% This function verifies that s.fd.Time is a column vector and that the
% first dimension of s.fd.Data corresponds to time, and transposes any
% results that dont fit this pattern. 
% 
% Does not work for data with 3 or more dimensions. 
%
% Example: 
% t = linspace(0,1);
% s.a.Time = t;        % row vector
% s.a.Data = sin(t)';  % col vector
% s.b.Time = t';       % col vector 
% s.b.Data = cos(t);   % row vector
%
% s = check_structts_dims(s);
% s.a    % all Time and Data fields are now col vectors
% s.b    

function s = check_structts_dims(s)


fds = fields(s);

for i = 1:length(fds)
  fd = fds{i};

  if isfield(s.(fd), 'Time') && isfield(s.(fd), 'Data')
    
    s.(fd).Time = s.(fd).Time(:);    
    n = length(s.(fd).Time);    
    sz = size(s.(fd).Data);

    if sz(1) ~= n
      if sz(2) == n && length(sz) == 2
        s.(fd).Data = s.(fd).Data';
      end
    end
  end
end

      
        
        
      
        






