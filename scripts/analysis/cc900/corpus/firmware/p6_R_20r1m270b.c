/* Helper R, round 1 of 2026-11-20: modules 270-274, form b (range test as one expression, array spellings of the
   constant-address reads, the bit-or on the cell). */

struct font { unsigned int w; unsigned int h; unsigned char pad[12]; };

extern unsigned char __near ram_8d4a;

int BoxLeftCheck(int x)
{
  return x <= 0x88 && x >= 0x80;
}

unsigned int GetCharHeight(unsigned long id)
{
  return *(unsigned int *)((id << 4) + 0x945c02L);
}

unsigned char _Read_VGA_Register(unsigned int r)
{
  return ((unsigned char *)0x170000L)[r];
}

unsigned char BitMapOut_GetRenderMode_CheckBit3(unsigned char a)
{
  return ram_8d4a |= a;
}
