  function pause_fig(pause_it);

% pause_fig pauses for look at figure
%
% SYNTAX:
%         pause_fig(pause_it)
%
% INPUT: [default]
%    pause_it=  0; % No pause - do nothing
%    pause_it=  1; % = pause, and wait for key stroke
%    pause_it=  2.1; % any +number other than 0 or 1 causes pause for # seconds
%
% OUTPUT: No Output => Just types Paused at gcf and pauses

% =======================================
% Jim Leuer 7-9-2004 Leuer@fusion.gat.com
% =======================================
% default input
% Modified 10/24/2021, Darren Garnier, garnier@mit.edu (make compatible with modern MATLAB)


  if nargin < 1
     return
  end

% ========================
% start load
  if pause_it
      if pause_it == 1
        fig=gcf;
        if fig.Name
            name = fig.Name;
        else
            name = ['Figure ' int2str(fig.Number)];
        end
        disp([' Paused at ' name ' press key to continue'])
	pause
      else
        pause(pause_it)
      end
   end
   return

% =======================
% testing
   pause_fig(1)
