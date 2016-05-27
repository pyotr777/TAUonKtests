
program jacobi_mpiomp

    ! Solve [(d/dx)2 + (d/dy)2] u(x,y) = f(x,y) for u(x,y) in a rectangular
    ! domain: 0 < x < 1 and 0 < y < 1.

    implicit none
    include 'mpif.h'
      include 'jacobi.f90.opari.inc'
    real, allocatable :: u(:,:), unew(:,:), f(:,:)
    integer :: ngrid         ! number of grid cells along each axis
    integer :: n             ! number of cells: n = ngrid - 1
    integer :: maxiter       ! max number of Jacobi iterations
    real    :: tol           ! convergence tolerance threshold
    real    :: omega         ! relaxation parameter
    integer i, j, k
    real    h, utmp, diffnorm
    integer np, myid
    integer js, je, js1, je1
    integer nbr_down, nbr_up, status(mpi_status_size), ierr

    call mpi_init(ierr)
    call mpi_comm_size(mpi_comm_world,np,ierr)
    call mpi_comm_rank(mpi_comm_world,myid,ierr)

    nbr_down = mpi_proc_null
    nbr_up   = mpi_proc_null
    if (myid >      0) nbr_down = myid - 1
    if (myid < np - 1) nbr_up   = myid + 1

    ! Read in problem and solver parameters.

    call read_params(ngrid,maxiter,tol,omega)

    n = ngrid - 1

    ! j-loop start and ending indices

    call get_indices(js,je,js1,je1,n)

    ! Allocate memory for arrays.

    allocate(u(0:n,js-1:je+1), unew(0:n,js-1:je+1), f(0:n,js:je))

    ! Initialize f, u(0,*), u(n:*), u(*,0), and u(*,n).

    call init_fields(u,f,n,js,je)

    ! Main solver loop.

    h = 1.0 / n

    do k=1,maxiter
        call mpi_sendrecv(u(1,js  ),n-1,mpi_real,nbr_down,2*k-1, &
            u(1,je+1),n-1,mpi_real,nbr_up  ,2*k-1, &
            mpi_comm_world,status,ierr)
        call mpi_sendrecv(u(1,je  ),n-1,mpi_real,nbr_up  ,2*k, &
            u(1,js-1),n-1,mpi_real,nbr_down,2*k, &
            mpi_comm_world,status,ierr)

      pomp2_num_threads = pomp2_lib_get_max_threads()
      pomp2_if = .true.
      call POMP2_Parallel_fork(pomp2_region_1,&
      pomp2_if, pomp2_num_threads, pomp2_old_task, &
      pomp2_ctc_1 )
        !$omp parallel    private(utmp) &
  !$omp firstprivate(pomp2_old_task) private(pomp2_new_task) &
  !$omp if(pomp2_if) num_threads(pomp2_num_threads)
      call POMP2_Parallel_begin(pomp2_region_1)
      call POMP2_Do_enter(pomp2_region_1, &
     pomp2_ctc_1 )
        !$omp          do              
        do j=js1,je1
            do i=1,n-1
                utmp = 0.25 * ( u(i+1,j) + u(i-1,j) &
                    + u(i,j+1) + u(i,j-1) &
                    - h * h * f(i,j) )
                unew(i,j) = omega * utmp + (1. - omega) * u(i,j)
            enddo
        enddo
!$omp end do nowait
      call POMP2_Implicit_barrier_enter(pomp2_region_1,&
      pomp2_old_task)
!$omp barrier
      call POMP2_Implicit_barrier_exit(pomp2_region_1, pomp2_old_task)
      call POMP2_Do_exit(pomp2_region_1)
      call POMP2_Parallel_end(pomp2_region_1)
