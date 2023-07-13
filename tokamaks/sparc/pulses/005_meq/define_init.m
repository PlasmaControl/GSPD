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

LY = load('./data/LYs').LYs{1};

init.ic = LY.Ia;
init.iv = zeros(250,1);  % plug in zeros for now
init.v = zeros(19,1);    % plug in zeros for now
  
