%------------------------------------
% BEGIN: function BattSizingEvent.m
%------------------------------------
function event = BattSizingEvent(sol);

t0 = sol.initial.time;
x0 = sol.initial.state;
tf = sol.terminal.time;
xf = sol.terminal.state;

event = [x0(1); xf(1)];

%------------------------------------
% END: function BattSizingEvent.m
%------------------------------------
