/* lane_p6 helper N, round 7, form a: module 232 (sequencer/bmdredit_routines.s), retries of p6_N_6m232a.
   - BmDrEdit_CalcTickPosition (p6-r49 Xr: +3): V4.23 loaded the beat tick first and multiplied in XWA; the ROM
     multiplies the measure in BC first and adds the tick from WA into BC: the product in a local.
   - NoteEdit_SendScrollCmds (p6-r49 Xr: +5): the ROM tests the drum bit with `jr nz` to the drum part and then
     jumps (`jr`) to the very next instruction, the melodic part; at -Xr V4.23 keeps both tails as the ROM does.
     Written with two gotos, the second to the label right after it.
   cc900-options: -Xr
*/
/* cc900-module: BmDrEdit_CheckAndAdvancePage */

extern unsigned int __near ram_279a;
extern unsigned int __near ram_2782;
extern unsigned char __near ram_2784;
extern void BmDrEdit_CheckAndAdvancePage(void);

void BmDrEdit_CalcTickPosition(void)
{
	unsigned int t;

	BmDrEdit_CheckAndAdvancePage();
	t = ram_2782 * 0x60;
	t += ram_2784;
	ram_279a = t;
}

extern unsigned char __near ram_2742;
extern unsigned char __near ram_295f;
extern void NoteEditSy_SendScrollCmd0(void);
extern void NoteEditSy_SendScrollCmd1(void);
extern void NoteEditSy_SendScrollCmd2(void);
extern void NoteEditSy_SendScrollCmd3(void);
extern void NoteEditSy_SendScrollCmd5(void);
extern void NoteEditSy_SendScrollCmd8(void);
extern void NoteEditSy_SendGateCmd(void);
extern void NoteEditSy_SendVelocityCmd(void);
extern void NoteEditSy_SendModeScrollCmd(void);

void NoteEdit_SendScrollCmds(void)
{
	if (ram_2742 & 0x01)
		goto drum;
	goto melodic;
melodic:
	if (!(ram_295f & 0x01))
		NoteEditSy_SendScrollCmd8();
	else {
		NoteEditSy_SendScrollCmd3();
		NoteEditSy_SendGateCmd();
		NoteEditSy_SendScrollCmd5();
	}
	NoteEditSy_SendScrollCmd0();
	NoteEditSy_SendScrollCmd1();
	NoteEditSy_SendScrollCmd2();
	NoteEditSy_SendModeScrollCmd();
	return;
drum:
	if (!(ram_295f & 0x01))
		NoteEditSy_SendVelocityCmd();
	else {
		NoteEditSy_SendScrollCmd3();
		NoteEditSy_SendGateCmd();
	}
	NoteEditSy_SendScrollCmd0();
	NoteEditSy_SendScrollCmd1();
	NoteEditSy_SendScrollCmd2();
	NoteEditSy_SendModeScrollCmd();
}
