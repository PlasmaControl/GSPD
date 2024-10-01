% Helper function for reading data from a vector format as is often done in
% model predictive control. The inverse of this procedure is structts2vec.m
% 
% Inputs: 
%    vec     - data vector to read in specific format, see example
%    fdnames - which data items to read
%    iy      - structure with indices corresponding to fdnames
%    time    - timebase associated with vec
%
% Outputs: 
%    s - structure with subfields according to fdnames with data and time
%
% Example:
% time = linspace(0,2*pi,50);
% sigA = sin(time);
% sigB = [cos(time); 0.8*cos(time)];
% sigC = sin(2*time);
% data = [sigA; sigB; sigC];
% vec = data(:);
% iy.sigA = 1;
% iy.sigB = [2; 3];
% iy.sigC = 4;
% fdnames = {'sigA', 'sigB', 'sigC'};
% s = vec2slstructts(vec, fdnames, iy, time);
% plot(time, sigB, '-b')
% hold on
% plot(s.sigB.Time, s.sigB.Data, '--r')


function s = vec2structts(vec, fdnames, iy, time)

x = reshape(vec, [], length(time))';

for i = 1:length(fdnames)  
  fd = fdnames{i};

  s.(fd).Time = time(:);
  s.(fd).Data = x(:, iy.(fd));
end

  