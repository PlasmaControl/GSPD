% merge structs. Copies all the fields of each structure to a new
% structure. Note that this can overwrite data
%
% example:
% s1.a = 1
% s2.b = 2
% s = merge_structs(s1, s2)

function s = merge_structs(varargin)

s = struct;
for i = 1:nargin
  tmp = varargin{i}; 
  fds = fields(tmp);
  for j = 1:length(fds)
    fd = fds{j};
    s.(fd) = tmp.(fd);
  end
end









