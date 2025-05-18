#!/usr/bin/env bash

# Copyright (c) 2024, Bandoti Ltd.
# SPDX-License-Identifier: BSD-3-Clause
# See LICENSE file for details.

## This file is meant to be run from the source root

fail() { printf 'error: %s\n' $1; exit 1; }

CFLAGS_PERMISSIVE="$CFLAGS -fpermissive -Wno-error=incompatible-function-pointer-types -Wno-error=incompatible-pointer-types -Wno-error=int-conversion -Wno-error=implicit-function-declaration"

source_dir="$(pwd)"
build_dir="${source_dir}"/build

exe_ext=.exe
so_ext=.dll

## Download Tcl/Tk SDK
## ------------

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

if test ! -f "${kit_file}"; then
    curl -L "${kit_url}" -o "${kit_file}"
fi

# In case the KitDLL is stored in the lib directory it should
# be moved to the bin directory (alongside wish).

if test ! -f "${sdk_dir}"/bin/libtclkit*${so_ext}; then
    mv "${sdk_dir}"/lib/libtclkit*${so_ext} "${sdk_dir}"/bin/
fi

tcl_lib_dir="${build_dir}"/

## Common setup
## ------------

configure() {
    ./configure --prefix="${sdk_dir}" --exec-prefix="${sdk_dir}" \
                --with-tclinclude="${sdk_dir}"/include --with-tkinclude="${sdk_dir}"/include \
                --with-tcl="${sdk_dir}"/lib --with-tk="${sdk_dir}"/lib \
                "$@"
}

pack() {
    "${kit_file}" "${source_dir}"/scripts/pack_deps.tcl "${sdk_dir}"/bin/libtclkit*${so_ext} "$@"
}

## Download/build Img
## ------------

img_version=2.0.1
img_dir="${build_dir}"/Img-${img_version}
img_url="https://download.sourceforge.net/project/tkimg/tkimg/2.0/tkimg%20${img_version}/Img-${img_version}.tar.gz"
img_sha256='e69d31b3f439a19071e3508a798b9d5dc70b9416e00926cdac12c1c2d50fce83'

if test ! -f "${img_dir}"/configure.ac; then
    curl -L "${img_url}" | tar -xz -C build/
fi

if test ! -f "${sdk_dir}"/lib/Img*/pngtcl*${so_ext}; then
    (
        cd "${img_dir}"
        configure --enable-symbols  ;# Without symbols libPNG is crashing?
        ${MAKE:-make}
        ${MAKE:-make} install-libraries
        pack "${sdk_dir}"/lib/Img*

    ) || fail 'to build Img'
fi

## Download/build tklib
## ------------

tklib_version=0.9
tklib_dir="${build_dir}"/tklib-${tklib_version}
tklib_url="https://core.tcl-lang.org/tklib/attachdownload/tklib-${tklib_version}.tar.bz2?page=Downloads&file=tklib-${tklib_version}.tar.bz2"
tklib_sha256='dcce6ad0270fad87afe3dd915fb1387f25728451de8a6d1ef6b8240180819c2a'

if test ! -f "${tklib_dir}"/configure.in; then
    curl -L "${tklib_url}" | tar -xj -C build/
fi

if test ! -f "${sdk_dir}"/lib/tklib*/pkgIndex.tcl; then
    (
        cd "${tklib_dir}"
        configure --with-tclsh="${kit_file}"
        ${MAKE:-make}
        ${MAKE:-make} install
        pack "${sdk_dir}"/lib/tklib*

    ) || fail 'to build tklib'
fi

## Download/build bwidget
## ------------

bwidget_version=1.10.1
bwidget_url="https://sourceforge.net/projects/tcllib/files/BWidget/${bwidget_version}/bwidget-${bwidget_version}.tar.gz/download"
bwidget_dir="${build_dir}"/bwidget-${bwidget_version}
bwidget_sha256='4aea02f38cf92fa4aa44732d4ed98648df839e6537d6f0417c3fe18e1a34f880'

if test ! -f "${bwidget_dir}"/README.txt; then
    curl -L "${bwidget_url}" | tar -xz -C build/
fi

if test ! -f "${sdk_dir}"/lib/bwidget*/notebook.tcl; then
    (
        cp -Rf "${bwidget_dir}" "${sdk_dir}"/lib
        pack "${sdk_dir}"/lib/bwidget*

    ) || fail 'to build bwidget'
fi

## Download/build Tktable
## ------------

