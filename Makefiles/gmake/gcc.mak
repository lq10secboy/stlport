# Time-stamp: <10/06/03 13:06:08 ptr>
#
# Copyright (c) 1997-1999, 2002, 2003, 2005-2010
# Petr Ovtchenkov
#
# This material is provided "as is", with absolutely no warranty expressed
# or implied. Any use is at your own risk.
#
# Permission to use or copy this software for any purpose is hereby granted
# without fee, provided the above notices are retained on all copies.
# Permission to modify the code and to distribute modified code is granted,
# provided the above notices are retained, and a notice that the code was
# modified is included with the above copyright notice.
#

ifndef _FORCE_CXX
CXX := c++
else
CXX := ${_FORCE_CXX}
endif

ifndef _FORCE_CC
CC := gcc
else
CC := ${_FORCE_CC}
endif

ifeq ($(OSNAME), windows)
RC := windres
endif

ifdef TARGET_OS
CXX := ${TARGET_OS}-${CXX}
CC := ${TARGET_OS}-${CC}
AS := ${TARGET_OS}-${AS}
endif

CXX_VERSION := $(shell ${CXX} -dumpversion)
CXX_VERSION_MAJOR := $(shell echo ${CXX_VERSION} | awk 'BEGIN { FS = "."; } { print $$1; }')
CXX_VERSION_MINOR := $(shell echo ${CXX_VERSION} | awk 'BEGIN { FS = "."; } { print $$2; }')
CXX_VERSION_PATCH := $(shell echo ${CXX_VERSION} | awk 'BEGIN { FS = "."; } { print $$3; }')

# Check that we need option -fuse-cxa-atexit for compiler
_CXA_ATEXIT := $(shell ${CXX} -v 2>&1 | grep -q -e "--enable-__cxa_atexit" || echo "-fuse-cxa-atexit")

ifeq ($(OSNAME), darwin)
# This is to differentiate Apple-builded compiler from original
# GNU compiler (it has different behaviour)
ifneq ("$(shell ${CXX} -v 2>&1 | grep Apple)", "")
GCC_APPLE_CC := 1
endif
endif

DEFS ?=
OPT ?=

ifdef WITHOUT_STLPORT
INCLUDES =
else
INCLUDES = -I${STLPORT_INCLUDE_DIR}
endif

ifdef BOOST_INCLUDE_DIR
INCLUDES += -I${BOOST_INCLUDE_DIR}
endif

OUTPUT_OPTION = -o $@
LINK_OUTPUT_OPTION = ${OUTPUT_OPTION}
CPPFLAGS = $(DEFS) $(INCLUDES)

ifeq ($(OSNAME), windows)
RCFLAGS = --include-dir=${STLPORT_INCLUDE_DIR} --output-format coff -DCOMP=gcc
release-shared : RCFLAGS += -DBUILD_INFOS=-O2
dbg-shared : RCFLAGS += -DBUILD=g -DBUILD_INFOS=-g
stldbg-shared : RCFLAGS += -DBUILD=stlg -DBUILD_INFOS="-g -D_STLP_DEBUG"
RC_OUTPUT_OPTION = -o $@
CXXFLAGS = -Wall -Wsign-promo -Wcast-qual -fexceptions
ifeq ($(OSREALNAME), mingw)
CCFLAGS += -mthreads
CFLAGS += -mthreads
CXXFLAGS += -mthreads
else
DEFS += -D_REENTRANT
endif
CCFLAGS += $(OPT)
CFLAGS += $(OPT)
CXXFLAGS += $(OPT)
COMPILE.rc = $(RC) $(RCFLAGS)
release-static : DEFS += -D_STLP_USE_STATIC_LIB
dbg-static : DEFS += -D_STLP_USE_STATIC_LIB
stldbg-static : DEFS += -D_STLP_USE_STATIC_LIB
ifeq ($(OSREALNAME), mingw)
dbg-shared : DEFS += -D_DEBUG
stldbg-shared : DEFS += -D_DEBUG
dbg-static : DEFS += -D_DEBUG
stldbg-static : DEFS += -D_DEBUG
endif
endif

ifeq ($(OSNAME),sunos)
CCFLAGS = -pthreads $(OPT)
CFLAGS = -pthreads $(OPT)
# CXXFLAGS = -pthreads -nostdinc++ -fexceptions $(OPT)
CXXFLAGS = -pthreads  -fexceptions $(OPT)
endif

ifeq ($(OSNAME),linux)
CCFLAGS = -pthread $(OPT)
CFLAGS = -pthread $(OPT)
# CXXFLAGS = -pthread -nostdinc++ -fexceptions $(OPT)
CXXFLAGS = -pthread -fexceptions $(OPT)
endif

