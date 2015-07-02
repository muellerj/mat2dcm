function run_specs
%RUN_SPECS
%
%  Run all specs located at [projectpath]/spec/**/*_spec.m

% Initialise counters
global ASSERTIONS;
ASSERTIONS = {};

specfiles = dir([projectpath '/spec/*_spec.m']);
for fidx = 1:length(specfiles)
  try
    feval(specfiles(fidx).name(1:end-2));
  catch exception
    disp([exception.stack(1).file ':' num2str(exception.stack(1).line) ' - ' exception.message]);

    % Delete temporary files
    if exist('tmp.mat', 'file'), delete('tmp.mat'); end
    if exist('tmp.dcm', 'file'), delete('tmp.dcm'); end
  end
end

% Print spec results
print_spec_status(ASSERTIONS);
