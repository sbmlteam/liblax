/**
 * @file    libsbml-version.h
 * @brief   Define libLAX version numbers for access from client software.
 * @author  Michael Hucka
 *
 *------------------------------------------------------------------------- -->
 */

#ifndef LIBLAX_VERSION_H
#define LIBLAX_VERSION_H 

#include <xml/common/extern.h>


/**
 * LIBLAX_DOTTED_VERSION:
 *
 * A version string of the form "1.2.3".
 */
#define LIBLAX_DOTTED_VERSION	"@PACKAGE_VERSION@"


/**
 * LIBLAX_VERSION:
 *
 * The version as an integer: version 1.2.3 becomes 10203.  Since the major
 * number comes first, the overall number will always increase when a new
 * libLAX is released, making it easy to use less-than and greater-than
 * comparisons when testing versions numbers.
 */
#define LIBLAX_VERSION		@LIBLAX_VERSION_NUMERIC@


/**
 * LIBLAX_VERSION_STRING:
 *
 * The numeric version as a string: version 1.2.3 becomes "10203".
 */
#define LIBLAX_VERSION_STRING	"@LIBLAX_VERSION_NUMERIC@"


LIBLAX_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Returns the version number of this copy of libLAX as an integer.
 *
 * @return the libLAX version as an integer; version 1.2.3 becomes 10203.
 */
LIBLAX_EXTERN
int 
getLibLAXVersion () ;


/**
 * Returns the version number of this copy of libLAX as a string.
 *
 * @return the libLAX version as a string; version 1.2.3 becomes
 * "1.2.3".
 *
 * @see getLibLAXVersionString()
 */
LIBLAX_EXTERN
const char* 
getLibLAXDottedVersion ();


/**
 * Returns the version number of this copy of libLAX as a string without
 * periods.
 *
 * @return the libLAX version as a string: version 1.2.3 becomes "10203".
 *
 * @see getLibLAXDottedVersion()
 */
LIBLAX_EXTERN
const char* 
getLibLAXVersionString ();


/**
 * Returns an indication whether libLAX has been compiled with
 * against a specific library. 
 *
 * @param option the library to test against, this can be one of
 *        "expat", "libxml", "xerces-c", "bzip2", "zip"
 * 
 * @return 0 in case the libLAX has not been compiled against 
 *         that library and non-zero otherwise (for libraries 
 *         that define an integer version number that number will 
 *         be returned).
 *
 * @see getLibLAXDependencyVersionOf()
 */
LIBLAX_EXTERN
int 
isLibLAXCompiledWith(const char* option);


/**
 * Returns the version string for the dependency library used. 
 *
 * @param option the library for which the version
 *        should be retrieved, this can be one of
 *        "expat", "libxml", "xerces-c", "bzip2", "zip"
 * 
 * @return NULL in case libLAX has not been compiled against 
 *         that library and a version string otherwise.
 *
 * @see isLibLAXCompiledWith()
 */
LIBLAX_EXTERN
const char* 
getLibLAXDependencyVersionOf(const char* option);


END_C_DECLS
LIBLAX_CPP_NAMESPACE_END

#endif  /* LIBLAX_VERSION_H */
