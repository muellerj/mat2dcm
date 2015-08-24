# Simple Makefile for accessing Matlab structure from the command line
#
# Jonas Mueller, EA-253

PWD := $(shell cygpath -w `pwd` | sed 's:\\:/:g')
MATLABINTERFACE := bin/im

.setup:
	@echo "cd('$(PWD)')" | $(MATLABINTERFACE) > /dev/null
	@echo "clear all" | $(MATLABINTERFACE) > /dev/null
	@echo "switch_encoding('UTF-8')" | $(MATLABINTERFACE) > /dev/null
%: .setup
	@if [ "$@" != "Makefile" ] && [ "$@" != "README.markdown" ]; then echo "make $@" | $(MATLABINTERFACE); fi
clean:
	rm *.mat *.dcm

.PHONY: clean
