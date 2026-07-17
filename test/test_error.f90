program test_error
   use error, only : fatal_error, warning, condition_error
   implicit none

   character(len=32) :: mode

   if (command_argument_count() /= 1) then
      write(*, '(a)') 'Usage: test_error MODE'
      write(*, '(a)') 'MODE = warning | condition_pass | fatal | condition_fail'
      error stop 2
   end if

   call get_command_argument(1, mode)

   select case (trim(mode))
   case ('warning')
      call warning('test_warning', 'expected warning message')
      write(*, '(a)') '[PASS] warning returned normally'

   case ('condition_pass')
      call condition_error(.true., 'test_condition_pass', &
                           'this message must not be printed')
      write(*, '(a)') '[PASS] true condition returned normally'

   case ('fatal')
      call fatal_error('test_fatal', 'expected fatal message')
      error stop 3  ! Unreachable when fatal_error behaves correctly.

   case ('condition_fail')
      call condition_error(.false., 'test_condition_fail', &
                           'expected condition failure message')
      error stop 4  ! Unreachable when condition_error behaves correctly.

   case default
      write(*, '(a)') 'Unknown test mode: ' // trim(mode)
      error stop 2
   end select

end program test_error
