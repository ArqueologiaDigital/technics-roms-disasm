/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_6m232a.c (2026-11-19-49-p6-r49)
   sha256 76bcd67d22a37ff81bfb5254063188feb49b335a94ccc2a5d7116ac8b8680506 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_295f;
extern unsigned char __near ram_2742;
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
	if (!(ram_2742 & 0x01)) {
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
	} else {
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
}
