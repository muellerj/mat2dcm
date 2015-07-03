function mat2dcm(matfilename, dcmfilename, varargin)
%FUNCTION MAT2DCM
% Write a DCM of all variables saved in file MATFILENAME to DCMFILENAME.
% Parameters can be adapted to the INCA format, whereby matrices are reshaped
% into their transposed dimensions. Usage:
%
%  MAT2DCM(MATFILENAME, DCMFILENAME[, KEY1, VAL1, ...])
%
% where the KEYS and VALUES can be any of the following
%
%   KEY           DESCRIPTION                            DEFAULT
%   ----------------------------------------------------------------
%   Precision     Precision of the exported parameter    %1.3f
%   Prefix        Prefix for all labels                  ''
%   Verbose       Report exported labels                 true
%   Encoding      Encoding to use for DCM file           'windows-1250'
%
% Jonas Mueller, EA-253
% 02.07.2015

% Parse parameters
if nargin > 2 && mod(nargin-2, 2) ~= 0
  error('Wrong number of parameters');
end

% Set default options
options = struct();
options.Precision    = '%1.3f';
options.Prefix       = '';
options.Verbose      = true;
options.Encoding     = 'windows-1250';

% Initialise counters for statistic
counter                         = struct();
counter.festwert                = 0;
counter.festwerteblock          = 0;
counter.kennlinie               = 0;
counter.kennfeld                = 0;
counter.stuetzstellenverteilung = 0;

% ... and let the user override them
for vidx = 1:2:nargin-2
  if any(strcmp(varargin{vidx}, fieldnames(options)))
    eval(['options.' varargin{vidx} ' = varargin{' num2str(vidx+1) '};']);
  else
    error(['Invalid parameter: ' varargin{vidx}]);
  end
end

% Load file and establish list of parameters
paramlist = who('-file', matfilename);
load(matfilename);

% Try to open connection to file
fid = open_file_connection(dcmfilename, options);

% Write header
write_header(fid, options);

% Make sure to close file connection if an error occurs
try
  for pidx = 1:length(paramlist)

    paramname  = paramlist{pidx};
    paramvalue = eval(paramname);
    paramsize  = size(paramvalue);
    paramname  = [options.Prefix paramname];

    switch categorise_param(paramname, paramvalue)
      case 'festwert'
        counter.festwert = counter.festwert + 1;
        write_festwert(fid, options, paramname, paramvalue);
      case 'festwerteblock'
        counter.festwerteblock = counter.festwerteblock + 1;
        write_festwerteblock(fid, options, paramname, paramvalue);
      case 'kennlinie'
        counter.kennlinie = counter.kennlinie + 1;
        write_kennlinie(fid, options, paramname, paramvalue);
      case 'kennfeld'
        counter.kennfeld = counter.kennfeld + 1;
        write_kennfeld(fid, options, paramname, paramvalue);
      case 'stuetzstellenverteilung'
        counter.stuetzstellenverteilung = counter.stuetzstellenverteilung + 1;
        write_stuetzstellenverteilung(fid, options, paramname, paramvalue);
    end
  end
catch exception
  fclose(fid);
  rethrow(exception);
end

% Close file connection
fclose(fid);

% Print report if required
if options.Verbose, print_status(dcmfilename, counter); end

function paramtype = categorise_param(name, value)
if isstruct(value) && isfield(value, 'x') && isfield(value, 'y') && isfield(value, 'z')
  paramtype = 'kennfeld';
elseif isstruct(value) && isfield(value, 'x') && isfield(value, 'y')
  paramtype = 'kennlinie';
elseif isstruct(value) && (isfield(value, 'x') || isfield(value, 'y'))
  paramtype = 'stuetzstellenverteilung';
elseif all(size(value) == 1)
  paramtype = 'festwert';
else
  paramtype = 'festwerteblock';
end

function write_header(fid, options)
VERSION = '0.0.1';
fprintf(fid, '* DCM export\n');
fprintf(fid, '* User: %s\n', getenv('USERNAME'));
fprintf(fid, '* Date: %s\n', date);
fprintf(fid, '* Script Version: %s\n', VERSION);
fprintf(fid, '\n\n');
fprintf(fid, 'KONSERVIERUNG_FORMAT 2.0');
fprintf(fid, '\n\n');

function write_festwert(fid, options, name, value)
fprintf(fid, 'FESTWERT %s\n', name);
if iscell(value)
  fprintf(fid, '   TEXT "%s"\n', value{:});
else
  fprintf(fid, ['   WERT ' options.Precision '\n'], value);
end
fprintf(fid, 'END\n\n');

function write_festwerteblock(fid, options, name, value)
fprintf(fid, 'FESTWERTEBLOCK %s %1.0f\n', name, size(value, 2));
if iscell(value)
fprintf(fid, '   TEXT');
  for cidx = 1:size(value, 2)
    fprintf(fid, '   "%s"', value{cidx});
  end
else
fprintf(fid, '   WERT');
  for cidx = 1:size(value, 2)
    fprintf(fid, ['   ' options.Precision], value(cidx));
  end
end
fprintf(fid, '\n');
fprintf(fid, 'END\n\n');


