

function bry = find_bry(psizr, tok, plotit)

if ~exist('plotit', 'var'), plotit=1; end

rg = tok.rg;
zg = tok.zg;
[rgg, zgg] = meshgrid(rg, zg);
nz = tok.nz;
nr = tok.nr;
rlim = tok.limdata(2,:);
zlim = tok.limdata(1,:);

[rlim, zlim] = interparc(rlim, zlim, 500, true, true);
rlim(end:end+3) = rlim(1:4); % wrap a few values, helps later with finding local extrema
zlim(end:end+3) = zlim(1:4);



% ==========================
% FIND O-POINTS AND X-POINTS
% ==========================

[psizr_r, psizr_z] = gradient(psizr);
gradpsi = sqrt(psizr_r.^2 + psizr_z.^2);
i = islocalmin(gradpsi, 'FlatSelection', 'all');
j =  islocalmin(gradpsi, 2, 'FlatSelection', 'all');
i = i | circshift(i,1) | circshift(i,-1) | circshift(i',1)' | circshift(i',-1)';
j = j | circshift(j,1) | circshift(j,-1) | circshift(j',1)' | circshift(j',-1)';
k = find(i & j);
in = find(inpolygon(rgg(k), zgg(k), rlim, zlim));
rsearch = rgg(k(in));
zsearch = zgg(k(in));


% zoom in on x/o-points
for i = 1:length(in)
  [rxo(i), zxo(i), psixo(i)] = isoflux_xpFinder(rg, zg, psizr, rsearch(i), zsearch(i));
end

% choose points inside limiter
in = find(inpolygon(rxo, zxo, rlim, zlim));
rxo = rxo(in);
zxo = zxo(in);
psixo = psixo(in);

% find unique points to within 1cm
tol = 0.01;
[~,~,idx_r] = uniquetol(rxo, tol);
[~,~,idx_z] = uniquetol(zxo, tol);
[~,i] = unique(idx_r);
[~,j] = unique(idx_z);
k = unique(union(i,j));
rxo = rxo(k);
zxo = zxo(k);
psixo = psixo(k);

% sort whether x-point or o-point
[~, ~, ~, psi_rr, psi_zz] = bicubicHermite(rg,zg,psizr,rxo,zxo);
is_xpt = sign(psi_rr) ~= sign(psi_zz);

ro = rxo(~is_xpt);
zo = zxo(~is_xpt);
psio = psixo(~is_xpt);

rx = rxo(is_xpt);
zx = zxo(is_xpt);
psix = psixo(is_xpt);

% check psi inside and outside limiter to see whether magnetic axis should
% be a local min or max
in = inpolygon(rgg, zgg, rlim, zlim);
psi_in = median(psizr(in));
psi_out = median(psizr(~in));
local_sign_maxis = sign(psi_in-psi_out);

% select magnetic axis from among o-points
[~,i] = max(local_sign_maxis*psio);
rmaxis = ro(i);
zmaxis = zo(i);
psimag = psio(i);

% =================
% FIND TOUCH POINTS
% =================
psilim = bicubicHermite(rg,zg,psizr,rlim,zlim);
i = islocalmax(local_sign_maxis*psilim, 'FlatSelection', 'all');
rtouch = rlim(i);
ztouch = zlim(i);

% =============================================================
% TRACE BOUNDARIES TO FIND WHICH CANDIDATES ARE CLOSED CONTOURS
% =============================================================

% rationale: the true boundary-defining point must be an x-point interior to
% limiter, or a local flux extrema (along the limiter). From all these
% candidate points, the bdef-pt is the one that forms the largest closed contour
rcandidates = [rx(:); rtouch(:)];
zcandidates = [zx(:); ztouch(:)];

robust = 1;
[rbdef, zbdef] = trace_contour(rg,zg,psizr,rcandidates,zcandidates,rmaxis,zmaxis,rlim,zlim,0,robust);


% All of the remaing (rbdef, zbdef) now form valid closed contours. 
% Choose the most external contour
psibdef = bicubicHermite(rg,zg,psizr,rbdef,zbdef);
[~,i] = min(local_sign_maxis*psibdef);
rbdef = rbdef(i);
zbdef = zbdef(i);
psibry = psibdef(i);

[~,~,~,rbbbs,zbbbs] = trace_contour(rg,zg,psizr,rbdef,zbdef,rmaxis,zmaxis,rlim,zlim,0,robust);
[rbbbs, zbbbs] = interparc(rbbbs{1}, zbbbs{1}, 200, 0);
rbbbs = rbbbs(:);
zbbbs = zbbbs(:);
area = polyarea(rbbbs, zbbbs);

[~,dist] = distance2curve([rlim zlim], [rbdef zbdef]);

islimited = dist < 0.005;


bry = variables2struct(psizr, rbdef, zbdef, psibry, rbbbs, zbbbs, rmaxis, zmaxis, ...
  psimag, islimited, area);


% PLOT
if plotit
  figure  
  hold on
  grid on
  plot(rlim, zlim, 'k', 'linewidth', 2)
  contour(rg, zg, psizr, 100, 'color', [1 1 1]*0.8)
  plot(rbbbs, zbbbs, 'r', 'linewidth', 3)
  scatter(rbdef, zbdef, 150, 'filled')
  set(gcf, 'Position', [110 110 379 650])
  axis equal
end

end























