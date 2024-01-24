# Copyright (c) 2018 ActiveState Software Inc.
# Released under the BSD-3 license. See LICENSE file for details.
#
# TclApp * Entry
# - Initialization of wrap support (VFS, Mk4FS foundation, ...)
# - License check
# - Invokation of the actual application.
# - (Inactive code for the debugging of the package management, and file sourcery.)


# Trace exactly which packages are required during execution
#source [file join [pwd] [file dirname [file dirname [info script]]] debug_require.tcl]

# Trace exactly which files are read via source.
#source [file join [pwd] [file dirname [file dirname [info script]]] debug_source.tcl]

# Dump loaded packages when exiting the application
#source [file join [pwd] [file dirname [file dirname [info script]]] dump_packages.tcl]

# Dump stack
#source [file join [pwd] [file dirname [file dirname [info script]]] dump_stack.tcl]

package require starkit
if {![info exists ::starkit::mode] || ("unwrapped" eq $::starkit::mode)} {
    # Unwrapped call is during build - tap scan/generate.  Other
    # unwrapped calls are during development from within the local
    # perforce depot area. Slightly different location of lib dir.
    # Hence we use two stanza's to define an externa lib directory.
    # Debug output is allowed, actually sort of wanted to be sure of
    # package locations.

    starkit::startup
    set tdkRoot [file dirname [file dirname $starkit::topdir]]
    lappend auto_path [file join $tdkRoot devkit lib]
    lappend auto_path [file join $tdkRoot lib]

    package require tclcompiler

    #package require teapot::link
    #::teapot::link::use ~/Abuild/lib/teapot-build
    #::teapot::link::use ~/Abuild/lib/teapot-build-save-core

    puts stderr unwrapped\n[join $auto_path \n\t]

    package require splash
    splash::configure -message DEVEL
    splash::configure -imagefile [file join $tdkRoot artwork splash.png]

    set startup [file join $tdkRoot app tclapp \
        lib app-tclapp tclapp_startup.tcl]

} else {
    # Wrapped standard actions.
    set appRoot [file join $starkit::topdir lib application]
    lappend auto_path [file join $appRoot lib]
    package require splash
    splash::configure -message "Tcl Dev Kit TclApp"
    splash::configure -imagefile [file join $appRoot artwork splash.png]
    set startup [file join $appRoot lib app-tclapp tclapp_startup.tcl]
}

package require tdk_appstartup
go $startup
