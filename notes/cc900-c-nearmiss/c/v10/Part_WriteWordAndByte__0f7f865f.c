/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m234a.c (2026-11-22-23-p6-r90)
   sha256 0f7f865fb80650700ac50b5090b752ffdd0b5c68975e4e0f3d9d8eaed84d5f07 (tar-sha256); compiled at -Xr */
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
