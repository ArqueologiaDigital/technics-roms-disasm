/* helper Z, round 22r1, module 129 (audio/semenu_routines.s), form b: SeMenu_SetupMenuDisplay_Section3_End, as
   form a but the if / else assigns the byte parameter itself, which is then stored (the ROM computes the flag in
   A, the parameter's own register). */
/* cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */

extern unsigned char __near ram_65c;

void SeMenu_SMD_Sec3End(unsigned char a)
{
  if (a != 0)
    a = 1;
  else
    a = 0;
  ram_65c = a;
}