!$omp end parallel
      call POMP2_Parallel_join(pomp2_region_1, pomp2_old_task)

        call set_bc(unew,n,js,je)

        !   Compute the difference between unew and u.

        call compute_diff(u,unew,n,js,je,diffnorm)

        if (myid == 0) print *, k, diffnorm

        !   Make the new value the old value for the next iteration.

      pomp2_num_threads = pomp2_lib_get_max_threads()
      pomp2_if = .true.
      call POMP2_Parallel_fork(pomp2_region_2,&
      pomp2_if, pomp2_num_threads, pomp2_old_task, &
      pomp2_ctc_2 )
        !$omp parallel    &
  !$omp firstprivate(pomp2_old_task) private(pomp2_new_task) &
  !$omp if(pomp2_if) num_threads(pomp2_num_threads)
      call POMP2_Parallel_begin(pomp2_region_2)
      call POMP2_Do_enter(pomp2_region_2, &
     pomp2_ctc_2 )
        !$omp          do
        do j=js-1,je+1
            u(:,j) = unew(:,j)
        end do
!$omp end do nowait
      call POMP2_Implicit_barrier_enter(pomp2_region_2,&
      pomp2_old_task)
!$omp barrier
      call POMP2_Implicit_barrier_exit(pomp2_region_2, pomp2_old_task)
      call POMP2_Do_exit(pomp2_region_2)
      call POMP2_Parallel_end(pomp2_region_2)
!$omp end parallel
      call POMP2_Parallel_join(pomp2_region_2, pomp2_old_task)

        !   Check for convergence of unew to u. If converged, exit the loop.

        if (diffnorm <= tol) exit
    enddo

    deallocate(u, unew, f)

    call mpi_finalize(ierr)

end program

!----------------------------------------------------------------------

subroutine read_params(ngrid,maxiter,tol,omega)

    implicit none
  include 'mpif.h'
      include 'jacobi.f90.opari.inc'
    integer ngrid, maxiter
    real    tol, omega
    namelist /params/ ngrid, maxiter, tol, omega
    integer np, myid, i
    integer ierr

    call mpi_comm_size(mpi_comm_world,np,ierr)
    call mpi_comm_rank(mpi_comm_world,myid,ierr)

    if (myid == 0) then
        !   Default values

        ngrid   = 10000
        maxiter = 1000
        tol     = 1.e-3
        omega   = 0.75

    !   open(10,file='indata')
    !   read(10,nml=params)
    !   close(10)
    endif

    call mpi_bcast(ngrid,1,mpi_integer,0,mpi_comm_world,ierr)
    call mpi_bcast(maxiter,1,mpi_integer,0,mpi_comm_world,ierr)
    call mpi_bcast(tol,1,mpi_real,0,mpi_comm_world,ierr)
    call mpi_bcast(omega,1,mpi_real,0,mpi_comm_world,ierr)

    if (mod(ngrid,np) /= 0) then  ! For a simple example code
        write(0,*) 'ERROR: ngrid must be divisible by the number of images'
        call mpi_abort(mpi_comm_world,1,ierr)
    endif
    if ((ngrid)/np < 1) then
        write(0,*) 'ERROR: local grid size should be greater than 0'
        call mpi_abort(mpi_comm_world,1,ierr)
    endif
end subroutine read_params

!----------------------------------------------------------------------

subroutine get_indices(js,je,js1,je1,n)
    implicit none
  include 'mpif.h'
      include 'jacobi.f90.opari.inc'
    integer js, je, js1, je1, n
    integer np, myid
    integer ierr

    call mpi_comm_size(mpi_comm_world,np,ierr)
    call mpi_comm_rank(mpi_comm_world,myid,ierr)

    js = 0
    je = ((n + 1) / np) - 1

    js1 = js
    if (myid ==      0) js1 = 1
    je1 = je
    if (myid == np - 1) je1 = je - 1

end subroutine get_indices

!----------------------------------------------------------------------

subroutine init_fields(u,f,n,js,je)

    implicit none
      include 'jacobi.f90.opari.inc'
    integer n, js, je
    real    u(0:n,js-1:je+1), f(0:n,js:je)
    integer j

    ! RHS term:

      pomp2_num_threads = pomp2_lib_get_max_threads()
      pomp2_if = .true.
      call POMP2_Parallel_fork(pomp2_region_3,&
      pomp2_if, pomp2_num_threads, pomp2_old_task, &
      pomp2_ctc_3 )
    !$omp parallel &
  !$omp firstprivate(pomp2_old_task) private(pomp2_new_task) &
  !$omp if(pomp2_if) num_threads(pomp2_num_threads)
      call POMP2_Parallel_begin(pomp2_region_3)
      call POMP2_Do_enter(pomp2_region_4, &
     pomp2_ctc_4 )
    !$omp do
    do j=js,je
        f(:,j) = 4.
    end do
    !$omp end do nowait
      call POMP2_Do_exit(pomp2_region_4)

    ! Initial guess:

      call POMP2_Do_enter(pomp2_region_5, &
     pomp2_ctc_5 )
    !$omp do
    do j=js-1,je+1
        u(:,j) = 0.5
    end do
    !$omp end do nowait
      call POMP2_Do_exit(pomp2_region_5)
      call POMP2_Implicit_barrier_enter(pomp2_region_3,&
      pomp2_old_task)
