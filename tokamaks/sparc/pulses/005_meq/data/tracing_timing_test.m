

ii = 15;

LYs = load('LYs').LYs;
LY = LYs{ii};
G = load('L').L.G;

figure
hold on

tic
for i = 1:100
[~,~,rbbbs,zbbbs] = trace_contour(...
  G.rx, G.zx, LY.Fx, LY.rB, LY.zB, LY.rA, LY.zA, G.rl, G.zl, 0, 1);
end
avg_time = toc/100

plot(rbbbs{1}, zbbbs{1})
plot(G.rl, G.zl, 'k')
axis equal

