program make_data
  use iso_fortran_env, only: real32
  implicit none
  real(real32) :: field(37,19), p(37,19)
  integer :: i,j
  do j=1,19
    do i=1,37
      field(i,j)=sin(real(i,real32)*0.2_real32)+cos(real(j,real32)*0.3_real32)
      p(i,j)=0.5_real32
    end do
  end do
  p(2,2)=0.01_real32
  p(3,2)=0.05_real32
  p(4,2)=-9999.0_real32
  p(5,2)=1.1_real32
  ! q defval prints both near-threshold values as 0.05 and the last as 1.
  ! Selection must therefore happen before formatting p as text.
  p(2,3)=0.04999999_real32
  p(3,3)=0.05000001_real32
  p(4,3)=1.0000001_real32
  open(10,file='field.bin',access='stream',form='unformatted',status='replace')
  write(10) field,p
  close(10)
end program
