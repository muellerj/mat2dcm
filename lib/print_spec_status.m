function print_spec_status(assertions)
%PRINT_SPEC_STATUS
%
%  Print a nicely formatted spec status message and display the lines
%  on which the failures occured

failures = {};

for aidx = 1:length(assertions)
  if assertions{aidx}.outcome == false
    failures = {failures{:} assertions{aidx}};
  end
end

specs  = length(assertions);
fails  = length(failures);
passes = specs - fails;

fprintf('%d %s\n%d %s, %d %s\n', ...
  specs, ternary(specs == 1, 'Assertion', 'Assertions'), ...
  passes, ternary(passes == 1, 'Pass', 'Passes'), ...
  fails, ternary(fails == 1, 'Fail', 'Fails'));

for fidx = 1:length(failures)
  fprintf('Failure in %s: line %d\n', ...
    failures{fidx}.stack.file, failures{fidx}.stack.line);
end

