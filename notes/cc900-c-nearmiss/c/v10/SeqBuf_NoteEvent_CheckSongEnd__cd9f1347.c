/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4b.c (2026-11-16-39-p6-r7)
   sha256 cd9f134746513c7c9c77d7c0d599b0c4008c48aed497a7f2cb2fa6c3e2f78376 (tar-sha256); compiled at -Xr */
extern unsigned int ram_204db;
extern unsigned int ram_204d7;
int SeqBuf_NoteEvent_CheckSongEnd(void)
{
    int r = ram_204db;
    if (r == ram_204d7) r = 0;
    else r = -1;
    return r;
}
