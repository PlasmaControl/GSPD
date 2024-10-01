function spRZ = isoflux_spFinder(psizr, psix, rg, zg, limdata, limIdx)
%
% ISOFLUX_SPFINDER
%
%   Locate the strike points for a given plasma equilibrium.
%
%   Determine the (r,z) coordinates of intersection points between the
%   separatrix and the limiter.
%
% USAGE: isoflux_spFinder.m
%
% INPUTS:
%
%   psizr.....matrix with dimensions (nz x nr) containing the magnetic flux
%             at nz vertical by nr radial grid points
%
%   psix......flux at the null corresponding to the strike points of interest
%
%   rg........array containing the nr radial grid points
%
%   zg........array containing the nz vertical grid points
%
%   limdata...limiter (r,z) vertices as defined in tok_data_struct
%
%   limIdx....indices of limiter segments on which to search for strike points
%
% OUTPUTS: 
%
%   spRZ......matrix with dimensions (nsp x 2) where each row contains [spR spZ] 
%             for a strike point
%                       
% AUTHOR: Patrick J. Vail
%
% DATE: 04/25/2018
%
% MODIFICATION HISTORY:
%   Patrick J. Vail: Original File 04/25/2018
%
%...............................................................................

numSegs = length(limIdx)-1;

spRZ = zeros(100,2);

% Grid point weighting matrix for cubic convolution (Keys, IEEE 1981)

mx = 1/2 * [0 2 0 0; -1 0 1 0; 2 -5 4 -1; -1 3 -3 1];

% Convert rg and zg to column vectors if necessary

if size(rg,1) == 1
    rg = rg';
end
if size(zg,1) == 1
    zg = zg';
end

dr = rg(2)-rg(1);
dz = zg(2)-zg(1);

% Convert psizr to (nz x nr) if necessary

nr = length(rg);
nz = length(zg);

if size(psizr,1) == 1 || size(psizr,2) == 1
    psizr = reshape(psizr, nz, nr);
end

for ii = 1:numSegs
    
    idx = limIdx(ii);
    
    % Compute slope of the limiter segment
    
    rS = limdata(2,idx);
    zS = limdata(1,idx);
    rE = limdata(2,idx+1);
    zE = limdata(1,idx+1);
    
    dR = rE - rS;
    dZ = zE - zS;
    if dR ~= 0
        m  = dZ/dR;
        z0 = zS - m*rS;
    end
    
    % Compute flux at selected points along the limiter segment
    
    rlim = linspace(rS, rE, 100);
    zlim = linspace(zS, zE, 100);
    
    psilim = interp2(rg, zg, psizr, rlim, zlim);
    
    % Use point with flux nearest to psix as guess for strike point location
    
    diffs = abs(psilim - psix);
    
    idxs = find(islocalmin(diffs));
    
    if diffs(1) < 2.5e-4
        idxs = [1 idxs];
    end
    if diffs(100) < 2.5e-4
        idxs = [idxs 100];
    end
    
    for jj = 1:length(idxs)
        
        spR = rlim(idxs(jj));
        spZ = zlim(idxs(jj));
        
        kk  = 20;  % maximum of 20 iterations to find the strike point
        err = inf;
        
        while kk > 0 && err > 1e-10
            
            kk = kk-1;
            
            % Locate four grid points in each direction around the query point
            
            ir = find(rg < spR, 1, 'last');
            iz = find(zg < spZ, 1, 'last');
            
            ii1 = nz*(ir-2) + [iz-1 iz iz+1 iz+2];
            ii2 = nz*(ir-1) + [iz-1 iz iz+1 iz+2];
            ii3 = nz*(ir+0) + [iz-1 iz iz+1 iz+2];
            ii4 = nz*(ir+1) + [iz-1 iz iz+1 iz+2];
        
            F = [psizr(ii1(1)) psizr(ii1(2)) psizr(ii1(3)) psizr(ii1(4)); ...
                 psizr(ii2(1)) psizr(ii2(2)) psizr(ii2(3)) psizr(ii2(4)); ...
                 psizr(ii3(1)) psizr(ii3(2)) psizr(ii3(3)) psizr(ii3(4)); ...
                 psizr(ii4(1)) psizr(ii4(2)) psizr(ii4(3)) psizr(ii4(4))  ...
            ];
    
            % Normalize the r and z intervals
        
            tr = (spR - rg(ir))/dr;
            tz = (spZ - zg(iz))/dz;
        
            % Interpolate to find psi at the strike point
        
            b0 = [1 tr tr^2 tr^3]*mx*F(:,1);
            b1 = [1 tr tr^2 tr^3]*mx*F(:,2);
            b2 = [1 tr tr^2 tr^3]*mx*F(:,3);
            b3 = [1 tr tr^2 tr^3]*mx*F(:,4);
        
            b0_r = ([0 1 2*tr 3*tr^2]/dr)*mx*F(:,1);
            b1_r = ([0 1 2*tr 3*tr^2]/dr)*mx*F(:,2);
            b2_r = ([0 1 2*tr 3*tr^2]/dr)*mx*F(:,3);
            b3_r = ([0 1 2*tr 3*tr^2]/dr)*mx*F(:,4);
        
            psiSP = [1 tz tz^2 tz^3]*mx*[b0 b1 b2 b3]';
        
            psiSP_r = [1 tz tz^2 tz^3]*mx*[b0_r b1_r b2_r b3_r]';
            psiSP_z = ([0 1 2*tz 3*tz^2]/dz)*mx*[b0 b1 b2 b3]';
        
            if dR ~= 0
            delta = -inv([psiSP_r psiSP_z; -m 1])*[psiSP-psix; spZ-m*spR-z0];
            else
            delta = -inv([psiSP_r psiSP_z; 1 0])*[psiSP-psix; spR-rS];
            end
        
            spR = max(min(spR + delta(1),rg(end-2)), rg(3));
            spZ = max(min(spZ + delta(2),zg(end-2)), zg(3));
        
            err = abs(psiSP - psix);
            
        end
        
        if (spR <= max(rS,rE)) && (spR >= min(rS,rE))
            spRZ(ii+jj+5,1) = spR;
        end
        if (spZ <= max(zS,zE)) && (spZ >= min(zS,zE))
            spRZ(ii+jj+5,2) = spZ;
        end
       
    end
     
end

[rowIdx, ~] = find(spRZ ~= 0);

bins = 1:100;
counts = zeros(1,length(bins));

for ii = 1:length(bins)
    counts(ii) = length(find(rowIdx == bins(ii)));
end
rowKeepIdx = counts == 2;

spRZ = sortrows(spRZ(rowKeepIdx,:),1);

end
