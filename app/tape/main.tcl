# Copyright (c) 2018 ActiveState Software Inc.
# Released under the BSD-3 license. See LICENSE file for details.
#
# TAPE - .tap Editor
#

package require starkit
if {"unwrapped" eq [starkit::startup]} {
    # Unwrapped call is during build - tap scan/generate.  Other
    # unwrapped calls are during development from within the local
    # perforce depot area. Slightly different location of lib dir.
    # Hence we use two stanza's to define an externa lib directory.
    # Debug output is allowed, actually sort of wanted to be sure of
    # package locations.

    puts stderr unwrapped\n[join $auto_path \n\t]

    namespace eval ::tcldevkit { variable debug_require 0 }
    namespace eval ::tcldevkit { variable debug_source  0 }
    namespace eval ::tcldevkit { variable dump_packages 0 }
    namespace eval ::tcldevkit { variable dump_stack    0 }

    lappend auto_path [file join [file dirname [file dirname $::starkit::topdir]] lib]

} else {
    # Path expected after wrapping with TclApp
    lappend auto_path [file join $::starkit::topdir lib application lib]
}

package require tdk_appstartup

package require splash
splash::configure -message "Tcl Dev Kit TAPE"
splash::configure -imagefile [file join $::tcldevkit::tdkRoot artwork splash.png]

set startup [file join $::tcldevkit::appRoot lib app-tape tape_startup.tcl]
go $startup
