/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern int SndParam_LookupReadOnly(long);
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
extern int SndParam_LookupViaEncode(int, int);
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern unsigned char __near CURRENT_TITLE;

unsigned char Note_CheckTransposeRange(unsigned char a, unsigned char c)
{
  unsigned char r = 0;
  if (SndParam_LookupReadOnly(0xc0L) == 1) {
    if (c == 0x78) r = 1; else r = 0;
  } else {
    if ((a & 0xf0) == 0xf0) r = 1; else r = 0;
  }
  return r;
}

void Rhythm_DispatchCCCommand(unsigned char a, unsigned char c)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0x90; b[2] = 0x19; b[3] = a; b[4] = c;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

unsigned char SelectTone_Continue_Prologue(unsigned char a)
{
  unsigned char b[6];
  if (CURRENT_TITLE == 246) {
    b[3] = SndParam_LookupViaEncode(0, 0);
    b[4] = SndParam_LookupViaEncode(0, 0x20);
    b[2] = 0;
    SndParam_FetchOscTableEntry(b);
    a = b[0] + 0xf0;
  }
  return a;
}

struct nent5 { unsigned char e0, e1, e2, e3, e4; };
#define NM_E(r, i) ((struct nent5 *)((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4)))
extern void InitChannelState_Che_InitVal(unsigned char *r);

void InitChannelState_Che_InitVal(unsigned char *r)
{
  unsigned int i;
  for (i = 0; i < r[1]; i++) {
    NM_E(r, i)->e4 = 0;
    if (NM_E(r, i)->e1 != 0) {
      NM_E(r, i)->e2 = NM_E(r, i)->e0;
      NM_E(r, i)->e3 = NM_E(r, i)->e0;
    }
  }
}

struct ct2 { unsigned char next; unsigned char pad; };
struct ct8 { unsigned char id; unsigned char x1; unsigned char v0; unsigned char x3, x4; unsigned char v1, v2;
             unsigned char x7; };
extern unsigned char CharMap_ValueData_A[];
extern unsigned char __near ram_cd42;
extern unsigned char __near ram_cd44;
extern struct ct2 __near ram_e82e[128];
extern struct ct8 __near ram_c66a[128];
extern unsigned char SndParam_UpdateChannelTuning(unsigned char m, unsigned char c, unsigned char e);

unsigned char SndParam_UpdateChannelTuning(unsigned char m, unsigned char c, unsigned char e)
{
	unsigned char r;

	if (m != 0xff) {
		ram_cd44 = CharMap_ValueData_A[m];
		ram_cd42 = ram_e82e[ram_cd44].next;
	}
	if (ram_cd42 != ram_cd44 && ram_c66a[ram_cd42].id == c) {
		switch (e) {
		case 0:
			r = ram_c66a[ram_cd42].v0;
			break;
		case 1:
			r = ram_c66a[ram_cd42].v1;
			break;
		case 2:
			r = ram_c66a[ram_cd42].v2;
			break;
		default:
			r = 0xff;
			break;
		}
		ram_cd42 = ram_e82e[ram_cd42].next;
	} else
		r = 0xff;
	return r;
}
