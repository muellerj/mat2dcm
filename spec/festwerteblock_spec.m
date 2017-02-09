function festwerteblock_spec

K_SOME_VECTOR = [1.5, 0, 10.5];
K_SOME_TEXT   = {'foo', 'bar'};
K_SOME_MATRIX = [1.5, 0, 10.5; 0 1 2];

% Save labels to a temporary file
save('tmp.mat', '-regexp', '^K_SOME_');

% Export using mat2dcm
mat2dcm('tmp.mat', 'tmp.dcm', ...
  'Precision', '%1.3f', ...
  'Prefix', '', ...
  'Verbose', false);
filecontent = regexprep(fileread('tmp.dcm'), '\r', '');

% FESTWERTEBLOCK numeric
expect(~isempty(regexp(filecontent, [...
  'FESTWERTEBLOCK K_SOME_VECTOR 3\n' ...
  '   WERT   1.500   0.000   10.500\n' ...
  'END\n' ...
])));

% FESTWERTEBLOCK numeric matrix
expect(~isempty(regexp(filecontent, [...
  'FESTWERTEBLOCK K_SOME_MATRIX 3 @ 2\n' ...
  '   WERT   1.500   0.000   10.500\n' ...
  '   WERT   0.000   1.000   2.000\n' ...
  'END\n' ...
])));

% FESTWERTEBLOCK text
expect(~isempty(regexp(filecontent, [...
  'FESTWERTEBLOCK K_SOME_TEXT 2\n' ...
  '   TEXT   "foo"   "bar"\n' ...
  'END\n' ...
])));

