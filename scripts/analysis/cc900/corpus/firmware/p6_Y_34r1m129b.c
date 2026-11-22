/* Probe round 34r1, helper Y, form b: audio/semenu_routines.s (module 129).
   As form a (SeMenu_RegisterElement_Type1), with one spot changed: the `register` pointers declared in the
   other order (end, then cursor, then object), which decides which scratch register each gets. */
/* cc900-module: SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_SetObjectFlags */

extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_SetObjectFlags(unsigned int);
extern void SeMenu_FlushDisplayObj(unsigned char *);
extern int SeMenu_RegisterElement_Type1(unsigned char, unsigned char, unsigned char, unsigned char);

int SeMenu_RegisterElement_Type1(unsigned char flags, unsigned char row, unsigned char col, unsigned char kind)
{
    unsigned char o[9];
    unsigned char m;
    register unsigned char *p;
    register unsigned char *e;
    register unsigned char *q;

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
