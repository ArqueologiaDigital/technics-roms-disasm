/* lane_p6 helper N, round 3, form b: module 236 (sequencer/sequencer_engine.s), retry of p6_N_1m236a / b.
   SeqPart_ClearSingle, form b against a: the index written as an explicit signed int conversion of the byte
   difference inside the subscript, `(int)(unsigned char)((int)p - 1)`.
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
	ram_23e0[(int)(unsigned char)((int)p - 1)].block = 0xffff;
	ram_23e0[(int)(unsigned char)((int)p - 1)].offset = 5;
}
