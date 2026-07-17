program test_lattice
   use parameters ,  only : stdout , stderr, ZERO, ONE, TWO
   use lattice_mod, only  : lattice, next  , prev
   
   implicit none

   type(lattice)        :: lat
   integer              :: failures
   integer              :: site, mu, shifted_site 
   integer, allocatable :: x(:)

   failures = ZERO

   ! Initialization and derived lattice sizes.
   call lat%init([2, 4, 6])

   call check(    lat % ndim   == 3, "ndim")
   call check(all(lat % lshape == [2, 4, 6]), "lattice shape")
   call check(all(lat % stride == [1, 2, 8]), "lattice strides")
   call check(    lat % nsites == 48, "number of sites")
   call check(    lat % nlinks == 144, "number of links")
   call check(     lat % nplaquettes == 144, "number of plaquettes")

   ! Coordinate convention: sites are one-based and coordinates are zero-based.
   x = lat % coord(1)
   call check(all(x == [0, 0, 0]), "coordinates of first site")

   x = lat % coord(2)
   call check(all(x == [1, 0, 0]), "coordinates along first direction")

   x = lat % coord(3)
   call check(all(x == [0, 1, 0]), "coordinates along second direction")

   x = lat % coord(lat % nsites)
   call check(all(x == [1, 3, 5]), "coordinates of last site")

   ! Parity is the coordinate sum modulo two.
   call check(lat%parity(1) == 0, "origin parity")
   call check(lat%parity(2) == 1, "nearest-neighbor parity")
   call check(lat%parity(4) == 0, "two-coordinate parity")

   ! Explicit periodic-boundary checks.
   call check(lat%neighbor(1, 1, next) == 2, &
              "forward neighbor in first direction")
   call check(lat%neighbor(2, 1, next) == 1, &
              "forward wrap in first direction")
   call check(lat%neighbor(1, 1, prev) == 2, &
              "backward wrap in first direction")

   call check(lat%neighbor(1, 2, next) == 3, &
              "forward neighbor in second direction")
   call check(lat%neighbor(1, 2, prev) == 7, &
              "backward wrap in second direction")

   call check(lat%neighbor(1, 3, next) == 9, &
              "forward neighbor in third direction")
   call check(lat%neighbor(1, 3, prev) == 41, &
              "backward wrap in third direction")

   ! Forward and backward shifts must be mutual inverses everywhere.
   do mu = ONE, lat%ndim
      do site = ONE, lat%nsites
         shifted_site = lat%neighbor(site, mu, next)
         call check( &
              lat%neighbor(shifted_site, mu, prev) == site, &
              "backward(forward(site))")

         shifted_site = lat%neighbor(site, mu, prev)
         call check( &
              lat%neighbor(shifted_site, mu, next) == site, &
              "forward(backward(site))")
   end do
end do
!!$ CONSECUTIVE PASS OF THE SAME METHOD FAILS!
!!$   do mu = ONE, lat%ndim
!!$      do site = ONE, lat%nsites
!!$         call check( &
!!$            lat%neighbor(lat%neighbor(site, mu, next), mu, next) == site, &
!!$            "backward(forward(site))")
!!$         call check( &
!!$            lat%neighbor(lat%neighbor(site, mu, prev), mu, next) == site, &
!!$            "forward(backward(site))")
!!$      end do
!!$   end do
   

   ! On an even lattice, every nearest-neighbor shift flips parity.
   do mu = ONE, lat%ndim
      do site = ONE, lat%nsites
         call check( &
            lat%parity(lat%neighbor(site, mu, next)) == &
            modulo(lat%parity(site) + ONE, TWO), &
            "forward neighbor flips parity")
         call check( &
            lat%parity(lat%neighbor(site, mu, prev)) == &
            modulo(lat%parity(site) + ONE, TWO), &
            "backward neighbor flips parity")
      end do
   end do

   ! Reinitialization must replace all geometry-dependent values.
   call lat%init([3, 5])

   call check(lat%ndim == 2, "reinitialized ndim")
   call check(all(lat%lshape == [3, 5]), "reinitialized shape")
   call check(all(lat%stride == [1, 3]), "reinitialized strides")
   call check(lat%nsites == 15, "reinitialized number of sites")
   call check(lat%nlinks == 30, "reinitialized number of links")
   call check(lat%nplaquettes == 15, "reinitialized number of plaquettes")

   if (failures /= ZERO) then
      write(stderr, '(a,i0)') "test_lattice: FAILED checks = ", failures
      error stop 1
   end if

   write(stdout, '(a)') "test_lattice: PASS"

contains

   subroutine check(condition, message)
      logical,          intent(in) :: condition
      character(len=*), intent(in) :: message

      if (.not. condition) then
         failures = failures + ONE
         write(stderr, '(a)') "FAIL: " // message
      end if
   end subroutine check

end program test_lattice
