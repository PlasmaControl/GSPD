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
s.ip.Time = [0 9 19 31];
s.ip.Data = [0.3 8.7 8.7 1] * 1e6;
s.ip.Units = 'A';

% li, internal inductance
s.li.Time = [0 3 22 31];
s.li.Data = [0.8 1.2 1.2 0.8];
s.li.Units = '';

% wmhd, stored thermal energy
s.wmhd.Time = [0 5 9 12 16 19 26 31];
s.wmhd.Data = [1 15 20 25 25 20 15 1] * 1e6;
s.wmhd.Units = 'J';

% Rp, plasma resistance in Ohms
s.Rp.Time = [0 0.1 0.5 5 9 19 31];
s.Rp.Data = [20 8 4 1 1 1 4] * 1e-7 * 0.3;
s.Rp.Units = 'Ohm';

% format data
s = check_structts_dims(s); 

plasma_scalars = s;

% plotting
if opts.plotlevel >= 2
  plot_structts(s, fields(s), 2);
  sgtitle('Plasma scalar targets'); drawnow
end


































