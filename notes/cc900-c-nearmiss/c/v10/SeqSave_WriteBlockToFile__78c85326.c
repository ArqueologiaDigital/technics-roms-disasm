/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m235a.c (2026-11-21-3-p6-r59)
   sha256 78c85326bb57cfad132bea5c0a806d9069c95c13361efad57236a04572e1749c (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char SEQ_SONG_SLOTS[];
extern long FileIO_WriteByte_Impl(void *, long);
void SeqSave_WriteBlockToFile(unsigned char a)
{
  FileIO_WriteByte_Impl((void *)(SEQ_SONG_SLOTS + ((unsigned long)a << 11)), 0x800L);
}
