
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

#TEA_PATH_TKCONFIG
#TEA_LOAD_TKCONFIG

TEA_PREFIX

TEA_SETUP_COMPILER
TEA_ENABLE_THREADS
TEA_ENABLE_SHARED
TEA_CONFIG_CFLAGS
TEA_ENABLE_SYMBOLS

TEA_PROG_TCLSH
#TEA_PROG_WISH

# Check for TclKit.

AC_CONFIG_SUBDIRS([
  lib/tclcompiler
  lib/tclparser
])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
