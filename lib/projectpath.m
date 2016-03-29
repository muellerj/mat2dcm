function x = projectpath()
% Return the current project root path
  x = char(regexp(mfilename('fullpath'), '(.*)[\\\/]lib[\\\/]projectpath', 'tokens', 'once'));
end
