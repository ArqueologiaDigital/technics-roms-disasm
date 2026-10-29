#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "zlib.h"
int main(int argc, char **argv) {
    FILE *f = fopen(argv[1], "rb"); fseek(f, 0, SEEK_END); long n = ftell(f); fseek(f, 0, SEEK_SET);
    unsigned char *in = malloc(n); fread(in, 1, n, f); fclose(f);
    uLong cap = n + n / 10 + 64; unsigned char *out = malloc(cap);
    z_stream s; memset(&s, 0, sizeof s);
    if (deflateInit(&s, Z_DEFAULT_COMPRESSION) != Z_OK) return 1;
    s.next_in = in; s.avail_in = n; s.next_out = out; s.avail_out = cap;
    if (deflate(&s, Z_FINISH) != Z_STREAM_END) return 2;
    f = fopen(argv[2], "wb"); fwrite(out, 1, s.total_out, f); fclose(f);
    deflateEnd(&s); return 0;
}
