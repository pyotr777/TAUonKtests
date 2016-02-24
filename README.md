# TAU on K tests

Set of sample programs and tools to test TAU installation on K.
There are 4 test programs:
* Fortran
* C MPI
* C++ MPI x2

Test are for TAU native source-based instrumentation, TAU compiler-based instrumentation,
and optionally for TAU instrumentation with Score-P and Score-P native instrumentation.

## Workflow

1. If Makefiles are not ready,  prepare them with makeMakefile.sh.
	! makeMakefile.sh may need editing.
2. After Makefiles for all programs are ready, run makeAll.sh. If you need to test Score-P add targets to makeAll.sh file: tauscorep and scorep.
```
./makeAll.sh clean 
./makeAll.sh 
```
It will produce exe files by number of targets in each program folder.
3. Create jobscripts. If need to test Score-P set scorep variable inside runAll.sh.
```
./runAll.sh clean 
./runAll.sh jobscripts
```
This will remove all jobscripts and profiles/traces, and create new jobscript files.
4. Run test jobs.
```
./runAll.sh run
```
If all goes fine, you will find following directories with files:
profiles, profiles_comp, trace_dir, trace_dir_comp
and optionally with tau_scorep and scorep_sum.
