#!/bin/sh

root_dir="$1"

grep_cmd="grep -E -ohR --exclude-dir=tests"

required=
provided=
for dir in lib app; do
    _more_required=$($grep_cmd '^\s*package\s+require\s+[[:alnum:]:_]+' $root_dir/$dir \
			 | sort | uniq | sed -nr 's!\s*package\s+require\s+!!p')
    for pkg in $_more_required; do
	required="$required $pkg"
    done

    # Regexp for provided packages can be a bit more forgiving since there may be
    # more complex patterns prior to the "package provide" statement.

    _more_provided=$($grep_cmd 'package\s+(provide|ifneeded)\s+[[:alnum:]:_]+' $root_dir/$dir \
			 | sort | uniq \
			 | sed -nr -e 's!\s*package\s+provide\s+!!p' \
			       -e 's!\s*package\s+ifneeded\s+!!p')

    for pkg in $_more_provided; do
	provided="$provided $pkg"
    done
done

external=
for pkg in $required; do
    pending="$pkg"
    for ppkg in $provided; do
	if test "$pkg" = "$ppkg"; then
	    pending=
	    break
	fi
    done
    if test -n "$pending"; then
	external="$external $pending"
    fi
done

echo $external
