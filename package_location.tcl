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
	set path [lindex [regexp -inline -- $re $res] 1]
	if {"$path" ne ""} {
	    set pkgDirName [lindex [file split [string map [list $distroLibDir/ {}] $path]] 0]
	    set pkgDir "${distroLibDir}/${pkgDirName}"
	    puts -nonewline "$p=$pkgDir "
	}
    }
}

catch {destroy .}
