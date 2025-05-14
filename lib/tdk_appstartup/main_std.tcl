# Copyright (c) 2018 ActiveState Software Inc.
# Released under the BSD-3 license. See LICENSE file for details.
#
# -*- tcl -*-

# -------------------------------------------------------
# Standard actions taken by a TDK application on startup.

# Note that checking for unwrapped needs a sensible result from
# starkit::startup, this is true iff it is run from main.tcl,
# therefore it cannot be done here.
# -------------------------------------------------------
package provide tdk_appstartup 1.0

namespace eval ::tcldevkit {
if {"unwrapped" eq $::starkit::mode} {
    variable appRoot $::starkit::topdir
    variable tdkRoot [file dirname [file dirname $appRoot]]

    # Only unwrapped code needs the $appRoot/lib added
    # because it is different than the $tdkRoot/lib.
    lappend auto_path [file join $appRoot lib]

    foreach dumpScript {debug_require  debug_source  dump_packages  dump_stack} {
        if {[info exists ::tcldevkit::${dumpScript}] \
                && [set ::tcldevkit::${dumpScript}]} {
            source [file join $tdkRoot app ${dumpScript}.tcl]
        }
    }

    # Ensure the ../lib gets added when running from within bin
    lappend auto_path [file join \
                           [file dirname \
                                [file dirname \
                                     [info nameofexecutable]]] lib]
} else {

    # Wrapped applications use the default TclApp anchor so all
    # application-specific files are stored in lib/application.
    variable appRoot [file join $::starkit::topdir lib application]
    variable tdkRoot $::starkit::topdir
}

variable imageDir   [file join $tdkRoot data images]
variable artworkDir [file join $tdkRoot artwork]
}

proc go {file} {
    # ### ### ### ######### ######### #########
    ## Extend auto_path with the P-* directories in the
    ## tdkbase. Starpacks have that automatically done for them by
    ## TclApp, but the TDK tools are starkits and TclApp doesn't set
    ## them up for the stuff in their starpack interpreter.

    global auto_path
    foreach d $auto_path {
        foreach pd [glob -nocomplain -directory $d P-*] {
            lappend auto_path $pd
        }
    }

    # ### ### ### #########

    uplevel \#0 [list source $file]
    return
}
