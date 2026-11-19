/* Functions of audio/presentation_sound_nav.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct pt { int x, y; };
extern void GetEditSwPoint(unsigned int id, struct pt *p);

/* cc900-data: GetEditSwPoint 1 = GetEditSwPoint_CaseTable */
void GetEditSwPoint(unsigned int id, struct pt *p)
{
	switch (id) {
	case 0x88: p->x = 0;   p->y = 0x2b; break;
	case 8:    p->x = 319; p->y = 0x2b; break;
	case 0x89: p->x = 0;   p->y = 0x55; break;
	case 9:    p->x = 319; p->y = 0x55; break;
	case 0x8a: p->x = 0;   p->y = 0x7f; break;
	case 10:   p->x = 319; p->y = 0x7f; break;
	case 0x8b: p->x = 0;   p->y = 0xa9; break;
	case 11:   p->x = 319; p->y = 0xa9; break;
	case 0x8c: p->x = 0;   p->y = 0xd3; break;
	case 12:   p->x = 319; p->y = 0xd3; break;
	case 0:    p->x = 20;  p->y = 239; break;
	case 1:    p->x = 60;  p->y = 239; break;
	case 2:    p->x = 100; p->y = 239; break;
	case 3:    p->x = 140; p->y = 239; break;
	case 4:    p->x = 180; p->y = 239; break;
	case 5:    p->x = 220; p->y = 239; break;
	case 6:    p->x = 260; p->y = 239; break;
	case 7:    p->x = 300; p->y = 239; break;
	default:   p->x = 160; p->y = 120; break;
	}
}
