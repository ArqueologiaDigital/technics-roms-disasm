/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m234.c (2026-11-22-24-p6-r91)
   sha256 32552a79255532c8078f841ca5bf72d778d5f743e5572be4405eb3dfb59adbc6 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ram_287d;
extern unsigned char SEQ_CURRENT_SONG;
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
void Part_WriteWordAndByte(register unsigned int w, unsigned char b)
{
    Part_WriteWord_Indexed(0, (unsigned char)ram_287d, w);
    Part_WriteByte_Indexed(0, (unsigned char)ram_287d, b);
    Part_WriteWord_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_287d, w);
    Part_WriteByte_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_287d, b);
}
