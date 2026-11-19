/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern int SndParam_LookupViaEncode(int, int);

void SndParam_ApplyVoiceValue(unsigned char *r)
{
  unsigned char *q;
  if (r[5] != 0x0f) {
    int h = SndParam_LookupViaEncode(r[5], 0x20);
    q = r + 4;
    r[3] = r[2];
    if (h == 0x78) *q = 0x78; else *q = r[1];
  } else {
    r[3] = r[2];
    r[4] = 0x78;
  }
}

extern int SndParam_LookupReadOnly(long);
extern void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q);

void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q)
{
	unsigned char c;

	if (SndParam_LookupReadOnly(0xc0) == 1)
		return;
	if (*q == 0x78)
		return;
	if (*p <= 0x7f) {
		*q &= 7;
		return;
	}
	if (*q == 7) {
		*p &= 0x7f;
		c = 0x70;
	} else if (*p <= 0xef) {
		if (*q == 0) {
			*p &= 0x7f;
			c = 0x10;
		} else if (*q == 5) {
			*p &= 0x7f;
			c = 0x15;
		} else
			goto def;
	} else if (*q <= 1) {
		*p &= 0x0f;
		*q = (*q & 1) | 0x40;
		return;
	} else if (*q == 6) {
		*p = 0;
		c = 0x50;
	} else if (*q == 5) {
		*p &= 3;
		c = 0x55;
	} else {
def:
		*p = 0;
		c = 0;
	}
	*q = c;
}

/* cc900-module: ApplyProgramChangeAs_DoLookupRe ApplyProgramChangeAs_LoadReg ApplyProgramChangeAs_LoadReg2 */
extern void ApplyProgramChangeAs_LoadReg(unsigned char *p);
extern void ApplyProgramChangeAs_LoadReg2(unsigned char *p);
extern void SndParam_FetchOscTableEntry(unsigned char *p);

void SndParam_FetchOscTableEntry(unsigned char *p)
{
	if (SndParam_LookupReadOnly(192) == 1)
		ApplyProgramChangeAs_LoadReg2(p);
	else
		ApplyProgramChangeAs_LoadReg(p);
}

/* cc900-module: FetchOscTableEntry_LoadReg FetchOscTableEntry_LoadReg2 */
struct sndtab { long a0; long a4; };
extern struct sndtab *__near SOUND_TABLE_BASE;
extern unsigned char GetCurrentPartSelect(void);
extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern void FetchOscTableEntry_LoadReg(unsigned char *);
extern void FetchOscTableEntry_LoadReg2(unsigned char *);
extern void SndParam_ApplyProgramChange(unsigned char *p);

unsigned char ApplyProgramChangeAs_DoLookupRe(void)
{
	unsigned char r;

	if (SndParam_LookupReadOnly(0xc0L) == 1) {
		if (GetCurrentPartSelect() != 15)
			r = 0x80;
		else
			r = 0x89;
	} else
		r = SOUND_TABLE_BASE->a4;
	return r;
}
void SndParam_ApplyProgramChange(unsigned char *p)
{
	if (SndParam_LookupReadOnly(0xc0L) == 1)
		FetchOscTableEntry_LoadReg2(p);
	else
		FetchOscTableEntry_LoadReg(p);
}
