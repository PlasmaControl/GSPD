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
% These currents are taken from the vacuum simulation

function init = define_init()

init = load('./data/startup_currents').currents;  % contains ic and iv from startup sim
init.v = zeros(19,1);
  

init.ic([13 14]) = init.ic([13 14]) - 1000;