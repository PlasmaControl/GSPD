%%
clear; clc; close all

load('soln')
eqs = soln.eqs;
tok = load('sparc_tok').tok;
t = soln.settings.t;

ip = [];
Li = [];
Wmag = [];
for i = 1:length(eqs)
  i
  ip(i) = sum(eqs{i}.pcurrt(:));
  [Li(i), Wmag(i)] = internal_inductance(ip(i), eqs{i}.psizr, eqs{i}.rbbbs, eqs{i}.zbbbs, tok.rg, tok.zg);
end


Wdot = gradient(Wmag, t);
psibrydotI = - 1./ip(:) .* Wdot(:);
psibryI = cumtrapz(t(:), psibrydotI);

figure
hold on
plot(t, psibryI, 'r')
plot(t, soln.targs.psibry.Data - soln.targs.psibry.Data(1), 'r')


% TSC data
tsc = load('tsc_data').tsc_data;

psibry = tsc.psibry - tsc.psibry(1);
tsc.Wdot = gradient(tsc.W, tsc.t);
tsc.psibrydotI = - 1./tsc.ip(:) .* tsc.Wdot(:);
tsc.psibryI = cumtrapz(tsc.t(:), tsc.psibrydotI);

plot(tsc.t, tsc.psibry - tsc.psibry(1), 'b')
plot(tsc.t, tsc.psibryI, 'b')



%%
clear; clc; % close all

load('soln')
eqs = soln.eqs;
tok = load('sparc_tok').tok;
t = soln.settings.t;

ip = [];
Li = [];
Wmag = [];

for i = 1:length(eqs)
  ip(i) = sum(eqs{i}.pcurrt(:));
  [Li(i), Wmag(i), Bp2(i,:,:), in(i,:,:), volumezr(i,:,:)] = internal_inductance(...
        ip(i), eqs{i}.psizr, eqs{i}.rbbbs, eqs{i}.zbbbs, tok.rg, tok.zg);
end

dt = mean(diff(t));
[~, dBp2dt, ~] = gradient(Bp2, 1, dt, 1);

mu0 = pi*4e-7;

z = dBp2dt .* in .* volumezr;
z = reshape(z, size(z,1), []);
z = sum(z,2);
z = z / (2*mu0);

psibrydotI = -1./ip(:) .* z(:);
psibryI = cumtrapz(t(:), psibrydotI);

% close all
figure
hold on
plot(t, psibryI)


Wdot = gradient(Wmag, t);
psibrydotI = - 1./ip(:) .* Wdot(:);
psibryI2 = cumtrapz(t(:), psibrydotI);
plot(t, psibryI2, '--r')









%%
% clear; clc; close all
% 
% tsc = load('gspd_data').gspd_data;
% 
% struct_to_ws(tsc);
% Wdot = gradient(tsc.W, tsc.t);
% psibrydot = -Rp(:) .* ip(:) - 1./ip(:) .* Wdot(:);
% psibrydotI = - 1./ip(:) .* Wdot(:);
% psibry = cumtrapz(t(:), psibrydot);
% psibryI = cumtrapz(t(:), psibrydotI);
% 
% figure
% hold on
% plot(t, psibry, '-r')
% plot(t, psibryI, '-b')
% 
% %%
% 
% clear
% 
% tsc = load('tsc_data').tsc_data;
% struct_to_ws(tsc);
% 
% psibry = tsc.psibry - tsc.psibry(1);
% Wdot = gradient(tsc.W, tsc.t);
% psibrydotI = - 1./ip(:) .* Wdot(:);
% psibryI = cumtrapz(t(:), psibrydotI);
% 
% plot(t, psibry, '--r')
% plot(t, psibryI, '--b')
% 
% 
% %%
% load('targs')
% plot(targs.psibry.Time, targs.psibry.Data - targs.psibry.Data(1), '-.b')
% 
% load('targs2')
% plot(targs.psibry.Time, targs.psibry.Data - targs.psibry.Data(1), '-.b')





































