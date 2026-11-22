/* Probe round 35r1, helper A, form b: boot/system_handlers.s (module 4), xr_screen family.
   SLIDE_Parse_Header as form a, with an early `return -1` and `p += 2` inside the call arguments. */
/* cc900-data: SLIDE_Parse_Header 1 = SLIDE_STRING */
/* cc900-module: SLIDE_Decompress_4K_Init SLIDE_Decompress_8K_Init */

extern int __cdecl String_Compare(void *, void *, int);
extern void SLIDE_Decompress_4K_Init(unsigned char *, void *);
extern void SLIDE_Decompress_8K_Init(unsigned char *, void *);
extern int SLIDE_Parse_Header(unsigned char *, void *);

int SLIDE_Parse_Header(register unsigned char *p, void *dst)
{
    char sig[6] = "SLIDE";

    if (String_Compare(p, sig, 5) != 0)
        return -1;
    p += 5;
    if (*p == '4')
        SLIDE_Decompress_4K_Init(p += 2, dst);
    else if (*p == '8')
        SLIDE_Decompress_8K_Init(p += 2, dst);
    return 0;
}
