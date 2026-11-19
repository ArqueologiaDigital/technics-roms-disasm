/* Phase 6, lane_p6 helper L, round 4, file b of module 271 -- NOT an alternative of 4m271a: a different hand source
   (ui/ui_widget_defs.s), new.
   - MainLswPartAdd: the matched MainLswPartGet's twin (cc900/ui_widget_defs_m0.c) with two more fields, the 4th
     argument on the stack (retd 2), IZ saved as a word (pushw iz), and MainFuncCall in place of FuncCall. */
/* (no module-local callee) */

#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_LSW_PART_ADD 0x1e0005bL
struct lswadd { long id; int c; int d; long z; };
extern void *__cdecl Malloc(unsigned int);
extern long MainFuncCall(long fn, long evt, void *par);
extern int MainLswPartAdd(unsigned int part, unsigned int idx, int c, int d);

int MainLswPartAdd(unsigned int part, unsigned int idx, int c, int d)
{
	struct lswadd *p;

	p = (struct lswadd *)Malloc(sizeof(struct lswadd));
	p->id = ((unsigned long)part << 16) + idx;
	p->c = c;
	p->d = d;
	p->z = 0;
	MainFuncCall(NAKA_MAINFUNC_MainPmanControl, EVT_LSW_PART_ADD, p);
	MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
	return 0;
}
