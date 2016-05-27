#!/bin/sh
#PJM -j
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=2x3x2"
#PJM --rsc-list "elapse=00:10:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./bones_mpi-t.exe %r:./"
#PJM --stgout "rank=* ./*.trc ./TAU_native_traces/"
#PJM --stgout "rank=* ./*.edf ./TAU_native_traces/"
. /work/system/Env_base
export TAU_PROFILE="0"
export TAU_TRACE="1"
pwd
ls -la
mpiexec ./bones_mpi-t.exe
ls -l
