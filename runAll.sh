#!/bin/bash
# Execute profiling and tracing jobs on K
# from designated directories
#
# 2015-2016 Bryzgalov Peter @ RIKEN AICS


source ./config.sh

# Set to nonzero to run Score-P instrumented jobs
pause=3

read -rd '' usage << EOF
Execute profiling and tracing jobs on FX10
from designated directories.
(C) 2015 Bryzgalov Peter @ RIKEN AICS

Usage:
runAll.sh jobscripts    - prepare job scripts for all jobs.
runAll.sh clean         - remove all job scripts.
runAll.sh run           - submit all jobs.

directories: $(echo "${directs[*]}")
Score-P is $( if [ -z "$scorep" ];then echo "not "; fi)used.
EOF

if [ "$#" -lt 1 ]
	then
	echo "$usage"
	exit 1
fi

function containsElement {
	local e
	for e in "${@:2}"; do [[ "$e" == "$1" ]] && echo "1"; done
	echo ""
}


if [ "$1" == "jobscripts" ]; then
	# Common part for all jobscripts
	read -rd '' common_part <<-COMEOF
	#!/bin/sh
	#PJM -j
	#PJM --rsc-list "rscgrp=small"
	#PJM --rsc-list "node=2x3x2"
	#PJM --rsc-list "elapse=00:10:00"
	# . /work/system/Env_base
	COMEOF

	for i in $(seq 0 ${#directs})
	do
		#let i=i1-1
		source=${sources[$i]}
		IFS="." read -ra nameparts <<< "$source"
		exe=${nameparts[0]}
		dir=${directs[$i]}
		echo -e "\e[34m$dir/$exe\e[0m"
		cd $dir
		if [[ $(containsElement "tau" "${targets[@]}") ]]; then
			# TAU native Profiling jobs
			echo "TAU"
			read -rd '' tau_profiling <<- TPROFEOF
			export TAU_PROFILE="1"
			export TAU_TRACE="0"
			export PROFILEDIR="TAU_native_profiles"
			mkdir \$PROFILEDIR
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$exe-t.exe
			TPROFEOF
		
			echo -e "$common_part" > job.tau.profile.sh
			echo -e "$tau_profiling" >> job.tau.profile.sh
		

			# TAU native Tracing jobs
			read -rd '' tau_tracing <<- TTRCEOF		
			export TAU_PROFILE="0"
			export TAU_TRACE="1"
			export TRACEDIR="TAU_native_traces"
			mkdir \$TRACEDIR
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$exe-t.exe
			ls -la tautrace
			TTRCEOF
			echo -e "$common_part" > job.tau.trace.sh
			echo -e "$tau_tracing" >> job.tau.trace.sh
		fi

		if [[ $(containsElement "tau-comp" "${targets[@]}") ]]; then
			# TAU compiler-based Profiling jobs
			echo "TAU compiler-based"
			read -rd '' tau_profiling <<- TPROFCOMPEOF
			export TAU_PROFILE="1"
			export TAU_TRACE="0"
			export PROFILEDIR="TAU_comp_profiles"
			mkdir \$PROFILEDIR
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$exe-comp.exe
			TPROFCOMPEOF
			
			echo -e "$common_part" > job.tau.comp.profile.sh
			echo -e "$tau_profiling" >> job.tau.comp.profile.sh
			

			# TAU compiler-based Tracing jobs
			read -rd '' tau_tracing <<- TTRCEOF
			export TAU_PROFILE="0"
			export TAU_TRACE="1"
			export TRACEDIR="TAU_comp_traces"
			mkdir \$TRACEDIR
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$exe-comp.exe
			ls -la tautrace
			TTRCEOF
			
			echo -e "$common_part" > job.tau.comp.trace.sh
			echo -e "$tau_tracing" >> job.tau.comp.trace.sh
		fi
		
		if [[ $(containsElement "tauscorep" "${targets[@]}") ]]; then
			# TAU with Score-P
			echo "TAU+Score-P"
			trace_dir="tau_scorep"
			read -rd '' tau_scorep <<- TSCORPEOF
			export TAU_PROFILE="1"
			export TAU_TRACE="1"
			export TAU_MAKEFILE=\$TAU/Makefile.tau-mpi-pdt-scorep-fujitsu
			export SCOREP_PROFILING_FORMAT=CUBE4
			export SCOREP_ENABLE_TRACING=1
			export SCOREP_EXPERIMENT_DIRECTORY=tau_scorep_sum
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$exe-ts.exe
			ls -la
			ls -l tau_scorep_sum
			ls -l tau_scorep_sum/tau
			ls -l tau_scorep_sum/traces
			TSCORPEOF
			
			echo -e "$common_part" > job.tau-scorep.sh
			echo -e "$tau_scorep" >> job.tau-scorep.sh
		fi

		if [[ $(containsElement "scorep" "${targets[@]}") ]]; then
			# Score-P
			echo "Score-P"
			trace_dir="scorep_sum"
			read -rd '' scorep <<- SCORPEOF
			export TAU_PROFILE=1
			export TAU_TRACE=1
			export SCOREP_PROFILING_FORMAT=CUBE4
			export SCOREP_ENABLE_TRACING=1
			export SCOREP_EXPERIMENT_DIRECTORY=scorep_sum
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$exe-s.exe
			ls -la
			ls -l scorep_sum
			ls -l scorep_sum/tau
			ls -l scorep_sum/traces
			SCORPEOF
			
			echo -e "$common_part" > job.scorep.sh
			echo -e "$scorep" >> job.scorep.sh			
		fi
		cd ..
	done
elif [ "$1" == "clean" ]
	then
	for i in $(seq 0 ${#directs})
	do
		#let i=i1-1
		dir=${directs[$i]}
		cd $dir
		echo -e "\e[34m$dir\e[0m"
		mapfile -t jobfiles <<< "$(ls job.*.sh)"
		for jobfile in "${jobfiles[@]}" 
		do
			echo "$dir/$jobfile"
			rm $jobfile
			rm *profile*
			rm *.sh.e*
			rm *.sh.o*
			rm *.sh.i*
			rm *.sh.s*
			rm -rf *trace*
			rm -rf *profiles*
			rm -rf *scorep*
		done
		cd ..
	done
elif [ "$1" == "run" ]
	then
	for i in $(seq 0 ${#directs})
	do
		#let i=i1-1
		dir=${directs[$i]}
		cd $dir
		mapfile -t jobfiles <<< "$(ls job.*.sh)"
		for jobfile in "${jobfiles[@]}" 
		do
			echo "Run $dir/$jobfile"
			pjsub $jobfile
			sleep $pause
		done
		cd ..
	done
fi

