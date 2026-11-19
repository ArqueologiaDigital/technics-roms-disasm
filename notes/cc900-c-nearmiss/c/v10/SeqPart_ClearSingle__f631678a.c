/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_3m236a.c (2026-11-19-22-p6-r45)
   sha256 f631678a54d9359e6a1dd3bfb3906a647da046602bc8b08a715578d146bf79a9 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
