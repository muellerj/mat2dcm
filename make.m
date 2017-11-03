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
      case 'clean'
        clc;
        evalin('base', 'clear all');
        delete('tmp.mat');
        delete('tmp.dcm');
      case 'spec'
        run_specs(varargin{:});
      otherwise
        error(['Unknown option: ' option]);
    end
  end
end

function x = projectpath()
  x = char(regexp(mfilename('fullpath'), '(.*)[\\\/]make', 'tokens', 'once'));
end
