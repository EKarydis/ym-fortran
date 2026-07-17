!==========================================================================================
! File: strings.f90
!==========================================================================================
module           strings 
  implicit none
  private 
  
  public :: lower_case


contains 
  
!==========================================================================================
!> Convert ASCII letters to lowercase.
!> Characters outside `A`--`Z` are unchanged.
  elemental function     lower_case(text) result(lower)
!==========================================================================================
    character(len=*), intent(in) :: text
    character(len=len(text))     :: lower
    
    integer :: i, code
    
    lower = text
    
    do i = 1, len(text)
       code = iachar(text(i:i))
       if (code >= iachar('A') .and. code <= iachar('Z')) then
          lower(i:i) = achar(code + iachar('a') - iachar('A'))
       end if
    end do
      
    end function       lower_case


  end module        strings
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
