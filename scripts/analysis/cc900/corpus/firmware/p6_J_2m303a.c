/* Phase 6, lane_p6 helper J, round 2, module 303 (audio/note_voice_mapping.s, -O3 -Xr like
   note_voice_mapping_m303.c), form a: SndParam_LookupOscEnvelope and SeqData_FormatOutput_Default_Helper. */
/* cc900-module: Param_SignExtendRetu_Data Param_SignExtendReturn_Helper */   /* scripts/analysis/cc900/module_calls.py v10 */

struct stab { char pad0[28]; unsigned char **t28; char pad1[16]; unsigned char *t48; };
typedef struct stab *STABP;
typedef unsigned char *UCP;
extern STABP __near SOUND_TABLE_BASE;
extern UCP __near ram_e193;
extern int SndParam_LookupViaEncode(int, int);
extern int Param_SignExtendReturn_Helper(unsigned char *);
extern long Param_SignExtendRetu_Data(unsigned char *);
extern void sendCOMM(int, int, unsigned char *);

/* The oscillator envelope pair of a voice record p: from the 0x30 table (2 bytes per entry, p[2] selects) when p[5]
   is 0x0f or the encoded lookup is >= 0xf0, else the first 3-byte step of the 0x1c table's list p[2] whose key
   ends the scan; the pair goes to p[3], p[4]. */
void SndParam_LookupOscEnvelope(unsigned char *p)
{
	unsigned char *e;
	unsigned char *k;
	unsigned char *q;
	unsigned char c;
	int h;

	if (p[5] != 0x0f) {
		h = SndParam_LookupViaEncode(p[5], 0);
		q = p + 2;
		if (h >= 0xf0)
			e = SOUND_TABLE_BASE->t48;
		else {
			e = SOUND_TABLE_BASE->t28[*q];
			c = p[1];
			for (k = e + 2; c >= *k || *k != 0xff; k += 3)
				e += 3;
			goto done;
		}
	} else {
		e = SOUND_TABLE_BASE->t48;
		q = p + 2;
	}
	e += (unsigned char)(*q << 1);
done:
	p[3] = e[0];
	p[4] = e[1];
}

/* Send a parameter (sendCOMM 3) when its value n (> 120) and its location (a long; the low 14 bits address a
   record whose byte 0x10 holds the kind in bits 6-7) fit the kind's range: 0 for sent, 1 for not.  Kinds 0x40 and
   0xc0 return r unset (the ROM returns the frame word it never wrote). */
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
