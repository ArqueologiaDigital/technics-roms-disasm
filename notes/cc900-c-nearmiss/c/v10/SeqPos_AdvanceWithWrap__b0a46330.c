/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_20d.c (2026-11-17-16-p6-r31)
   sha256 b0a463301b0df5ee1b77752998ced5894b533e51b8fa4afb7cfdd901f0c8cfb2 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int PartCtrl_ReadWord(unsigned int);
void SeqPos_AdvanceWithWrap(unsigned char a)
{
  unsigned int o;
  o = SEQ_DATA_OFFSET + a;
  SEQ_DATA_OFFSET = o;
  if (o > 0xff) {
    o -= 0x100;
    o += 5;
    SEQ_DATA_OFFSET = o;
    SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
  }
}
