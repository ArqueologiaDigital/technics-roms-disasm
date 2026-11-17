/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/midi_dispatch_handlers.c (2026-11-16-40-p6-r8)
   sha256 c8506d3b1427959e38673461679326677060071b4d9806189c04338306408d18 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct cmp16 { unsigned char p0[2]; unsigned char b2; unsigned char h3 : 1; unsigned char r3 : 3; unsigned char v3 : 4;
               unsigned char b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15; };
void DataBuf_CopyCompressorBlock16(struct cmp16 *s, struct cmp16 *d)
{
    d->b2 = s->b2;
    d->h3 = s->h3;
    d->v3 = s->v3;
    d->b4 = s->b4;
    d->b5 = s->b5;
    d->b6 = s->b6;
    d->b7 = s->b7;
    d->b8 = s->b8;
    d->b9 = s->b9;
    d->b10 = s->b10;
    d->b11 = s->b11;
    d->b12 = s->b12;
    d->b13 = s->b13;
    d->b14 = s->b14;
    d->b15 = s->b15;
}
struct b6 { unsigned char h : 1; unsigned char f : 1; unsigned char r : 6; };
struct b10 { unsigned char r : 6; unsigned char b1 : 1; unsigned char b0 : 1; };
