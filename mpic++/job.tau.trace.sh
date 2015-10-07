#!/bin/bash
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=4"
#PJM --rsc-list "elapse=00:05:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=* ./ring-t.exe %r:./"
#PJM --stgout "rank=* ./events.* ./trace_dir/"
#PJM --stgout "rank=* ./tautrace.* ./trace_dir/"
. /work/system/Env_base
export TAU_PROFILE="0"
export TAU_TRACE="1"
pwd
ls -la
env | grep -i tau
mpiexec ./ring-t.exe
ls -la tautrace
