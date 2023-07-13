% find inner/outer and upper/lower strike points for SPARC
%
% method: 
% look for points along pre-defined limiter surfaces that match boundary 
% flux most closely. 
% 
% restrictions:
%   - limiter surfaces to search are pre-defined
%   - does not handle multiple strike points well
%   - just chooses the closest point (resolution determined by npts), does
%     not perform a line search

function sp = strikepoints(rg, zg, psizr, psibry)

npts = 500;

% first, define inner/outer and upper/lower limiter sections
[rliu, zliu] = interparc([1.4327 1.3028 1.51], [1.0575 1.2115 1.2102], npts, 0, 0);
[rlou, zlou] = interparc([1.5119 1.719 1.6956 1.6446], [1.213 1.51 1.38 1.163], npts, 0, 0);
rlil = rliu;
zlil = -zliu;
rlol = rlou;
zlol = -zlou;



% find inner/outer and upper/lower strike points
psi = bicubicHermite(rg, zg, psizr, rliu, zliu);
[~,i] = min(abs(psi - psibry));
sp.riu = rliu(i);
sp.ziu = zliu(i);

psi = bicubicHermite(rg, zg, psizr, rlil, zlil);
[~,i] = min(abs(psi - psibry));
sp.ril = rlil(i);
sp.zil = zlil(i);

psi = bicubicHermite(rg, zg, psizr, rlou, zlou);
[~,i] = min(abs(psi - psibry));
sp.rou = rlou(i);
sp.zou = zlou(i);

psi = bicubicHermite(rg, zg, psizr, rlol, zlol);
[~,i] = min(abs(psi - psibry));
sp.rol = rlol(i);
sp.zol = zlol(i);


sp.r = [sp.riu sp.ril sp.rou sp.rol]';
sp.z = [sp.ziu sp.zil sp.zou sp.zol]';








































