/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_3m236b.c (2026-11-19-22-p6-r45)
   sha256 0df2932a05c7e945f5e765fbb27c62f6d70eb035afe43a143512f865ddd167be (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
