/* lane_p6 helper D, round 23r1, form a: module 128 (display/scoop_display.s), roots23_B's stretch at f023cf:
   Scoop_EventLoop_36Entry (-Xr shape: the record pointer spilled to the frame and reloaded), and three bound-field
   print handlers (-O3 shape: the record in XIZ / XDE): Scoop_BoundOp0B_PrintSignedField, Scoop_BoundOp0A_PrintByte,
   Scoop_BoundOp07_DrawStringByField.  Records are byte arrays (the ROM reads words at odd offsets 7 / 9 / 11 / 13 /
   15), words through `*(unsigned int *)(s + n)` (SeqStep_FileSectorReturn's matched spelling).  Format strings are
   far pointers pushed as two words; DrawString's stack arguments font, 0xff, 0xf5 (pushed in that order, as in
   ui_window_procs_m271.c).  Frames: box highest, pt, buf, then scalars (helper A's Scoop lesson).
   cc900-options: -O3 -Xr
*/
/* cc900-name: ScFmt1d=Scoop_EventLoop_36Entry_Str_Fmt1d */
/* cc900-name: ScFmt2dB1=Scoop_EventLoop_36Entry_Branch1_Str_Fmt2d */
/* cc900-name: ScFmt3dB2=Scoop_EventLoop_36Entry_Branch2_Str_Fmt3d */
/* cc900-name: ScB3Fmt1d=Scoop_EventLoop_36Entry_Branch3_Str_Fmt1d */
/* cc900-name: ScB3Fmt2d=Scoop_EventLoop_36Entry_Branch3_Str_Fmt2d */
/* cc900-name: ScB3Fmt3d=Scoop_EventLoop_36Entry_Branch3_Str_Fmt3d */
/* cc900-name: ScB3Fmt2d2=Scoop_EventLoop_36Entry_Branch3_Str_Fmt2d_2 */
/* cc900-name: ScB3Fmt3d2=Scoop_EventLoop_36Entry_Branch3_Str_Fmt3d_2 */
/* cc900-name: ScB3Fmt4d=Scoop_EventLoop_36Entry_Branch3_Str_Fmt4d */
/* cc900-name: ScB3Fmt1d2=Scoop_EventLoop_36Entry_Branch3_Str_Fmt1d_2 */
/* cc900-name: ScB3Fmt2d3=Scoop_EventLoop_36Entry_Branch3_Str_Fmt2d_3 */
/* cc900-name: ScB3Fmt3d3=Scoop_EventLoop_36Entry_Branch3_Str_Fmt3d_3 */

struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };

extern struct rect Scoop_BoundOp06_ClipBox;
extern struct rect GUI_FormatStrings;
extern struct rect Scoop_BoundOp0A_ClipBox;
extern struct rect Scoop_BoundOp07_ClipBox;
extern long TextStyle_FontTable[];
extern long TextStyle_NibbleFontTable[];
extern char ScFmt1d[];
extern char ScFmt2dB1[];
extern char ScFmt3dB2[];
extern char ScB3Fmt1d[];
extern char ScB3Fmt2d[];
extern char ScB3Fmt3d[];
extern char ScB3Fmt2d2[];
extern char ScB3Fmt3d2[];
extern char ScB3Fmt4d[];
extern char ScB3Fmt1d2[];
extern char ScB3Fmt2d3[];
extern char ScB3Fmt3d3[];

extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern int CalcTotalWidth(char *, long);
extern int GetCharDescent(long);
extern int GetCharHeight(long);

void Scoop_EventLoop_36Entry(unsigned char *s)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	long font;
	int *p;
	unsigned int pos;
	int type;
	int d;

	box = Scoop_BoundOp06_ClipBox;
	p = (int *)*(unsigned int *)(s + 2);
	pos = *(unsigned int *)(s + 7);
	type = s[9];
	pt.y = pos / 40;
	pt.x = (pos - pt.y * 40) * 8;
	pt.y -= 2;
	switch (type) {
	case 1:
		Sprintf_Locked(buf, ScFmt1d, *p);
		break;
	case 2:
		Sprintf_Locked(buf, ScFmt2dB1, *p);
		break;
	default:
		Sprintf_Locked(buf, ScFmt3dB2, *p);
		break;
	}
	font = TextStyle_FontTable[s[6] & 0x3f];
	box.x0 = pt.x;
	box.x1 = pt.x + CalcTotalWidth(buf, font);
	box.y0 = pt.y + 2;
	d = GetCharDescent(font);
	box.y1 = pt.y + GetCharHeight(font) - d;
	DrawString(&box, &pt, buf, font, 0xff, 0xf5);
}

void Scoop_BoundOp0B_PrintSignedField(unsigned char *s)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	unsigned char v;
	unsigned char type;
	unsigned char c;

	box = GUI_FormatStrings;
	v = (*(unsigned char *)*(unsigned int *)(s + 2) & s[4]) >> s[5];
	type = s[11];
	pt.x = *(int *)(s + 7);
	pt.y = *(int *)(s + 9);
	c = s[12];
	if (c != v) {
		if (c < 128 && v >= 128) {
			c = 128;
			v -= 128;
		}
		if (v > c) {
			buf[0] = '+';
			v -= c;
		} else {
			buf[0] = '-';
			v = c - v;
		}
		switch (type) {
		case 1:
			Sprintf_Locked(buf + 1, ScB3Fmt1d, v);
			break;
		case 2:
			Sprintf_Locked(buf + 1, ScB3Fmt2d, v);
			break;
		default:
			Sprintf_Locked(buf + 1, ScB3Fmt3d, v);
			break;
		}
	} else {
		v = 0;
		switch (type) {
		case 1:
			Sprintf_Locked(buf, ScB3Fmt2d2, v);
			break;
		case 2:
			Sprintf_Locked(buf, ScB3Fmt3d2, v);
			break;
		default:
			Sprintf_Locked(buf, ScB3Fmt4d, v);
			break;
		}
	}
	DrawString(&box, &pt, buf, TextStyle_NibbleFontTable[s[6] & 15], 0xff, 0xf5);
}

void Scoop_BoundOp0A_PrintByte(unsigned char *s)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	int *p;
	unsigned char type;

	box = Scoop_BoundOp0A_ClipBox;
	p = (int *)*(unsigned int *)(s + 2);
	type = s[11];
	pt.x = *(int *)(s + 7);
	pt.y = *(int *)(s + 9);
	switch (type) {
	case 1:
		Sprintf_Locked(buf, ScB3Fmt1d2, *p);
		break;
	case 2:
		Sprintf_Locked(buf, ScB3Fmt2d3, *p);
		break;
	default:
		Sprintf_Locked(buf, ScB3Fmt3d3, *p);
		break;
	}
	DrawString(&box, &pt, buf, TextStyle_NibbleFontTable[s[6] & 15], 0xff, 0xf5);
}

void Scoop_BoundOp07_DrawStringByField(unsigned char *s)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	unsigned char idx;
	unsigned int n;
	unsigned int i;

	box = Scoop_BoundOp07_ClipBox;
	idx = (*(unsigned char *)*(unsigned int *)(s + 2) & s[4]) >> s[5];
	pt.x = *(int *)(s + 13);
	pt.y = *(int *)(s + 15);
	n = *(unsigned int *)(s + 11);
	for (i = 0; i < n; i++)
		buf[i] = (*(unsigned char **)(s + 7))[(unsigned long)idx * n + i];
	buf[i] = 0;
	DrawString(&box, &pt, buf, TextStyle_NibbleFontTable[s[6] & 15], 0xff, 0xf5);
}
