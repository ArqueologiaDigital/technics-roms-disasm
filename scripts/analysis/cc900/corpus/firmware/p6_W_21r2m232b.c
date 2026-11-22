/* helper W, round 21r2, module 232, form b: as form a, with the base in a local b assigned first and both the
   running pointer and the end derived from it (b = base; p = b; e = b + 24). */

extern unsigned char __near ram_2746[];
extern unsigned char __near ram_2747[];

void BmDrEdit_ClearAllSlots(void)
{
  unsigned char *b, *p, *e;
  b = ram_2746;
  p = b;
  e = b + 24;
  do {
    *p = 0;
    p += 3;
  } while (p < e);
}

void BmDrEdit_ClearAllSlotsAlt(void)
{
  unsigned char *b, *p, *e;
  b = ram_2747;
  p = b;
  e = b + 24;
  do {
    *p = 0;
    p += 3;
  } while (p < e);
}
