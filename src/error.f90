!==========================================================================================
! File: error.f90
!==========================================================================================
module error
   use parameters, only : stderr
!------------------------------------------------------------------------------------------
   implicit none
   private
!------------------------------------------------------------------------------------------
   public :: fatal_error
   public :: warning
   public :: condition_error
   
!------------------------------------------------------------------------------------------

 contains

!==========================================================================================
   pure subroutine     fatal_error(source, message)
!==========================================================================================
   character(len=*), intent(in) :: source
   character(len=*), intent(in) :: message
!------------------------------------------------------------------------------------------
   
   error stop '[ERROR] [' // trim(source) // '] ' // trim(message)
   ! Fortran 2018 permits error stop in pure subroutines
 end subroutine   fatal_error
 
!==========================================================================================
 subroutine       warning(source, message)
!==========================================================================================
   character(len=*), intent(in) :: source
   character(len=*), intent(in) :: message
!------------------------------------------------------------------------------------------

   write(stderr, '(3a)') '#WARNING [', trim(source), '] ', trim(message)

 end subroutine  warning

!==========================================================================================
 pure subroutine    condition_error(condition, source, message)
!==========================================================================================
   logical         , intent(in) :: condition
   character(len=*), intent(in) :: source
   character(len=*), intent(in) :: message
!------------------------------------------------------------------------------------------

   if (.not. condition) call fatal_error(source, message)

 end subroutine   condition_error


end module error
!==========================================================================================



!------------------------------------------------------------------------------------------
!  Copyright by Evangelos K. Karydis, 
!  Physics Department, National Technical University of Athens, 2026
!  ekarydis@mail.ntua.gr
!  
!  This program is free software: you can redistribute it 
!  and/or modify it under the terms of the GNU General Public License as 
!  published by the Free Software Foundation, version 3 of the License.
!  
!  This program is distributed in the hope that it will be useful, 
!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
!  See the GNU General Public License for more details.
!  
!  You should have received a copy of the GNU General Public Liense along with this program.
!  If not, see http://www.gnu.org/licenses
!-------------------------------------------------------------------------------------------
