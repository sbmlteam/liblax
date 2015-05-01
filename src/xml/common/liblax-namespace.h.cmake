/**
 * @file    liblax-namespace.h
 * @brief   Defines C++ namespace of libLAX
 * @author  Akiya Jouraku
 * 
 *------------------------------------------------------------------------- -->
 *
 */

#ifndef LIBLAX_NAMESPACE_H
#define LIBLAX_NAMESPACE_H 1

/*
 *
 * The idea of the following marcors are borrowed from 
 * Xerces-C++ XML Parser (http://xerces.apache.org/xerces-c/).
 *
 */

/* Define to enable libLAX C++ namespace */
#cmakedefine LIBLAX_USE_CPP_NAMESPACE 1


#if defined(__cplusplus) && defined(LIBLAX_USE_CPP_NAMESPACE) && !defined(SWIG)
  /* C++ namespace of libLAX */
  #define LIBLAX_CPP_NAMESPACE            libLAX
  #define LIBLAX_CPP_NAMESPACE_BEGIN      namespace LIBLAX_CPP_NAMESPACE {
  #define LIBLAX_CPP_NAMESPACE_END        }
  #define LIBLAX_CPP_NAMESPACE_USE        using namespace LIBLAX_CPP_NAMESPACE;
  #define LIBLAX_CPP_NAMESPACE_QUALIFIER  LIBLAX_CPP_NAMESPACE::

  namespace LIBLAX_CPP_NAMESPACE {}
#else
  #define LIBLAX_CPP_NAMESPACE 
  #define LIBLAX_CPP_NAMESPACE_BEGIN
  #define LIBLAX_CPP_NAMESPACE_END  
  #define LIBLAX_CPP_NAMESPACE_USE 
  #define LIBLAX_CPP_NAMESPACE_QUALIFIER 
#endif


#endif  /* LIBLAX_NAMESPACE_H */

