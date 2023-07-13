%FBTXSPARC  SPARC FBT configuration parameters
% LX = FBTXSPARC(t,L) returns a structure LX with 
% (possibly time-dependent) equilibrium constraints/cost terms for 
% the SPARC tokamak. See also FBTX
%
% [+FreeBoundaryTokamakEquilibrium+] Sw+ssPlasmaCenter EPF+Lausanne
function LX = fbtxsparc(t,L)
 P = L.P;

 LX.t       = 21;           % Time in pulse (s)
 CS1_current = -34958;      % Amps

 %% Equilibrium scalars
 LX.rBt     = 12.2*P.r0;    % R B_T (Tesla - m)
 LX.Ip      = 7.1e6 ;       % Plasma current (A)
 LX.qA      = 1.0;          % Central q
 LX.bp      = 0.33;         % Beta poloidal (%)
 
 %% Boundary shape control points
 % Description: Up/down symmetric double null with strike-point constraints
 a0 = 0.565;                % Midplane minor radius (m)
 r0 = 1.28+a0;              % Geometry major radius (m)

 X_R = 1.51;                % R of both X-points (m)
 X_Z = 1.13;                % Z distance from midplane of X-points (m)
 X_fw = .1;                  % Flux error weight >0 is more forgiving
 X_bw = .1;                  % B field error weight >0 is more forgiving

 OS_R = 1.6;                % Outboard strikepoint R (m)
 OS_Z = 1.34;               % Outboard strikepoint Z (m)
 OS_fw = 0;                 % Outboard strikepoint flux weight

 IS_R = 1.32;               % Inboard strikepoint R (m)
 IS_Z = 1.22;               % Inboard strikepoint Z (m)
 IS_fw = 0;                % Inboard strikepoint flux weight

 OS2_R = 1.72;              % Outboard strikepoint for target AOI R (m)
 OS2_Z = 1.55;              % Outboard strikepoint for target AOI Z (m)
 OS2_fw = 0;                % Outboard strikepoint flux weight

 %% Fixed coil currents
 
 % Initialize PF currents and dipole constraint
 na = L.G.na;               % Number of coils
 LX.gpia = 0*ones(na,1);    % Minimize total current in each coil
 LX.gpie = 1*ones(na,1);    % Weight = 1 so current can float
 LX.gpdw = ones(na,1);      % Simple current dipoles
 
 % Define CS1 current
 LX.gpie(1:2) = 0;          % gpie = 0 for a fixed value
 LX.gpia(1:2) = CS1_current;% Current in Amps

 % Don't use VS1 for equilibria
 LX.gpie(19) = 0;
 
 % Give some weight to keeping DIV current at zero
 LX.gpie(15:18) = .01;        % gpie = 0 for a fixed value
 LX.gpia(15:18) = 0;         % Current in Amps

 %% Set control points
 % Flux control points
 %   fbtgp(LX,r ,z ,b,fa,fb,fe,br,bz,ba,be,cr,cz,ca,ce,vrr,vrz,vzz,ve)
 %   b = 1    1 = points are on the LCFS (used for initialization)
 %   fa = 0   The flux difference on these points compared to the LCFS
 %   fb = 1   All coils can be used to minimize flux error
 %   fe = 0   Flux error weight is large (bigger #s make the weight smaller)
 
 %   Midplane control positions
 rw = r0 + [1;-1]*a0;
 zw = 1e-20 * [1;1]; % Bug will be fixed so these can be zero

  %   fbtgp(LX,r ,z ,b,fa,fb,fe,br,bz,ba,be,cr,cz,ca,ce,vrr,vrz,vzz,ve)
 LX = fbtgp(LX,rw,zw,1, 0, 1, 0,[],[],[],[],[],[],[],[],[] ,[] ,[] ,[]);

 %   Outboard strike-point control positions
 rs = OS_R*[1;1]; 
 zs = OS_Z*[1;-1];

 %    fbtgp(LX,r ,z ,b,fa,fb,    fe,br,bz,ba,be,cr,cz,ca,ce,vrr,vrz,vzz,ve)
 LX = fbtgp(LX,rs,zs,0, 0, 1, OS_fw,[],[],[],[],[],[],[],[],[] ,[] ,[] ,[]);
 
 rs = OS2_R*[1;1];
 zs = OS2_Z*[1;-1];

 %    fbtgp(LX,r ,z ,b,fa,fb,     fe,br,bz,ba,be,cr,cz,ca,ce,vrr,vrz,vzz,ve)
 LX = fbtgp(LX,rs,zs,0, 0, 1, OS2_fw,[],[],[],[],[],[],[],[],[] ,[] ,[] ,[]);

 %   Inboard strike-point control positions
 rs = IS_R*[1;1]; 
 zs = IS_Z*[1;-1];

 %    fbtgp(LX,r ,z ,b,fa,fb,    fe,br,bz,ba,be,cr,cz,ca,ce,vrr,vrz,vzz,ve)
 LX = fbtgp(LX,rs,zs,0, 0, 1, IS_fw,[],[],[],[],[],[],[],[],[] ,[] ,[] ,[]);

 % X-point control points
 %   b = 1    These points are on the LCFS (used for initialization)
 %   fa = 0   The flux difference on these points compared to the LCFS
 %   fb = 1   All coils can be used to minimize flux error
 %   fe > 0   Flux error weight is > 0 (more forgiving)
 %   br = 0   No radial field at this point
 %   bz = 0   No vertical field at this point
 %   be > 0   Net b-field weight (bigger #s make the weight smaller)
 
 rx = X_R*[1;1];
 zx = X_Z*[1;-1];

  %   fbtgp(LX,r ,z ,b,fa,fb,   fe,br,bz,ba,  be,cr,cz,ca,ce,vrr,vrz,vzz,ve)
 LX = fbtgp(LX,rx,zx,1, 0, 1, X_fw, 0, 0,[],X_bw,[],[],[],[],[] ,[] ,[] ,[]);

end

 