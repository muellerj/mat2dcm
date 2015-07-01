function run_specs
%RUN_SPECS
%
%  Run all specs located at [projectpath]/spec/**/*_spec.m

% Initialise counters
global ASSERTIONS;
ASSERTIONS = {};

% Compile a list of paths to be processed
specpaths = strread(genpath([projectpath '/spec']), '%s', 'delimiter', ';');
specpaths(1) = [];

for pidx = 1:length(specpaths)
  specfiles = dir([specpaths{pidx} '/*_spec.m']);
  for fidx = 1:length(specfiles)
    try
      feval(specfiles(fidx).name(1:end-2));
    catch exception
      disp([exception.stack(1).file ' errors: ' exception.message]);
    end
  end
end

% Print spec results
print_spec_status(ASSERTIONS);
