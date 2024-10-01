clc; close all

saveit = 1;
savefn = '/Users/jwai/Desktop/tmp/basis_funs.png';
addpath('/Users/jwai/Documents/MATLAB/export_fig')

psin = linspace(0,1)';
b.psin = psin;
b.p1 = -4 * (-(psin-0.5).^2 + 0.25);                  % basis function for P'
b.f1 = -polyval([0.54 -0.08 -1.46 1], psin) * 1e-6;   % 1st basis fun for FF'
b.f2 = -ones(size(psin)) * 1e-6;


fig = figure;
fig.Position = [730 593 485 285];
hold on
plot(psin, -b.p1, 'r', 'linewidth', 1.5)
plot(psin, -b.f1*1e6, '-b', 'linewidth', 1.5)
plot(psin, -b.f2*0.5e6, '-.b' , 'linewidth', 1.5)
ylim([0 1.1])
legend("P' fun", "FF' fun1", "FF' fun2", 'fontsize', 18, 'fontweight', 'normal')
xlabel('\psi_N', 'fontsize', 16)
yticklabels('')
ylabel('[a.u.]', 'fontsize', 16)
title('Profile basis functions', 'fontsize', 16)


if saveit
  export_fig(savefn, '-m2', '-transparent')
end


