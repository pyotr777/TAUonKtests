CC = mpiFCCpx
CFLAGS = -Kfast,parallel
PROG =  ring.exe
CTPROG = ring-comp.exe
SPROG = ring-s.exe
TPROG = ring-t.exe
TSPROG= ring-ts.exe
SRC= ring.cpp
CCS = scorep --user $(CC)
CCT = tau_cxx.sh
TFLAGS="-tau_makefile=$(TAU)/Makefile.tau-mpi-pdt-fujitsu"
SCRFLAGS="-tau_makefile=$(TAU)/Makefile.tau-mpi-pdt-scorep-fujitsu"
TAUCOMPINSTR="-tau_options=-optCompInst"

all: $(PROG)

$(PROG): $(SRC) 
	$(CC) -V $(CFLAGS),optmsg=2 -o $(PROG) $(SRC) 
	
tau: $(TPROG)

$(TPROG): $(SRC)
	$(info TAU native instrumentation)
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
	rm -f *.exe *.o* *.i* *.sh.e* *.sh.i* *.sh.o* *.sh.s* *script.e* *script.i* *script.s* profile* tautrace* events* *.log *file_for_script *.edf *.slog2 *.trc
