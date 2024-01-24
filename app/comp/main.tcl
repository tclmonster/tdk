# Copyright (c) 2018 ActiveState Software Inc.
# Released under the BSD-3 license. See LICENSE file for details.
#
# Comp * Entry
# - Initialization of wrap support (VFS, Mk4FS foundation, ...)
# - Invokation of the actual application.
# - (Inactive code for the debugging of the package management, and file sourcery.)

package require starkit
if {"unwrapped" eq [starkit::startup]} {
    # Unwrapped call is during build - tap scan/generate.  Other
    # unwrapped calls are during development from within the local
    # perforce depot area. Slightly different location of lib dir.
    # Hence we use two stanza's to define an externa lib directory.
    # Debug output is allowed, actually sort of wanted to be sure of
    # package locations.

    puts stderr unwrapped\n[join $auto_path \n\t]

    # Trace exactly which packages are required during execution
    #source [file join [pwd] [file dirname [file dirname [info script]]] debug_require.tcl]

    # Trace exactly which files are read via source.
    #source [file join [pwd] [file dirname [file dirname [info script]]] debug_source.tcl]

    # Dump loaded packages when exiting the application
    #source [file join [pwd] [file dirname [file dirname [info script]]] dump_packages.tcl]

    # Dump stack
    #source [file join [pwd] [file dirname [file dirname [info script]]] dump_stack.tcl]

    lappend auto_path [file join [file dirname [file dirname $::starkit::topdir]] lib]

} else {
    # Path expected after wrapping with TclApp
    lappend auto_path [file join $::starkit::topdir lib application lib]
}

package require tdk_appstartup

package require splash
splash::configure -message "Tcl Dev Kit Compiler"
splash::configure -imagefile [file join $::tcldevkit::tdkRoot artwork splash.png]

set startup [file join $::tcldevkit::appRoot lib app-comp comp_startup.tcl]

# ### ### ### ######### ######### #########
## We load Tclx so that the compiler code will have access to the new
## math functions of this package. Without this we cannot compile code
## using Tclx math functions, they would be syntax errors.

## This is a bit of a hack. A generic solution would allow the user to
## preload packages for compiling, but this can become a security
## nightmare. For now only Tclx is known to define new math functions,
## and is safe, so we go for the hack.

# This is done by 'go' as well, but comes too late for Tclx.
global auto_path
foreach d $auto_path {
    foreach pd [glob -nocomplain -directory $d P-*] {
	lappend auto_path $pd
    }
}

package require Tclx

##
# ### ### ### ######### ######### #########

# Hand over to the actual application.

go $startup
