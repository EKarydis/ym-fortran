program test_parameters
   use, intrinsic :: iso_fortran_env, only : real32, real64, real128, &
                                             input_unit, output_unit, error_unit
   use parameters, only : dp, stdin, stdout, stderr, &
                          ZERO, ONE, TWO, &
                          ZEROD, ONED, TWOD, HALF, EPS, &
                          PI, PISQ, PIHLF, &
                          ZEROC, ONEC, IMU
   implicit none

   integer :: failures

   failures = 0

   ! Selected floating-point kind.
#ifdef SINGLE
   call check(dp == real32,  "dp must be real32 when SINGLE is defined")
#elif defined(QUAD)
   call check(dp == real128, "dp must be real128 when QUAD is defined")
#else
   call check(dp == real64,  "dp must default to real64")
#endif

   ! Standard I/O aliases.
   call check(stdin  == input_unit,  "stdin must equal input_unit")
   call check(stdout == output_unit, "stdout must equal output_unit")
   call check(stderr == error_unit,  "stderr must equal error_unit")

   ! Integer constants.
   call check(ZERO == 0, "ZERO must equal 0")
   call check(ONE  == 1, "ONE must equal 1")
   call check(TWO  == 2, "TWO must equal 2")

   ! Real constants and machine precision.
   call check(ZEROD == 0.0_dp,             "ZEROD must equal 0")
   call check(ONED  == 1.0_dp,             "ONED must equal 1")
   call check(TWOD  == 2.0_dp,             "TWOD must equal 2")
   call check(HALF  == 0.5_dp,             "HALF must equal 1/2")
   call check(abs(EPS - epsilon(1.0_dp)) <= tiny(1.0_dp), &
              "EPS must equal machine epsilon")

   ! Pi-related constants.  Use scaled tolerances rather than exact equality.
   call check(abs(PI - acos(-1.0_dp)) <= 4.0_dp*EPS, &
              "PI has an unexpected value")
   call check(abs(PISQ - PI*PI) <= 4.0_dp*EPS*abs(PISQ), &
              "PISQ must equal PI squared")
   call check(abs(PIHLF - 0.5_dp*PI) <= 4.0_dp*EPS*abs(PIHLF), &
              "PIHLF must equal PI/2")

   ! Complex constants.
   call check(abs(real(ZEROC, dp)) <= EPS .and. abs(aimag(ZEROC)) <= EPS, &
              "ZEROC must equal (0,0)")
   call check(abs(real(ONEC, dp) - 1.0_dp) <= EPS .and. abs(aimag(ONEC)) <= EPS, &
              "ONEC must equal (1,0)")
   call check(abs(real(IMU, dp)) <= EPS .and. abs(aimag(IMU) - 1.0_dp) <= EPS, &
              "IMU must equal (0,1)")
   call check(abs(IMU*IMU + ONEC) <= EPS, "IMU squared must equal -ONEC")

   if (failures /= 0) then
      write(stderr, '(a,i0)') "test_parameters: FAILED checks = ", failures
      error stop 1
   end if

   write(stdout, '(a)') "test_parameters: PASS"

contains

   subroutine check(condition, message)
      logical,          intent(in) :: condition
      character(len=*), intent(in) :: message

      if (.not. condition) then
         failures = failures + 1
         write(stderr, '(a)') "FAIL: " // message
      end if
   end subroutine check

end program test_parameters
