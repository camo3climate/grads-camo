dnl GA_CHECK_LIB_SHP : check for shp library
dnl args :             action-if-yes, action-if-no

AC_DEFUN([GA_CHECK_LIB_SHP],
[
  ga_check_shp="no"
  SHP_LIBS=
  SHP_CFLAGS=
  SHP_LDFLAGS=

  ac_save_LIBS="$LIBS"
  ac_save_CPPFLAGS="$CPPFLAGS"
  ac_save_LDFLAGS="$LDFLAGS"

dnl check for the header shapefil.h and the SHPOpen symbol in libshp.
dnl AC_CHECK_LIB temporarily appends -lshp to LIBS for the test, but this
dnl macro restores LIBS afterwards.  Therefore SHP_LIBS must be set explicitly
dnl so configure.ac can propagate it to shp_libs and src/Makefile gets -lshp
dnl in grads_LDADD/libgradspy_la_LIBADD.
  AC_CHECK_HEADER([shapefil.h],
  [  AC_CHECK_LIB([shp], [SHPOpen],
     [  ga_check_shp=yes
        SHP_LIBS="-lshp"
     ],
     [
        SHP_LDFLAGS=
        SHP_LIBS=
        LIBS="$ac_save_LIBS"
        LDFLAGS="$ac_save_LDFLAGS"
     ])
  ],
  [
    SHP_CFLAGS=
    CPPFLAGS="$ac_save_CPPFLAGS"
  ])

  LIBS="$ac_save_LIBS"
  CPPFLAGS="$ac_save_CPPFLAGS"
  LDFLAGS="$ac_save_LDFLAGS"

  if test $ga_check_shp = 'yes'; then
     m4_if([$1], [], [:], [$1])
  else
     m4_if([$2], [], [:], [$2])
  fi

  AC_SUBST([SHP_LIBS])
  AC_SUBST([SHP_LDFLAGS])
  AC_SUBST([SHP_CFLAGS])
])
