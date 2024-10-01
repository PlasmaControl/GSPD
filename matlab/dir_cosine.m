   function [ax,ay,az]= dir_cosine(x1,y1,z1,x2,y2,z2)
%
%  SYNTAX:
%  [ax,ay,az]= dir_cosine(x1,y1,z1,x2,y2,z2)
%
%  PURPOSE: generates direction cosines [ax,ay,az]
%  of a line segment from point x1,y1,z1 to point x2,y2,z2
%  If only 3 arguments are passed then it assumes these are x2,y2,z2 and
%  computes direction cosines from origin: (i.e. x1= y1= z1 = 0).

% Jim Leuer 8-28-96; Modified for 3 element input 1-7-97

  if nargin >= 4
    d= sqrt((x2-x1).^2+(y2-y1).^2+(z2-z1).^2);
    ax= (x2-x1)./d;
    ay= (y2-y1)./d;
    az= (z2-z1)./d;
  else
    d= sqrt(x1.^2+y1.^2+z1.^2);
    ax= x1./d;
    ay= y1./d;
    az= z1./d;
  end
  return
