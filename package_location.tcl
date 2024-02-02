#!/usr/bin/env tclsh

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
		set staticExtension [regexp {load\s+\{\}} $res]
		if {$staticExtension} {
			set pkgDir NA

		} else {
			set path [lindex [regexp -inline -- $re $res] 1]
			set pkgDirName [lindex [file split [string map [list $distroLibDir/ {}] $path]] 0]
			set pkgDir "${distroLibDir}/${pkgDirName}"
		}
		puts -nonewline "$p=$pkgDir "
	}
}

catch {destroy .}
