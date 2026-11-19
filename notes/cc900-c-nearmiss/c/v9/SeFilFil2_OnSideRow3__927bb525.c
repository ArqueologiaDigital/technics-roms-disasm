/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/scoop_editor_data_m0.c (2026-11-19-73-p6-r53)
   sha256 927bb52536f32bff43a0ba8d9e4daa5bec3f59c3489a0c4bad53ca7c7e97c3bd (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define TT_SEFILLFO1 0x39
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
#define TT_SEFILFIL2 0x36
void SeFilFil2_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILLFO1, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 1);
}
