clear all; clc; close all
%%
soln = load('soln3').soln;
tok = load('tok').tok;

i = 18;
init = soln.eqs{i};
init.li = 1.2;
init.betap = 0.3;
init.ic = soln.mpcsoln.ic.Data(i,:)';
init.iv = soln.mpcsoln.iv.Data(i,:)';

p = backfit_profiles(init, tok);
init.pprime = p.pprime;
init.ffprim = p.ffprim;

[spec, config] = recreate_init(init, tok);

%%
% spec.targets.cpasma = -spec.targets.cpasma;

spec.mxiter = 8;

spec.weights.sep(:) = 1e3;

spec.weights.cpasma = 1;

spec.targets.ic = init.ic;
spec.weights.ic = ones(size(spec.targets.ic)) * 0.3;

spec.targets.iv = init.iv;
spec.weights.iv = ones(size(spec.targets.iv)) * 1;

spec.targets.li = nan;
spec.targets.betap = nan;

spec.targets.pprime = init.pprime;
spec.weights.pprime = ones(size(spec.targets.pprime)) * 1;

% spec.targets.ffprim = init.ffprim;
% spec.weights.ffprim = ones(size(spec.targets.ffprim)) * 1;


spec.targets.rbdef = init.rbdef;
spec.targets.zbdef = init.zbdef;
spec.weights.bdef = 1;

eq = gsdesign(spec, init, config);


%%
close all

figure
plot(init.psin, eq.pprime, init.psin, init.pprime, '--')

figure
plot(init.psin, eq.ffprim, init.psin, init.ffprim, '--')

figure
bar([init.iv eq.iv])

figure
bar([init.ic eq.ic])


figure
contourf(tok.rg, tok.zg, eq.pcurrt, 30)
colorbar

figure
contourf(tok.rg, tok.zg, init.pcurrt, 30)
colorbar



%%
figure
hold on
contour(tok.rg, tok.zg, eq.psizr, [1 1]*eq.psibry, '-b', 'linewidth', 0.5);
contour(tok.rg, tok.zg, init.psizr, [1 1]*init.psibry,'--r', 'linewidth', 0.5);
plot(tok.limdata(2,:), tok.limdata(1,:), 'color', [1 1 1] * 0, 'linewidth', 1)
axis equal




































































