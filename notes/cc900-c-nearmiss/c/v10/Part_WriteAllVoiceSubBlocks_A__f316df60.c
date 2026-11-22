/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_26r1m234b.c (2026-11-22-5-p6-r72)
   sha256 f316df6085e8748df6652fc087065511a652687f1f637e8ac98e407668b66221 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char PartSubBlkA_WriteLoop32_Table[];
extern unsigned char PartSubBlkA_WriteLoop48_Table[];
extern void Part_WriteSubBlock32(unsigned int, unsigned int, unsigned char);
extern void Part_WriteSubBlock48(unsigned int, unsigned int, unsigned char);
void Part_WriteAllVoiceSubBlocks_A(unsigned char p)
{
	unsigned char i;

	for (i = 1; i <= 16; i++)
		Part_WriteSubBlock32(p, i, PartSubBlkA_WriteLoop32_Table[i - 1]);
	for (i = 1; i <= 16; i++)
		Part_WriteSubBlock48(p, i, PartSubBlkA_WriteLoop48_Table[i - 1]);
}
