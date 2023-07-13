%  inputs: opts struct
%          if opts.plotlevel >= 2, makes a plot of the plasma scalars
% 
%  outputs: the plasma_scalars struct that has fields:
%     ip, li, wmhd, Rp each with subfields (Time, Data, Units). 
%     Units is only used for plotting, i.e. don't change units 
%     from A to kA and expect the code to intelligently adapt. 
%
function plasma_scalars   = define_plasma_scalars(opts)

% ip, plasma current in Amps
s.ip.Time = [0 10];
s.ip.Data = [5 5] * 1e6;
s.ip.Units = 'A';

% li, internal inductance
s.li.Time = [0 10];
s.li.Data = [1.2 1.2];
s.li.Units = '';

% wmhd, stored thermal energy
s.wmhd.Time = [0 10];
s.wmhd.Data = [2 2] * 1e7;
s.wmhd.Units = 'J';

% Rp, plasma resistance in Ohms
s.Rp.Time = [0 10];
s.Rp.Data = [0 0] * 1e-6;
s.Rp.Units = 'Ohm';

% format data
s = check_structts_dims(s); 

plasma_scalars = s;

% plotting
if opts.plotlevel >= 2
  plot_structts(s, fields(s), 2);
  sgtitle('Plasma scalar targets'); drawnow
end


































