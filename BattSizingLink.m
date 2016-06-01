function [Link] = BattSizingLink(sol);

xf_left = sol.left.state;
left_phase = sol.left.phase;
x0_right = sol.right.state;
right_phase = sol.right.phase;

Link = x0_right-xf_left;


