function make(option, varargin)
%MAKE
%
% Project specific Makefile for ASD application. Executes common tasks
% depending on the context and the `option` passed by parameter:
%
%   make [option]

% Add library paths
addpath(genpath([projectpath '/lib']));
addpath(genpath([projectpath '/spec']));

if nargin < 1
  make('spec');
else
  switch(option)
    case 'all'
      % Do nothing
    case 'clean'
      clc;
      evalin('base', 'clear all');
      delete('tmp.mat');
      delete('tmp.dcm');
    case 'spec'
      disp('# Running specs ...');
      run_specs;
    otherwise
      error(['Unknown option: ' option]);
  end
end

function ppath = projectpath()
% Return the current project root path
fullpath = mfilename('fullpath');
ppath    = regexp(fullpath, '(.*)[\\\/]make', 'tokens');
ppath    = ppath{1}{1};
