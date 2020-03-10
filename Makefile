# Makefile to build the SDL_image 2

CDEFS   = -DAROS_ALMOST_COMPATIBLE -DUSE_INLINE_STDARG -D__MORPHOS_SHAREDLIBS -D_NO_PPCINLINE   -DLOAD_BMP  -DLOAD_LBM -DLOAD_PCX -DLOAD_PNM -DLOAD_TGA -DLOAD_XCF -DLOAD_XPM -DLOAD_JPG -DLOAD_PNG -DLOAD_TIF  -DLOAD_XV -DLOAD_SVG
CC      = ppc-morphos-gcc-4 -noixemul
# -DLOAD_WEBP -DLOAD_GIF
INCLUDE = -I../SDL-mos-sdl2/include
CFLAGS  = -mcpu=750 -mtune=7450 -O2 $(INCLUDE) -mresident32 -Wall -Wno-pointer-sign -fno-strict-aliasing $(CDEFS)
AR	= ar
RANLIB	= ranlib

ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."
HEADERING = @$(ECHE) "creating headers files $(BOLD)$@$(NRML)..."

TARGET  = libSDL2_image.a
LIBRARY = sdl2_image.library

SOURCES = \
	IMG.c			\
	IMG_bmp.c		\
	IMG_gif.c		\
	IMG_jpg.c		\
	IMG_lbm.c		\
	IMG_pcx.c		\
	IMG_png.c		\
	IMG_pnm.c		\
	IMG_svg.c		\
	IMG_tga.c		\
	IMG_tif.c		\
	IMG_xcf.c		\
	IMG_xpm.c		\
	IMG_xv.c		\
	IMG_webp.c		\
	IMG_WIC.c \
	IMG_xxx.c
		
CORESOURCES = MorphOS/*.c
COREOBJECTS = $(shell echo $(CORESOURCES) | sed -e 's,\.c,\.o,g')

OBJECTS = $(shell echo $(SOURCES) | sed -e 's,\.c,\.o,g')

all: $(LIBRARY) sdklibs

sdklibs:
	@cd MorphOS/devenv; if ! $(MAKE) all; then exit 1; fi;

sdk: sdklibs
	mkdir -p /usr/local/include/SDL2
	mkdir -p /usr/local/lib
	mkdir -p /usr/local/lib/libb32
	cp SDL_image.h /usr/local/include/SDL2/SDL2_image.h
	cp MorphOS/devenv/lib/libSDL_image.a  /usr/local/lib/SDL2_image.a
	cp MorphOS/devenv/lib/libb32/libSDL_image.a  /usr/local/lib/libb32/SDL2_image.a

headers:
	$(HEADERING)
	@cvinclude.pl --fd=MorphOS/sdk/fd/sdl2_image_lib.fd --clib=MorphOS/sdk/clib/sdl2_image_protos.h --proto=MorphOS/sdk/proto/sdl2_image.h
	@cvinclude.pl --fd=MorphOS/sdk/fd/sdl2_image_lib.fd --clib=MorphOS/sdk/clib/sdl2_image_protos.h --inline=MorphOS/sdk/ppcinline/sdl2_image.h
	
install: $(LIBRARY)
	@cp $(LIBRARY) LIBS:
	-flushlib $(LIBRARY)

#install-iso: $(LIBRARY)
#	mkdir -p $(ISOPATH)MorphOS/Libs/
#	@cp $(LIBRARY) $(ISOPATH)MorphOS/Libs/

install-iso:
	@echo "not for the ISO.. skipping"

MorphOS/IMG_library.o: MorphOS/IMG_library.c MorphOS/IMG_library.h MorphOS/IMG_stubs.h
	$(COMPILING)
	$(CC) -mcpu=750 -O2 $(INCLUDE) -Wall -fno-strict-aliasing -DAROS_ALMOST_COMPATIBLE -o $@ -c $*.c

$(TARGET): $(OBJECTS)
	$(ARCHIVING)
	@$(AR) crv $@ $^
	$(RANLIB) $@

$(LIBRARY): $(TARGET) $(COREOBJECTS)
	$(LINKING)
	$(CC) -nostartfiles -mresident32 -Wl,-Map=sdl2_image.map $(COREOBJECTS) -o $@.db -L. -lSDL2_image -L../SDL-mos-sdl2/src/core/morphos/devenv/lib -lSDL -lm
	$(STRIPPING)
	@ppc-morphos-strip -o $@ --remove-section=.comment $@.db

showimage: sdklibs showimage.c
	$(CC) -noixemul -O2 -Wall showimage.c -o $@ -I../SDL-mos-sdl2/include -DUSE_INLINE_STDARG -LMorphOS/devenv/lib -L../SDL-mos-sdl2/src/core/morphos/devenv/lib -lSDL2_image -lSDL

clean:
	rm -f $(LIBRARY) $(TARGET) $(OBJECTS) $(COREOBJECTS) *.db *.s

dump:
	objdump --disassemble-all --reloc $(LIBRARY).db >$(LIBRARY).s
