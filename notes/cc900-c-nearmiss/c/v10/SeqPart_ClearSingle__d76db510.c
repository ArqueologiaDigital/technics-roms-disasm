/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m236a.c (2026-11-19-15-p6-r42)
   sha256 d76db5107a6ae53f36e23214afb911ff6ea7fe531e76b00ae178ec7d29a42205 (tar-sha256); compiled at -O3 -Xr
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
	ram_23e0[(unsigned char)(p - 1)].block = 0xffff;
	ram_23e0[(unsigned char)(p - 1)].offset = 5;
}
