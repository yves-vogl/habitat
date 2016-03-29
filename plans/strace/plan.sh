pkg_name=strace
pkg_origin=chef
pkg_version=4.11
pkg_license=('strace')
pkg_source=http://downloads.sourceforge.net/project/strace/strace/${pkg_version}/strace-${pkg_version}.tar.xz
pkg_shasum=e86a5f6cd8f941f67f3e4b28f4e60f3d9185c951cf266404533210a2e5cd8152
pkg_gpg_key=3853DA6B
pkg_deps=(chef/glibc)
pkg_bin_dirs=(bin)
pkg_build_deps=(chef/coreutils chef/make chef/gcc)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
