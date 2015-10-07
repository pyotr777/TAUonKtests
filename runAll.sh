#!/bin/bash 
# Execute profiling and tracing jobs on K
# from designated directories
# 2015 Bryzgalov Peter @ AICS RIKEN

directs=( f90 mpic mpic++ mpic++bones )
exefiles=( ring mpic ring bones_mpi )
jobfiles=( job.tau.profile.sh job.tau.trace.sh job.tau.comp.profile.sh job.tau.comp.trace.sh  job.tau-scorep.sh job.scorep.sh )

# Set to nonzero to run Score-P instrumented jobs
scorep=""
pause=3

read -rd '' usage << EOF
Execute profiling and tracing jobs on K
from designated directories.
(C) 2015 Bryzgalov Peter @ AICS RIKEN

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


if [ "$1" == "jobscripts" ]
	then

	# Common part for all jobscripts
	read -rd '' common_part <<-COMEOF
	#!/bin/bash
	#PJM --rsc-list "rscgrp=small"
	#PJM --rsc-list "node=4"
	#PJM --rsc-list "elapse=00:05:00"
	#PJM --stg-transfiles all
	#PJM --mpi "use-rankdir"
	COMEOF

	for i in $(seq 0 ${#directs})
	do
		#let i=i1-1
		exe=${exefiles[$i]}
		dir=${directs[$i]}
		echo -e "\e[34m$dir\e[0m"
		cd $dir
		# TAU native Profiling jobs		
		read -rd '' tau_profiling <<- TPROFEOF
		#PJM --stgin "rank=* ./$exe-t.exe %r:./"
		#PJM --stgout "rank=* ./profile.* ./profiles/"
		. /work/system/Env_base
		export TAU_PROFILE="1"
		export TAU_TRACE="0"
		pwd
		ls -la
		env | grep -i tau
		mpiexec ./$exe-t.exe
		TPROFEOF
		
		echo -e "$common_part" > job.tau.profile.sh
		echo -e "$tau_profiling" >> job.tau.profile.sh
		

		# TAU native Tracing jobs
		read -rd '' tau_tracing <<- TTRCEOF
		#PJM --stgin "rank=* ./$exe-t.exe %r:./"
		#PJM --stgout "rank=* ./events.* ./trace_dir/"
		#PJM --stgout "rank=* ./tautrace.* ./trace_dir/"
		. /work/system/Env_base
		export TAU_PROFILE="0"
		export TAU_TRACE="1"
		pwd
		ls -la
		env | grep -i tau
		mpiexec ./$exe-t.exe
		ls -la tautrace
		TTRCEOF
		
		echo -e "$common_part" > job.tau.trace.sh
		echo -e "$tau_tracing" >> job.tau.trace.sh
		



		# TAU compiler-based Profiling jobs		
		read -rd '' tau_profiling <<- TPROFCOMPEOF
		#PJM --stgin "rank=* ./$exe-comp.exe %r:./"
		#PJM --stgout "rank=* ./profile.* ./profiles_comp/"
		. /work/system/Env_base
		export TAU_PROFILE="1"
		export TAU_TRACE="0"
		pwd
		ls -la
		env | grep -i tau
		mpiexec ./$exe-comp.exe
		TPROFCOMPEOF
		
		echo -e "$common_part" > job.tau.comp.profile.sh
		echo -e "$tau_profiling" >> job.tau.comp.profile.sh
		

		# TAU compiler-based Tracing jobs
		read -rd '' tau_tracing <<- TTRCEOF
		#PJM --stgin "rank=* ./$exe-comp.exe %r:./"
		#PJM --stgout "rank=* ./events.* ./trace_dir_comp/"
		#PJM --stgout "rank=* ./tautrace.* ./trace_dir_comp/"
		. /work/system/Env_base
		export TAU_PROFILE="0"
		export TAU_TRACE="1"
		pwd
		ls -la
		env | grep -i tau
		mpiexec ./$exe-comp.exe
		ls -la tautrace
		TTRCEOF
		
		echo -e "$common_part" > job.tau.comp.trace.sh
		echo -e "$tau_tracing" >> job.tau.comp.trace.sh
		

		if [ -n "$scorep" ]; then
			# TAU with Score-P
			trace_dir="tau_scorep"
			read -rd '' tau_scorep <<- TSCORPEOF
			#PJM --stgin "rank=* ./$exe-ts.exe %r:./"
			#PJM --stgout "rank=* ./scorep_sum/*.* ./$trace_dir/"
			#PJM --stgout "rank=* ./scorep_sum/tau/*.* ./$trace_dir/tau/"
			#PJM --stgout "rank=* ./scorep_sum/traces/*.* ./$trace_dir/traces/"
			. /work/system/Env_base
			export TAU_PROFILE="1"
			export TAU_TRACE="1"
			export SCOREP_PROFILING_FORMAT=CUBE4
			export SCOREP_ENABLE_TRACING=1
			export SCOREP_EXPERIMENT_DIRECTORY=scorep_sum
			pwd
			ls -la
			env | grep -i tau
			mpiexec ./$exe-ts.exe
			ls -la
			ls -l scorep_sum
			ls -l scorep_sum/tau
			ls -l scorep_sum/traces
			TSCORPEOF
			
			echo -e "$common_part" > job.tau-scorep.sh
			echo -e "$tau_scorep" >> job.tau-scorep.sh
			


			# Score-P
			trace_dir="scorep_sum"
			read -rd '' scorep <<- SCORPEOF
			#PJM --stgin "rank=* ./$exe-s.exe %r:./"
			#PJM --stgout "rank=* ./scorep_sum/*.* ./$trace_dir/"
			#PJM --stgout "rank=* ./scorep_sum/tau/*.* ./$trace_dir/tau/"
			#PJM --stgout "rank=* ./scorep_sum/traces/*.* ./$trace_dir/traces/"
			. /work/system/Env_base
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
		for jobfile in "${jobfiles[@]}" 
		do
			echo "$dir/$jobfile"
			rm $jobfile
			rm *profile*
			rm *.sh.e*
			rm *.sh.o*
			rm *.sh.i*
			rm *.sh.s*
			rm -rf trace_dir*
			rm -rf profiles*
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
		for jobfile in "${jobfiles[@]}" 
		do
			if [[ "$jobfile" == *"scorep"* ]]
				then
				if [ -n "$scorep" ]; then
					echo "Run $dir/$jobfile"
					pjsub $jobfile
					sleep $pause				
				fi
			else
				echo "Run $dir/$jobfile"
				pjsub $jobfile
				sleep $pause			
			fi
		done
		cd ..
	done
fi

