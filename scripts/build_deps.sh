#!/usr/bin/env bash

fail() { printf 'error: %s\n' $1; exit 1; }

CFLAGS_PERMISSIVE="$CFLAGS -fpermissive -Wno-error=incompatible-function-pointer-types -Wno-error=incompatible-pointer-types -Wno-error=int-conversion -Wno-error=implicit-function-declaration"

build_dir="$(pwd)"/build

## Download pre-requisite Tcl/Tk SDK

kit_version=0.13.9
tcl_version=8.6.16
release_url="https://github.com/tclmonster/kitcreator/releases/download"
sdk_url="${release_url}/${kit_version}/libtclkit-sdk-${tcl_version}-x86_64-w64-mingw32.tar.gz"
sdk_dir="${build_dir}"/libtclkit-sdk-${tcl_version}

if test ! -f "${sdk_dir}"/lib/tclConfig.sh; then
    mkdir -p build 2>/dev/null

    curl -L "$sdk_url" | tar -xz -C build/

    if test ! -d "${sdk_dir}"/bin; then
        mkdir -p "${sdk_dir}"/bin  ;# In case the KitDLL has no bin
    fi
fi

kit_file="${sdk_dir}"/bin/tclsh.exe
kit_url="${release_url}/${kit_version}/tclkitsh-${tcl_version}-x86_64-w64-mingw32.exe"

if test ! -f "${build_dir}"/${kit_file}; then
    curl -L "${kit_url}" -o "${kit_file}"
fi

tcl_lib_dir="${build_dir}"/

## Common setup

configure() {
    ./configure --prefix="${sdk_dir}" --exec-prefix="${sdk_dir}" \
                --with-tclinclude="${sdk_dir}"/include --with-tkinclude="${sdk_dir}"/include \
                --with-tcl="${sdk_dir}"/lib --with-tk="${sdk_dir}"/lib \
                "$@"
}

## Download/build Img

img_version=2.0.1
img_dir="${build_dir}"/Img-${img_version}
img_url="https://download.sourceforge.net/project/tkimg/tkimg/2.0/tkimg%20${img_version}/Img-${img_version}.tar.gz"
img_sha256='e69d31b3f439a19071e3508a798b9d5dc70b9416e00926cdac12c1c2d50fce83'

if test ! -f "${img_dir}"/configure.ac; then
    curl -L "${img_url}" | tar -xz -C build/
fi

(
    cd "${img_dir}"
    configure --enable-symbols  ;# Without symbols libPNG is crashing?
    ${MAKE:-make}
    ${MAKE:-make} install-libraries

) || fail 'to build Img'

## Download/build tklib

tklib_version=0.9
tklib_dir="${build_dir}"/tklib-${tklib_version}
tklib_url="https://core.tcl-lang.org/tklib/attachdownload/tklib-${tklib_version}.tar.bz2?page=Downloads&file=tklib-${tklib_version}.tar.bz2"
tklib_sha256='dcce6ad0270fad87afe3dd915fb1387f25728451de8a6d1ef6b8240180819c2a'

if test ! -f "${tklib_dir}"/configure.in; then
    curl -L "${tklib_url}" | tar -xj -C build/
fi

(
    cd "${tklib_dir}"
    configure --with-tclsh="${kit_file}"
    ${MAKE:-make}
    ${MAKE:-make} install

) || fail 'to build tklib'

## Download/build bwidget

bwidget_version=1.10.1
bwidget_url="https://sourceforge.net/projects/tcllib/files/BWidget/${bwidget_version}/bwidget-${bwidget_version}.tar.gz/download"
bwidget_dir="${build_dir}"/bwidget-${bwidget_version}
bwidget_sha256='4aea02f38cf92fa4aa44732d4ed98648df839e6537d6f0417c3fe18e1a34f880'

if test ! -f "${bwidget_dir}"/README.txt; then
    curl -L "${bwidget_url}" | tar -xz -C build/
fi

( cp -Rf "${bwidget_dir}" "${sdk_dir}"/lib ) || fail 'to build bwidget'

## Download/build Tktable

tktable_url="https://github.com/tclmonster/tktable.git"
tktable_dir="${build_dir}"/tktable-magicsplat-1.8.0
tktable_sha256=''

if test ! -f "${tktable_dir}"/configure.in; then
    git clone -b tea-update "${tktable_url}" "${tktable_dir}" || fail 'to clone tktable'
fi

(
    cd "${tktable_dir}"
    export CFLAGS="$CFLAGS_PERMISSIVE"
    configure
    ${MAKE:-make}
    ${MAKE:-make} install

) || fail 'to build tktable'

## Download/build treectrl

treectrl_url="https://github.com/tclmonster/tktreectrl.git"
treectrl_dir="${build_dir}"/tktreectrl-magicsplat-1.8.0
treectrl_sha256=''

if test ! -f "${treectrl_dir}"/configure.ac; then
    git clone -b tea-update "${treectrl_url}" "${treectrl_dir}" || fail 'to clone treectrl'
fi

(
    cd "${treectrl_dir}"
    export CFLAGS="$CFLAGS_PERMISSIVE"
    configure
    ${MAKE:-make}
    ${MAKE:-make} install

) || fail 'to build tktreectrl'

## Download/build tbcload

tbcload_url="https://github.com/tclmonster/tbcload.git"
tbcload_dir="${build_dir}"/tbcload
tbcload_sha256=''

if test ! -f "${tbcload_dir}"/configure.ac; then
    git clone "${tbcload_url}" "${tbcload_dir}" || fail 'to clone tbcload'
fi

(
    cd "${tbcload_dir}"
    export CFLAGS="$CFLAGS_PERMISSIVE"
    configure
    ${MAKE:-make}
    ${MAKE:-make} install

) || fail 'to build tbcload'

## Download/build tclcompiler

tclcompiler_url="https://github.com/tclmonster/tclcompiler.git"
tclcompiler_dir="${build_dir}"/tclcompiler
tclcompiler_sha256=''

if test ! -f "${tclcompiler_dir}"/configure.ac; then
    git clone "${tclcompiler_url}" "${tclcompiler_dir}" || fail 'to clone tclcompiler'
fi

(
    cd "${tclcompiler_dir}"
    export CFLAGS="$CFLAGS_PERMISSIVE"
    configure
    ${MAKE:-make}
    ${MAKE:-make} install

) || fail 'to build tclcompiler'

## Download/build tclparser

tclparser_url="https://github.com/tclmonster/tclparser.git"
tclparser_dir="${build_dir}"/tclparser
tclparser_sha256=''

if test ! -f "${tclparser_dir}"/configure.ac; then
    git clone "${tclparser_url}" "${tclparser_dir}" || fail 'to clone tclparser'
fi

(
    cd "${tclparser_dir}"
    export CFLAGS="$CFLAGS_PERMISSIVE"
    configure
    ${MAKE:-make}
    ${MAKE:-make} install

) || fail 'to build tclparser'
