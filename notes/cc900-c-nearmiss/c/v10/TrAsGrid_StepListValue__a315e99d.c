/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4a.c (2026-11-16-40-p6-r8)
   sha256 a315e99d2abe85580e38dfba3d46d23a20ad559e556e2bf7a471551863fb0ae9 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char TrAsGrid_ByteData1_Table[], TrAsGrid_ByteData1_Table_2[];
unsigned char TrAsGrid_StepListValue(unsigned char i, unsigned char dir)
{
	unsigned char v = TrAsGrid_ByteData1_Table[i];

	if (dir == 0) {
		if (v < 19) v++;
	} else {
		if (v != 0) v--;
	}
	return TrAsGrid_ByteData1_Table_2[v];
}
