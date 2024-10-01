% append fields to struct
%
% example:
% s.a = 1; 
% b = 2; 
% s = append2struct(s, b)

function s = append2struct(s, varargin)  
  for i = 2:nargin
    s.(inputname(i)) = varargin{i-1};
  end
end












