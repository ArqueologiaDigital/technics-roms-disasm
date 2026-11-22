/* lane_p6 helper C, round 23r1, form a: module 272 (ui/ui_widget_defs.s), the class-object procs of pool roots23_A's
   ClassProc stretch: ClassProc (the table proc of the Class objects, with its eight-way 0x1e00000.. jump table
   ClassProc_CaseTable), SupportClassProc and FunctionProc.
   An object id is (table slot << 16) | index; OBJECT_REGISTRY[slot].data is the slot's record array.
   V4.23 compares the sparse case labels in reverse source order, then the dense 0x1e00000..07 range by its table;
   a default the ROM places right after the compares is written first (FunctionProc).
   Form b: form a with ClassProc's MT_CheckClassSp loop written as a guarded do-while (the ROM tests obj once before
   the loop and the parent at its bottom), and FunctionProc's name lookup through a second table pointer.
*/
/* cc900-data: ClassProc 1 = ClassProc_CaseTable */
/* cc900-module: ObjectProc */   /* scripts/analysis/cc900/module_calls.py v10 */

struct clsrec { long (*proc)(unsigned long, long, long); long parent; unsigned int size; int pad; char *name;
	char *props; char **names; };
struct suprec { long (*proc)(unsigned long, long, long); int pad; unsigned int size; int pad2; };
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
struct pnreq { long n; char *buf; };
extern struct objent OBJECT_REGISTRY[];

#define EVT_GET_CLASS_SP		0x1e00000L
#define EVT_GET_PARENT_SP		0x1e00001L
#define EVT_GET_PROC_SP			0x1e00002L
#define EVT_GET_INSTANCE_SIZE_SP	0x1e00003L
#define EVT_CHECK_CLASS_SP		0x1e00004L
#define EVT_GET_PROP_STRING_EX		0x1e00005L
#define EVT_GET_PROP_COUNT_SP		0x1e00006L
#define EVT_GET_PROP_NAME_SP		0x1e00007L
#define EVT_GET_PROP_DATA_SP		0x1e0000dL
#define EVT_GET_PROP_DATA_COUNT_SP	0x1e0000eL
#define EVT_GET_INSTANCE		0x1e0000fL
#define EVT_GET_NAME			0x1e00015L
#define EVT_GET_PROP_STRING		0x1e00019L
#define EVT_CHECK_PROP_STRING		0x1e00025L
#define EVT_GET_PROP_MEMBER		0x1e00026L
#define EVT_GET_PROP_SIZE		0x1e00027L
#define EVT_GET_FUNCTION		0x1e0002aL
#define NAKA_CLASS_Function		0x1600001L
#define NAKA_CLASS_SupportClass		0x1600005L

