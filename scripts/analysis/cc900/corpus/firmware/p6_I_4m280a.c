/* Phase 6, lane_p6 helper I, round 4, module 280 (audio/audio_control_engine.s, -O3 -Xr), form a.  New.
   PanelMem_InitFromFactory(n): for panel memory n < 80, clears its 960 bytes at 0x1ed400 and refills them from
   the factory record n (674 bytes at 0x99eca0 in the table data: 0x7c bytes, then 0x226 bytes at +0x7c into +0x19a)
   and the default sound-parameter image's 0x11e bytes from +0x7c into +0x7c.
   Read from the hand assembly: n in the frame (+4), the record pointer in XIZ; the Memset address formed with the
   base as an immediate (a pointer converted to void *, lane_hd's idiom) where the kept pointer uses lda; the
   factory address n * 0x2a2 by Math_Multiply32 plus the base immediate; the record pointer assigned inside the
   first Mem_Copy's argument list (V4.23 evaluates the arguments right to left, as the ROM orders them) and
   advanced in the second.  ram_1ed400 is spelled as in the staged PanelTlv_ValidatePanelMemory.
   Form b: the pointer assigned and advanced in statements of their own. */

#define FACT ((unsigned char *)0x99eca0L)

extern unsigned char ram_1ed400[];
extern unsigned char SndParamRam_DefaultImage[];
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void PanelMem_InitFromFactory(unsigned int n);

void PanelMem_InitFromFactory(unsigned int n)
{
    unsigned char *p;

    if (n >= 80)
        return;
    Memset(ram_1ed400 + (unsigned long)n * 960, 0, 0x3c0);
    Mem_Copy(p = ram_1ed400 + (unsigned long)n * 960, FACT + (unsigned long)n * 0x2a2, 0x7c);
    Mem_Copy(p += 0x7c, SndParamRam_DefaultImage + 0x7c, 0x11e);
    Mem_Copy(p + 0x11e, FACT + (unsigned long)n * 0x2a2 + 0x7c, 0x226);
}
