function expect(condition)

  % Guard against stupid data types
  condition = logical(condition);

  if not(isscalar(condition))
    error('Condition must be a scalar boolean value!');
  end

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
