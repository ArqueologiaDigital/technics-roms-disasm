/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m236b.c (2026-11-19-15-p6-r42)
   sha256 3bac0065d28789923eaf8e2e7abfa23586ade6b337a67ce2505266e54f4a546b (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
