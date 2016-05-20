#!/bin/sh
### submit with "pjsub run.sh"
#PJM -s
#PJM -j
#PJM --mpi proc=8
#PJM --rsc-list node=2
#PJM --rsc-list elapse=10:0
#PJM --rsc-list rscgrp=small
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./a.out %r:./"
#PJM --stgout "rank=* %r:./*.* ./"
source /work/system/Env_base
export FLIB_FASTOMP=false
export OMP_NUM_THREADS=4

mpiexec -np 8 ./a.out
ls -l
