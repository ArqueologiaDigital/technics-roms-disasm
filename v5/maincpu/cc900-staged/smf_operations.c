/* Functions of file_io/smf_operations.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char CType_ClassTable[];

void RenderSmfFilename(unsigned char *name, unsigned char len)
{
	int i;

	name[len] = 0;
	for (i = 0; i < 8 && name[i] != 0; i++)
		if (!(CType_ClassTable[name[i]] & 7)) name[i] = 0x5f;
	if (i < 8) do { name[i] = 0x5f; i++; } while (i < 8);
}
