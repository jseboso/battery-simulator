CFLAGS = -Wall -Wno-comment -Werror -g 
CC     = gcc $(CFLAGS)
SHELL  = /bin/bash
CWD    = $(shell pwd | sed 's/.*\///g')

PROGRAMS = \
	battery_main \

TESTPROGRAMS = \
	hybrid_main \
	test_battery_update \
	test_hybrid_battery_update


all : $(PROGRAMS)

clean :
	rm -f $(PROGRAMS) *.o $(TESTPROGRAMS)

help :
	@echo 'Typical usage is:'
	@echo '  > make                          # build all programs'
	@echo '  > make clean                    # remove all compiled items'
	@echo '  > make testnum=5                # run test #5 only'
	@echo '  > make test                     # run all tests'
	@echo 'SPECIAL TARGETS for this Part'      
	@echo '  > make hybrid_main              # build the combined C/assembly program'
	@echo '  > make test-hybrid              # run tests on the hybrid executable'


################################################################################
# battery problem (asm)

# build .o files from corresponding .c files
%.o : %.c battery.h
	$(CC) -c $<

# build assembly object via gcc + debug flags
battery_update_asm.o : battery_update_asm.s batt.h
	$(CC) -c $<

battery_main : battery_main.o battery_sim.o battery_update_asm.o 
	$(CC) -o $@ $^

# batt_update functions testing program
test_battery_update : test_battery_update.o battery_sim.o battery_update_asm.o
	$(CC) -o $@ $^

# uses both assmebly and C update functions for incremental testing
hybrid_main : battery_main.o battery_sim.o battery_update_asm.o battery_update.o
	$(CC) -o $@ $^

# hybrid test program
test_hybrid_battery_update : test_battery_update.o battery_sim.o battery_update_asm.o battery_update.o
	$(CC) -o $@ $^

################################################################################

