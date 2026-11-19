/* lane_p6 helper N, round 1, form b: module 236 (sequencer/sequencer_engine.s).
   SeqPart_ClearSingle, form b against a: the {block, offset} table as a constant-address struct pointer (scalar
   member stores only, one function in the file: bug 11 concerns whole-element copies), the element address in a
   pointer local.
   cc900-options: -O3 -Xr
*/

struct bo { unsigned int block; unsigned int offset; };
extern void Part_SetClearVoiceBit7(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);

void SeqPart_ClearSingle(unsigned char p)
{
	struct bo *e;

	Part_SetClearVoiceBit7(0, p, 0);
	Part_WriteVoiceWord(0, p, 0xffff);
	Part_WriteWord_Indexed(0, p, 0xffff);
	Part_WriteByte_Indexed(0, p, 5);
	e = &((struct bo *)0x23e0)[(unsigned char)(p - 1)];
	e->block = 0xffff;
	e->offset = 5;
}
