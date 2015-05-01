/**
 * @file    liblaxversion.cpp
 * @brief   Define libLAX version numbers for access from client software.
 * @author  Akiya Jouraku
 * 
 * ------------------------------------------------------------------------ -->
 */

#include <xml/common/liblax-version.h>
#include <string.h>

#ifdef USE_EXPAT
#include <expat.h>
#endif 

#ifdef USE_XERCES
#include <xercesc/util/XercesDefs.hpp>
#include <xercesc/util/XercesVersion.hpp>
#endif

#ifdef USE_LIBXML
#include <libxml/xmlversion.h>
#endif

#ifdef USE_ZLIB
#include <zlib.h>
#endif

#ifdef USE_BZ2
#include <bzlib.h>
#endif

LIBLAX_CPP_NAMESPACE_BEGIN

LIBLAX_EXTERN
int 
getLibLAXVersion () 
{ 
  return LIBLAX_VERSION; 
}


LIBLAX_EXTERN
const char* 
getLibLAXDottedVersion () 
{ 
  return LIBLAX_DOTTED_VERSION;
}


LIBLAX_EXTERN
const char* 
getLibLAXVersionString () 
{ 
  return LIBLAX_VERSION_STRING;
}

LIBLAX_EXTERN
int 
isLibLAXCompiledWith(const char* option)
{
  if (option == NULL) return 0;

  if (strcmp(option, "expat") == 0)
  {
#ifdef USE_EXPAT
    return 1;
#else
    return 0;
#endif
  }

  if (strcmp(option, "libxml") == 0 ||
      strcmp(option, "xml2") == 0 ||
      strcmp(option, "libxml2") == 0)
  {
#ifdef USE_LIBXML
    return LIBXML_VERSION;
#else
    return 0;
#endif
  }

  if (strcmp(option, "xerces-c") == 0 ||
    strcmp(option, "xercesc") == 0)
  {
#ifdef USE_XERCES
#ifdef _XERCES_VERSION
    return _XERCES_VERSION;
#else
    return 1;
#endif
#else
    return 0;
#endif
  }

  if (strcmp(option, "zlib") == 0 ||
    strcmp(option, "zip") == 0)
  {
#ifdef USE_ZLIB
    return ZLIB_VERNUM;
#else
    return 0;
#endif
  }

  if (strcmp(option, "bzip") == 0 ||
    strcmp(option, "bzip2") == 0 ||
    strcmp(option, "bz2") == 0)
  {
#ifdef USE_BZ2
    return 1;
#else
    return 0;
#endif
  }

  return 0;
}

LIBLAX_EXTERN
const char* 
getLibLAXDependencyVersionOf(const char* option)
{
  if (option == NULL) return NULL;
  
  if (strcmp(option, "expat") == 0)
  {
#ifdef USE_EXPAT
    return static_cast<const char*>(XML_ExpatVersion());
#else
    return NULL;
#endif
  }

  if (strcmp(option, "libxml") == 0 ||
    strcmp(option, "libxml2") == 0)
  {
#ifdef USE_LIBXML
    return LIBXML_DOTTED_VERSION;
#else
    return NULL;
#endif
  }

  if (strcmp(option, "xerces-c") == 0 ||
    strcmp(option, "xercesc") == 0)
  {
#ifdef USE_XERCES
    return XERCES_FULLVERSIONDOT;
#else
    return NULL;
#endif
  }

  if (strcmp(option, "zlib") == 0 ||
    strcmp(option, "zip") == 0)
  {
#ifdef USE_ZLIB
    return ZLIB_VERSION;
#else
    return NULL;
#endif
  }

  if (strcmp(option, "bzip") == 0 ||
    strcmp(option, "bzip2") == 0 ||
    strcmp(option, "bz2") == 0)
  {
#ifdef USE_BZ2
    return BZ2_bzlibVersion();
#else
    return NULL;
#endif
  }

  return NULL;
}



LIBLAX_CPP_NAMESPACE_END


