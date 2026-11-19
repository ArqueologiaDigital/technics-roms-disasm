/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_7m232a.c (2026-11-19-56-p6-r51)
   sha256 e408bc161eb38032cb7a39cb4aff8d53dc64e1dd502c608a1a90534478631cdb (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