function write_matrix(fid, options, name, value)
value = reshape(value, 1, size(value, 1)*size(value, 2));

if size(value, 1) == 1
  fprintf(fid, 'FESTWERTEBLOCK %s %1.0f\n', name, length(value));
  fprintf(fid, '   EINHEIT_W "-"\n');
  fprintf(fid, '   WERT');
  for cidx = 1:length(value)
    fprintf(fid, ['   ' options.Precision], value(cidx));
  end
  fprintf(fid, '\n');
  fprintf(fid, 'END\n\n');
else
  fprintf(fid, 'FESTWERTEBLOCK %s %1.0f @ %1.0f\n', name, ...
    size(value, 2), size(value, 1));
  fprintf(fid, '   EINHEIT_W "-"\n');
  for ridx = 1:size(value, 1)
    fprintf(fid, '   WERT');
    for cidx = 1:size(value, 2)
      fprintf(fid, ['   ' options.Precision], value(ridx,cidx));
    end
    fprintf(fid, '\n');
  end
  fprintf(fid, 'END\n\n');
end

function write_kennlinie(fid, options, name, value)
if isfield(value, 'type') && strcmpi(value.type, 'gruppenkennlinie')
  type = 'GRUPPENKENNLINIE';
else
  type = 'KENNLINIE';
end
fprintf(fid, '%s %s %1.0f\n', type, name, length(value.x));
if iscell(value.x)
  fprintf(fid, '   ST_TX/X');
  for xidx = 1:length(value.x)
    fprintf(fid, '   "%s"', value.x{xidx});
  end
else
  fprintf(fid, '   ST/X');
  for xidx = 1:length(value.x)
    fprintf(fid, ['   ' options.Precision], value.x(xidx));
  end
end
fprintf(fid, '\n');
if iscell(value.y)
  fprintf(fid, '   TEXT');
  for yidx = 1:length(value.y)
    fprintf(fid, '   "%s"', value.y{yidx});
  end
else
  fprintf(fid, '   WERT');
  for yidx = 1:length(value.y)
    fprintf(fid, ['   ' options.Precision], value.y(yidx));
  end
end
fprintf(fid, '\n');
fprintf(fid, 'END\n\n');

function write_stuetzstellenverteilung(fid, options, name, value)
if isfield(value, 'x'), value = value.x; else value = value.y; end
fprintf(fid, 'STUETZSTELLENVERTEILUNG %s %1.0f\n', name, length(value));
if iscell(value)
  fprintf(fid, '   ST_TX/X');
  for xidx = 1:length(value)
    fprintf(fid, '   "%s"', value{xidx});
  end
else
  fprintf(fid, '   ST/X');
  for xidx = 1:length(value)
    fprintf(fid, ['   ' options.Precision], value(xidx));
  end
end
fprintf(fid, '\n');
fprintf(fid, 'END\n\n');

function write_kennfeld(fid, options, name, value)
fprintf(fid, 'KENNFELD %s %1.0f %1.0f\n', name, size(value.z, 2), size(value.z, 1));
if iscell(value.x)
  fprintf(fid, '   ST_TX/X');
  for xidx = 1:length(value.x)
    fprintf(fid, '   "%s"', value.x{xidx});
  end
else
  fprintf(fid, '   ST/X');
  for xidx = 1:length(value.x)
    fprintf(fid, ['   ' options.Precision], value.x(xidx));
  end
end
fprintf(fid, '\n');
for yidx = 1:length(value.y)
  if iscell(value.y)
    fprintf(fid, '   ST_TX/Y   "%s"\n', value.y{yidx});
  else
    fprintf(fid, ['   ST/Y   ' options.Precision '\n'], value.y(yidx));
  end
  if iscell(value.z)
    fprintf(fid, '   TEXT');
    for xidx = 1:length(value.x)
      fprintf(fid, '   "%s"', value.z{yidx,xidx});
    end
  else
    fprintf(fid, '   WERT');
    for xidx = 1:length(value.x)
      fprintf(fid, ['   ' options.Precision], value.z(yidx,xidx));
    end
  end
  fprintf(fid, '\n');
end
fprintf(fid, 'END\n\n');

function print_status(dcmfilename, c)
[pathstr, name, ext] = fileparts(dcmfilename);
fprintf(1, '%s: Exported %d %s, %d %s, %d %s, %d %s\n', ...
  [name ext], ...
  c.festwert, ternary(c.festwert == 1, 'Festwert', 'Festwerte'), ...
  c.festwerteblock, ternary(c.festwerteblock == 1, 'Festwerteblock', 'Festwertebloecke'), ...
  c.kennlinie, ternary(c.kennlinie == 1, 'Kennlinie', 'Kennlinien'), ...
  c.kennfeld, ternary(c.kennfeld == 1, 'Kennfeld', 'Kennfelder') ...
  );

function fid = open_file_connection(dcmfilename, options)
% Establish file connection, making sure it's fresh
if exist(dcmfilename, 'file'), delete(dcmfilename); end
fid = fopen(dcmfilename, 'w+t', 'n', options.Encoding);
if fid == -1, error('Cannot open DCM file for write access'); end

function c = ternary(condition, a, b)
% Provide a shorthand for conditionals
if condition, c = a; else c = b; end
