/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_3a.c (2026-11-16-38-p6-r6)
   sha256 08077e5f71e6fd71c8809069ff7c2ec22415c371e919999a81e5dbe9e7f09f47 (tar-sha256); compiled at -O3 -XS -Xr */
struct nm9hdr { unsigned char h1, t1, h2, t2; };
extern unsigned char __near ram_1db6[][9];
extern struct nm9hdr __near ram_1db2;
void NoteMap_RemoveHeadEntry(unsigned char a)
{
  unsigned char (*t)[9];
  unsigned char *p;
  unsigned char e;
  t = ram_1db6;
  p = t[a];
  e = p[1];
  ram_1db2.h2 = e;
  if (e != 0xff) t[e][0] = 0xff;
  else ram_1db2.t2 = e;
}
