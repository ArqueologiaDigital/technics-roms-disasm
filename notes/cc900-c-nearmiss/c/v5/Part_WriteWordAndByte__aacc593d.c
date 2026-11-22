/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m234.c (2026-11-22-24-p6-r91)
   sha256 aacc593d1ea3b5a93abc725d973962b3d0857ed35f979e80be760688a6a69dd5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ram_2861;
extern unsigned char SEQ_CURRENT_SONG;
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
void Part_WriteWordAndByte(register unsigned int w, unsigned char b)
{
    Part_WriteWord_Indexed(0, (unsigned char)ram_2861, w);
    Part_WriteByte_Indexed(0, (unsigned char)ram_2861, b);
    Part_WriteWord_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_2861, w);
    Part_WriteByte_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_2861, b);
}
