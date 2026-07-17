program test_strings
   use strings, only : lower_case
   implicit none

   integer :: failures

   failures = 0

   call check_equal(lower_case('ABCDEF'),       'abcdef',       'uppercase letters')
   call check_equal(lower_case('abcdef'),       'abcdef',       'lowercase letters')
   call check_equal(lower_case('AbCdEf'),       'abcdef',       'mixed-case letters')
   call check_equal(lower_case('SU(3)_LINK-42'), 'su(3)_link-42', 'letters and symbols')
   call check_equal(lower_case(''),             '',             'empty string')
   call check_equal(lower_case(' A B C '),      ' a b c ',      'embedded and outer spaces')

   if (failures /= 0) then
      write(*, '(a,i0)') '[FAIL] ym_strings: ', failures
      error stop 1
   end if

   write(*, '(a)') '[PASS] ym_strings'

contains

   subroutine check_equal(actual, expected, description)
      character(len=*), intent(in) :: actual
      character(len=*), intent(in) :: expected
      character(len=*), intent(in) :: description

      if (actual /= expected) then
         failures = failures + 1
         write(*, '(a)') '  Test failed: ' // trim(description)
         write(*, '(a,a,a)') '    expected: "', expected, '"'
         write(*, '(a,a,a)') '    actual:   "', actual,   '"'
      end if
   end subroutine check_equal

end program test_strings
