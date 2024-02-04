
AC_INIT([tcl-dev-kit], [8.0])

TEA_INIT([3.7])

# There are two ways to invoke configure:
# 1. Supplying a full Tcl distribution (ActiveTcl, Magicsplat, BAWT).
#    In this case it is expected that all dependencies save for "tclcompiler"
#    and "tclparser" will be supplied by the distro. Running configure
#    and make will compile these two extensions and store them directly
#    in the resultant Starkits (along with their TDK dependencies).
#
# 2. Supplying a full Tcl distribution + TclKit.
#    Here the same steps as above are followed, except instead of
#    generating a Starkit, a Starpack will be generated using the supplied
#    TclKit as the "basekit" for generating the Starpack executable.
#    A check for dependencies will be completed and anything missing
#    from the TclKit will be supplied by the distribution.
#

TEA_PATH_TCLCONFIG
TEA_LOAD_TCLCONFIG

# Tk config checks are intentionally skipped because nmake builds
# do not (as of 8.6.13) generate tkConfig.sh files. Consequently this
# will fail for ActiveTcl, Magicsplat, et cetera. As a workaround it
# is simply assumed that the `wish` executable is located alongside
# the `tclsh` executable.

TEA_SETUP_COMPILER
TEA_ENABLE_THREADS
TEA_ENABLE_SHARED
TEA_CONFIG_CFLAGS
TEA_ENABLE_SYMBOLS

AC_PROG_AWK

TDK_TAP_DIR="$($CYGPATH $(cd $srcdir; pwd))"
AC_SUBST(TDK_TAP_DIR)

AC_MSG_CHECKING([for tclkit])
AC_ARG_WITH(tclkit,
	AS_HELP_STRING([--with-tclkit],
		[tclkit used for generating all TDK Starpacks]),
	[with_tclkit="${withval}"],
	[with_tclkit=no])

if test "$with_tclkit" = "no"; then
	AC_MSG_RESULT([none])
	TDK_TCLKIT=""
	TDK_KIT_EXT=".tcl"
else
	AC_MSG_RESULT([found "${with_tclkit}"])
	TDK_TCLKIT="$($CYGPATH "$with_tclkit")"
	TDK_KIT_EXT="$EXEEXT"
fi

TDK_TCLSH_PROG="$($CYGPATH ${TCL_BIN_DIR}/../bin/tclsh${EXEEXT})"
TDK_WISH_PROG="$($CYGPATH ${TCL_BIN_DIR}/../bin/wish${EXEEXT})"

AC_SUBST(TDK_TCLKIT)
AC_SUBST(TDK_KIT_EXT)
AC_SUBST(TDK_TCLSH_PROG)
AC_SUBST(TDK_WISH_PROG)

AC_MSG_CHECKING([for required external packages])
AC_CACHE_VAL(tdk_cv_required_pkgs, [
	tdk_cv_required_pkgs="$($SHELL $srcdir/scripts/external_pkgs.sh "$srcdir")"
])
if test -n "$tdk_cv_required_pkgs"; then
	AC_MSG_RESULT([
------------------------------
$tdk_cv_required_pkgs
------------------------------])
else
	AC_MSG_RESULT([none found])
fi

AC_MSG_CHECKING([packages provided by "$TDK_TCLSH_PROG"])
AC_CACHE_VAL(tdk_cv_distro_pkgs, [
	tdk_cv_distro_pkgs="$(echo "$tdk_cv_required_pkgs" | $TDK_TCLSH_PROG $srcdir/scripts/package_location.tcl)"
])
if test -n "$tdk_cv_distro_pkgs"; then
	AC_MSG_RESULT([
------------------------------
$tdk_cv_distro_pkgs
------------------------------])
else
	AC_MSG_RESULT([none])
fi

AC_MSG_CHECKING([packages provided by TclKit])
AC_CACHE_VAL(tdk_cv_kit_pkgs, [
	if test "$with_tclkit" = "no"; then
		tdk_cv_kit_pkgs=
	else
		tdk_cv_kit_pkgs="$(echo "$tdk_cv_required_pkgs" | $TDK_TCLKIT $srcdir/scripts/package_location.tcl)"
	fi
])
if test -n "$tdk_cv_kit_pkgs"; then
	AC_MSG_RESULT([
------------------------------
$tdk_cv_kit_pkgs
------------------------------])
else
	AC_MSG_RESULT([none])
fi

TDK_EXTRA_DISTRO_PKGS=
if test "$with_tclkit" != "no" -a -n "$tdk_cv_distro_pkgs"; then
AC_MSG_NOTICE([creating DistroPackages.tap])

