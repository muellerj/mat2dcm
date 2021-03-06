function gruppenkennfeld_spec

KF_LOOKUP_TABLE1.x = [-10 0 100];
KF_LOOKUP_TABLE1.y = [0 1]';
KF_LOOKUP_TABLE1.z = [0 0 0; -1 0 10];
KF_LOOKUP_TABLE1.type = 'gruppenkennfeld';

KF_LOOKUP_TABLE2.x = {'foo', 'bar', 'baz'};
KF_LOOKUP_TABLE2.y = [0 1]';
KF_LOOKUP_TABLE2.z = [0 0 0; -1 0 10];
KF_LOOKUP_TABLE2.type = 'gruppenkennfeld';

KF_LOOKUP_TABLE3.x = [-10 0 100];
KF_LOOKUP_TABLE3.y = {'foo', 'bar'};
KF_LOOKUP_TABLE3.z = [0 0 0; -1 0 10];
KF_LOOKUP_TABLE3.type = 'gruppenkennfeld';

KF_LOOKUP_TABLE4.x = [-10 0 100];
KF_LOOKUP_TABLE4.y = [0 1]';
KF_LOOKUP_TABLE4.z = {'a1', 'a2', 'a3'; 'b1', 'b2', 'b3'};
KF_LOOKUP_TABLE4.type = 'gruppenkennfeld';

% Save labels to a temporary file
save('tmp.mat', '-regexp', '^KF');

% Export using mat2dcm
mat2dcm('tmp.mat', 'tmp.dcm', ...
  'Precision', '%1.3f', ...
  'Prefix', '', ...
  'Verbose', false);
filecontent = regexprep(fileread('tmp.dcm'), '\r', '');

% GRUPPENKENNFELD numeric/numeric/numeric
expect(~isempty(regexp(filecontent, [...
'GRUPPENKENNFELD KF_LOOKUP_TABLE1 3 2\n' ...
'   ST/X   -10.000   0.000   100.000\n' ...
'   ST/Y   0.000\n' ...
'   WERT   0.000   0.000   0.000\n' ...
'   ST/Y   1.000\n' ...
'   WERT   -1.000   0.000   10.000\n' ...
'END\n' ...
])));

% GRUPPENKENNFELD text/numeric/numeric
expect(~isempty(regexp(filecontent, [...
'GRUPPENKENNFELD KF_LOOKUP_TABLE2 3 2\n' ...
'   ST_TX/X   "foo"   "bar"   "baz"\n' ...
'   ST/Y   0.000\n' ...
'   WERT   0.000   0.000   0.000\n' ...
'   ST/Y   1.000\n' ...
'   WERT   -1.000   0.000   10.000\n' ...
'END\n' ...
])));

% GRUPPENKENNFELD numeric/text/numeric
expect(~isempty(regexp(filecontent, [...
'GRUPPENKENNFELD KF_LOOKUP_TABLE3 3 2\n' ...
'   ST/X   -10.000   0.000   100.000\n' ...
'   ST_TX/Y   "foo"\n' ...
'   WERT   0.000   0.000   0.000\n' ...
'   ST_TX/Y   "bar"\n' ...
'   WERT   -1.000   0.000   10.000\n' ...
'END\n' ...
])));

% GRUPPENKENNFELD numeric/numeric/text
expect(~isempty(regexp(filecontent, [...
'GRUPPENKENNFELD KF_LOOKUP_TABLE4 3 2\n' ...
'   ST/X   -10.000   0.000   100.000\n' ...
'   ST/Y   0.000\n' ...
'   TEXT   "a1"   "a2"   "a3"\n' ...
'   ST/Y   1.000\n' ...
'   TEXT   "b1"   "b2"   "b3"\n' ...
'END\n' ...
])));