!$omp barrier
      call POMP2_Implicit_barrier_exit(pomp2_region_3, pomp2_old_task)
      call POMP2_Parallel_end(pomp2_region_3)
    !$omp end parallel
      call POMP2_Parallel_join(pomp2_region_3, pomp2_old_task)

    ! Apply the boundary conditions.

    call set_bc(u,n,js,je)

end subroutine init_fields

!----------------------------------------------------------------------

subroutine set_bc(u,n,js,je)

    implicit none
  include 'mpif.h'
      include 'jacobi.f90.opari.inc'
    integer n, js, je
    real    u(0:n,js-1:je+1)
    integer i, j, joff, np, myid
    real    h
    integer ierr

    call mpi_comm_size(mpi_comm_world,np,ierr)
    call mpi_comm_rank(mpi_comm_world,myid,ierr)

    joff = myid * ((n + 1) / np)     ! j-index offset

    h = 1.0 / n

    if (myid == 0) then
      pomp2_num_threads = pomp2_lib_get_max_threads()
      pomp2_if = .true.
      call POMP2_Parallel_fork(pomp2_region_6,&
      pomp2_if, pomp2_num_threads, pomp2_old_task, &
      pomp2_ctc_6 )
        !$omp parallel    &
  !$omp firstprivate(pomp2_old_task) private(pomp2_new_task) &
  !$omp if(pomp2_if) num_threads(pomp2_num_threads)
      call POMP2_Parallel_begin(pomp2_region_6)
      call POMP2_Do_enter(pomp2_region_6, &
     pomp2_ctc_6 )
        !$omp          do
        do i=0,n
            u(i,js) = (i * h)**2
        enddo
!$omp end do nowait
      call POMP2_Implicit_barrier_enter(pomp2_region_6,&
      pomp2_old_task)
!$omp barrier
      call POMP2_Implicit_barrier_exit(pomp2_region_6, pomp2_old_task)
      call POMP2_Do_exit(pomp2_region_6)
      call POMP2_Parallel_end(pomp2_region_6)
!$omp end parallel
      call POMP2_Parallel_join(pomp2_region_6, pomp2_old_task)
    endif

    if (myid == np - 1) then
      pomp2_num_threads = pomp2_lib_get_max_threads()
      pomp2_if = .true.
      call POMP2_Parallel_fork(pomp2_region_7,&
      pomp2_if, pomp2_num_threads, pomp2_old_task, &
      pomp2_ctc_7 )
        !$omp parallel    &
  !$omp firstprivate(pomp2_old_task) private(pomp2_new_task) &
  !$omp if(pomp2_if) num_threads(pomp2_num_threads)
      call POMP2_Parallel_begin(pomp2_region_7)
      call POMP2_Do_enter(pomp2_region_7, &
     pomp2_ctc_7 )
        !$omp          do
        do i=0,n
            u(i,je) = (i * h)**2 + 1.
        enddo
!$omp end do nowait
      call POMP2_Implicit_barrier_enter(pomp2_region_7,&
      pomp2_old_task)
!$omp barrier
      call POMP2_Implicit_barrier_exit(pomp2_region_7, pomp2_old_task)
      call POMP2_Do_exit(pomp2_region_7)
      call POMP2_Parallel_end(pomp2_region_7)
