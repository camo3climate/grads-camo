# Central downstream version settings. Update these together for a release.
%global upstream_version 2.2.3
%global camo_version camo26.1
%global camo_release 1.%{camo_version}
%global public_release_name grads-%{upstream_version}-%{camo_version}
%global github_tag v%{upstream_version}-%{camo_version}

Name:           grads
Version:        %{upstream_version}
Release:        %{camo_release}%{?dist}
Summary:        Unofficial CAMO build of GrADS 2.2.3 for Enterprise Linux

License:        GPL-2.0-only AND MIT
URL:            https://github.com/camo3climate/grads-camo
Source0:        grads-%{upstream_version}-src.tar.gz
Source1:        cairo.m4
Source2:        libshp.m4
Source3:        udpt.in
Source4:        grads-camo-packaging-docs.tar.gz

Patch0:         grads-2.2.1-system-supplibs.patch
Patch1:         grads-2.2.1-fhs-paths.patch
Patch2:         grads-2.2.3-camo-config.patch
Patch3:         grads-2.2.1-timeunits-parse.patch
Patch4:         grads-2.2.1-format-security.patch
Patch8:         grads-2.2.1-without-dap.patch
Patch9:         grads-2.2.1-cairo-aflush.patch
Patch11:        grads-2.2.1-gcc14.patch
Patch12:        grads-2.2.1-gcc15.patch
Patch13:        grads-2.2.1-disable-gadap-macro.patch
Patch14:        grads-2.2.1-themes-rgbmap.patch
Patch15:        grads-2.2.3-geo-draw.patch
Patch16:        grads-2.2.3-geo-commands.patch
Patch17:        grads-2.2.3-command-cleanup.patch
Patch18:        grads-2.2.3-udunits2-include.patch
Patch19:        grads-2.2.3-hdf5-serial-ldflags.patch
Patch20:        grads-2.2.3-hdf5-modern-api.patch
Patch21:        grads-2.2.3-enable-grib2-g2c-portable.patch
Patch22:        grads-2.2.3-txtwrite.patch
Patch23:        grads-2.2.3-modern-gxout2.patch
Patch24:        grads-2.2.3-re-limited.patch
Patch25:        grads-2.2.3-axis-label-size.patch
Patch26:        grads-2.2.3-modern-startup-defaults.patch

BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  glibc-devel
BuildRequires:  glibc-headers
BuildRequires:  binutils
BuildRequires:  redhat-rpm-config
BuildRequires:  make
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  libtool
BuildRequires:  pkgconfig
BuildRequires:  readline-devel
BuildRequires:  ncurses-devel
BuildRequires:  zlib-devel
BuildRequires:  libpng-devel
BuildRequires:  libjpeg-turbo-devel
BuildRequires:  jasper-devel
BuildRequires:  cairo-devel
BuildRequires:  freetype-devel
BuildRequires:  fontconfig-devel
BuildRequires:  gd-devel
BuildRequires:  libX11-devel
BuildRequires:  libXext-devel
BuildRequires:  libXmu-devel
BuildRequires:  libXrender-devel
BuildRequires:  libgeotiff-devel
BuildRequires:  shapelib-devel
BuildRequires:  udunits2-devel
BuildRequires:  netcdf-devel
BuildRequires:  hdf5-devel
BuildRequires:  hdf-devel
BuildRequires:  libaec-devel
BuildRequires:  g2clib-devel
BuildRequires:  g2clib-static

%description
GrADS is an interactive tool for access, manipulation, and visualization of
earth science data. This unofficial CAMO downstream package is built for
Enterprise Linux using system libraries, without bundled supplibs/supptools,
without the libsx GUI, and without GrADS-side OPeNDAP support.


%prep
%autosetup -p1
cp -p %{SOURCE1} m4/cairo.m4
cp -p %{SOURCE2} m4/libshp.m4
tar -xzf %{SOURCE4}

g2clib_name="$(rpm --eval '%%{?g2clib}')"
if [ -z "${g2clib_name}" ] || [ "${g2clib_name}" = "%%{?g2clib}" ]; then
  g2clib_name="grib2c"
