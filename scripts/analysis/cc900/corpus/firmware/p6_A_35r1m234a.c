/* Probe round 35r1, helper A, form a: sequencer/sequencer_engine.s (module 234), xr_screen family.
   Part_WriteWordAndByte(w, b): store w / b at entry (low byte of the word ram_287d) of the 0x78 / 0x98 arrays of
   song slot 0 and of song slot SEQ_CURRENT_SONG + 1.  w is a `register` parameter (IZ), b stays on the frame. */
/* cc900-module: Part_WriteByte_Indexed Part_WriteWord_Indexed */

extern unsigned int __near ram_287d;
extern unsigned char SEQ_CURRENT_SONG;
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWordAndByte(unsigned int, unsigned char);

void Part_WriteWordAndByte(register unsigned int w, unsigned char b)
{
    Part_WriteWord_Indexed(0, (unsigned char)ram_287d, w);
    Part_WriteByte_Indexed(0, (unsigned char)ram_287d, b);
    Part_WriteWord_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_287d, w);
    Part_WriteByte_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_287d, b);
}
