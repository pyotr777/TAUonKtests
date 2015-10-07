#!/bin/bash
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=4"
#PJM --rsc-list "elapse=00:05:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./ring-t.exe %r:./"
#PJM --stgout "rank=* ./profile.* ./"
. /work/system/Env_base
export TAU_PROFILE="1"
export TAU_TRACE="0"
pwd
ls -la
env | grep -i tau
mpiexec ./ring-t.exe
