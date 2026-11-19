/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_1m277a.c (2026-11-19-13-p6-r41)
   sha256 81ad1bfe27deba6b95f1f97bedabf3d01b469661bb448f95ab5cffed0b71790c (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_8ec4;
extern unsigned char __near ram_8eb2[];
extern void PanelInput_QueueChange(unsigned char *);
void PanelInput_UpdatePedalRecord(unsigned char *rec, unsigned char c)
{
	unsigned char *q;
	unsigned char *p;
	unsigned char old;
	unsigned char b;
	unsigned char nv;

	if (rec[0] == 0x1d && (c & 0x0f) == 0x0f)
		rec[1] = c ^ 0x0f;
	else
		rec[1] = c;
	if (ram_8ec4 < 7) {
		p = &rec[1];
		b = *p;
		if (b != 0 || rec[3] != 0) {
			q = ram_8eb2;
			old = rec[3];
			nv = (rec[2] & b) | ((rec[2] ^ b) & old);
			rec[3] = nv;
			rec[2] = *p;
			if (nv != old) {
				q[0] = rec[0];
				q[1] = nv;
				q[2] = old ^ nv;
				PanelInput_QueueChange(q);
			}
		}
	}
}
