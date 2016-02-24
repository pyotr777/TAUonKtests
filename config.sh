directs=( f90 mpic mpic++ mpic++bones )
langs=( mpif mpic mpic++ mpic++ )
sources=( ring.f90 C_MPI.c ring.cpp bones_mpi.cpp )
# Possible targets: clean tau tau-com tauscorep scorep 
targets=( clean tau tauscorep scorep )