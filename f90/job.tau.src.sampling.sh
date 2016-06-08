#!/bin/sh
#PJM -j
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=2x3x2"
#PJM --rsc-list "elapse=00:10:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./ring.exe %r:./"
#PJM --stgout "rank=* ./*.xml ./TAU_sampling_profiles/"
#PJM -s
. /work/system/Env_base
export TAU_PROFILE=1
export TAU_TRACE=0
export TAU_VERBOSE=1
export TAU_PROFILE_FORMAT=merged
pwd
#ls -la
. /opt/aics/TAU/env25.sh
env | grep -i tau
mpiexec tau_exec -ebs ./ring.exe
#ls -l
