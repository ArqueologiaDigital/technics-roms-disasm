/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_21a.c (2026-11-18-1-p6-r33)
   sha256 51db1894e0548ad6e8554a56903c077aefe0942789783a229322191a79e150c8 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int PartCtrl_ReadWord(unsigned int);
void SeqPos_AdvanceWithWrap(unsigned char a)
{
  unsigned int o;
  o = a + SEQ_DATA_OFFSET;
  SEQ_DATA_OFFSET = o;
  if (o > 0xff) {
    o -= 0x100;
    o += 5;
    SEQ_DATA_OFFSET = o;
    SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
  }
}
