function stuetzstellenverteilung_spec

AXX_SOME_AXIS.x    = [-0.5   100];
AXY_ANOTHER_AXIS.y = {'foo', 'bar', 'baz'};

% Save labels to a temporary file
save('tmp.mat', '-regexp', '^AX');

% Export using mat2dcm
mat2dcm('tmp.mat', 'tmp.dcm', ...
  'Precision', '%1.3f', ...
  'Prefix', '', ...
  'Verbose', false);
filecontent = regexprep(fileread('tmp.dcm'), '\r', '');

% STUETZSTELLENVERTEILUNG numeric
expect(~isempty(regexp(filecontent, [...
'STUETZSTELLENVERTEILUNG AXX_SOME_AXIS 2\n' ...
'   ST/X   -0.500   100.000\n' ...
'END\n' ...
])));

% STUETZSTELLENVERTEILUNG text
expect(~isempty(regexp(filecontent, [...
'STUETZSTELLENVERTEILUNG AXY_ANOTHER_AXIS 3\n' ...
'   ST_TX/X   "foo"   "bar"   "baz"\n' ...
'END\n' ...
])));

