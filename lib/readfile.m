function content = readfile(fname)
%READFILE
%
% Read a given file into a cell array of strings, representing
% the lines of the file.

fid = fopen(fname);
content = {fgetl(fid)};

while ischar(content{end})
  content{end+1} = fgetl(fid);
end

content(end) = [];
content = content';
fclose(fid);
