#!/bin/sh
#PJM -j
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=2x3x2"
#PJM --rsc-list "elapse=00:10:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./bones_mpi-comp.exe %r:./"
#PJM --stgout "rank=* ./*.xml ./TAU_comp_profiles/"
. /work/system/Env_base
export TAU_PROFILE=1
export TAU_TRACE=0
export TAU_PROFILE_FORMAT=merged
pwd
ls -la
mpiexec ./bones_mpi-comp.exe
ls -l
