# floppy/tools/kd: the deflate coder of the KN6000 / KN7000 disk files (zlib 1.0.4, vendored, see README.md).
CC      ?= cc
CFLAGS  ?= -O2
Z104    := zlib-1.0.4
Z104SRC := $(Z104)/deflate.c $(Z104)/trees.c $(Z104)/adler32.c $(Z104)/zutil.c

zdeflate104: zdeflate104.c $(Z104SRC) $(wildcard $(Z104)/*.h)
	$(CC) $(CFLAGS) -std=gnu89 -w -I$(Z104) -o $@ zdeflate104.c $(Z104SRC)

clean:
	rm -f zdeflate104
.PHONY: clean
