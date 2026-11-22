/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct fs { unsigned int w, h; long x; };
extern unsigned char Text_CharGlyphMap[];

void GetFrameSPSize(unsigned int i, unsigned int *w, unsigned int *h)
{
	struct fs *f = (struct fs *)0x934000 + i;

	*w = f->w;
	*h = f->h;
}

unsigned char HexCharToNibble(unsigned char a)
{
	if (a >= 0x30 && a <= 0x39) return a - 0x30;
	if (a >= 0x61 && a <= 0x66) return a - 0x57;
	if (a >= 0x41 && a <= 0x46) return a - 0x37;
	return 0;
}

void Text_GlyphToCharCode(unsigned char *in, unsigned char *out)
{
	int i;
	unsigned char e;

	e = *in;
	if (e == 32 || e == 0) {
		*out = *in;
		return;
	}
	for (i = 0; i < 256; i++)
		if (*in == Text_CharGlyphMap[i]) {
			*out = i;
			break;
		}
	if (i != 256) return;
	*out = 32;
}

/* cc900-module: CalcTotalWidth */
extern int __cdecl Strlen(char *);
extern char *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern void __cdecl Free(void *);
extern int CalcTotalWidth(char *, long);
extern int WordwrapStrings(char *s, long font, int width);

int WordwrapStrings(char *s, long font, int width)
{
	int n;
	char *b2;
	int best;
	char *buf;
	char *p;

	n = 0;
	best = 0;
	p = s;
	buf = Malloc(Strlen(p) + 1);
	b2 = buf;
	if (*p != 0) do {
		while (*p != 0) {
			if (*p == 0x20) break;
			p++;
			n++;
		}
		while (*p != 0) {
			if (*p != 0x20) break;
			p++;
			n++;
		}
		Strcpy(b2, s);
		b2[n] = 0;
		if (CalcTotalWidth(b2, font) <= width) best = n;
	} while (*p != 0);
	Free(buf);
	return best;
}

/* cc900-module: HexCharToNibble */
extern unsigned char HexCharToNibble(int c);
extern void ConvertStrings(unsigned char *src, unsigned char *dst);

void ConvertStrings(unsigned char *src, unsigned char *dst)
{
	for (;;) {
		if (*src == '~') {
			src++;
			if (*src == 0)
				goto term;
			*dst = HexCharToNibble(*src) << 4;
			src++;
			if (*src == 0)
				goto term;
			*dst += HexCharToNibble(*src);
			goto next;
term:
			*dst = 0;
			return;
		}
		if (*src == 0) {
			*dst = *src;
			return;
		}
		if (*src < 0x20)
			*dst = ' ';
		else
			*dst = *src;
next:
		src++;
		dst += 1;
	}
}

/* cc900-module: SetDialFocus */
struct glyph { long bits; int descent; int w; long rest; int pad; int pad2; };
extern int GetCharDescent(unsigned long c);
struct font { unsigned int w; unsigned int h; unsigned char pad[12]; };
extern unsigned int GetCharHeight(unsigned long id);

int GetCharDescent(unsigned long c)
{
  return ((struct glyph *)0x945c00L)[c].descent;
}
unsigned int GetCharHeight(unsigned long id)
{
  return ((struct font *)0x945c00L)[id].h;
}

