#!/bin/bash
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=4"
#PJM --rsc-list "elapse=00:05:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./ring-ts.exe %r:./"
#PJM --stgout "rank=* ./scorep_sum/*.* ./tau_scorep/"
#PJM --stgout "rank=* ./scorep_sum/tau/*.* ./tau_scorep/tau/"
#PJM --stgout "rank=* ./scorep_sum/traces/*.* ./tau_scorep/traces/"
. /work/system/Env_base
export TAU_PROFILE="1"
export TAU_TRACE="1"
export SCOREP_PROFILING_FORMAT=CUBE4
export SCOREP_ENABLE_TRACING=1
export SCOREP_EXPERIMENT_DIRECTORY=scorep_sum
pwd
ls -la
env | grep -i tau
mpiexec ./ring-ts.exe
ls -la
ls -l scorep_sum
ls -l scorep_sum/tau
ls -l scorep_sum/traces
