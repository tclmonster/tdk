# Copyright (c) 2018 ActiveState Software Inc.
# Released under the BSD-3 license. See LICENSE file for details.
#
# Debugging source invokations
# ----------------------------

rename ::source ::__source
proc ::source {args} {
    set fd [open [file join $::tcldevkit::appRoot debug_source.txt] a]
    puts $fd "SOURCE [join $args]"
    catch {close $fd}
    uplevel 1 ::__source $args
}
