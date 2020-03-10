# Makefile to build the SDL_image version 2

CC      = ppc-morphos-gcc-4 -noixemul
#INCLUDE = -I../../../../include -I../../../../../../../development/os-include
CFLAGS  = -cstd=c99 -mcpu=750 -mtune=7450 -O2 $(INCLUDE) -Wall -Wno-pointer-sign -fno-strict-aliasing
AR	= ar
RANLIB	= ranlib
TARGET = libSDL_image.a

ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."

all: lib/$(TARGET) lib/libb32/$(TARGET) lib/libb32/libSDL_image-nc.a

sdl-startup.o: sdl-startup.c
	$(COMPILING)
	@$(CC) $(CFLAGS) -o $@ -c sdl-startup.c

sdl-startup-brel.o: sdl-startup.c
	$(COMPILING)
	@$(CC) $(CFLAGS) -mresident32 -o $@ -c sdl-startup.c

sdl-startup-brel-nc.o: sdl-startup.c
	$(COMPILING)
	@$(CC) $(CFLAGS) -mresident32 -o $@ -c sdl-startup.c -D__NO_SDL_CONSTRUCTORS

lib/$(TARGET): sdl-startup.o ../../../../../development/os-include/fd/sdl2_image_lib.fd
	$(ARCHIVING)
	@mkdir -p lib
	@-rm -f $@
	@cvinclude.pl --fd ../../../../../development/os-include/fd/sdl2_image_lib.fd --clib ../../../../../development/os-include/clib/sdl2_image_protos.h --gluelib=$@
	@$(AR) cru $@ sdl-startup.o
	@ppc-morphos-ranlib $@

lib/libb32/$(TARGET): sdl-startup-brel.o  ../../../../../development/os-include/fd/sdl2_image_lib.fd
	$(ARCHIVING)
	@mkdir -p lib/libb32
	@-rm -f $@
	@cvinclude.pl --fd ../../../../../development/os-include/fd/sdl2_image_lib.fd --clib ../../../../../development/os-include/clib/sdl2_image_protos.h --brelgluelib=$@
	@$(AR) cru $@ sdl-startup-brel.o
	@ppc-morphos-ranlib $@

lib/libb32/libSDL_image-nc.a: sdl-startup-brel-nc.o ../../../../../development/os-include/fd/sdl2_image_lib.fd
	$(ARCHIVING)
	@mkdir -p lib/libb32
	@-rm -f $@
	@cvinclude.pl --fd ../../../../../development/os-include/fd/sdl2_image_lib.fd --clib ../../../../../development/os-include/clib/sdl2_image_protos.h --brelgluelib=$@
	@$(AR) cru $@ sdl-startup-brel-nc.o
	@ppc-morphos-ranlib $@

clean:
	@-rm -rf lib *.s

dump:
	objdump --disassemble-all --reloc lib/$(TARGET).a >lib/libSDL_image.s
