function expect(condition)
  global ASSERTIONS;
  [stack, ~] = dbstack;

  assertion = struct();
  assertion.stack = stack(2);
  assertion.outcome = condition;
  ASSERTIONS = {ASSERTIONS{:} assertion};

  if condition
    fprintf('.');
  else
    fprintf('F');
  end
end