#define NAKA_CLASS_Function          0x1600001L
#define NAKA_CLASS_ApFunction        0x1600002L
#define NAKA_CLASS_MainFunction      0x1600003L
#define NAKA_CLASS_Class             0x1600004L
#define NAKA_CLASS_ResEvent          0x160000cL
#define NAKA_CLASS_ResMethod         0x160000dL
#define NAKA_CLASS_ResName           0x160000fL
#define NAKA_CLASS_Viewable          0x1600010L
#define NAKA_APFUNC_DefaultFunction  0x1200000L
#define NAKA_MAINFUNC_CheckTitleFunc 0x1400009L
#define NAKA_VIEW_CheckTitle         0xff0000L
#define TITLE_PS                     0x1a00000L
struct objreg { long cls; void *proc; int count; void *base; };
extern void RegisterObjectTable(unsigned int, struct objreg *);
extern void RegisterMode(long id, long func, long a, int b, char *name);
extern void RegisterTitle(long id, long func, long view, int b, char *name);
extern long ClassProc(long, long, long);
extern long ResEventProc(long, long, long);
extern long ResMethodProc(long, long, long);
extern long ApFunctionProc(long, long, long);
extern long FunctionProc(long, long, long);
extern long MainFunctionProc(long, long, long);
extern long ViewableProc(long, long, long);
extern long ResNameProc(long, long, long);
extern int Root_ClassCount_160;
extern int Root_ResEventCount_1C0;
extern int Root_ResMethodCount_1E0;
extern char Root_ClassTable_160[];
extern char Root_ResEventTable_1C0[];
extern char Root_ResMethodTable_1E0[];
extern char Root_ApFunctionTable_120[];
extern char Root_ApFunctionTable_420[];
extern char Root_FunctionTable_100[];
extern char WidgetName_InitPtrTable[];
extern char Root_MainFunctionTable_140[];
extern char Root_MainFunctionTable_440[];
extern char Root_ViewableTable_000[];
extern char Root_ResNameTable_300[];
extern char Root_ViewableTable_0FF[];
extern char Root_ResNameTable_3FF[];
extern char InitializeRoot_Str_MD_PS[];
extern char InitializeRoot_Str_TT_PS[];
extern char InitializeRoot_Str_TT_CHECK[];
extern void InitializeRoot(void);

void InitializeRoot(void)
{
	struct objreg reg;

	reg.cls = NAKA_CLASS_Class;
	reg.proc = (void *)ClassProc;
	reg.count = Root_ClassCount_160;
	reg.base = Root_ClassTable_160;
	RegisterObjectTable(0x160, &reg);
	reg.cls = NAKA_CLASS_ResEvent;
	reg.proc = (void *)ResEventProc;
	reg.count = Root_ResEventCount_1C0;
	reg.base = Root_ResEventTable_1C0;
	RegisterObjectTable(0x1c0, &reg);
	reg.cls = NAKA_CLASS_ResMethod;
	reg.proc = (void *)ResMethodProc;
	reg.count = Root_ResMethodCount_1E0;
	reg.base = Root_ResMethodTable_1E0;
	RegisterObjectTable(0x1e0, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0xc;
	reg.base = Root_ApFunctionTable_120;
	RegisterObjectTable(0x120, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0xc;
	reg.base = Root_ApFunctionTable_420;
	RegisterObjectTable(0x420, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x160;
	reg.base = Root_FunctionTable_100;
	RegisterObjectTable(0x100, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x160;
	reg.base = WidgetName_InitPtrTable;
	RegisterObjectTable(0x400, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0xd;
	reg.base = Root_MainFunctionTable_140;
	RegisterObjectTable(0x140, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0xd;
	reg.base = Root_MainFunctionTable_440;
	RegisterObjectTable(0x440, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x33;
	reg.base = Root_ViewableTable_000;
	RegisterObjectTable(0, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x33;
	reg.base = Root_ResNameTable_300;
	RegisterObjectTable(0x300, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 9;
	reg.base = Root_ViewableTable_0FF;
	RegisterObjectTable(0xff, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 9;
	reg.base = Root_ResNameTable_3FF;
	RegisterObjectTable(0x3ff, &reg);
	RegisterMode(0, NAKA_APFUNC_DefaultFunction, TITLE_PS, 0, InitializeRoot_Str_MD_PS);
	RegisterTitle(0, NAKA_APFUNC_DefaultFunction, 0, 0, InitializeRoot_Str_TT_PS);
	RegisterTitle(0xff, NAKA_MAINFUNC_CheckTitleFunc, NAKA_VIEW_CheckTitle, 0, InitializeRoot_Str_TT_CHECK);
}
