#!/bin/bash
# Make Makefile from template. 
# Use 3 parameters:
# 1. Program type: mpic/mpic++/mpif
# 2. Source file
# 3. Output file

usage="Usage: makeMakefile.sh <mpic/mpic++/mpif> <source file> <output file>"

if [ "$#" -lt 3 ]
then
    echo $usage
    exit 1
fi

c=""
tc=""
case "$1" in
    mpic)
        c="mpifccpx"
        tc="tau_cc.sh"
        ;;
    mpic++)
        c="mpiFCCpx"
        tc="tau_cxx.sh"
        ;;
    mpif)
        c="mpifrtpx"
        tc="tau_f90.sh"
        ;;
    *)
        echo "1st parameter must be one of mpic/mpic++/mpif. Got $1"
        exit 1
        ;;    
esac
        

IFS="." read -ra nameparts <<< "$3"
# echo "Parts: ${nameparts[0]} : ${nameparts[1]}"
namebase=${nameparts[0]}

read -r -d '' file << EOF
CC = $c
CFLAGS = -Kfast,parallel
PROG =  $namebase.exe
SPROG = $namebase-s.exe
TPROG = $namebase-t.exe
TSPROG= $namebase-ts.exe
SRC= $2
CCS = scorep --user \$(CC)
CCT = $tc
TFLAGS="-tau_makefile=\$(TAU)/Makefile.tau-mpi-pdt-fujitsu"
SCRFLAGS="-tau_makefile=\$(TAU)/Makefile.tau-mpi-pdt-scorep-fujitsu"

all: \$(PROG)

\$(PROG): \$(SRC) 
	\$(CC) -V \$(CFLAGS),optmsg=2 -o \$(PROG) \$(SRC) 
	
tau: \$(TPROG)

\$(TPROG): \$(SRC)
	\$(info TAU native instrumentation)
	\$(CCT) \$(TFLAGS) \$(SRC) -o \$(TPROG)

tauscorep: \$(TSPROG)

\$(TSPROG): \$(SRC)
	\$(info Instrumenting with TAU + ScoreP)
	\$(CCT) \$(SCRFLAGS) \$(SRC) -o \$(TSPROG) 

scorep: \$(SPROG)
	
\$(SPROG): \$(SRC)
	\$(info Instrumenting for Score-P)
	\$(CCS) \$(SRC) -o \$(SPROG)
	
clean: 
	rm -f *.exe *.o* *.i* *.sh.e* *.sh.i* *.sh.o* *.sh.s* *script.e* *script.i* *script.s* profile* tautrace* events* *.log *file_for_script *.edf *.slog2 *.trc
EOF

# echo"$file"
echo "$file" > Makefile
