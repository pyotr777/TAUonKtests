CC = mpifccpx
CFLAGS = -Kfast,parallel
PROG =  C_MPI.exe
# TAU source based
TPROG = C_MPI-t.exe
# TAU comp. based
CTPROG = C_MPI-comp.exe
# ScoreP only
SPROG = C_MPI-s.exe
# TAU-ScoreP
TSPROG = C_MPI-ts.exe
SRC= C_MPI.c
CCS = scorep --user $(CC)
CCT = tau_cc.sh
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
	rm -rf *.exe *.o* *.i* *.sh.e* *.sh.i* *.sh.o* *.sh.s* *script.e* *script.i* *script.s* profile* trace* events* *.log *file_for_script *.edf *.slog2 *.trc 
