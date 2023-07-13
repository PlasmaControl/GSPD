%  inputs: opts struct
%          if opts.plotlevel >= 2, makes a plot of the plasma scalars
% 
%  outputs: the plasma_scalars struct that has fields:
%     ip, li, wmhd, Rp each with subfields (Time, Data, Units). 
%     Units is only used for plotting, i.e. don't change units 
%     from A to kA and expect the code to intelligently adapt. 
%
function plasma_scalars   = define_plasma_scalars(opts)

LYs = load('./data/LYs').LYs;
LYs = cell2mat(LYs);

t = [0.2 1:30];

% ip, plasma current in Amps
s.ip.Time = t;
s.ip.Data = [LYs(:).Ip];
s.ip.Units = 'A';

% li, internal inductance
s.li.Time = t;
s.li.Data = [LYs(:).li];
s.li.Units = '';

% wmhd, stored thermal energy
s.wmhd.Time = t;
s.wmhd.Data = [LYs(:).Wk];
s.wmhd.Units = 'J';

% Rp, plasma resistance in Ohms
s.Rp.Time = t;
s.Rp.Data = min(max(1.82 * t.^-1.8, 0.02), 10)*1e-6;
s.Rp.Units = 'Ohm';

% format data
s = check_structts_dims(s); 

plasma_scalars = s;

% plotting
if opts.plotlevel >= 2
  plot_structts(s, fields(s), 2);
  sgtitle('Plasma scalar targets'); drawnow
end


































