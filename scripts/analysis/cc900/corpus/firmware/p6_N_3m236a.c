/* lane_p6 helper N, round 3, form a: module 236 (sequencer/sequencer_engine.s), retry of p6_N_1m236a / b.
   SeqPart_ClearSingle: the calls match; at the table store V4.23 (form a) treated the index as unsigned
   (dec, extz, sll, extz, add) where the ROM zero-extends the char, decrements the byte, zero-extends again, then
   scales signed (sla) and sign-extends (exts): a signed int index holding (unsigned char)(p - 1).  Form a: the
   index in an int local.
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
	int i;

	Part_SetClearVoiceBit7(0, p, 0);
	Part_WriteVoiceWord(0, p, 0xffff);
	Part_WriteWord_Indexed(0, p, 0xffff);
	Part_WriteByte_Indexed(0, p, 5);
	i = (unsigned char)(p - 1);
	ram_23e0[i].block = 0xffff;
	ram_23e0[i].offset = 5;
}
