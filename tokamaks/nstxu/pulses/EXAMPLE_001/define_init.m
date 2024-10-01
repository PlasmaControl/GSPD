% define the initial condition for the optimization
%
% inputs  - none
% outputs - init struct
%           init.ic = initial coil currents
%           init.iv = initial vessel currents          
%           init.v  = initial voltages in the active coils, only used for
%                     weighting the derivative of voltages and can often
%                     be set to zero. 
%
% For this example, we will grab these values from the presaved equilibrium
% from shot 204660 at t=30ms.

function init = define_init()

eq = load('eq204660_030.mat').eq;

init.ic = eq.icx;
init.iv = eq.ivx;
init.v  = zeros(8,1);  