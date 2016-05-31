#!/bin/sh
#PJM -j
#PJM -s
#PJM --rsc-list "node=4"
#PJM --rsc-list "elapse=00:15:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./jacobi-comp.exe %r:./"
#PJM --stgin "rank=* ./indata %r:./"
#PJM --stgout "rank=* ./*.xml ./TAU_comp_profiles/"
. /work/system/Env_base
export FLIB_FASTOMP=false
export OMP_NUM_THREADS=4
export TAU_PROFILE=1
export TAU_TRACE=0
export TAU_PROFILE_FORMAT=merged
pwd
ls -la
mpiexec ./jacobi-comp.exe
ls -l
