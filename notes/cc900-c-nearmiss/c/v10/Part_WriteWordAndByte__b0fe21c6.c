/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m234b.c (2026-11-22-23-p6-r90)
   sha256 b0fe21c6b419590fe22e243a8cdd644bb521a2972b7818f3578a132a6f597a4e (tar-sha256); compiled at -Xr */
extern unsigned int __near ram_287d;
extern unsigned char SEQ_CURRENT_SONG;
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
void Part_WriteWordAndByte(unsigned int w, unsigned char b)
{
    Part_WriteWord_Indexed(0, (unsigned char)ram_287d, w);
    Part_WriteByte_Indexed(0, (unsigned char)ram_287d, b);
    Part_WriteWord_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_287d, w);
    Part_WriteByte_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_287d, b);
}
