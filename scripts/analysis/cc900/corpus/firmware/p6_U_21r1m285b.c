/* helper U, round 21r1, module 285, form b: Part_LookupByIndex with the table pointer local and an unsigned int
   index local. */

typedef unsigned char *ucp;
typedef ucp *ucpp;

extern ucpp __near PART_RECORD_PTRS;

unsigned char *Part_LookupByIndex(unsigned char i)
{
  ucpp t;
  unsigned int n;
  t = PART_RECORD_PTRS;
  n = i;
  return t[n];
}
