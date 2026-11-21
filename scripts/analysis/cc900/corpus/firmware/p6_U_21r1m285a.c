/* helper U, round 21r1, module 285, form a: Part_LookupByIndex with the table pointer in a local first (the ROM
   loads XBC from the cell before it scales the index in WA). */

typedef unsigned char *ucp;
typedef ucp *ucpp;

extern ucpp __near PART_RECORD_PTRS;

unsigned char *Part_LookupByIndex(unsigned char i)
{
  ucpp t;
  t = PART_RECORD_PTRS;
  return t[i];
}
