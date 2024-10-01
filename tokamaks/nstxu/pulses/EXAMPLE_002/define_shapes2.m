% function shapes = define_shapes()

%  inputs: opts struct
%          if opts.plotlevel >= 1, makes a gui plot of the target shapes
%          if opts.plotlevel >= 2, also plots the shape target timetraces
% 
%  outputs: the shape struct that has the target shapes vs time 
%
%     (rb.Data, rb.Time) - R position of boundary target shape, 
%                          timebase for R position of boundary target shape
%     (zb.Data, zb.Time) - Z position of boundary target shape


% these will hold all the shapes and times
rb = {};
zb = {};
t  = [];
i = 0;


% this forms a small limited plasma @ t=0
s = struct;
s.rsurf = 0.79;
s.zsurf = -0.02;
s.aminor = 0.475;
s.elong = 1.47;
s.triu = 0.2;
s.tril = 0.2;
s.squo = -0.05;
s.sqlo = -0.05;
s.squi = 0.15;
s.sqli = 0.15;
s.c_xplo = 0;
s.c_xpup = 0;
[r,z] = shape_create_deadstart(s, 200);

i = i+1;
t(i)  = 0;
rb{i} = r;
zb{i} = z;


% this forms a limited plasma about to divert with an x-point @ t=0.2
s = struct;
s.rsurf = 0.887;
s.zsurf = -0.02;
s.aminor = 0.5765;
s.elong = 1.9;
s.triu = 0.3;
s.tril = 0.48;
s.squo = -0.1;
s.sqlo = -0.2;
s.squi = 0;
s.sqli = -0.3;
s.c_xplo = 0.05;
s.c_xpup = 0;
[r,z] = shape_create_deadstart(s, 200);

i = i+1;
t(i)  = 0;
rb{i} = r;
zb{i} = z;



% divert plasma by moving radially from wall @ t=0.25
i = i + 1;
t(i) = 0.25;
rb{i} = rb{i-1} + 0.03;
zb{i} = zb{i-1};


% keep the same shape until shot end @ t=1
i = i + 1;
t(i) = 1;
rb{i} = rb{i-1};
zb{i} = zb{i-1};
t = t(:);



%% Map target shapes to boundary-control points
% At this point, each of the (rb{i}, zb{i}) define a shape. Now sort these
% and map them onto control points. 


% interpolate to finer boundary
for i = 1:length(rb)
  [rb{i}, zb{i}] = interparc(rb{i}, zb{i}, 200, 1, 0);  % interpolate
  [rb{i}, zb{i}] = sort_ccw(rb{i}, zb{i}, 0.9, 0);      % sort 
end
  




shapes.rb.Time = t;
shapes.rb.Data = rcp;

shapes.zb.Time = t;
shapes.zb.Data = zcp;











