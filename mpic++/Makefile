CC = mpiFCCpx
CFLAGS = -Kfast,parallel
PROG =  ring.exe
# TAU source based
TPROG = ring-t.exe
# TAU comp. based
CTPROG = ring-comp.exe
# ScoreP only
SPROG = ring-s.exe
# TAU-ScoreP
TSPROG = ring-ts.exe
SRC= ring.cpp
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
