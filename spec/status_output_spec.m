function status_output_spec

K_SOME_SCALAR = 1.50;
K_SOME_TEXT = {'foo'};

KL_LOOKUP_LINE_TEXT_TEXT.x = {'a', 'b', 'c'};
KL_LOOKUP_LINE_TEXT_TEXT.y = {'foo', 'bar', 'baz'};

AXX_SOME_AXIS.x    = [-0.5   100];

% Save labels to a temporary file
save('tmp.mat', '-regexp', '^K_SOME_');

% Export using mat2dcm
output = evalc('mat2dcm(''tmp.mat'', ''tmp.dcm'', ''Verbose'', true)');

expect(strcmp(deblank(output), 'tmp.dcm: Exported 2 Festwerte, 0 Festwertebloecke, 0 Kennlinien, 0 Kennfelder, 0 Stuetzstellenverteilungen'));
