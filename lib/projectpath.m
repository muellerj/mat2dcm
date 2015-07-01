function ppath = projectpath()
% Return the current project root path
fullpath = mfilename('fullpath');
ppath    = regexp(fullpath, '(.*)[\\\/]lib', 'tokens');
ppath    = regexprep(ppath{1}{1}, '\\', '/');
