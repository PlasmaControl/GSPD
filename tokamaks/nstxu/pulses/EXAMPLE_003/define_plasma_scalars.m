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
s.ip.Time = [0 0.05 0.15 0.25 0.4 1]';
s.ip.Data = [0 2.2 4.7 5.8 7.7 7.7]' * 1e5;
s.ip.Units = 'A';

% li, internal inductance
s.li.Time = [0 0.06 0.32 0.58 1]';
s.li.Data = [0.1 0.4 0.95 1.25 1.25]';
s.li.Units = '';

% wmhd, stored thermal energy
s.wmhd.Time = [0 0.13 0.27 0.49 0.71 1]';
s.wmhd.Data = [0.01 1.2 3 8 8 3.5]' * 1e4;
s.wmhd.Units = 'J';

% Rp, plasma resistance in Ohms
s.Rp.Time = [0 0.03 0.075 0.12 0.15 0.24 0.39 0.55 1]';
s.Rp.Data = [17 12 8 4.7 3.6 2.5 1.8 0.8 0.8]' * 1e-6 * 0.7; 
s.Rp.Units = 'Ohm';

% format data
s = check_structts_dims(s); 

plasma_scalars = s;

% plotting
if opts.plotlevel >= 2
  plot_structts(s, fields(s), 2);
  sgtitle('Plasma scalar targets'); drawnow
end


































