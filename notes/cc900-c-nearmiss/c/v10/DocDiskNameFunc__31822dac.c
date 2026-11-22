/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_22r2m269b.c (2026-11-21-21-p6-r66)
   sha256 31822dac9fce4f3d4402d0b1216ec461c9927be9ab297aaf836dbe726fa5d004 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
#define EVT_PAINT      0x1c0000bL
#define EVT_PARA_DRAW  0x1c0000fL
extern unsigned char __near ram_878c[];
extern long ApPostEvent(long, long, long);
extern unsigned char *FileIO_SearchAndLoadFile(void);
long DocDiskNameFunc(long obj, long evt, long par)
{
	unsigned char *s;
	unsigned char *d;
	int i;

	if (evt != EVT_PAINT)
		return 0;
	s = FileIO_SearchAndLoadFile();
	i = 0;
	while (d = ram_878c, *s != 0 && i < 30) {
		if (*s != ' ')
			d[i++] = *s;
		s++;
	}
	d[i] = 0;
	for (;;) {
		i--;
		if (d[i] != ' ')
			break;
		if (i <= 0)
			break;
		d[i] = 0;
	}
	ApPostEvent(par, EVT_PARA_DRAW, (long)d);
	return 0;
}
