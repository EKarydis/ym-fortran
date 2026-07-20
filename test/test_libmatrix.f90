!==========================================================================================
! File: test_libmatrix.f90
!==========================================================================================

program test_libmatrix
   use parameters, only : dp, EPS, stdout
   use array_mod, only : lmatmul, determinant
!------------------------------------------------------------------------------------------
   implicit none
!------------------------------------------------------------------------------------------

   complex(dp) :: a(2, 2)
   complex(dp) :: b(2, 2)
   complex(dp) :: result(2, 2)
   complex(dp) :: expected(2, 2)
   complex(dp) :: det_a

   real(dp), parameter :: tolerance = 100.0_dp * EPS

!------------------------------------------------------------------------------------------

   ! Column-major construction:
   !
   !     a = [ 1  2 ]       b = [ 5  6 ]
   !         [ 3  4 ]           [ 7  8 ]
   !
   a = reshape([ &
      cmplx(1.0_dp, 0.0_dp, dp), &
      cmplx(3.0_dp, 0.0_dp, dp), &
      cmplx(2.0_dp, 0.0_dp, dp), &
      cmplx(4.0_dp, 0.0_dp, dp)  &
   ], shape(a))

   b = reshape([ &
      cmplx(5.0_dp, 0.0_dp, dp), &
      cmplx(7.0_dp, 0.0_dp, dp), &
      cmplx(6.0_dp, 0.0_dp, dp), &
      cmplx(8.0_dp, 0.0_dp, dp)  &
   ], shape(b))

   expected = matmul(a, b)
   result   = lmatmul(a, b)

   if (maxval(abs(result - expected)) > tolerance) then
      error stop 'test_libmatrix: lmatmul returned an incorrect result'
   end if

   det_a = determinant(a)

   if (abs(det_a + cmplx(2.0_dp, 0.0_dp, dp)) > tolerance) then
      error stop 'test_libmatrix: determinant returned an incorrect result'
   end if

   write(stdout, '(a)') 'test_libmatrix: PASS'

end program test_libmatrix

!==========================================================================================
