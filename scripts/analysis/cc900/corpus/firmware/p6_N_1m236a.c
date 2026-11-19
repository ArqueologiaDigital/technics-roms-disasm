/* lane_p6 helper N, round 1, form a: module 236 (sequencer/sequencer_engine.s).
   SeqPart_ClearSingle: clears part p of song 0 (the Part_* writes of the built SeqPart_InitClear) and resets its
   {block, offset} pair in the 4-byte table at 0x23e0.  Form a: a __near struct array indexed by the char.
   cc900-options: -O3 -Xr
*/

struct bo { unsigned int block; unsigned int offset; };
extern struct bo __near ram_23e0[];
extern void Part_SetClearVoiceBit7(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);

void SeqPart_ClearSingle(unsigned char p)
{
	Part_SetClearVoiceBit7(0, p, 0);
	Part_WriteVoiceWord(0, p, 0xffff);
	Part_WriteWord_Indexed(0, p, 0xffff);
	Part_WriteByte_Indexed(0, p, 5);
	ram_23e0[(unsigned char)(p - 1)].block = 0xffff;
	ram_23e0[(unsigned char)(p - 1)].offset = 5;
}
