# Copyright (c) 2018 ActiveState Software Inc.
# Released under the BSD-3 license. See LICENSE file for details.
#
# Debugging 'package require' invokations
# ---------------------------------------

rename ::package ::__package
proc ::package {args} {
    if {[lindex $args 0] eq "require"} {
    set fd [open [file join $::tcldevkit::appRoot debug_require.txt] a]
	puts $fd ">>> [info script]"
	puts $fd "    package $args"
	puts $fd ""
    catch {close $fd}
    }
    return [uplevel 1 [linsert $args 0 ::__package]]
}
