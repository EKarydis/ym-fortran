!==========================================================================================
! File: lattice.f90 
!==========================================================================================
module     lattice_mod 
  use      parameters , only : ZERO, ONE, TWO, stdout  
  use      error      , only : condition_error
!------------------------------------------------------------------------------------------
   implicit none
   private  
   integer, parameter, public  :: next =  ONE 
   integer, parameter, public  :: prev = -ONE
!------------------------------------------------------------------------------------------
   type       , public          :: lattice
      integer                   :: ndim        = ZERO
      integer                   :: nsites      = ZERO
      integer                   :: nplaquettes = ZERO
      integer                   :: nlinks      = ZERO  
      integer , allocatable     :: lshape(:)   
      integer , allocatable     :: stride(:)   

    contains

      procedure, public          :: init     =>     init_lattice 
      procedure, public          :: coord    =>    coord_lattice
      procedure, public          :: parity   =>   parity_lattice
      procedure, public          :: neighbor => neighbor_lattice
      procedure, public          :: print    =>    print_lattice
   end type                        lattice

 contains

!=========================================================================================
   subroutine     init_lattice                (this, lat_shape)
!=========================================================================================
     class    (lattice)  ,  intent(inout)   :: this
     integer             ,  intent(in   )   :: lat_shape(:)
     character(len=*)    ,  parameter       :: myname='init_lattice'
     integer                                :: mu 

     call condition_error ((size(lat_shape) >= ONE), myname, &
                           "lat_shape < 1"                   )
     call condition_error ( all(lat_shape  >= ONE), myname, &
                           'Every lattice extent must be positive.')
     
     this % lshape     = lat_shape
     this % ndim        = size   (this % lshape)
     this % nsites      = product(this % lshape)
     this % nlinks      =         this % ndim *  this % nsites
     this % nplaquettes =         this % ndim * (this % ndim - ONE)  / TWO * this % nsites

     if ( allocated(this % stride) ) deallocate(this % stride) 
     allocate(this % stride (this % ndim) )
     this % stride(ONE) = ONE
      do mu   = TWO, this % ndim
         this % stride(mu) = this % stride(mu - ONE) * this % lshape(mu - 1)
      end do
   end subroutine init_lattice
!==========================================================================================
  pure function  coord_lattice       (this, site)                     result(x)
!==========================================================================================
     class(lattice)  , intent(in)  :: this
     integer         , intent(in)  :: site 
     integer                       :: x(this % ndim), mu 
     character(len=*), parameter   :: myname = 'neighbor_lattice'

     call condition_error( (site >= ONE .and. site <= this%nsites), myname, &
                           'Site index is outside the lattice.')
     
     do mu = ONE, this % ndim
         x(mu) = modulo( (site - ONE) / this % stride(mu), this % lshape(mu) ) 
      end do
   end function   coord_lattice

!==========================================================================================
   pure function neighbor_lattice   (this, site, mu, direction)       result(other_site)
!==========================================================================================
     class(lattice),   intent(in) :: this
     integer,          intent(in) :: site
     integer,          intent(in) :: mu
     integer,          intent(in) :: direction
     integer                      :: other_site
     integer                      :: x(this % ndim), xmu  
     character(len=*), parameter  :: myname = 'neighbor_lattice'

     call condition_error( (site >= ONE .and. site <= this % nsites ), myname, &
                           'Site index is outside the lattice.')
     call condition_error( (mu   >= ONE .and. mu <= this%ndim       ), myname, &
                           'Direction index is outside the lattice dimensions.')
     call condition_error( (direction == next .or. direction == prev), myname, &
                           'Direction must be next or prev.')
     
     x = this % coord(site) ; xmu = x(mu) 

     select case (direction)
      case (next)
         if (xmu == this%lshape(mu) - ONE) then
            other_site = site - (this%lshape(mu) - ONE) * this%stride(mu)
         else
            other_site = site + this%stride(mu)
         end if

      case (prev)
         if (xmu == 0) then
            other_site = site + (this%lshape(mu) - ONE) * this%stride(mu)
         else
            other_site = site - this%stride(mu)
         end if
      end select
      
   end function  neighbor_lattice

!==========================================================================================
   pure function parity_lattice      (this, site)            result(site_parity)
!==========================================================================================
      class(lattice),   intent(in) :: this
      integer,          intent(in) :: site
      integer                      :: site_parity
      integer                      :: x(this % ndim), mu 
      character(len=*), parameter  :: myname = 'parity_lattice'

      call condition_error((site >= ONE .and. site <= this%nsites), myname, &
                           'Site index is outside the lattice.')

      site_parity = ZERO 
      x = this % coord(site) 
      do mu = ONE, this % ndim
         site_parity = site_parity + x(mu)    
      end do
      site_parity = modulo(site_parity, TWO)
   end function parity_lattice


!==========================================================================================
   subroutine print_lattice                  (this, unit)
!==========================================================================================
     class(lattice),           intent(in)  :: this
     integer       , optional, intent(in)  :: unit
     integer                               :: io_unit

     io_unit = stdout 
     if (present(unit)) io_unit = unit
   
     write(io_unit, '(a   )') "# ========================================================="
     write(io_unit, '(a   )') '# Lattice geometry'
     write(io_unit, '(a   )') "# ========================================================="
     write(io_unit, '(a,i0)') '# ndim        = ', this % ndim
     write(io_unit, '(a,i0)') '# nsites      = ', this % nsites
     write(io_unit, '(a,i0)') '# nlinks      = ', this % nlinks
     write(io_unit, '(a,i0)') '# nplaquettes = ', this % nplaquettes
     write(io_unit, '(a,i0)') '# lshape      = ', this % lshape 
     write(io_unit, '(a,i0)') '# stride      = ', this % stride 
   
   end subroutine print_lattice

 end module lattice_mod
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
