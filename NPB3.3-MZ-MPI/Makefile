# Modified Makefile
# Use environment variable NPB_TEST to switch tests,
# and use make targets to switch ordinary/instrumented builds.

SHELL=/bin/sh
CLASS=W
NPROCS=1
VERSION=
SFILE=config/suite.def


all: makefile_org suite

makefile_org:
	$(info Building without instrumentation)
	cp config/make.def.org config/make.def

tau: makefile_tau suite

makefile_tau:
	$(info Building with TAU source-based instrumentation)
	cp config/make.def.tau config/make.def

tau-comp: makefile_tau_comp suite

makefile_tau_comp:
	$(info Building with TAU compiler-based instrumentation)
	cp config/make.def.tau-comp config/make.def

default: header
	@ sys/print_instructions

BT-MZ: bt-mz
bt-mz: header
	cd BT-MZ; $(MAKE) CLASS=$(CLASS) NPROCS=$(NPROCS) VERSION=$(VERSION)

SP-MZ: sp-mz
sp-mz: header
	cd SP-MZ; $(MAKE) CLASS=$(CLASS) NPROCS=$(NPROCS)
		       
LU-MZ: lu-mz
lu-mz: header
	cd LU-MZ; $(MAKE) CLASS=$(CLASS) NPROCS=$(NPROCS) VERSION=$(VERSION)

# Awk script courtesy cmg@cray.com
suite:
	@ awk -f sys/suite.awk SMAKE=$(MAKE) $(SFILE) | $(SHELL)


# It would be nice to make clean in each subdirectory (the targets
# are defined) but on a really clean system this will won't work
# because those makefiles need config/make.def
clean:
	- rm -f core
	- rm -f */*opari* */*.mod.*
	- rm -f *~ */core */*~ */*.o */npbparams.h */*.obj */*.exe
	- rm -f sys/setparams sys/makesuite sys/setparams.h

veryclean: clean
#	- rm -f config/make.def config/suite.def Part*
	- rm -f bin/sp-mz.* bin/lu-mz.* bin/bt-mz.*

header:
	@ sys/print_header


