function outval = ternary(condition, trueval, falseval)
%TERNARY - Simple imitation of a ternary operator.
%
%  OUT = TERNARY(COND, TRUEVAL, FALSEVAL) assigns OUT with TRUEVAL if COND
%    is true, with FALSEVAL if it is false.

if condition
  outval = trueval;
else
  outval = falseval;
end
