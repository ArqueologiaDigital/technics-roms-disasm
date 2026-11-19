/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m129a.c (2026-11-19-15-p6-r42)
   sha256 67c161e25dfdbf9eb6d31ace3b1df1a2d2c1933e524fb9780054924a984863ac (tar-sha256); compiled at -O3 -Xr */
struct semrows { char pad[16]; char row[8][21]; };
extern unsigned char __near ram_68c;
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *obj);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void SeMenu_SetupDisplayObject_Alt1(int, unsigned char, unsigned char *, unsigned int);
int SeMenu_SetFilterType(unsigned char type)
{
	unsigned char part;
	unsigned char obj;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	if (obj == 0)
		SeMenu_RegisterElement_Extended(part, 54, &type, 7);
	else
		SeMenu_SetupDisplayObject_Alt1(0,
			(unsigned char)(long)&((struct semrows *)0)->row[(unsigned char)(part - 1)][15], &type, 7);
	ram_68c = type;
	return 0;
}
