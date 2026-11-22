/* helper W, round 21r2, module 129 (audio/semenu_routines.s), form a: SeMenu_SetupMenuDisplay_Section3_End.  Run
   r62's best (p6_U_21r1m129b@Xr, `ram_65c = (unsigned char)(a != 0)`) differed only in the scc width: V4.23 wrote
   the 16-bit `scc nz, wa`, the ROM the 8-bit `scc nz, a`.  Here the flag is assigned back to the byte parameter
   first, then stored. */
/* cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */

extern unsigned char __near ram_65c;

void SeMenu_SMD_Sec3End(unsigned char a)
{
  a = a != 0;
  ram_65c = a;
}
