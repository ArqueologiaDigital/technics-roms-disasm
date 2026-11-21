/* helper U, round 21r1, module 129, form a: SeMenu_SetupMenuDisplay_Section3_End.  The ROM's scc works on A
   (a byte), V4.23 gave a word scc for `a != 0`: the compare result stored back into the byte parameter first. */
/* cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */

extern unsigned char __near ram_65c;

void SeMenu_SMD_Sec3End(unsigned char a)
{
  a = a != 0;
  ram_65c = a;
}
