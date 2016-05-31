CC = mpiFCCpx
CFLAGS = -Kfast,parallel
PROG =  bones_mpi.exe
# TAU source based
TPROG = bones_mpi-t.exe
# TAU comp. based
CTPROG = bones_mpi-comp.exe
# ScoreP only
SPROG = bones_mpi-s.exe
# TAU-ScoreP
TSPROG = bones_mpi-ts.exe
SRC= bones_mpi.cpp
CCS = scorep --user $(CC)
CCT = tau_cxx.sh
#TFLAGS="-tau_makefile=$(TAU)/Makefile.tau-mpi-pdt-fujitsu"
TAUCOMPINSTR="-tau_options=-optCompInst"
#SCRFLAGS="-tau_makefile=$(TAU)/Makefile.tau-mpi-pdt-scorep-fujitsu"

all: $(PROG)

$(PROG): $(SRC) 
	$(CC) -V $(CFLAGS),optmsg=2 -o $(PROG) $(SRC) 
	
tau: $(TPROG)

$(TPROG): $(SRC)
	$(info TAU native source-based instrumentation)
	$(CCT) $(TFLAGS) $(SRC) -o $(TPROG)

tau-comp: $(CTPROG)

$(CTPROG): $(SRC)
	$(info TAU compiler-based instrumentation)
	$(CCT) $(TAUCOMPINSTR) $(TFLAGS) $(SRC) -o $(CTPROG)


tauscorep: $(TSPROG)

$(TSPROG): $(SRC)
	$(info Instrumenting with TAU + ScoreP)
	$(CCT) $(SCRFLAGS) $(SRC) -o $(TSPROG)

scorep: $(SPROG)

$(SPROG): $(SRC)
	$(info Instrumenting for Score-P)
	$(CCS) $(SRC) -o $(SPROG)

	
clean: 
	rm *.sh.e* *.sh.i* *.sh.o* *.sh.s* profile* trace* events* *.log *.o *.edf *.slog2 *.trc


cleanall: 
	rm *.exe *.o* *.i* *.sh.e* *.sh.i* *.sh.o* *.sh.s* *script.e* *script.i* *script.s* profile* tautrace* events* *.log *file_for_script *.edf *.slog2 *.trc 
