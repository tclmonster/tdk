#!/usr/bin/env tclsh

# Copyright (c) 2024, Bandoti Ltd. and contributors
# SPDX-License-Identifier: BSD-3-Clause
# See LICENSE file for details.


# This script is intended to be used by configure in order to
# locate a list of Tcl packages, by package name, in the invoked
# Tcl shell.

# In the future it may make sense to combine this with `external_pkgs.sh`
# and add the capability to TclApp so dependencies may be packaged
# during the wrap process.
#

set packages {}
if {$argc > 0} {
    lappend packages {*}$argv
} else {
    while {! [eof stdin]} {
	append packages [read stdin]
    }
}

set distroLibDir [file dirname $tcl_library]
set re [string map [list %DIR% $distroLibDir] {(?:source|load) (%DIR%[^\s]+)}]

foreach p $packages {
    if {! [catch {package ifneeded $p [package require $p]} res ropt]} {
		set version [package require $p]
		set staticExtension [regexp {load\s+\{\}} $res]
		if {$staticExtension} {
			set pkgDir NA

		} else {
			set path [lindex [regexp -inline -- $re $res] 1]
			set pkgDirName [lindex [file split [string map [list $distroLibDir/ {}] $path]] 0]
			set pkgDir "${distroLibDir}/${pkgDirName}"
		}
		puts -nonewline "$p=$version,$pkgDir "
	}
}

catch {destroy .}
