/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4b.c (2026-11-16-39-p6-r7)
   sha256 cd9f134746513c7c9c77d7c0d599b0c4008c48aed497a7f2cb2fa6c3e2f78376 (tar-sha256); compiled at -Xr */
extern unsigned int SEQMAIN_WRITE_POS;
extern unsigned int SEQMAIN_READ_POS;
int Seq_CheckSongEnd(void)
{
    int r = SEQMAIN_WRITE_POS;
    if (r == SEQMAIN_READ_POS) r = 0;
    else r = -1;
    return r;
}
