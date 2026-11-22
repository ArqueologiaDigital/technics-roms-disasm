/* Probe round 35r1, helper A, form b: sequencer/sequencer_engine.s (module 234), xr_screen family.
   Part_WriteWordAndByte as form a, but w is a plain parameter (the compiler's own choice of IZ) and the entry is
   read through an unsigned char local. */
/* cc900-module: Part_WriteByte_Indexed Part_WriteWord_Indexed */

extern unsigned int __near ram_287d;
extern unsigned char SEQ_CURRENT_SONG;
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWordAndByte(unsigned int, unsigned char);

void Part_WriteWordAndByte(unsigned int w, unsigned char b)
{
    Part_WriteWord_Indexed(0, (unsigned char)ram_287d, w);
    Part_WriteByte_Indexed(0, (unsigned char)ram_287d, b);
    Part_WriteWord_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_287d, w);
    Part_WriteByte_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_287d, b);
}
