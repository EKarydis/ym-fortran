!==========================================================================================
! File: parameters.F90 
!==========================================================================================
module parameters
  use, intrinsic :: iso_fortran_env, only : real64       ,&
                                            real32       ,&
                                            real128      ,& 
                                             output_unit ,&
                                              input_unit ,&
                                              error_unit 
!------------------------------------------------------------------------------------------ 
  implicit none
  private
!------------------------------------------------------------------------------------------
! Numerical Kinds
#ifdef SINGLE
   integer   , parameter, public :: dp = real32
#elif defined(QUAD)
   integer   , parameter, public :: dp = real128
#else
   integer   , parameter, public :: dp = real64
#endif
!------------------------------------------------------------------------------------------ 
! Standard I/O units
  integer    , parameter, public :: stdout = output_unit
  integer    , parameter, public :: stderr =  error_unit
  integer    , parameter, public :: stdin  =  input_unit 
!------------------------------------------------------------------------------------------ 
! Integer parameters
  integer    , parameter, public :: ZERO   =  0 
  integer    , parameter, public :: ONE    =  1   
  integer    , parameter, public :: TWO    =  2 
!------------------------------------------------------------------------------------------ 
! Real parameters
  real   (dp), parameter, public :: ZEROD  =  0.0_dp       
  real   (dp), parameter, public :: ONED   =  1.0_dp
  real   (dp), parameter, public :: TWOD   =  2.0_dp
  real   (dp), parameter, public :: HALF   =  ONED  / TWOD 
  real   (dp), parameter, public :: EPS    =  epsilon(ONED)
!------------------------------------------------------------------------------------------ 
! PI  
  real   (dp), parameter, public :: PI     = atan2(0.0_dp, -1.0_dp)
  real   (dp), parameter, public :: PISQ   = PI  **2                        
  real   (dp), parameter, public :: PIHLF  = HALF* PI
!------------------------------------------------------------------------------------------
! Complex parameters 
  complex(dp), parameter, public :: ONEC   = (1.0_dp,  0.0_dp)  ,  IMU = (0.0_dp,  1.0_dp)
  complex(dp), parameter, public :: ZEROC  = (0.0_dp,  0.0_dp)
  
  
end module parameters
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
