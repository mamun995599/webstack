GENCCODE_ASSEMBLY_TYPE=-a gcc
SO=so
SOBJ=so
A=a
LIBPREFIX=lib
LIB_EXT_ORDER=.74.1
COMPILE=gcc -I/home/mamun/webstack/deps/include -D_REENTRANT  -DU_HAVE_ELF_H=1 -DU_HAVE_STRTOD_L=1 -DU_HAVE_XLOCALE_H=0  -DU_ATTRIBUTE_DEPRECATED= -I/home/mamun/webstack/deps/include -std=c11 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings   -c
LIBFLAGS=-I/home/mamun/webstack/deps/include -DPIC -fPIC
GENLIB=gcc -I/home/mamun/webstack/deps/include -std=c11 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings   -L/home/mamun/webstack/deps/lib -Wl,-rpath,/home/mamun/webstack/deps/lib  -shared -Wl,-Bsymbolic
LDICUDTFLAGS=-nodefaultlibs -nostdlib
LD_SONAME=-Wl,-soname -Wl,
RPATH_FLAGS=
BIR_LDFLAGS=-Wl,-Bsymbolic
AR=ar
ARFLAGS=r
RANLIB=ranlib
INSTALL_CMD=/usr/bin/install -c
