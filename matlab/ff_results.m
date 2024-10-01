eqs1 = eqs;
eqs2 = eqs;
%%

saveit = 1;
savefn = '/Users/jwai/Desktop/tmp/ff_convergence.png';
addpath('/Users/jwai/Documents/MATLAB/export_fig')

i = 40; 

close all

figure

subplot(121)
eq = eqs1{i};
eq = find_bry(eq.psizr, tok, 0);
plot_eq(eq, tok, 'r', 'linewidth', 1)
scatter(targ.rb.Data(i,:), targ.zb.Data(i,:), 'k', 'filled')
title('Solver Iteration 1: t=0.8s')

subplot(122)
eq = eqs3{i};
eq = find_bry(eq.psizr, tok, 0);
plot_eq(eq, tok, 'r', 'linewidth', 1)
scatter(targ.rb.Data(i,:), targ.zb.Data(i,:), 'k', 'filled')
title('Solver Iteration 2: t=0.8s')



if saveit
  export_fig(savefn, '-m2', '-transparent')
end