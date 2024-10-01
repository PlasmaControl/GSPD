% creates a struct with each field and fieldname given by the input args
% 
% example:
% a = 1;
% b = 2;
% s = variables2struct(a,b);

function s = variables2struct(varargin)
  s = struct;
  for i = 1:nargin
    s.(inputname(i)) = varargin{i};
  end
end