tktable_url="https://github.com/tclmonster/tktable.git"
tktable_dir="${build_dir}"/tktable-magicsplat-1.8.0
tktable_sha256=''

if test ! -f "${tktable_dir}"/configure.ac; then
    git clone -b tea-update "${tktable_url}" "${tktable_dir}" || fail 'to clone tktable'
fi

if test ! -f "${sdk_dir}"/lib/Tktable*/Tktable*${so_ext}; then
    (
        cd "${tktable_dir}"
        export CFLAGS="$CFLAGS_PERMISSIVE"
        configure
        ${MAKE:-make}
        ${MAKE:-make} install
        pack "${sdk_dir}"/lib/Tktable*

    ) || fail 'to build tktable'
fi

## Download/build treectrl
## ------------

treectrl_url="https://github.com/tclmonster/tktreectrl.git"
treectrl_dir="${build_dir}"/tktreectrl-magicsplat-1.8.0
treectrl_sha256=''

if test ! -f "${treectrl_dir}"/configure.ac; then
    git clone -b tea-update "${treectrl_url}" "${treectrl_dir}" || fail 'to clone treectrl'
fi

if test ! -f "${sdk_dir}"/lib/treectrl*/treectrl*${so_ext}; then
    (
        cd "${treectrl_dir}"
        export CFLAGS="$CFLAGS_PERMISSIVE"
        configure
        ${MAKE:-make}
        ${MAKE:-make} install
        pack "${sdk_dir}"/lib/treectrl*

    ) || fail 'to build tktreectrl'
fi

## Download/build tbcload
## ------------

tbcload_url="https://github.com/tclmonster/tbcload.git"
tbcload_dir="${build_dir}"/tbcload
tbcload_sha256=''

if test ! -f "${tbcload_dir}"/configure.ac; then
    git clone "${tbcload_url}" "${tbcload_dir}" || fail 'to clone tbcload'
fi

if test ! -f "${sdk_dir}"/lib/tbcload*/tbcload*${so_ext}; then
    (
        cd "${tbcload_dir}"
        configure
        ${MAKE:-make}
        ${MAKE:-make} install
        pack "${sdk_dir}"/lib/tbcload*

    ) || fail 'to build tbcload'
fi

## Download/build tclcompiler
## ------------

tclcompiler_url="https://github.com/tclmonster/tclcompiler.git"
tclcompiler_dir="${build_dir}"/tclcompiler
tclcompiler_sha256=''

if test ! -f "${tclcompiler_dir}"/configure.ac; then
    git clone "${tclcompiler_url}" "${tclcompiler_dir}" || fail 'to clone tclcompiler'
fi

if test ! -f "${sdk_dir}"/lib/tclcompiler*/tclcompiler*${so_ext}; then
    (
        cd "${tclcompiler_dir}"
        configure
        ${MAKE:-make}
        ${MAKE:-make} install
        pack "${sdk_dir}"/lib/tclcompiler*

    ) || fail 'to build tclcompiler'
fi

## Download/build tclparser
## ------------

tclparser_url="https://github.com/tclmonster/tclparser.git"
tclparser_dir="${build_dir}"/tclparser
tclparser_sha256=''

if test ! -f "${tclparser_dir}"/configure.ac; then
    git clone "${tclparser_url}" "${tclparser_dir}" || fail 'to clone tclparser'
fi

if test ! -f "${sdk_dir}"/lib/tclparser*/tclparser*${so_ext}; then
    (
        cd "${tclparser_dir}"
        configure
        ${MAKE:-make}
        ${MAKE:-make} install
        pack "${sdk_dir}"/lib/tclparser*

    ) || fail 'to build tclparser'
fi

## Download/build Tclx
## ------------

tclx_url="https://github.com/tclmonster/tclx.git"
tclx_dir="${build_dir}"/tclx
tclx_sha256=''

if test ! -f "${tclx_dir}"/configure.in; then
    git clone "${tclx_url}" "${tclx_dir}" || fail 'to clone tclx'
fi

if test ! -f "${sdk_dir}"/lib/tclx*/tclx*${so_ext}; then
    (
        cd "${tclx_dir}"
        configure
        ${MAKE:-make}
        ${MAKE:-make} install
        pack "${sdk_dir}"/lib/tclx*

    ) || fail 'to build tclx'
fi

## Copy wish & libtclkit so it may be used in TDK build
## ------------

cp -f "${sdk_dir}"/bin/wish${exe_ext} "${source_dir}"/
cp -f "${sdk_dir}"/bin/libtclkit*${so_ext} "${source_dir}"/
