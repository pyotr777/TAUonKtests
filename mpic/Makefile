CC = mpifccpx
CFLAGS = -Kfast,parallel
PROG =  mpic.exe
SPROG = mpic-s.exe
TPROG = mpic-t.exe
TSPROG= mpic-ts.exe
SRC= C_MPI.c
CCS = scorep --user $(CC)
CCT = tau_cc.sh
TFLAGS="-tau_makefile=$(TAU)/Makefile.tau-mpi-pdt-fujitsu"
SCRFLAGS="-tau_makefile=$(TAU)/Makefile.tau-mpi-pdt-scorep-fujitsu"

all: $(PROG)

$(PROG): $(SRC) 
	$(CC) -V $(CFLAGS),optmsg=2 -o $(PROG) $(SRC) 
	
tau: $(TPROG)

$(TPROG): $(SRC)
	$(info TAU native instrumentation)
	$(CCT) $(TFLAGS) $(SRC) -o $(TPROG)

tauscorep: $(TSPROG)

$(TSPROG) : $(SRC)
	$(info Instrumenting with TAU + ScoreP)
	$(CCT) $(SCRFLAGS) $(SRC) -o $(TSPROG) 

scorep: $(SPROG)
	
$(SPROG) : $(SRC)
	$(info Instrumenting for Score-P)
	$(CCS) $(SRC) -o $(SPROG)
	
clean: 
	rm -f *.exe *.o* *.i* *.sh.e* *.sh.i* *.sh.o* *.sh.s* *script.e* *script.i* *script.s* profile* tautrace* events* *.log *file_for_script *.edf *.slog2 *.trc
