#!/usr/bin/env tclsh

# Copyright (c) 2024, Bandoti Ltd.
# SPDX-License-Identifier: BSD-3-Clause
# See LICENSE file for details.

if {$argc != 2} {
    puts "Usage: tclsh pack_deps.tcl <binary_file> <source_directory>"
    exit 1
}

# Get arguments
set binary_file [lindex $argv 0]
set source_dir [lindex $argv 1]

# Validate inputs
if {![file exists $binary_file]} {
    puts "Error: Binary file '$binary_file' does not exist"
    exit 1
}

if {![file exists $source_dir] || ![file isdirectory $source_dir]} {
    puts "Error: Source directory '$source_dir' does not exist or is not a directory"
    exit 1
}

# Load required package for virtual file system
if {[catch {package require vfs::mk4} err]} {
    puts "Error: Failed to load vfs::mk4 package: $err"
    puts "Please ensure MetaKit VFS package is installed"
    exit 1
}

# Set compression
set mk4vfs::compress 1

# Mount the virtual file system
puts "Mounting virtual file system from $binary_file..."
if {[catch {vfs::mk4::Mount $binary_file /files -nocommit} err]} {
    puts "Error: Failed to mount virtual file system: $err"
    exit 1
}

# Create lib directory if it doesn't exist
if {![file exists /files/lib]} {
    file mkdir /files/lib
    puts "Created /files/lib directory"
}

# Copy the source directory to the virtual file system
puts "Copying $source_dir to /files/lib/..."
if {[catch {file copy -force $source_dir /files/lib/} err]} {
    puts "Error: Failed to copy directory: $err"
    vfs::unmount /files
    exit 1
}

# Unmount the virtual file system
puts "Unmounting virtual file system..."
if {[catch {vfs::unmount /files} err]} {
    puts "Error: Failed to unmount virtual file system: $err"
    exit 1
}

puts "Operation completed successfully"
