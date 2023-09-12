# Copyright (c) 2018 ActiveState Software Inc.
# Released under the BSD-3 license. See LICENSE file for details.
#

set self [file dirname [file dirname [file dirname [file normalize [info script]]]]]

package require starkit
if {"unwrapped" eq [starkit::startup]} {
    lappend auto_path [file join $self lib]
    # External standard actions
    source [file join $self app main_std.tcl]
    puts stderr unwrapped\n[join $auto_path \n\t]
}
starkit::startup
package require app-listmfs
