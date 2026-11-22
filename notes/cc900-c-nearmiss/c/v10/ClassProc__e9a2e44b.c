/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_24r1m272a.c (2026-11-22-1-p6-r69)
   sha256 e9a2e44bf44dd35d5b284376573e0bb6248a48db8c452b6cacc890bfd9ca66fe (tar-sha256); compiled at -O3 -Xr */
struct clsrec { long (*proc)(unsigned long, long, long); long parent; unsigned int size; int pad; char *name;
	char *props; char **names; };
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
extern long SendEvent(unsigned long, long, long);
extern long ObjectProc(unsigned long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strcat(char *, char *);
extern int __cdecl Strlen(char *);
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

	&evt;
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
