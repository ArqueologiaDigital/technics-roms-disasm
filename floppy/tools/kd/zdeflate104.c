/* zdeflate104 -- compress stdin with zlib 1.0.4's deflate, as the KN6000 / KN7000 firmware does.
 *
 * The firmware links zlib 1.0.4 (kn7000/kn7000_manual.sym, "zlib 1.0.4 (deflate and inflate)") and its
 * fmm-layer writers call deflateInit_(strm, level, "1.0.4") = windowBits 15, memLevel 8, default strategy.
 * zlib 1.0.4 differs from every later release in one place that changes the bits: _tr_tally() always
 * ends a block early at each multiple of 4096 symbols when its estimate says that pays
 * (later releases compile that only under -DTRUNCATE_BLOCK, at multiples of 8192).
 *
 * usage: zdeflate104 [level] < raw > out
 * out = the deflate body WITHOUT the 2-byte zlib header, then the 4-byte adler32 (big endian):
 * the shape every 'I KD' / 'J K\x01' file part has on disk.  Default level 6 (Z_DEFAULT_COMPRESSION).
 */
#include <stdio.h>
#include <stdlib.h>
#include "zlib.h"

int main(int argc, char **argv)
{
    int level = argc > 1 ? atoi(argv[1]) : 6;
    size_t cap = 1 << 20, n = 0, r;
    unsigned char *in = malloc(cap), *out;
    z_stream s;
    while ((r = fread(in + n, 1, cap - n, stdin)) > 0) {
        n += r;
        if (n == cap) { cap *= 2; in = realloc(in, cap); }
    }
    out = malloc(n + n / 100 + 64);
    s.zalloc = Z_NULL; s.zfree = Z_NULL; s.opaque = Z_NULL;
    if (deflateInit(&s, level) != Z_OK) { fprintf(stderr, "zdeflate104: deflateInit failed\n"); return 1; }
    s.next_in = in; s.avail_in = (uInt)n;
    s.next_out = out; s.avail_out = (uInt)(n + n / 100 + 64);
    if (deflate(&s, Z_FINISH) != Z_STREAM_END) { fprintf(stderr, "zdeflate104: deflate failed\n"); return 1; }
    if (s.total_out < 6) { fprintf(stderr, "zdeflate104: short stream\n"); return 1; }
    fwrite(out + 2, 1, s.total_out - 2, stdout);
    deflateEnd(&s);
    return 0;
}
