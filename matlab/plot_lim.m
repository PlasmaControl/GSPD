

function plot_lim(tok, varargin)


if isempty(varargin)
  varargin = {'color', [0.4 0.4 0.4], 'linewidth', 1.5};
end

if size(tok.limdata,1) ~= 2
  tok.limdata = tok.limdata';
end

hold on
plot(tok.limdata(2,:), tok.limdata(1,:), varargin{:});

axis equal
axis([min(tok.rg) max(tok.rg) min(tok.zg) max(tok.zg)])








