directs=(f90 mpic mpic++ mpic++bones MPIopenMP)
langs=(mpif mpic mpic++ mpic++ mpif)
sources=(ring.f90 C_MPI.c ring.cpp bones_mpi.cpp jacobi.f90)
# Possible targets: clean tau tau-comp tauscorep scorep 
targets=(clean tau tau-comp)