extern long SendEvent(unsigned long, long, long);
extern long ObjectProc(unsigned long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strcat(char *, char *);
extern int __cdecl Strlen(char *);
extern long ClassProc(unsigned long obj, long evt, long par);
extern long SupportClassProc(unsigned long obj, long evt, long par);
extern long FunctionProc(unsigned long obj, long evt, long par);

long ClassProc(unsigned long obj, long evt, long par)
{
	struct clsrec *cls;
	unsigned int i;
	long k;
	long m;
	char buf[128];
	char buf2[128];
	unsigned int t;
	unsigned long x;

	t = (unsigned int)((obj >> 16) & 0xfff);
	i = (unsigned int)(obj & 0xffff);
	cls = (struct clsrec *)OBJECT_REGISTRY[t].data;
	switch (evt) {
	case EVT_GET_CLASS_SP:
		return obj;
	case EVT_GET_PARENT_SP:
		return cls[i].parent;
	case EVT_GET_PROC_SP:
		return (long)cls[i].proc;
	case EVT_GET_NAME:
		return (long)cls[i].name;
	case EVT_GET_INSTANCE:
		return (long)&cls[i];
	case EVT_GET_INSTANCE_SIZE_SP:
		return cls[i].size;
	case EVT_CHECK_CLASS_SP:
		if (obj == 0xffffffffUL)
			return 0;
		x = obj;
		do {
			if (x == par)
				return 1;
			cls = (struct clsrec *)OBJECT_REGISTRY[(unsigned int)((x >> 16) & 0xfff)].data;
			x = cls[(unsigned int)(x & 0xffff)].parent;
		} while (x != 0xffffffffUL);
		return 0;
	case EVT_GET_PROP_STRING_EX:
		Strcpy(buf, cls[i].props);
		for (k = 0; buf[k] != 0; k++)
			SendEvent((unsigned char)(buf[k] - 'A') + 0x2600000L, EVT_CHECK_PROP_STRING, (long)buf);
		Strcat(buf, (char *)par);
		Strcpy((char *)par, buf);
		if (cls[i].parent != -1)
			ClassProc(cls[i].parent, EVT_GET_PROP_STRING_EX, par);
		return 0;
	case EVT_GET_PROP_COUNT_SP:
		SendEvent(obj, EVT_GET_PROP_STRING, (long)buf);
		return (unsigned int)Strlen(buf);
	case EVT_GET_PROP_NAME_SP:
		if (cls[i].parent != -1)
			ClassProc(cls[i].parent, EVT_GET_PROP_NAME_SP, par);
		if (*((struct pnreq *)par)->buf != 0)
			return 0;
		Strcpy(buf, cls[i].props);
		for (k = 0; buf[k] != 0; k++)
			SendEvent((unsigned char)(buf[k] - 'A') + 0x2600000L, EVT_CHECK_PROP_STRING, (long)buf);
		k = m = 0;
		while (buf[k] != 0) {
			Strcpy(buf2, cls[i].names[m]);
			m += SendEvent((unsigned char)(buf[k] - 'A') + 0x2600000L, EVT_GET_PROP_MEMBER, (long)buf2);
			if (((struct pnreq *)par)->n == 0) {
				Strcpy(((struct pnreq *)par)->buf, buf2);
				return 0;
			}
			k++;
			((struct pnreq *)par)->n--;
		}
		return 0;
	case EVT_GET_PROP_DATA_SP:
		SendEvent(obj, EVT_GET_PROP_STRING, (long)buf);
		return SendEvent((unsigned char)(buf[*(long *)par] - 'A') + 0x2600000L, EVT_GET_PROP_DATA_SP, par);
	case EVT_GET_PROP_DATA_COUNT_SP:
		SendEvent(obj, EVT_GET_PROP_STRING, (long)buf);
		return SendEvent((unsigned char)(buf[par] - 'A') + 0x2600000L, EVT_GET_PROP_DATA_COUNT_SP, par);
	default:
		return ObjectProc(obj, evt, par);
	}
}

long SupportClassProc(unsigned long obj, long evt, long par)
{
	unsigned int t;
	unsigned int i;
	struct suprec *rec;

	t = (unsigned int)((obj >> 16) & 0xfff);
	i = (unsigned int)(obj & 0xffff);
	rec = &((struct suprec *)OBJECT_REGISTRY[t].data)[i];
	switch (evt) {
	case EVT_GET_CLASS_SP:
		return NAKA_CLASS_SupportClass;
	case EVT_GET_INSTANCE:
		return (long)rec;
	case EVT_GET_PROP_SIZE:
		return rec->size;
	default:
		if (obj != NAKA_CLASS_SupportClass)
			return rec->proc(obj, evt, par);
		return ObjectProc(obj, evt, par);
	}
}

long FunctionProc(unsigned long obj, long evt, long par)
{
	unsigned int t;
	unsigned int i;
	long *tab;

	t = (unsigned int)((obj >> 16) & 0xfff);
	i = (unsigned int)(obj & 0xffff);
	tab = (long *)OBJECT_REGISTRY[t].data;
	switch (evt) {
	default:
		return ObjectProc(obj, evt, par);
	case EVT_GET_CLASS_SP:
		return NAKA_CLASS_Function;
	case EVT_GET_INSTANCE:
		return (long)&tab[i];
	case EVT_GET_FUNCTION:
		return tab[i];
	case EVT_GET_NAME:
		t += 0x300;
		tab = (long *)OBJECT_REGISTRY[t].data;
		return tab[i];
	}
}
