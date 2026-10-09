program make_percentile_test_data
  use iso_fortran_env, only: real32, int32
  implicit none
  integer :: e, t, x, y, z
  real(real32) :: value

  open(10, file='percentile-test.dat', access='stream', form='unformatted', &
       status='replace')
  do e = 1, 3
    do t = 1, 5
      do x = 1, 3
        value = real(100*e + 10*t + x, real32)
        if (e == 2 .and. t == 3 .and. x == 2) value = -9999.0
        write(10) value
      end do
    end do
  end do
  close(10)

  open(10, file='percentile-xyz.dat', access='stream', form='unformatted', &
       status='replace')
  do e = 1, 2
    do t = 1, 2
      do z = 1, 3
        do y = 1, 3
          do x = 1, 4
            value = real(10000*e + 1000*t + 100*z + 10*y + x, real32)
            write(10) value
          end do
        end do
      end do
    end do
  end do
  close(10)

  ! A valid station file with one empty time group, for input-type rejection.
  open(10, file='percentile-station.dat', access='stream', form='unformatted', &
       status='replace')
  write(10) '        ', 0.0_real32, 0.0_real32, 0.0_real32, 0_int32, 0_int32
  close(10)
end program make_percentile_test_data
