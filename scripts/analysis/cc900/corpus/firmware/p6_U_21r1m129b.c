/* helper U, round 21r1, module 129, form b: the compare result cast to unsigned char in the store. */
/* cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */

extern unsigned char __near ram_65c;

void SeMenu_SMD_Sec3End(unsigned char a)
{
  ram_65c = (unsigned char)(a != 0);
}
