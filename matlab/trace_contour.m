% For each point in (rstart,zstart), trace the psi=constant contour until 
% it either completes a loop or exits the limiter. If it can complete a
% loop without exiting limiter, consider it a 'good' starting point,
% meaning it is a candidate for a boundary-defining point (i.e. the primary
% x-point or the limiting point). 

function [rstart_good, zstart_good, isgood, rcontour, zcontour] = trace_contour(...
  rg,zg,psizr,rstart,zstart,rmaxis,zmaxis,rlim,zlim,plotit,robust)


if ~exist('plotit','var'), plotit=0; end
if ~exist('robust','var'), robust=1; end

out_tol = 0.01; % [m] if not within this distance of limiter, consider it outside. 

isgood = false(size(rstart));
ngood = 0;

for ipt = 1:length(rstart)
  r0 = rstart(ipt);
  z0 = zstart(ipt);

  % move initial condition slightly toward magnetic axis, improves robustness  
  step = 0.002; % [m]
  vec = [rmaxis-r0; zmaxis-z0];
  vec = vec/norm(vec);
  r0 = r0 + step*vec(1);
  z0 = z0 + step*vec(2);
    
  if robust
    ds = 0.002;
  else
    ds = 0.01;
  end
  
  % initialize
  theta = 0;
  limiter_length = sum(sqrt(diff(rlim).^2 + diff(zlim).^2));
  N = ceil(limiter_length/ds);
  r = r0;
  z = z0;
  psi0 = bicubicHermite(rg,zg,psizr,r0,z0);

  
  for i = 1:N
    
%     if i > 835
%       plot(r,z,'r','linewidth',2)
%     end
%     
%     [~, psi_r, psi_z] = bicubicHermite(rg,zg,psizr,r(i),z(i))
    
    % gradient descent to make sure we're staying on the psi=constant contour
    for j = 1:3
      [psi, psi_r, psi_z] = bicubicHermite(rg,zg,psizr,r(i),z(i));
      eps = 1;
      Jinv = pinv([psi_r psi_z]) * eps;            
      r(i) = r(i) - Jinv(1) * (psi-psi0);
      z(i) = z(i) - Jinv(2) * (psi-psi0);
    end
    
    % take a step along the psi=constant contour
    step = ds / sqrt(psi_r^2 + psi_z^2);
    r(i+1) = r(i) + psi_z * step;
    z(i+1) = z(i) - psi_r * step;    
          
    % measure change in angle of rotation, after 2pi rotation terminate
    u = [r(i+1) 0 z(i+1)] - [rmaxis 0 zmaxis];
    v = [r(i) 0 z(i)] - [rmaxis 0 zmaxis];
    theta = theta + atan2(norm(cross(u,v)),dot(u,v));
    if abs(theta) > 2*pi 
      ngood = ngood+1;
      isgood(ipt) = true;
      rcontour{ngood} = r;
      zcontour{ngood} = z;
      break; 
    end

    % if outside limiter terminate
    if mod(i,30) == 0      
      if ~inpolygon(r(i), z(i), rlim, zlim)
        d = sqrt(min((rlim-r(i)).^2 + (zlim-z(i)).^2));    
        if d > out_tol, break; end    
      end
    end
  end  
  if plotit, plot(r,z,'r','linewidth',2); end
end

rstart_good = rstart(isgood);
zstart_good = zstart(isgood);