distro_pkg_name() {
	echo "$1" | awk -F= '{print $1}'
}

distro_pkg_version() {
	echo "$1" | awk -F= '{print $2}' | awk -F, '{print $1}'
}

distro_pkg_path() {
	echo "$1" | awk -F= '{print $2}' | awk -F, '{print $2}'
}

distro_tap_header() {
	local version="$PACKAGE_VERSION"
	local timestamp="$(date)"
	local user="$(id -un)"
	cat <<EOF > $srcdir/DistroPackages.tap
format  {TclDevKit Project File}
fmtver  2.0
fmttool {TclDevKit TclApp PackageDefinition} $version

##  Saved at : $timestamp
##  By       : $user

########
#####
###
##
#

EOF
}

distro_tap_footer() {
	cat <<'EOF' >> $srcdir/DistroPackages.tap

#
##
###
#####
########

EOF
}

distro_tap_append() {
	echo "$1" >> $srcdir/DistroPackages.tap
}

distro_pkg_append() {
	TDK_EXTRA_DISTRO_PKGS="${TDK_EXTRA_DISTRO_PKGS} $1"
}

gen_distro_tap_file_and_pkg_list() {
	local missing=
	local projects=
	local pkgRef=
	local pkgName=
	local pkgPath=
	local pkgVersion=

	for pkg in $tdk_cv_required_pkgs; do
		if ! echo "$tdk_cv_kit_pkgs" | grep -q "$pkg="; then
			missing="$missing $pkg"
		fi
	done

	# Collect list of missing packages which are provided
	# by the Tcl distribution.

	missing="$(echo "$missing" | sed 's/ /\n/g' | $AWK "\
		BEGIN { \
			split(\"$tdk_cv_distro_pkgs\", tmp, \" \"); \
			for (i in tmp) { \
				match(tmp[[i]], /([[^=]]+)=(.+)/, m); \
				distro_pkgs[[m[1]]] = m[[2]]; \
			} \
		} { \
			if (\$1 in distro_pkgs) { \
				printf \"%s=%s\\n\", \$1, distro_pkgs[[\$1]]; \
			} \
		}" \
	| sort | uniq)"

	distro_tap_header

	# Because packages may be nested only the first package which
	# contains a given path will copy the files. Note that within
	# the TAP file the logical ordering of packages may not be
	# intuitive because it does not matter *which* package of
	# a series of nested packages contains the files.

	local completed=
	local deferred=
	for pkg in $missing; do
		pkgName="$(distro_pkg_name "$pkg")"
		pkgPath="$(distro_pkg_path "$pkg")"
		pkgVersion="$(distro_pkg_version "$pkg")"
		if ! echo "$projects" | grep -Fq "$pkgName"; then
			if echo "$completed" | grep -Fq "$pkgPath"; then
				deferred="$deferred $pkg"
				continue
			fi
			distro_tap_append "Package	{$pkgName $pkgVersion}"
			distro_tap_append "Base	$pkgPath"

			for file in $(find "$pkgPath" -type f); do
				file="${file#"$pkgPath/"}"
				distro_tap_append "Path	$file"
			done

			distro_pkg_append "$pkgName"

			projects="$projects $pkgName"
			completed="$completed $pkg"
		fi
	done

	# Remaining packages need only reference the files contained
	# in the previously-populated package.

	local refName=
	local refPath=
	for pkg in $deferred; do
		pkgName="$(distro_pkg_name "$pkg")"
		pkgVersion="$(distro_pkg_version "$pkg")"
		pkgPath="$(distro_pkg_path "$pkg")"
		for refPkg in $completed; do
			refPath="$(distro_pkg_path "$refPkg")"
			refName="$(distro_pkg_name "$refPkg")"
			if test "$refPath" = "$pkgPath"; then
				distro_tap_append "Package	{$pkgName $pkgVersion}"
				distro_tap_append "See	$refName"

				distro_pkg_append "$pkgName"
			fi
		done
	done

	distro_tap_footer
}

gen_distro_tap_file_and_pkg_list

if test -n "$TDK_EXTRA_DISTRO_PKGS"; then
	AC_MSG_NOTICE([including packages from DistroPackages.tap
------------------------------
$TDK_EXTRA_DISTRO_PKGS
------------------------------])
else
	AC_MSG_WARN([no packages to include from DistroPackages.tap])
fi
fi

AC_SUBST(TDK_EXTRA_DISTRO_PKGS)

AC_CONFIG_SUBDIRS([lib/tbcload lib/tclcompiler lib/tclparser])

AC_CONFIG_FILES([
   Makefile
   TclCompiler.tap
   TdkPackages.tap
])

AC_OUTPUT
