#!/bin/sh
#PJM -j
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=2x3x2"
#PJM --rsc-list "elapse=00:10:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./ring-comp.exe %r:./"
#PJM --stgout "rank=* ./*.trc ./TAU_comp_traces/"
#PJM --stgout "rank=* ./*.edf ./TAU_comp_traces/"
. /work/system/Env_base
export TAU_PROFILE="0"
export TAU_TRACE="1"
mkdir TAU_comp_traces
pwd
ls -la
env | grep -i tau
mpiexec ./ring-comp.exe
ls -l
