
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

AC_ARG_WITH(tclkit,
   AS_HELP_STRING([--with-tclkit],
      [tclkit used for generating all TDK Starpacks]),
   [with_tclkit="${withval}"],
   [with_tclkit=no])

if test "$with_tclkit" = "no"; then
   AC_MSG_NOTICE([no TclKit supplied - generate Starkits])
   TDK_TCLKIT=""
else
   AC_MSG_NOTICE([TclKit supplied: ${with_tclkit} - generate Starpacks])
   TDK_TCLKIT="$with_tclkit"
fi

TDK_TCLSH_PROG="${TCL_BIN_DIR}/../bin/tclsh${EXEEXT}"
TDK_WISH_PROG="${TCL_BIN_DIR}/../bin/wish${EXEEXT}"

AC_SUBST(TDK_TCLKIT)
AC_SUBST(TDK_TCLSH_PROG)
AC_SUBST(TDK_WISH_PROG)

AC_MSG_CHECKING([for required extensions])
AC_CACHE_VAL(tdk_cv_missing_extensions, [
dnl Check for list of dependencies by running the TclKit and
dnl several require statements. Compile a list of missing packages
dnl to present the user stored as a list in tdk_cv_missing_extensions.
dnl For each app:
dnl     1. Grep all "package require" statements from the app dir.
dnl     2. Grep all "package require" statements from the lib dir.
dnl     3. Do the same for "package provides" statements. Anything
dnl     	 not provided internally must be available in the Kit *or*
dnl	 within the distribution (when --with-tcl/--with-tk are
dnl	 supplied).
tdk_cv_missing_extensions=0
])

if test "${tdk_cv_missing_extensions}" = "0" ; then
   AC_MSG_RESULT([found all required extensions])
else
   AC_MSG_WARN([Missing some extensions])
fi

AC_CONFIG_SUBDIRS([
   lib/tbcload
   lib/tclcompiler
   lib/tclparser
])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
