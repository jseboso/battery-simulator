SHELL = /bin/bash
CWD = $(shell pwd | sed 's/.*\///g')

clean : 
	$(MAKE) -C battery-simulator clean