ifeq ($(OSNAME),android)
CCFLAGS = -mandroid --sysroot=$(SYSROOT) $(OPT)
CFLAGS = -mandroid --sysroot=$(SYSROOT) $(OPT)
# NDK 1.5 and 1.6 was shipout without exceptions and rtti
CXXFLAGS = -mandroid --sysroot=$(SYSROOT) -fno-exceptions -fno-rtti $(OPT)
# CXXFLAGS = -mandroid --sysroot=$(SYSROOT) $(OPT)
endif

ifeq ($(OSNAME),openbsd)
CCFLAGS = -pthread $(OPT)
CFLAGS = -pthread $(OPT)
# CXXFLAGS = -pthread -nostdinc++ -fexceptions $(OPT)
CXXFLAGS = -pthread -fexceptions $(OPT)
endif

ifeq ($(OSNAME),freebsd)
CCFLAGS = -pthread $(OPT)
CFLAGS = -pthread $(OPT)
DEFS += -D_REENTRANT
# CXXFLAGS = -pthread -nostdinc++ -fexceptions $(OPT)
CXXFLAGS = -pthread -fexceptions $(OPT)
endif

ifeq ($(OSNAME),darwin)
CCFLAGS = $(OPT)
CFLAGS = $(OPT)
DEFS += -D_REENTRANT
CXXFLAGS = -fexceptions $(OPT)
release-shared : CXXFLAGS += -dynamic
dbg-shared : CXXFLAGS += -dynamic
stldbg-shared : CXXFLAGS += -dynamic
endif

ifeq ($(OSNAME),hp-ux)
ifneq ($(M_ARCH),ia64)
release-static : OPT += -fno-reorder-blocks
release-shared : OPT += -fno-reorder-blocks
endif
CCFLAGS = -pthread $(OPT)
CFLAGS = -pthread $(OPT)
# CXXFLAGS = -pthread -nostdinc++ -fexceptions $(OPT)
CXXFLAGS = -pthread -fexceptions $(OPT)
endif

#ifeq ($(CXX_VERSION_MAJOR),3)
#ifeq ($(CXX_VERSION_MINOR),2)
#CXXFLAGS += -ftemplate-depth-32
#endif
#ifeq ($(CXX_VERSION_MINOR),1)
#CXXFLAGS += -ftemplate-depth-32
#endif
#ifeq ($(CXX_VERSION_MINOR),0)
#CXXFLAGS += -ftemplate-depth-32
#endif
#endif
ifeq ($(CXX_VERSION_MAJOR),2)
CXXFLAGS += -ftemplate-depth-32
endif

# Required for correct order of static objects dtors calls:
ifeq ("$(findstring $(OSNAME),darwin windows)","")
ifneq ($(CXX_VERSION_MAJOR),2)
CXXFLAGS += $(_CXA_ATEXIT)
endif
endif

# Code should be ready for this option
#ifneq ($(OSNAME),windows)
#ifneq ($(CXX_VERSION_MAJOR),2)
#ifneq ($(CXX_VERSION_MAJOR),3)
#CXXFLAGS += -fvisibility=hidden
#CFLAGS += -fvisibility=hidden
#endif
#endif
#endif

CXXFLAGS += -std=gnu++0x ${EXTRA_CXXFLAGS}
CFLAGS += ${EXTRA_CFLAGS}

CDEPFLAGS = -E -M
CCDEPFLAGS = -E -M

# STLport DEBUG mode specific defines
stldbg-static :	    DEFS += -D_STLP_DEBUG
stldbg-shared :     DEFS += -D_STLP_DEBUG
stldbg-static-dep : DEFS += -D_STLP_DEBUG
stldbg-shared-dep : DEFS += -D_STLP_DEBUG

# optimization and debug compiler flags
release-static : OPT += -O2
release-shared : OPT += -O2

dbg-static : OPT += -g
dbg-shared : OPT += -g
#dbg-static-dep : OPT += -g
#dbg-shared-dep : OPT += -g

stldbg-static : OPT += -g
stldbg-shared : OPT += -g
#stldbg-static-dep : OPT += -g
#stldbg-shared-dep : OPT += -g

# dependency output parser (dependencies collector)

DP_OUTPUT_DIR = | sed 's|\($*\)\.o[ :]*|$(OUTPUT_DIR)/\1.o $@ : |g' > $@; \
                           [ -s $@ ] || rm -f $@

DP_OUTPUT_DIR_DBG = | sed 's|\($*\)\.o[ :]*|$(OUTPUT_DIR_DBG)/\1.o $@ : |g' > $@; \
                           [ -s $@ ] || rm -f $@

DP_OUTPUT_DIR_STLDBG = | sed 's|\($*\)\.o[ :]*|$(OUTPUT_DIR_STLDBG)/\1.o $@ : |g' > $@; \
                           [ -s $@ ] || rm -f $@

