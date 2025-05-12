#!/usr/bin/env bash

fail() { printf 'error: %s\n' $1; exit 1; }

export CFLAGS="$CFLAGS -fpermissive -Wno-error=incompatible-function-pointer-types -Wno-error=incompatible-pointer-types -Wno-error=int-conversion -Wno-error=implicit-function-declaration"

build_dir="$(pwd)"/build

## Download pre-requisite Tcl/Tk SDK

kit_version=0.13.7
tcl_version=8.6.16
release_url="https://github.com/tclmonster/kitcreator/releases/download"
sdk_url="${release_url}/${kit_version}/libtclkit-sdk-${tcl_version}-x86_64-w64-mingw32.tar.gz"
sdk_dir="${build_dir}"/libtclkit-sdk-${tcl_version}

kit_file="tclkitsh-${tcl_version}-x86_64-w64-mingw32.exe"
kit_url="${release_url}/${kit_version}/${kit_file}"

if ! test -f "${sdk_dir}"/lib/tclConfig.sh; then
    mkdir -p build 2>/dev/null

    curl -L "$sdk_url" | tar -xz -C build/
fi

if ! test -f "${build_dir}"/${kit_file}; then
    curl -L "$kit_url" -o "${build_dir}"/${kit_file}
fi

tcl_lib_dir="${build_dir}"/

## Download/build Img

img_version=2.0.1
img_dir="${build_dir}"/Img-${img_version}
img_url="https://download.sourceforge.net/project/tkimg/tkimg/2.0/tkimg%20${img_version}/Img-${img_version}.tar.gz"
img_sha256='e69d31b3f439a19071e3508a798b9d5dc70b9416e00926cdac12c1c2d50fce83'

if ! test -f "${img_dir}"/configure.ac; then
    curl -L "${img_url}" | tar -xz -C build/
fi

( exit 0
    cd "${img_dir}"
    ./configure --with-tclinclude="${sdk_dir}"/include --with-tkinclude="${sdk_dir}"/include \
		--prefix="${sdk_dir}" --exec-prefix="${sdk_dir}"

    ${MAKE:-make}
    ${MAKE:-make} install-libraries

) || fail 'to build Img'

## Download/build tklib

tklib_version=0.9
tklib_dir="${build_dir}"/tklib-${tklib_version}
tklib_url="https://core.tcl-lang.org/tklib/attachdownload/tklib-${tklib_version}.tar.bz2?page=Downloads&file=tklib-${tklib_version}.tar.bz2"
tklib_sha256='dcce6ad0270fad87afe3dd915fb1387f25728451de8a6d1ef6b8240180819c2a'

if ! test -f "${tklib_dir}"/configure.in; then
    curl -L "${tklib_url}" | tar -xj -C build/
fi

( exit 0
    cd "${tklib_dir}"
    ./configure --with-tclsh="${build_dir}"/${kit_file} \
		--prefix="${sdk_dir}" --exec-prefix="${sdk_dir}"

    ${MAKE:-make}
    ${MAKE:-make} install

) || fail 'to build tklib'

## Download/build bwidget

bwidget_version=1.10.1
bwidget_url="https://sourceforge.net/projects/tcllib/files/BWidget/${bwidget_version}/bwidget-${bwidget_version}.tar.gz/download"
bwidget_dir="${build_dir}"/bwidget-${bwidget_version}
bwidget_sha256='4aea02f38cf92fa4aa44732d4ed98648df839e6537d6f0417c3fe18e1a34f880'

if ! test -f "${bwidget_dir}"/README.txt; then
    curl -L "${bwidget_url}" | tar -xz -C build/
fi

( exit 0
    cp -Rf "${bwidget_dir}" "${sdk_dir}"/lib

) || fail 'to build bwidget'

## Download/build Tktable

tktable_url="https://github.com/apnadkarni/tktable/archive/refs/tags/magicsplat-1.8.0.tar.gz"
tktable_dir="${build_dir}"/tktable-magicsplat-1.8.0
tktable_sha256='1408e16d66faa7a6618b7865ebfc2123e24c0a2758bd6ce7e0e88bbc324fe289'

if test ! -f "${tktable_dir}"/configure.in; then
    curl -L "${tktable_url}" | tar -xz -C build/
fi

( exit 0
    cd "${tktable_dir}"
    ./configure --with-tcl="${sdk_dir}"/lib --with-tk="${sdk_dir}"/lib \
		--with-tclinclude="${sdk_dir}"/include --with-tkinclude="${sdk_dir}"/include \
		--prefix="${sdk_dir}" --exec-prefix="${sdk_dir}"

    ${MAKE:-make}
    ${MAKE:-make} install-libraries

) || fail 'to build tktable'

## Download/build treectrl

treectrl_url="https://github.com/tclmonster/tktreectrl/archive/refs/tags/magicsplat-1.8.0.tar.gz"
treectrl_dir="${build_dir}"/tktreectrl-magicsplat-1.8.0
treectrl_sha256='e0c1a9d14b1c742c9490d7164c538b429b7fc269042840b8f75edca31337e0c5'

if test ! -f "${treectrl_dir}"/configure.ac; then
    curl -L "${treectrl_url}" | tar -xz -C build/
fi

(
    # TODO: Makefile:
    # Need to do an upgrade to entire TEA setup. There's multiple failures due to
    # old macros and so-forth, along with invalid platform-detection logic.

    cd "${treectrl_dir}"
    autoreconf
    ./configure --with-tcl="${sdk_dir}"/lib --with-tk="${sdk_dir}"/lib \
		--with-tclinclude="${sdk_dir}"/include --with-tkinclude="${sdk_dir}"/include \
		--prefix="${sdk_dir}" --exec-prefix="${sdk_dir}" \
		--disable-shellicon

    ${MAKE:-make}
    ${MAKE:-make} install

) || fail 'to build tktreectrl'
