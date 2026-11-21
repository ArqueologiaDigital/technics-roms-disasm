/* helper Z, round 22r1, module 129 (audio/semenu_routines.s), form a: SeMenu_SetupMenuDisplay_Section3_End.  Run
   r64's best (p6_W_21r2m129a@Xr) differed at +2 only in the scc width (V4.23 `scc nz, wa`, the ROM the byte
   `scc nz, a`).  The built SeCtr2_OnPartColumn (cc900/semenu_routines_m129.c) gets a byte scc (`scc nz, c`) from
   an if / else that sets a byte local to 1 or 0; here the same spelling, the local then stored.
   Form b: the same if / else assigning the byte parameter itself. */
/* cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */

extern unsigned char __near ram_65c;

void SeMenu_SMD_Sec3End(unsigned char a)
{
  unsigned char f;
  if (a)
    f = 1;
  else
    f = 0;
  ram_65c = f;
}
