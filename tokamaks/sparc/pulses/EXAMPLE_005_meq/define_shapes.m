function shapes = define_shapes(opts, tok)
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
%     Each of these can use different timebases which are later
%     interpolated. Each quantity should be defined at each time, but will 
%     only enter the optimization depending on the optimization weights. 


eqs = load('./data/eqs').eqs; % from the MEQ 1500 equilibria series
eqs = cell2mat(eqs);
t = [0.2 1:30];

% define control segments
segopts.rc = 1.75; 
segopts.zc = 0;
segopts.a = 0.15;
segopts.b = 0.2;
segopts.plotit = 0;
segopts.seglength = 6;
segs = gensegs(60, segopts);


% find intersections of boundary with segments
rcp = [];
zcp = [];
for i = 1:length(eqs)
  [rcp(i,:), zcp(i,:)] = seg_intersections(eqs(i).rbbbs, eqs(i).zbbbs, segs, 0);  
end

shapes.rb.Time = t;
shapes.rb.Data = rcp;

shapes.zb.Time = t;
shapes.zb.Data = zcp;

shapes.rx.Time = t;
shapes.rx.Data = [eqs(:).rxup; eqs(:).rxlo];

shapes.zx.Time = t;
shapes.zx.Data = [eqs(:).zxup; eqs(:).zxlo];

shapes.rtouch.Time = [t(1) t(end)];
shapes.rtouch.Data = [1 1]*1.269;

shapes.ztouch.Time = [t(1) t(end)];
shapes.ztouch.Data = [0 0];


shapes.rbdef.Time = t;
shapes.rbdef.Data = [eqs(:).rbdef];

zbdef = [eqs(:).zbdef];
i = zbdef > 0.5;
zbdef(i) = -zbdef(i);  % these equilibria have 2 x-points, always use lower x-pt as the bdef-pt

shapes.zbdef.Time = t;
shapes.zbdef.Data = zbdef;

shapes = check_structts_dims(shapes);

if opts.plotlevel >= 1
  summary_shape_plot(shapes, tok);
end

if opts.plotlevel >= 2
  plot_structts(shapes, fields(shapes), 3);
  sgtitle('Shape targets'); drawnow
end


















