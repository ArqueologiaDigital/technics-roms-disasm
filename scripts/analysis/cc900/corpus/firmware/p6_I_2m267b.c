/* FORM B of p6_I_2m267a.c (the chunk as an if).  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 2, module 267 (demo/file_demo_proc.s, an -O3 -Xr file), form a.  New.
   FileIO_WriteByte_Impl(buf, n): writes n bytes to the open file ram_7f44 in chunks of at most 0x7fff
   (FileWrite(buf, 1, chunk, fp)); returns n, or on error (no file: -100; short write: -11 when the file's flag is
   0x1f, else -3) records the error in ram_7f48 unless an earlier negative one is there, and returns it as a long.
   Read from the hand assembly: frame error +4, chunk +6, remaining +10, then n and buf; the chunk also kept in XIZ;
   the remaining-bytes test copied to the loop entry (-O3).  The error cell keeps a negative value through a
   conditional expression (the ROM stores the cell back in both cases).
   Form b: the chunk as `chunk = 0x7fff; if (rem < 0x7fff) chunk = rem;`. */

struct FileS { char pad[6]; int flag; };
typedef struct FileS *FileP;

extern FileP __near ram_7f44;
extern int __near ram_7f48;
extern int __cdecl FileWrite(char *, int, int, FileP);
extern long FileIO_WriteByte_Impl(char *buf, long n);

long FileIO_WriteByte_Impl(char *buf, long n)
{
    int err;
    long chunk;
    long rem;

    err = 0;
    if (ram_7f44 == 0) {
        err = -100;
        goto fail;
    }
    rem = n;
    while (rem > 0) {
        chunk = 0x7fff;
        if (rem < 0x7fff)
            chunk = rem;
        if (FileWrite(buf, 1, (int)chunk, ram_7f44) < chunk) {
            if ((ram_7f44->flag & 0x7fff) == 0x1f)
                err = -11;
            else
                err = -3;
            goto fail;
        }
        buf += chunk;
        rem -= chunk;
    }
    if (err < 0) {
fail:
        ram_7f48 = ram_7f48 < 0 ? ram_7f48 : err;
        n = err;
    }
    return n;
}
