# Makefile to build the SDL_image 2

CDEFS   = -DAROS_ALMOST_COMPATIBLE -DUSE_INLINE_STDARG -D__MORPHOS_SHAREDLIBS -D_NO_PPCINLINE -DLOAD_BMP -DLOAD_LBM -DLOAD_PCX -DLOAD_PNM -DLOAD_TGA -DLOAD_XPM -DLOAD_JPG -DLOAD_PNG -DLOAD_TIF -DLOAD_GIF -DLOAD_XCF -DLOAD_XV
CC      = ppc-morphos-gcc-4 -noixemul
INCLUDE = -I../sdl2-main/include
CFLAGS  = -cstd=c99 -mcpu=750 -mtune=7450 -O2 $(INCLUDE) -mresident32 -Wall -Wno-pointer-sign -fno-strict-aliasing $(CDEFS)
AR	= ar
RANLIB	= ranlib

ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."

TARGET  = libSDL_image.a
LIBRARY = sdl2_image.library

SOURCES = \
	IMG.c \
	IMG_bmp.c \
	IMG_gif.c \
	IMG_jpg.c \
	IMG_lbm.c \
	IMG_pcx.c \
	IMG_png.c \
	IMG_pnm.c \
	IMG_tga.c \
	IMG_tif.c \
	IMG_webp.c \
	IMG_xcf.c \
	IMG_xpm.c \
	IMG_xv.c \
	IMG_xxx.c

CORESOURCES = MorphOS/*.c
COREOBJECTS = $(shell echo $(CORESOURCES) | sed -e 's,\.c,\.o,g')

OBJECTS = $(shell echo $(SOURCES) | sed -e 's,\.c,\.o,g')

all: $(LIBRARY) sdklibs

sdklibs:
	@cd MorphOS/devenv; if ! $(MAKE) all; then exit 1; fi;

sdk: sdklibs
	mkdir -p $(SDKPATH)$(SDKROOT)$(SDKGG)includestd/SDL
	mkdir -p $(SDKPATH)$(SDKROOT)$(SDKGG)ppc-morphos/lib
	mkdir -p $(SDKPATH)$(SDKROOT)$(SDKGG)ppc-morphos/lib/libb32
	cp SDL_image.h $(SDKPATH)$(SDKROOT)$(SDKGG)includestd/SDL
	cp MorphOS/devenv/lib/libSDL_image.a $(SDKPATH)$(SDKROOT)$(SDKGG)ppc-morphos/lib/
	cp MorphOS/devenv/lib/libb32/libSDL_image.a $(SDKPATH)$(SDKROOT)$(SDKGG)ppc-morphos/lib/libb32/

install: $(LIBRARY)
	@cp $(LIBRARY) /sys/MorphOS/Libs/
	-flushlib $(LIBRARY)

#install-iso: $(LIBRARY)
#	mkdir -p $(ISOPATH)MorphOS/Libs/
#	@cp $(LIBRARY) $(ISOPATH)MorphOS/Libs/

install-iso:
	@echo "not for the ISO.. skipping"

MorphOS/IMG_library.o: MorphOS/IMG_library.c MorphOS/IMG_library.h MorphOS/IMG_stubs.h
	$(COMPILING)
	@ppc-morphos-gcc -mcpu=750 -O2 $(INCLUDE) -Wall -fno-strict-aliasing -DAROS_ALMOST_COMPATIBLE -o $@ -c $*.c

$(TARGET): $(OBJECTS)
	$(ARCHIVING)
	@$(AR) crv $@ $^
	$(RANLIB) $@

$(LIBRARY): $(TARGET) $(COREOBJECTS)
	$(LINKING)
	@$(CC) -nostartfiles -mresident32 -Wl,-Map=sdl2_image.map $(COREOBJECTS) -o $@.db -L. -lSDL_image -L../sdl2-main/src/core/morphos/devenv/lib -lSDL -lm
	$(STRIPPING)
	@ppc-morphos-strip -o $@ --remove-section=.comment $@.db

showimage: sdklibs showimage.c
	$(CC) -noixemul -O2 -Wall showimage.c -o $@ -I../sdl2-main/include -DUSE_INLINE_STDARG -LMorphOS/devenv/lib -L../sdl2-main/src/core/morphos/devenv/lib -lSDL_image -lSDL

clean:
	rm -f $(LIBRARY) $(TARGET) $(OBJECTS) $(COREOBJECTS) *.db *.s

dump:
	objdump --disassemble-all --reloc $(LIBRARY).db >$(LIBRARY).s
