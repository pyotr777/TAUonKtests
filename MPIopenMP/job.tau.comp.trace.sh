#!/bin/sh
#PJM -j
#PJM -s
#PJM --rsc-list "node=4"
#PJM --rsc-list "elapse=00:15:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./jacobi-comp.exe %r:./"
#PJM --stgin "rank=* ./indata %r:./"
#PJM --stgout "rank=* ./* ./TAU_comp_traces/"
. /work/system/Env_base
export FLIB_FASTOMP=false
export OMP_NUM_THREADS=4
export TAU_PROFILE="0"
export TAU_TRACE="1"
pwd
ls -la
mpiexec ./jacobi-comp.exe
ls -l
