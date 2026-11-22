/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m234.c (2026-11-21-10-p6-r65)
   sha256 168c1e5936b35c1161f7bdae477a0bd8109ed19ea701bc9c02256f545648d795 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  return Part_ReadByteDirect(a, (c *= 3, c -= 3, c += 0xd0)) & 0x80;
}
