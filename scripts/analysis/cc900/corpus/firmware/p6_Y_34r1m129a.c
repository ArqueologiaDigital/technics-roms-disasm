/* Probe round 34r1, helper Y, form a: audio/semenu_routines.s (module 129), unoptimised -Xr shape (three char
   parameters stored to the frame, no register saves, scratch registers for `register` pointers).
   SeMenu_RegisterElement_Type1(flags, row, col, kind): clear a 9-byte display object, load the master byte,
   fill the object {0x80, master, row, col, 1, kind}, set the object flags from the first argument and flush it;
   returns 0.  The clear is a byte loop on two `register` pointers (XWA / XBC, live across no call), the fill one
   `register` object pointer (XBC). */
/* cc900-module: SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_SetObjectFlags */

extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_SetObjectFlags(unsigned int);
extern void SeMenu_FlushDisplayObj(unsigned char *);
extern int SeMenu_RegisterElement_Type1(unsigned char, unsigned char, unsigned char, unsigned char);

int SeMenu_RegisterElement_Type1(unsigned char flags, unsigned char row, unsigned char col, unsigned char kind)
{
    unsigned char o[9];
    unsigned char m;
    register unsigned char *q;
    register unsigned char *e;
    register unsigned char *p;

    e = (q = o) + 9;
    do
        *q++ = 0;
    while (q < e);
    SeMenu_LoadMasterPtr(&m);
    p = o;
    p[0] = 0x80;
    p[1] = m;
    p[2] = row;
    p[3] = col;
    p[4] = 1;
    p[5] = kind;
    SeMenu_SetObjectFlags(flags);
    SeMenu_FlushDisplayObj(o);
    return 0;
}
