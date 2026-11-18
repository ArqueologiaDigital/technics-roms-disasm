/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m234.c (2026-11-18-12-p6-r35)
   sha256 cc04abf6bd9183372ea4d401207ba7bbb922d5b7b56a23aa7e7eddfefd39244d (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int PartCtrl_ReadWord(unsigned int);
void SeqPos_AdvanceWithWrap(unsigned char a)
{
  unsigned int n, o;
  n = a;
  o = SEQ_DATA_OFFSET + n;
  SEQ_DATA_OFFSET = o;
  if (o > 0xff) {
    o -= 0x100;
    o += 5;
    SEQ_DATA_OFFSET = o;
    SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
  }
}
