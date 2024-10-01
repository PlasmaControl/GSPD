function ax = plot_vessel_currents(t, iv, tok_data_struct)

vvdata  = tok_data_struct.vvdata;
limdata = tok_data_struct.limdata;
circ = sparc_circ(tok_data_struct);
vvgroup = circ.vvgroup;


% ===========
% PLOT TRACES
% ===========
% cmap = linespecer(max(vvgroup));
cmap = linespecer(max(vvgroup), 'sequential');

% define color scheme
nv = max(vvgroup);
ivmax = max(iv(end,:));
ivmin = min(iv(end,:));
for i = 1:nv
  j = round(nv * (iv(end,i) - ivmin) / (ivmax - ivmin));    
  j = min(max(j,1), nv);
  rgbs{i} = cmap(j,:);
end
  
% plot vessel current traces
ax = subplot(121);
hold on
for i = 1:max(vvgroup)
  plot(t, iv(:,i) / 1e3, 'linewidth', 3, 'color', rgbs{i});
end
title('Vessel Currents [kA]', 'fontsize', 20, 'fontweight', 'bold')

% =========================================
% PLOT GEOMETRY CORRESPONDING TO TIMETRACES
% =========================================

ax(2) = subplot(122);
hold on
plot(limdata(2,:), limdata(1,:), 'color', [1 1 1]*0.1, 'linewidth', 2)



% Plot the passive conductors, color by vvgroup
z   = vvdata(1,:);
r   = vvdata(2,:);
dz  = vvdata(3,:);
dr  = vvdata(4,:);
ac  = vvdata(5,:);
ac2 = vvdata(6,:);

for ii = 1:size(vvdata,2)
  % rgb = cmap(vvgroup(ii), :);
  rgb = rgbs{vvgroup(ii)};

  plot_efit_region(z(ii), r(ii), dz(ii), dr(ii), ac(ii), ac2(ii), ...
    rgb, 'linestyle', '-', 'edgecolor', [1 1 1]*0.7);
  
  % text(r(ii), z(ii), num2str(vvgroup(ii)));
end

% Figure settings
axis equal
% axis([1 3 -2 2])
axis([0.2370    2.9983   -2.8    2.8])
hXl = xlabel('r [m]');
hYl = ylabel('z [m]');
hTl = title('SPARC');
set([hXl, hYl], 'FontSize', 14, 'FontWeight', 'bold')
set(hTl, 'FontSize', 14, 'FontWeight', 'bold')
grid on


if 1
  plot_coil_geo(tok_data_struct)
end













