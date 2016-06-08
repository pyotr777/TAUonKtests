#!/bin/sh
#PJM -j
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=2x3x2"
#PJM --rsc-list "elapse=00:10:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./jacobi.exe %r:./"
#PJM --stgout "rank=* ./*.xml ./TAU_sampling_profiles/"
. /work/system/Env_base
export TAU_PROFILE="1"
export TAU_TRACE="0"
export TAU_PROFILE_FORMAT=merged
pwd
. /opt/aics/TAU/env25.sh
env | grep -i tau
mpiexec tau_exec -ebs ./jacobi.exe
