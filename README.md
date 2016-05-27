# TAU on K tests

Set of sample programs and tools to test TAU installation on K.

Tests are for TAU native source-based instrumentation, TAU compiler-based instrumentation,
and optionally for TAU instrumentation with Score-P and Score-P native instrumentation.

## Workflow

1. Prepare makefiles with targets:
- all - ordinary build
- tau - build with TAU source-based instrumentation
- tau-comp - build with TAU compiler-based instrumentation

 Optionally with:
- scorep - Score-P instrumentation
- tauscorep - TAU + Score-P instrumentation

2. Edit configh.sh to include tests (direcotries) and targets you want to build and test.
E.g. For f90 (ring.f90) and mpic samples with tau and tau-comp targets config.sh should be like this:
```
directs=(f90 mpic)
targets=(clean tau tau-comp)
```
(It is advisable to run clean target to remove old files)


3. Run makeAll
```
./makeAll
```
It will produce exe files by the number of targets in each program folder.

3. Prepare jobscript files. Remove old profiles and traces.

4. Run test jobs.
```
./runAll
```

