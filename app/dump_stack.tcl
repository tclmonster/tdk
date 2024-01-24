# Copyright (c) 2018 ActiveState Software Inc.
# Released under the BSD-3 license. See LICENSE file for details.
#

proc dumpstack {} {
    set n [info level]
    set fd [open [file join $::tcldevkit::appRoot dump_stack.txt] a]
    puts $fd "$n Levels"
    for {set i 0} {$n > 0} {incr i -1 ; incr n -1} {
	puts $fd [info level $i]
    catch {close $fd}
    }
    exit
}
