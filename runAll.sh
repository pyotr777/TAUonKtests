#!/bin/bash
# Execute profiling and tracing jobs on K
# from designated directories
#
# 2015-2016 Bryzgalov Peter @ RIKEN AICS


source ./config.sh

# Set to nonzero to run Score-P instrumented jobs
pause=15

read -rd '' usage << EOF
Execute profiling and tracing jobs on FX10
from designated directories.
(C) 2015-2016 Bryzgalov Peter @ RIKEN AICS

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
	#PJM --stg-transfiles all
	#PJM --mpi "use-rankdir"
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
			#PJM --stgin "rank=* ./$exe-t.exe %r:./"
			#PJM --stgout "rank=* ./profile* ./TAU_native_profiles/"
	        . /work/system/Env_base
			export TAU_PROFILE="1"
			export TAU_TRACE="0"
			export PROFILEDIR=""
            mkdir TAU_native_profiles
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$exe-t.exe
            ls -l
			TPROFEOF
		
			echo -e "$common_part" > job.tau.profile.sh
			echo -e "$tau_profiling" >> job.tau.profile.sh
		

			# TAU native Tracing jobs
			read -rd '' tau_tracing <<- TTRCEOF		
			#PJM --stgin "rank=* ./$exe-t.exe %r:./"
			#PJM --stgout "rank=* ./*.trc ./TAU_native_traces/"
			#PJM --stgout "rank=* ./*.edf ./TAU_native_traces/"
			. /work/system/Env_base
            export TAU_PROFILE="0"
			export TAU_TRACE="1"
			export TRACEDIR=""
            mkdir TAU_native_traces
			pwd
			ls -la
			mpiexec ./$exe-t.exe
			ls -l
			TTRCEOF
			echo -e "$common_part" > job.tau.trace.sh
			echo -e "$tau_tracing" >> job.tau.trace.sh
		fi

		if [[ $(containsElement "tau-comp" "${targets[@]}") ]]; then
			# TAU compiler-based Profiling jobs
			echo "TAU compiler-based"
			read -rd '' tau_profiling <<- TPROFCOMPEOF
			#PJM --stgin "rank=* ./$exe-comp.exe %r:./"
			#PJM --stgout "rank=* ./profile* ./TAU_comp_profiles"
			. /work/system/Env_base
            export TAU_PROFILE="1"
			export TAU_TRACE="0"
			export PROFILEDIR=""
            mkdir TAU_comp_profiles
			pwd
			ls -la
			mpiexec ./$exe-comp.exe
            ls -l
			TPROFCOMPEOF
			
			echo -e "$common_part" > job.tau.comp.profile.sh
			echo -e "$tau_profiling" >> job.tau.comp.profile.sh
			

			# TAU compiler-based Tracing jobs
            job_exe="$exe-comp.exe"
            job_dir="TAU_comp_traces"
			read -rd '' tau_tracing <<- TTRCEOF
			#PJM --stgin "rank=* ./$job_exe %r:./"
			#PJM --stgout "rank=* ./*.trc ./$job_dir/"
			#PJM --stgout "rank=* ./*.edf ./$job_dir/"
			. /work/system/Env_base
			export TAU_PROFILE="0"
			export TAU_TRACE="1"
			export TRACEDIR=""
            mkdir $job_dir
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$exe-comp.exe
			ls -l
			TTRCEOF
			
			echo -e "$common_part" > job.tau.comp.trace.sh
			echo -e "$tau_tracing" >> job.tau.comp.trace.sh
		fi
		
		if [[ $(containsElement "tauscorep" "${targets[@]}") ]]; then
			# TAU with Score-P
			echo "TAU+Score-P"
            job_exe="$exe-ts.exe"
            job_dir="tau_scorep"
			read -rd '' tau_scorep <<- TSCORPEOF
			#PJM --stgin "rank=* ./$job_exe %r:./"
			#PJM --stgout-dir "rank=* ./$job_dir ./$job_dir recursive=2"
			. /work/system/Env_base
			export TAU_PROFILE="1"
			export TAU_TRACE="1"
			export TAU_MAKEFILE=\$TAU/Makefile.tau-mpi-pdt-scorep-fujitsu
			export SCOREP_PROFILING_FORMAT=CUBE4
			export SCOREP_ENABLE_TRACING=1
			export SCOREP_EXPERIMENT_DIRECTORY="$job_dir"
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$job_exe
			ls -la
			ls -l $job_dir
			ls -l $job_dir/tau
			ls -l $job_dir/traces
			TSCORPEOF
			
			echo -e "$common_part" > job.tau-scorep.sh
			echo -e "$tau_scorep" >> job.tau-scorep.sh
		fi

		if [[ $(containsElement "scorep" "${targets[@]}") ]]; then
			# Score-P
			echo "Score-P"
			job_dir="scorep"
			job_exe="$exe-s.exe"
            read -rd '' scorep <<- SCORPEOF
			#PJM --stgin "rank=* ./$job_exe %r:./"
			#PJM --stgout-dir "rank=* ./$job_dir ./$job_dir recursive=2"
			. /work/system/Env_base
			export TAU_PROFILE=1
			export TAU_TRACE=1
			export SCOREP_PROFILING_FORMAT=CUBE4
			export SCOREP_ENABLE_TRACING=1
			export SCOREP_EXPERIMENT_DIRECTORY="$job_dir"
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$job_exe
			ls -la
			ls -l $job_dir
			ls -l $job_dir/tau
			ls -l $jib_dir/traces
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

