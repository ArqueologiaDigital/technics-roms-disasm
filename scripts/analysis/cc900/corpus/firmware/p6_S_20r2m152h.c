/* Phase 6, lane_p6 helper S, round 2 of 2026-11-20, hand source audio/sound_editor_ui.s (m152), form h: first
   probe of SeTonTon2_OnColumn2 (no earlier attempt).
   Read from the hand assembly: part (+6), the part-select mask (parameter 1, +4), the part's value (parameter
   part + 1, +2); sel = the part's 2-bit field of the mask (SeMenu_BitShiftMask_End, & 3) in QIZL; the dial
   (a & 0x7f == 0: up, else down) steps sel 0 -> 1 -> 2 ... with bit 7 of the value as the extra state; then the
   mask's field is replaced (SeMenu_BitShiftMask(3, n) in QIZH, cleared; SeMenu_BitShiftMask(sel, n) or-ed in, n =
   part + part - 2 as a byte, as the built SeMenu_SetPartEnabled), both re-registered
   (SeMenu_RegisterElement_Extended(part, 0, &val, 128), then (0, 18, &mask, m)), both stored, title field 1 of
   popup 35, column 2.  The first RegisterElement_Extended call has the RANGE handlers' argument order (WA, XDE,
   push, BC), the spot p6_S_20r1m128a-c test; here &val is passed directly.
   Form h: sel declared before m (form g's other order; QIZH = m, QIZL = sel in the ROM).
*/
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern unsigned char SeMenu_BitShiftMask_End(int, int);
extern unsigned char SeMenu_BitShiftMask(int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_BindDialToColumn(int col);
extern void SeTonTon2_OnColumn2(unsigned char a);

void SeTonTon2_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char mask;
	unsigned char val;
	unsigned char sel;
	unsigned char m;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(1, &mask);
	SeMenu_LoadPartParam((unsigned char)(part + 1), &val);
	sel = SeMenu_BitShiftMask_End(mask, (unsigned char)(part + part - 2));
	sel &= 3;
	if ((a & 0x7f) == 0) {
		if (val & 0x80)
			return;
		if (sel == 1) {
			val |= 0x80;
			sel = 0;
		} else
			sel++;
	} else {
		if (val & 0x80) {
			val &= 0x7f;
			sel = 1;
		} else {
			if (sel == 0)
				return;
			sel--;
		}
	}
	m = SeMenu_BitShiftMask(3, (unsigned char)(part + part - 2));
	mask &= ~m;
	mask |= SeMenu_BitShiftMask(sel, (unsigned char)(part + part - 2));
	SeMenu_RegisterElement_Extended(part, 0, &val, 128);
	SeMenu_RegisterElement_Extended(0, 18, &mask, m);
	SeMenu_StorePartParam((unsigned char)(part + 1), val);
	SeMenu_StorePartParam(1, mask);
	SeTitle_DrawField(35, 1);
	SeMenu_BindDialToColumn(2);
}
