function run_specs(varargin)
%RUN_SPECS [SEARCHSTR]
%
%  Run all available specs matching SEARCHSTR inside
%  [rootpath]/spec/*

  global ASSERTIONS;
  ASSERTIONS = {};
  EXCEPTIONS = {};

  if nargin > 0
    searchstr = varargin{1};
  else
    searchstr = '.';
  end

  specfiles = collectfiles({}, fullfile(rootpath, 'spec'));
  specfiles = filterfiles(specfiles, searchstr);

  fprintf(['Running ' pluralise(numel(specfiles), 'specfile', 'specfiles') '\n']);

  close_testharness_models();

  for fidx = 1:numel(specfiles)
    try
      [~, fname, ~] = fileparts(specfiles{fidx});
      feval(fname);
    catch exception
      EXCEPTIONS = {EXCEPTIONS{:} exception};
      fprintf('E');
    end
  end

  fprintf('\n');

  if not(isempty(EXCEPTIONS))
    for eidx = 1:numel(EXCEPTIONS)
      disp(EXCEPTIONS{eidx}.message);
      for sidx = 1:numel(EXCEPTIONS{eidx}.stack)
        fprintf('%s:%d\n' ,EXCEPTIONS{eidx}.stack(sidx).file, EXCEPTIONS{eidx}.stack(sidx).line);
      end
      disp(' ');
    end
  end

  passes = cellfun(@(x) x.outcome, ASSERTIONS);

  if not(isempty(EXCEPTIONS))
    fprintf('ERROR\n\n')
  elseif all(passes)
    fprintf('PASSED\n\n')
  else
    fprintf([pluralise(numel(find(passes == 0)), 'FAIL', 'FAILS') '\n\n']);

    for aidx = 1:numel(ASSERTIONS)
      if ASSERTIONS{aidx}.outcome == 0
        fprintf('Failure in %s: line %d\n', ...
          ASSERTIONS{aidx}.stack.file, ASSERTIONS{aidx}.stack.line);
      end
    end
  end

  close_testharness_models();

end

function outstr = pluralise(n, singular, plural)
  if n == 1
    outstr = ['1 ' singular];
  else
    outstr = [num2str(n) ' ' plural];
  end
end

function newfiles = collectfiles(oldfiles, folder)
  newfiles = oldfiles;
  files = dir(folder);
  for fidx = 3:numel(files)
    if isdir(fullfile(folder, files(fidx).name))
      newfiles = collectfiles(newfiles, fullfile(folder, files(fidx).name));
    else
      if regexp(files(fidx).name, '_spec.m$')
        newfiles{end+1} = fullfile(folder, files(fidx).name);
      end
    end
  end
end

function newfiles = filterfiles(oldfiles, searchstr)
  searchstr = regexprep(searchstr, '\\', '/');
  newfiles = {};
  ignore   = fullfile(rootpath);
  for fidx = 1:numel(oldfiles)
    specname = strrep(oldfiles{fidx}, ignore, '');
    specname = regexprep(specname, '\\', '/');
    if regexp(specname, ['\<' searchstr '(\>|_spec.m)'])
      newfiles{end+1} = oldfiles{fidx};
    end
  end
end

function close_testharness_models
  models = find_system('SearchDepth', 0);
  for midx = 1:numel(models)
    if starts_with(models{midx}, 'testharness_')
      bdclose(models{midx});
    end
  end
  warning('off','Simulink:blocks:AssumingDefaultSimStateForSFcn')
end

function cond = starts_with(str, pat)
  cond = strcmp(str(1:min(length(pat), length(str))), pat);
end
