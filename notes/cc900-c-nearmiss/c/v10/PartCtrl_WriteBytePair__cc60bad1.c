/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_5m234a.c (2026-11-19-37-p6-r47)
   sha256 cc60bad19ae10448167216037fc218caf5a95e41a3bcf8f414c2d43efdc802c8 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char ram_b0000[];
extern unsigned int PartCtrl_ReadWord(unsigned int n);
int PartCtrl_WriteBytePair(unsigned int blk, unsigned int off, unsigned char *s)
{
	unsigned char *p;
	unsigned int n;

	p = (unsigned char *)((unsigned long)ram_b0000 + (((unsigned long)(blk - 1) << 8) + off));
	*p = s[0];
	if (off == 0xff) {
		if ((n = PartCtrl_ReadWord(blk)) == 0xffff)
			return -1;
		p = (unsigned char *)((unsigned long)ram_b0000 + (((unsigned long)(n - 1) << 8) + 5));
	} else
		p++;
	*p = s[1];
	return 0;
}
