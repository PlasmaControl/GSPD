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


% this example holds the shape constant while performing outer strike
% leg sweep oscillations

% some reference equilibria to draw new shapes from
eq = load('sweep_init').eq;  
tok   = load('sparc_tok').tok;


% define control segments
segopts.rc = 1.75; 
segopts.zc = 0;
segopts.a = 0.3;
segopts.b = 0.4;
segopts.plotit = 0;
segopts.seglength = 4;
segs = gensegs(40, segopts);

% find intersections of boundary with segments
[rbbbs, zbbbs] = seg_intersections(eq.rbbbs, eq.zbbbs, segs, 0);  
[rx, zx] = isoflux_xpFinder(tok.rg, tok.zg, eq.psizr, 1.5, -1.15);

t = [0 1.5 1.8 2.1 2.4 2.7];

% strike point oscillations
rsp = [1.79 1.79 1.54 1.79 1.54 1.79];
zsp = [-1.57 -1.57 -1.25 -1.57 -1.25 -1.57];

N = length(t); 
for i = 1:N
  rb(i,:) = [rbbbs; rsp(i)];
  zb(i,:) = [zbbbs; zsp(i)];
end

shapes.rb.Time = t;
shapes.rb.Data = rb;

shapes.zb.Time = t;
shapes.zb.Data = zb;

shapes.rx.Time = t;
shapes.rx.Data = ones(size(t))*rx;

shapes.zx.Time = t;
shapes.zx.Data = ones(size(t))*zx;

shapes.rbdef.Time = t;
shapes.rbdef.Data = ones(size(t))*rx;

shapes.zbdef.Time = t;
shapes.zbdef.Data = ones(size(t))*zx;

shapes.rtouch.Time = t;
shapes.rtouch.Data = nan*t;

shapes.ztouch.Time = t;
shapes.ztouch.Data = nan*t;

shapes.pcurrt.Time = t;
shapes.pcurrt.Data = ones(N,1) * eq.pcurrt(:)';

shapes = check_structts_dims(shapes);

if opts.plotlevel >= 1
  summary_shape_plot(shapes, tok);
end

if opts.plotlevel >= 2
  plot_structts(shapes, fields(shapes), 3);
  sgtitle('Shape targets'); drawnow
end


