!$omp end parallel
      call POMP2_Parallel_join(pomp2_region_7, pomp2_old_task)
    endif

      pomp2_num_threads = pomp2_lib_get_max_threads()
      pomp2_if = .true.
      call POMP2_Parallel_fork(pomp2_region_8,&
      pomp2_if, pomp2_num_threads, pomp2_old_task, &
      pomp2_ctc_8 )
    !$omp parallel    &
  !$omp firstprivate(pomp2_old_task) private(pomp2_new_task) &
  !$omp if(pomp2_if) num_threads(pomp2_num_threads)
      call POMP2_Parallel_begin(pomp2_region_8)
      call POMP2_Do_enter(pomp2_region_8, &
     pomp2_ctc_8 )
    !$omp          do
    do j=js,je
        u(0,j) = ((joff + j) * h)**2
        u(n,j) = ((joff + j) * h)**2 + 1.
    enddo
!$omp end do nowait
      call POMP2_Implicit_barrier_enter(pomp2_region_8,&
      pomp2_old_task)
!$omp barrier
      call POMP2_Implicit_barrier_exit(pomp2_region_8, pomp2_old_task)
      call POMP2_Do_exit(pomp2_region_8)
      call POMP2_Parallel_end(pomp2_region_8)
!$omp end parallel
      call POMP2_Parallel_join(pomp2_region_8, pomp2_old_task)

end subroutine set_bc

!----------------------------------------------------------------------

subroutine compute_diff(u,unew,n,js,je,diffnorm)

    implicit none
  include 'mpif.h'
      include 'jacobi.f90.opari.inc'
    integer n, js, je
    real    u(0:n,js-1:je+1), unew(0:n,js-1:je+1)
    integer i, j
    real    diffnorm
    real    dnorm
    integer np, myid
    integer ierr

    call mpi_comm_size(mpi_comm_world,np,ierr)
    call mpi_comm_rank(mpi_comm_world,myid,ierr)

    dnorm = 0.0

      pomp2_num_threads = pomp2_lib_get_max_threads()
      pomp2_if = .true.
      call POMP2_Parallel_fork(pomp2_region_9,&
      pomp2_if, pomp2_num_threads, pomp2_old_task, &
      pomp2_ctc_9 )
    !$omp parallel    reduction(+:dnorm) &
  !$omp firstprivate(pomp2_old_task) private(pomp2_new_task) &
  !$omp if(pomp2_if) num_threads(pomp2_num_threads)
      call POMP2_Parallel_begin(pomp2_region_9)
      call POMP2_Do_enter(pomp2_region_9, &
     pomp2_ctc_9 )
    !$omp          do                   
    do j=js,je
        do i=1,n-1
            dnorm = dnorm + (unew(i,j) - u(i,j))**2
        end do
    end do
!$omp end do nowait
      call POMP2_Implicit_barrier_enter(pomp2_region_9,&
      pomp2_old_task)
!$omp barrier
      call POMP2_Implicit_barrier_exit(pomp2_region_9, pomp2_old_task)
      call POMP2_Do_exit(pomp2_region_9)
      call POMP2_Parallel_end(pomp2_region_9)
!$omp end parallel
      call POMP2_Parallel_join(pomp2_region_9, pomp2_old_task)

    call mpi_allreduce(dnorm,diffnorm,1,mpi_real,mpi_sum,mpi_comm_world,ierr)

    diffnorm = sqrt(diffnorm)

end subroutine compute_diff

      subroutine POMP2_Init_reg_432292914_9()
         include 'jacobi.f90.opari.inc'
         call POMP2_Assign_handle( pomp2_region_1, &
         pomp2_ctc_1 )
         call POMP2_Assign_handle( pomp2_region_2, &
         pomp2_ctc_2 )
         call POMP2_Assign_handle( pomp2_region_3, &
         pomp2_ctc_3 )
         call POMP2_Assign_handle( pomp2_region_4, &
         pomp2_ctc_4 )
         call POMP2_Assign_handle( pomp2_region_5, &
         pomp2_ctc_5 )
         call POMP2_Assign_handle( pomp2_region_6, &
         pomp2_ctc_6 )
         call POMP2_Assign_handle( pomp2_region_7, &
         pomp2_ctc_7 )
         call POMP2_Assign_handle( pomp2_region_8, &
         pomp2_ctc_8 )
         call POMP2_Assign_handle( pomp2_region_9, &
         pomp2_ctc_9 )
      end