fi
sed -i \
  -e "s/AC_CHECK_LIB(\[grib2c\]/AC_CHECK_LIB([${g2clib_name}]/g" \
  -e "s/AC_CHECK_LIB(grib2c/AC_CHECK_LIB(${g2clib_name}/g" \
  -e "s/-lgrib2c/-l${g2clib_name}/g" \
  -e "s/png15/png16/g" \
  configure.ac m4/grib2.m4

autoreconf -fiv


%build
%if 0%{?rhel} >= 9
%set_build_flags
export CFLAGS="${CFLAGS} -Wall -fPIC -Wno-trigraphs -DH5_USE_110_API"
export CXXFLAGS="${CXXFLAGS} -Wall"
export CPPFLAGS="${CPPFLAGS:-} -I%{_includedir}/hdf -I%{_includedir}/udunits2 -DH5_USE_110_API"
export LDFLAGS="${LDFLAGS} -L%{_libdir}/hdf"
%else
# EL8 may inherit a stale external annobin plugin through the host RPM flags.
export CFLAGS="-O2 -g -pipe -Wall -fPIC -Wno-trigraphs -DH5_USE_110_API"
export CXXFLAGS="-O2 -g -pipe -Wall"
export CPPFLAGS="-I%{_includedir}/hdf -I%{_includedir}/udunits2 -DH5_USE_110_API"
export LDFLAGS="-L%{_libdir}/hdf"
%endif

%configure \
  --enable-dyn-supplibs \
  --without-gadap \
  --without-dap \
  --with-x \
  --with-hdf4-include=%{_includedir}/hdf \
  --with-hdf4-libdir=%{_libdir}/hdf \
  --with-netcdf-include=%{_includedir} \
  --with-netcdf-libdir=%{_libdir} \
  --libdir=%{_libdir}/grads

printf '\n#define CAMO_VERSION "%s"\n' '%{camo_version}' >> src/config.h

%make_build


%install
%make_install
find %{buildroot} -name '*.la' -delete

install -d -m 0755 %{buildroot}%{_datadir}/grads
cp -a data/* %{buildroot}%{_datadir}/grads/
sed 's|@LIBDIR@|%{_libdir}|g' %{SOURCE3} > %{buildroot}%{_datadir}/grads/udpt


%files
%license COPYRIGHT
%license grads-camo-docs/LICENSES/MIT-Simon-Tatham.txt
%doc INSTALL doc
%doc grads-camo-docs/README.md
%doc grads-camo-docs/CHANGELOG.md
%doc grads-camo-docs/NOTICE.md
%doc grads-camo-docs/docs/*.md
%doc grads-camo-docs/docs/*.html
%{_bindir}/bufrscan
%{_bindir}/grads
%{_bindir}/gribmap
%{_bindir}/grib2scan
%{_bindir}/gribscan
%{_bindir}/stnmap
%dir %{_libdir}/grads
%{_libdir}/grads/*.so*
%{_datadir}/grads/


%changelog
* Mon Jun 22 2026 CAMO packaging maintainers <noreply@example.invalid> - 2.2.3-1.camo26.1
- Update the upstream base to GrADS 2.2.3 for HDF5 and native UDUNITS2 fixes.
- Add projection-aware geographic vector, circle, and rectangle drawing commands.
- Share the RPM spec with the initial AlmaLinux 10 x86-64-v3 build target.
- Remove the obsolete outxwd and printim command aliases.

* Sun Jun 21 2026 CAMO packaging maintainers <noreply@example.invalid> - 2.2.1-1.camo26.0
- Add AlmaLinux 9 build support while retaining the common source and patches.
- Use distribution RPM compiler and linker flags on EL9.
- Require the Xmu development header used by the X11 display backend.

* Thu Jun 18 2026 CAMO packaging maintainers <noreply@example.invalid> - 2.2.1-1.camo26.0
- Prepare the initial unofficial CAMO EL8 downstream release.
- Build against distribution libraries and disable DAP/GADAP and libsx GUI.
- Include CAMO compatibility and drawing patches.
