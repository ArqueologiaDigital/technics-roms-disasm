/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_22r2m270b.c (2026-11-21-21-p6-r66)
   sha256 b57943f4440a342f9582eab8b5106b936562db17f6ea8c655d9693d05d69c989 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_LSW_DATA             0x1c0001cL
#define EVT_AUTO_FREE            0x1e00023L
#define EVT_LSW_PUT              0x1e00057L
#define EVT_LSW_ADD              0x1e00058L
#define EVT_LSW_GET              0x1e00059L
#define EVT_LSW_PART_PUT         0x1e0005aL
#define EVT_LSW_PART_ADD         0x1e0005bL
#define EVT_LSW_PART_GET         0x1e0005cL
#define EVT_PART_SELECT_PUT      0x1e000a0L
struct lsw { unsigned long id; int value; int out; long spare; };
extern unsigned char __near PART_SELECT;
extern long ApPostEvent(long, long, void *);
extern void *__cdecl Malloc(unsigned int);
extern void SoundParam_NotifyChange(long, int, int);
extern int SndParam_LookupByKey(unsigned long, int, int);
extern int SndParam_LookupReadOnly(long);
extern void SndParam_NotifyAndReturn(long, long, int, int);
extern void SndParam_WrapNotify2(long, long, int, int);
extern int SndParam_LookupViaEncode(long, long);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
long MainPmanControl(long obj, long evt, unsigned long param)
{
	struct lsw *s;
	struct lsw *q;
	switch (evt) {
	case EVT_LSW_PUT:
		s = (struct lsw *)param;
		SoundParam_NotifyChange(s->id, s->value, s->out);
		break;
	case EVT_LSW_ADD:
		s = (struct lsw *)param;
		SndParam_LookupByKey(s->id, s->value, s->out);
		break;
	case EVT_LSW_GET:
		s = (struct lsw *)param;
		s->value = SndParam_LookupReadOnly(s->id);
		q = Malloc(12);
		*q = *s;
		ApPostEvent(-1L, EVT_LSW_DATA, q);
		ApPostEvent(-1L, EVT_AUTO_FREE, q);
		break;
	case EVT_LSW_PART_PUT:
		s = (struct lsw *)param;
		SndParam_NotifyAndReturn((unsigned int)(s->id >> 16), s->id, s->value, s->out);
		break;
	case EVT_LSW_PART_ADD:
		s = (struct lsw *)param;
		SndParam_WrapNotify2((unsigned int)(s->id >> 16), s->id, s->value, s->out);
		break;
	case EVT_LSW_PART_GET:
		s = (struct lsw *)param;
		s->value = SndParam_LookupViaEncode((unsigned int)(s->id >> 16), s->id);
		q = Malloc(12);
		*q = *s;
		ApPostEvent(-1L, EVT_LSW_DATA, q);
		ApPostEvent(-1L, EVT_AUTO_FREE, q);
		break;
	case EVT_PART_SELECT_PUT: {
		unsigned char old = PART_SELECT;
		if (param < 0x10 || param == 0x15 || param == 0x16) {
			PART_SELECT = (unsigned char)param;
		} else {
			unsigned char v = SndParam_LookupReadOnly(0x4100L);
			if (v == 1 || v == 5) PART_SELECT = 1;
			else PART_SELECT = 0;
		}
		if (PART_SELECT != old) AddswbWr(0x90, 0x10, PART_SELECT, 0xff);
		break;
	}
	}
	return 0;
}
