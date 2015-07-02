function festwerteblock_spec

K_SOME_SCALAR = [1.5, 0, 10.5];
K_SOME_TEXT = {'foo', 'bar'};

% Save labels to a temporary file
save('tmp.mat', '-regexp', '^K_SOME_');

% Export using convert_to_dcm
convert_to_dcm('tmp.mat', 'tmp.dcm', ...
  'Precision', '%1.3f', ...
  'Prefix', '', ...
  'Verbose', false);
filecontent = regexprep(fileread('tmp.dcm'), '\r', '');

% FESTWERTEBLOCK numeric
myassert(~isempty(regexp(filecontent, [...
  'FESTWERTEBLOCK K_SOME_SCALAR 3\n' ...
  '   WERT   1.500   0.000   10.500\n' ...
  'END\n' ...
])));

% FESTWERTEBLOCK text
myassert(~isempty(regexp(filecontent, [...
  'FESTWERTEBLOCK K_SOME_TEXT 2\n' ...
  '   TEXT   "foo"   "bar"\n' ...
  'END\n' ...
])));
