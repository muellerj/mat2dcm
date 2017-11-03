function x = rootpath()
% Return the current project root path
  x = char(regexp(mfilename('fullpath'), '(.*)[\\\/]lib[\\\/]rootpath', 'tokens', 'once'));
end
