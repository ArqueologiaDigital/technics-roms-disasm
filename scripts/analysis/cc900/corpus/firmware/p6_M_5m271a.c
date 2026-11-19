/* Phase 6, lane_p6 helper M, round 5, module 271 (audio/presentation_sound_nav.s), new: GetEditSwPoint.
   The screen point of edit switch id: ids 0..7 a bottom row (x = 20 + 40 i, y = 239), 8..12 the right column
   (x = 319), 0x88..0x8c the left column (x = 0) at the same five heights, else the centre (160, 120).  A compiled
   switch: 0..12 through the jump table GetEditSwPoint_CaseTable (based at the first case body), the 0x88.. ids by
   a compare chain (written in ascending order: V4.23 compares the last case first, 0x8c).  Case bodies interleave
   in the ROM as 0x88, 8, 0x89, 9, ... (each pair shares its tail), then 0..7, then default: the source order. */
/* cc900-data: GetEditSwPoint 1 = GetEditSwPoint_CaseTable */

struct pt { int x, y; };
extern void GetEditSwPoint(unsigned int id, struct pt *p);

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
