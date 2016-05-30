#!/bin/sh
### submit from ./bin directory with "pjsub run.sh"
#PJM -j
#PJM --mpi proc=8
#PJM --rsc-list node=4
#PJM --rsc-list elapse=10:0
#PJM --rsc-list rscgrp=small
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./bt-mz_B.8 %r:./"
#PJM --stgout "rank=* %r:./*.* ./"
source /work/system/Env_base

# benchmark configuration
CLASS=B
NPROCS=8

EXE=./bt-mz_${CLASS}.${NPROCS}

export FLIB_FASTOMP=false
export OMP_NUM_THREADS=4
export NPB_MZ_BLOAD=0 # disable load balancing with dynamic threads

set -x

export TAU_VERBOSE=1
export TAU_PROFILE=1
export TAU_TRACE=0
export TAU_PROFILE_FORMAT=merged

mpiexec -np $NPROCS $EXE
ls -l
