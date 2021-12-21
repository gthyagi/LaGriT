/*
*  FILE: opsys.h
*
*  allows platform conditions to be set at compile time
*  this file contains more than what is being used
*  and can be added later if desired
*  the current compile flags are
*  lin      - linux 32 bit
*  linx64   - linux x64 64 bit
*  sun      - solaris
*  maci     - intel mac (supported for now)
*  mac      - powerpc mac (supported for now)
*
*  no longer supported
*  sgi
*  hp
*  ibm
*  cray
*
* default sizes are based on 32 bit
* SIZEOF_INT 4
* SIZEOF_LONG 4
* SIZEOF_VOIDP 4
*
* FORTRAN calls C:
* Name mangling is necessary in Fortran compilers, originally because the language is
* case insensitive. Further mangling requirements have been imposed because of the
* addition of modules and other features in the Fortran 90 standard. Name mangling
* must be dealt with in order to call Fortran libraries from other languages such as C.
* The name of a subroutine or function "FOO" must be converted to a canonical case
* and format by the Fortran compiler so that it will be linked in the same way
* regardless of case. Different compilers have implemented this in various ways,
* and no standardization has occurred.
* The AIX and HP-UX Fortran compilers convert all identifiers to lower case ("foo").
* Cray Unicos Fortran compilers convert identifiers all upper case ("FOO").
* The GNU g77 compiler converts identifiers to lower case plus an underscore ("foo_"),
* except that identifiers already containing an underscore ("FOO_BAR") have
* two underscores appended ("foo_bar__").
* Many other compilers, including SGI's IRIX, gfortran, and Intel's Fortran compiler,
* convert all identifiers to lower case plus an underscore ("foo_" and "foo_bar_").
* Identifiers in Fortran 90 modules must be further mangled, because the same
* subroutine name may apply to different routines in different modules.
*
* For C files being used by fortran code.
* Defines the Function name Conversion needed for the system compiler.
* Possible Function name mangling for foo():
*      FCV_NONE        foo()
*      FCV_UNDERSCORE  foo_()
*      FCV_CAPS        FOO()
*
* Current code contains 3 copies of externally used functions.
* Each copy is given a name that satisfies each of the possible
* name mangling conversion possible in various compilers.
*
* An alternative method requires Defines set at compiler time.
* The function in the .c file has each of the following defined:
*
*  #ifdef FCV_NONE
*  foo()
*  #endif
*
*  #ifdef FCV_UNDERSCORE
*  foo_()
*  #endif
*
*  #ifdef FCV_CAPS
*  FOO()
*  #endif
*
*/

/* These can be set with autoconfig */
/* portinfo.  Generated by configure.  */
/* portinfo.in.  Generated from configure.ac by autoheader.  */

/* PACKAGE PACKAGE_NAME VERSION
/* SIZEOF_INT   The size of a `int', as computed by sizeof. */
/* SIZEOF_LONG  The size of a `long', as computed by sizeof. */
/* SIZEOF_VOIDP The size of a `void*', as computed by sizeof. */

/*
*  portinfo can also define name mangling schemes
*  they are not included in this version of lagrit code
*  but may be implemented at a later time
*/

/* Define to a macro mangling the given C identifier (in lower and upper */
/*   case), which must not contain underscores, for linking with Fortran. */
/*  FC_FUNC(name,NAME) name ## _  */

/*  Alternately these FCV_ macros can be defined (not enabled here)
*/

/* Default name mangle */
#define FCV_UNDERSCORE

/* Default max unsigned int */

/**** linux 32 ****/
#ifdef lin
#define FCV_UNDERSCORE
#define SIZEOF_INT 4
#define SIZEOF_LONG 4
#define SIZEOF_VOIDP 4
#define MAX_UINT 4294967295.00
#endif

/**** linux x64 ****/
#ifdef linx64
#define FCV_UNDERSCORE
#define SIZEOF_INT 4
#define SIZEOF_LONG 8
#define SIZEOF_VOIDP 8
#define MAX_UINT 18446744073709551615.00
#endif

/**** sun ****/
#ifdef sun
#define FCV_UNDERSCORE
#define SIZEOF_INT 4
#define SIZEOF_LONG 4
#define SIZEOF_VOIDP 4
#endif

/**** Mac 32 ****/
#ifdef mac
#define FCV_UNDERSCORE
#define SIZEOF_INT 4
#define SIZEOF_LONG 4
#define SIZEOF_VOIDP 4
#endif

/**** Mac x64 ****/
#ifdef macx64
#define SIZEOF_INT 4
#define SIZEOF_LONG 8
#define SIZEOF_VOIDP 8
#define MAX_UINT 18446744073709551615.00
#endif

/**** hp ****/
#ifdef hp
#define FCV_NONE
#endif

/**** ibm ****/
#ifdef ibm
#define FCV_NONE
#endif

/**** cray ****/
#ifdef cray
#define FCV_CAPS
#endif

/**** win ****/
#ifdef win64
#define FCV_UNDERSCORE
#define SIZEOF_INT 4
#define SIZEOF_LONG 8
#define SIZEOF_VOIDP 8
#define MAX_UINT 18446744073709551615.00
#endif

/**** Platform-independent method ****/
#if INTPTR_MAX == INT64_MAX
// 64-bit
#define FCV_UNDERSCORE
#define SIZEOF_INT 4
#define SIZEOF_LONG 8
#define SIZEOF_VOIDP 8
#define MAX_UINT 18446744073709551615.00

#elif INTPTR_MAX == INT32_MAX
// 32-bit
#define FCV_UNDERSCORE
#define SIZEOF_INT 4
#define SIZEOF_LONG 4
#define SIZEOF_VOIDP 4
#define MAX_UINT 4294967295.00

#endif

/**** default 32 bit ****/
#ifndef SIZEOF_INT
#define SIZEOF_INT 4
#endif
#ifndef SIZEOF_LONG
#define SIZEOF_LONG 4
#endif
#ifndef SIZEOF_VOIDP
#define SIZEOF_VOIDP 4
#endif
#ifndef MAX_UINT
#define MAX_UINT 4294967295.00
#endif

#if SIZEOF_INT == SIZEOF_VOIDP
#define int_ptrsize int
#elif SIZEOF_LONG == SIZEOF_VOIDP
#ifdef win64
#define int_ptrsize long long
#else
#define int_ptrsize long
#endif
#else
#error "Unknown case for size of pointer."
#endif



/* end file opsys.h */

