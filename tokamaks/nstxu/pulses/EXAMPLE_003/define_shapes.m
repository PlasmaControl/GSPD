function shapes = define_shapes(tok, eqs, opts)
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

t = double(eqs.time);
rb = {};
zb = {};
for i = 1:length(t)
  rb{i} = eqs.gdata(i).rbbbs;
  zb{i} = eqs.gdata(i).zbbbs;
end
k = t < 0.05 | t > 0.95;
rb(k) = [];
zb(k) = [];
t(k) = [];


%% Map target shapes to boundary-control points
% At this point, each of the (rb{i}, zb{i}) define a shape. Now sort these
% and map them onto control points. 

% interpolate to finer boundary
for i = 1:length(rb)
  [rb{i}, zb{i}] = interparc(rb{i}, zb{i}, 200, 1, 0);  % interpolate
  [rb{i}, zb{i}] = sort_ccw(rb{i}, zb{i}, 0.9, 0);      % sort 
end
  

% define control segments
segopts.rc = 0.85; 
segopts.zc = 0;
segopts.a = 0.3;
segopts.b = 0.5;
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
  if t(i) >= 0.2
    [zx(i), j] = min(zb{i});
    rx(i) = rb{i}(j);
  else
    rx(i) = nan;
    zx(i) = nan;
  end
end
rx = inpaint_nans(rx(:));
zx = inpaint_nans(zx(:));
rx = smoothdata(rx, 'movmedian', 5);
zx = smoothdata(zx, 'movmedian', 5);

shapes.rx.Time = t;
shapes.rx.Data = rx;

shapes.zx.Time = t;
shapes.zx.Data = zx;

shapes.rtouch.Time = [0 1]';
shapes.rtouch.Data = [0.315 0.315]';

shapes.ztouch.Time = [0 1]';
shapes.ztouch.Data = [0 0]';

shapes.rbdef.Time = t;
shapes.rbdef.Data = rx(:);
shapes.rbdef.Data(t<=0.2) = 0.315;

shapes.zbdef.Time = t;
shapes.zbdef.Data = zx(:);
shapes.zbdef.Data(t<=0.2) = 0;


if opts.plotlevel >= 1
  summary_shape_plot(shapes, tok);
end

if opts.plotlevel >= 2
  plot_structts(shapes, fields(shapes), 3);
  sgtitle('Shape targets'); drawnow
end


















