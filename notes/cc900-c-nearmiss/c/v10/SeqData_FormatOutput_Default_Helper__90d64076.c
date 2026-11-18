/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_2m303a.c (2026-11-18-28-p6-r36)
   sha256 90d64076abb0872d786212234ff52bcf7c74bd411d34f1e1e61ee7f908d9d634 (tar-sha256); compiled at -O3 -Xr */
typedef unsigned char *UCP;
extern UCP __near ram_e193;
extern int Param_SignExtendReturn_Helper(unsigned char *);
extern long Param_SignExtendRetu_Data(unsigned char *);
extern void sendCOMM(int, int, unsigned char *);
int SeqData_FormatOutput_Default_Helper(unsigned char *p)
{
	int r;
	int n;
	long a;
	long b;
	unsigned long m;
	unsigned char e;

	n = Param_SignExtendReturn_Helper(p);
	a = Param_SignExtendRetu_Data(p);
	b = n;
	if (n == 0 || n <= 120 || a == 0) {
		r = 1;
		return r;
	}
	m = a % 0x4000;
	e = ((unsigned char *)m)[0x10] & 0xc0;
	if (e != 0xc0) {
		m += b;
		switch (e) {
		case 0:
			if (m > 0x1d6)
				r = 1;
			else {
				ram_e193 = p;
				sendCOMM(3, n, p);
				r = 0;
			}
			break;
		case 0x40:
			break;
		case 0x80:
			if (m > 0x2927)
				r = 1;
			else {
				ram_e193 = p;
				sendCOMM(3, n, p);
				r = 0;
			}
			break;
		}
	}
	return r;
}
