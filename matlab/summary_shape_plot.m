% Creates a figure to summarize target shape and x-point

function fig = summary_shape_plot(shapes, tok)

t = shapes.rb.Time;

% create figure
fig = figure;
fig.Position = [754   322   425   611];
ax = axes(fig);
ax.Box = 'on';
ax.Position = [0.13 0.2 0.775 0.7];


% slider button
s = uicontrol(fig, 'style', 'slider');
s.Units = 'normalized';
s.Position = [0.15 0.05 0.6 0.05];
s.Min = t(1);
s.Max = t(end);
s.Value = t(1);
s.Callback = {@sliderCallback, shapes, tok};

% text edit button
e = uicontrol(fig, 'style', 'edit');
e.Units = 'normalized';
e.Position = [0.8 0.07 0.15 0.05];
e.Callback = {@editCallback, shapes, tok};

plot_shape(s.Value, shapes, tok)


% slider callback
function sliderCallback(src, event, shapes, tok)
  t = src.Value;
  plot_shape(t, shapes, tok)
end


% text edit callback
function editCallback(src, event, shapes, tok)
  t = str2double(src.String);
  plot_shape(t, shapes, tok)
end


% plot shape targets
function plot_shape(t, shapes, tok)

  % read parameters
  rb = interp1(shapes.rb.Time, shapes.rb.Data, t);
  zb = interp1(shapes.zb.Time, shapes.zb.Data, t);
  rx = interp1(shapes.rx.Time, shapes.rx.Data, t);
  zx = interp1(shapes.zx.Time, shapes.zx.Data, t);

  if isfield(shapes, 'rtouch')
    rtouch = interp1(shapes.rtouch.Time, shapes.rtouch.Data, t);
    ztouch = interp1(shapes.ztouch.Time, shapes.ztouch.Data, t);
  end

  rb(end+1) = rb(1);
  zb(end+1) = zb(1);

  % plot parameters
  cla
  hold on
  title(['Time = ' num2str(t)], 'fontsize', 16)
  plot(tok.limdata(2,:), tok.limdata(1,:), 'k', 'linewidth', 1.5)
  plot(rb, zb, 'b')
  scatter(rb, zb, 20, 'r', 'filled')
  plot(rx, zx, 'xb', 'linewidth', 4, 'markersize', 14)
  
  if isfield(shapes, 'rtouch')
    scatter(rtouch, ztouch, 100, 'db', 'filled')
  end

  axis equal
  axis([min(tok.rg) max(tok.rg) min(tok.zg) max(tok.zg)])
  text(1.02, -0.1, 'Enter time:', 'units', 'normalized', 'fontsize', 11)    
  text(-0.25, -0.1, 'Drag slider to view shape targets.', ...
    'units', 'normalized', 'fontsize', 11)

  drawnow
end


end





































