#!/bin/bash
# Make Makefile from template. 
# Optional are 2 parameters:
# 1. Program type: mpic/mpic++/mpif
# 2. Source file
#
# 2015-2016 Bryzgalov Peter @ RIKEN AICS

usage="Usage: makeMakefile.sh [<mpic/mpic++/mpif> <source file name>]"

source ./config.sh


if [ "$#" -gt 2 ]
then
	echo $usage
	exit 1
fi

function make_one_makefile {
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

	IFS="." read -ra nameparts <<< "$2"
	# echo "Parts: ${nameparts[0]} : ${nameparts[1]}"
	namebase=${nameparts[0]}

read -r -d '' file << EOF
CC = $c
CFLAGS = -Kfast,parallel
PROG =  $namebase.exe
# TAU source based
TPROG = $namebase-t.exe
# TAU comp. based
CTPROG = $namebase-comp.exe
# ScoreP only
SPROG = $namebase-s.exe
# TAU-ScoreP
TSPROG = $namebase-ts.exe
SRC= $2
CCS = scorep --user \$(CC)
CCT = $tc
#TFLAGS="-tau_makefile=\$(TAU)/Makefile.tau-mpi-pdt-fujitsu"
TAUCOMPINSTR="-tau_options=-optCompInst"
#SCRFLAGS="-tau_makefile=\$(TAU)/Makefile.tau-mpi-pdt-scorep-fujitsu"

all: \$(PROG)

\$(PROG): \$(SRC) 
	\$(CC) -V \$(CFLAGS),optmsg=2 -o \$(PROG) \$(SRC) 
	
tau: \$(TPROG)

\$(TPROG): \$(SRC)
	\$(info TAU native source-based instrumentation)
	\$(CCT) \$(TFLAGS) \$(SRC) -o \$(TPROG)

tau-comp: \$(CTPROG)

\$(CTPROG): \$(SRC)
	\$(info TAU compiler-based instrumentation)
	\$(CCT) \$(TAUCOMPINSTR) \$(TFLAGS) \$(SRC) -o \$(CTPROG)


tauscorep: \$(TSPROG)

\$(TSPROG): \$(SRC)
	\$(info Instrumenting with TAU + ScoreP)
	\$(CCT) \$(SCRFLAGS) \$(SRC) -o \$(TSPROG)

scorep: \$(SPROG)

\$(SPROG): \$(SRC)
	\$(info Instrumenting for Score-P)
	\$(CCS) \$(SRC) -o \$(SPROG)

	
clean: 
	rm -rf *.exe *.o* *.i* *.sh.e* *.sh.i* *.sh.o* *.sh.s* *script.e* *script.i* *script.s* *profile* *trace* events* *.log *file_for_script *.edf *.slog2 *.trc job*.*
EOF

	# echo"$file"
	echo "$file" > Makefile
	echo "Created Makefile for $1 source:$2 target:$namebase"
}

if [[ -n "$1" ]]; then
	if [ "$#" -lt 2 ]
	then
		echo $usage
		exit 1
	fi
	echo "Make makefile for $1 and $2"
	make_one_makefile $1 $2
fi
i=0
for direct in ${directs[@]}; do
    #echo "Proceed to $direct"
	source=${sources[$i]}
	lang=${langs[$i]}
    echo "$i $direct $source $lang"
	make_one_makefile $lang $source
	mv Makefile $direct/
    ((i++))
done
