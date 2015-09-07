#!/bin/bash
# Execute profiling and tracing jobs on K
# from designated directories
# 2015 Bryzgalov Peter @ AICS RIKEN

directs=( f90 mpic mpic++ )
exefiles=( ring mpic ring )
jobfiles=( job.tau.profile.sh job.tau.trace.sh job.tau-scorep.sh job.scorep.sh )

read -rd '' usage << EOF
Execute profiling and tracing jobs on K
from designated directories.
(C) 2015 Bryzgalov Peter @ AICS RIKEN

Usage:
runAll.sh jobscripts    - prepare job scripts for all jobs.
runAll.sh clean         - remove all job scripts.
runAll.sh run           - submit all jobs.

directories: $(echo "${directs[*]}")
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
	#PJM --rsc-list "node=2x3x2"
	#PJM --rsc-list "elapse=00:05:00"
	#PJM --stg-transfiles all
	#PJM --mpi "use-rankdir"
	COMEOF

	for i1 in $(seq 1 ${#directs})
	do
		let i=i1-1
		exe=${exefiles[$i]}
		dir=${directs[$i]}

		# TAU native Profiling jobs		
		read -rd '' tau_profiling <<- TPROFEOF
		#PJM --stgin "rank=* ./$exe-t.exe %r:./"
		#PJM --stgout "rank=* ./profile.* ./"
		. /work/system/Env_base
		export TAU_PROFILE="1"
		export TAU_TRACE="0"
		pwd
		ls -la
		env | grep -i tau
		mpiexec ./$exe-t.exe
		TPROFEOF
		cd $dir
		echo -e "$common_part" > job.tau.profile.sh
		echo -e "$tau_profiling" >> job.tau.profile.sh
		cd ..

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
		cd $dir
		echo -e "$common_part" > job.tau.trace.sh
		echo -e "$tau_tracing" >> job.tau.trace.sh
		cd ..

		
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
		cd $dir
		echo -e "$common_part" > job.tau-scorep.sh
		echo -e "$tau_scorep" >> job.tau-scorep.sh
		cd ..


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
		cd $dir
		echo -e "$common_part" > job.scorep.sh
		echo -e "$scorep" >> job.scorep.sh
		cd ..

	done
elif [ "$1" == "clean" ]
	then
	for i1 in $(seq 1 ${#directs})
	do
		let i=i1-1
		dir=${directs[$i]}
		for jobfile in "${jobfiles[@]}" 
		do
			cd $dir
			echo "$dir/$jobfile"
			rm $jobfile
			cd ..
		done
	done
fi

