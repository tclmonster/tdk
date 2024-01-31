
AC_INIT([tcl-dev-kit], [7.0])

TEA_INIT([3.7])

# There are three ways to invoke configure:
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
# 3. Only supplying a TclKit.
#    In this case, all Tcl Dev Kit applications will be be packed into
#    Starpacks (skipping the compile steps mentioned in 1 above). This
#    means that if dependencies are not statically linked to the TclKit
#    or provided in the "tdkRoot/lib" directory the build will fail.
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

TDK_TAP_DIR=`$CYGPATH $(cd $srcdir; pwd)`
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
	TDK_TCLKIT=`$CYGPATH "$with_tclkit"`
	TDK_KIT_EXT="$EXEEXT"
fi

TDK_TCLSH_PROG=`$CYGPATH ${TCL_BIN_DIR}/../bin/tclsh${EXEEXT}`
TDK_WISH_PROG=`$CYGPATH ${TCL_BIN_DIR}/../bin/wish${EXEEXT}`

AC_SUBST(TDK_TCLKIT)
AC_SUBST(TDK_KIT_EXT)
AC_SUBST(TDK_TCLSH_PROG)
AC_SUBST(TDK_WISH_PROG)

AC_MSG_CHECKING([for required external packages])
AC_CACHE_VAL(tdk_cv_required_pkgs, [
	tdk_cv_required_pkgs=`$SHELL $srcdir/external_pkgs.sh "$srcdir"`
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
	tdk_cv_distro_pkgs=`echo "$tdk_cv_required_pkgs" | $TDK_TCLSH_PROG $srcdir/package_location.tcl`
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
		tdk_cv_kit_pkgs=`echo "$tdk_cv_required_pkgs" | $TDK_TCLKIT $srcdir/package_location.tcl`
	fi
])

TDK_EXTRA_FILES=
if test -n "$tdk_cv_kit_pkgs"; then
	AC_MSG_RESULT([
------------------------------
$tdk_cv_kit_pkgs
------------------------------])
	find_extra_tclapp_globs() {
		local missing=
		local pkgname=
		local pkgloc=
		local copythese=
		local extraglobs=
		for pkg in $tdk_cv_required_pkgs; do
			if ! test `echo "$tdk_cv_kit_pkgs" | grep -q "$pkg"`; then
				missing="$missing $pkg"
			fi
		done
		for pkg in $missing; do
			for pair in $tdk_cv_distro_pkgs; do
				pkgname=`echo "$pair" | cut -d= -f1`
				pkgloc=`echo "$pair" | cut -d= -f2`
				if test "$pkgname" = "$pkg"; then
					copythese="$copythese $pkgloc"
					break
				fi
			done
		done
		for dir in $copythese; do
			for subdir in `find "$dir" -type d`; do
				extraglobs="$extraglobs $subdir"
			done
		done
		return "$extraglobs"
	}
#	TDK_EXTRA_FILES=`find_extra_tclapp_globs`
	AC_MSG_NOTICE([
------------------------------
$TDK_EXTRA_FILES
------------------------------])
else
	AC_MSG_RESULT([none])
fi
AC_SUBST(TDK_EXTRA_FILES)

#AC_CONFIG_SUBDIRS([
#   lib/tbcload
#   lib/tclcompiler
#   lib/tclparser
#])

AC_CONFIG_FILES([
   Makefile
   TclCompiler.tap
   TdkPackages.tap
])

AC_OUTPUT
