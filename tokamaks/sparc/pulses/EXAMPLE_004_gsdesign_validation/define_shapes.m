function shapes = define_shapes(opts)
%
%  inputs: opts struct
%          if opts.plotlevel >= 1, makes a gui plot of the target shapes
%          if opts.plotlevel >= 2, also plots the shape target timetraces
% 
%  outputs: the shape struct that has the target shapes vs time 
%
%     (rb.Data, rb.Time) - R position of boundary target shape, 
%                          timebase for R position of boundary target shape
%
%     (zb.Data, zb.Time)         - Z position of boundary target shape
%     (rx.Data, rx.Time)         - R position of target x-point
%     (zx.Data, zx.Time)         - Z position of target x-point
%     (rtouch.Data, rtouch.Time) - R position of target touch point
%     (ztouch.Data, ztouch.Time) - Z position of target touch point
%     (rbdef.Data, rbdef.Time)   - R of point where boundary flux (psibry)
%                                    is evaluated
%     (zbdef.Data, zbdef.Time)   - Z of " " "
%
%     Note that each of these can use different timebases which are later
%     interpolated. Each quantity should be defined at each time, but will 
%     only enter the optimization depending on the optimization weights. 


% some reference equilibria to draw new shapes from
eq0 = load('./data/eq_low_ip').eq;  
eq1 = load('./data/eqLSN').eq;
tok   = load('sparc_tok').tok;


% Define target shapes
i = 0;
rb = {};
zb = {};
rmin = min(tok.limdata(2,:));


% start with a small limited plasma shortly after t=0
eq = eq0;
i = i + 1;
t(i) = 0.5;
rb{i} = eq.rbbbs;
zb{i} = eq.zbbbs;


% elongated shape and limited
eq = eq0;
i = i + 1;
t(i) = 2;
s = shape_analysis(eq.rbbbs, eq.zbbbs);
s.elong = 1.3;
s.aminor = 0.52;
s.triu = 0.2;
s.tril = 0.2;
s.squo = -0.1;
s.squi = 0.02;
s.sqli = 0.02;
s.sqlo = -0.1;
[rb{i}, zb{i}] = shape_edit(eq.rbbbs, eq.zbbbs, s);
rb{i} = rb{i} - min(rb{i}) + rmin;


% about to divert 
eq = eq1;
i = i + 1;
t(i) = 3;
s = shape_analysis(eq.rbbbs, eq.zbbbs);
s.aminor = 0.55;
s.elong = 1.9;
[rb{i}, zb{i}] = shape_edit(eq.rbbbs, eq.zbbbs, s);
rb{i} = rb{i} - min(rb{i}) + rmin;


% divert
i = i + 1;
t(i) = 3.4;
rb{i} = rb{i-1} + 0.03;
zb{i} = zb{i-1};


% hold position
i = i + 1;
t(i) = 24;
rb{i} = rb{i-1};
zb{i} = zb{i-1};


% clf
% plot(tok.limdata(2,:), tok.limdata(1,:), 'color', [1 1 1] * 0, 'linewidth', 1)
% hold on
% for i = 1:length(rb)
%   plot(rb{i}, zb{i}, 'linewidth', 2)
% end
% axis equal
% axis([1 2.8 -2 2])


%% Map target shapes to boundary-control points
% At this point, each of the (rb{i}, zb{i}) define a shape. Now sort these
% and map them onto control points. 


% interpolate to finer boundary
% interpolate to finer boundary
warning('off', 'MATLAB:polyshape:repairedBySimplify');
for i = 1:length(rb)
  [rb{i}, zb{i}] = interparc(rb{i}, zb{i}, 200, 0, 0);  % interpolate
  P = polyshape(rb{i}, zb{i});
  [rc,zc] = centroid(P);
  [rb{i}, zb{i}] = sort_ccw(rb{i}, zb{i}, rc, zc);      % sort 
  rb{i}(end+1) = rb{i}(1);  % make it a loop
  zb{i}(end+1) = zb{i}(1);
end
  


% clf
% plot(tok.limdata(2,:), tok.limdata(1,:), 'color', [1 1 1] * 0, 'linewidth', 1)
% hold on
% axis equal
% axis([1 2.8 -2 2])


% define control segments
segopts.rc = 1.75; 
segopts.zc = 0;
segopts.a = 0.3;
segopts.b = 0.4;
segopts.plotit = 0;
segopts.seglength = 4;
segs = gensegs(40, segopts);



% find intersections of boundary with segments
rcp = [];
zcp = [];
ncp = length(rb);
for i = 1:ncp
  [rcp(i,:), zcp(i,:)] = seg_intersections(rb{i}, zb{i}, segs, 0);  
end

shapes.rb.Time = t;
shapes.rb.Data = rcp;

shapes.zb.Time = t;
shapes.zb.Data = zcp;


%% define x-points, touch points
% for time>0.2, just take the lowest boundary z-position as the x-point
rx = [];
zx = [];

for i = 1:length(rb)
  if i >= 3
    [zx(i), j] = min(zb{i});
    rx(i) = rb{i}(j);
  else
    rx(i) = nan;
    zx(i) = nan;
  end
end
rx = inpaint_nans(rx(:));
zx = inpaint_nans(zx(:));

shapes.rx.Time = t;
shapes.rx.Data = rx;

shapes.zx.Time = t;
shapes.zx.Data = zx;

shapes.rtouch.Time = [0 10]';
shapes.rtouch.Data = [rmin rmin]';

shapes.ztouch.Time = [0 10]';
shapes.ztouch.Data = [0 0]';

shapes.rbdef.Time = t;
shapes.rbdef.Data = min(shapes.rb.Data');

shapes.zbdef.Time = t;
shapes.zbdef.Data = zeros(size(t));



shapes = check_structts_dims(shapes);

if opts.plotlevel >= 1
  summary_shape_plot(shapes, tok);
end

if opts.plotlevel >= 2
  plot_structts(shapes, fields(shapes), 3);
  sgtitle('Shape targets'); drawnow
end


















