/* helper W, round 21r2, module 129, form b: SeMenu_SetupMenuDisplay_Section3_End with the flag as a conditional
   expression of byte constants (form a: the comparison assigned back to the byte parameter). */
/* cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */

extern unsigned char __near ram_65c;

void SeMenu_SMD_Sec3End(unsigned char a)
{
  ram_65c = a ? (unsigned char)1 : (unsigned char)0;
}
