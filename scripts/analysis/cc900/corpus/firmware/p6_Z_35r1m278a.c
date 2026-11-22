/* Probe round 35r1, helper Z, form a: audio/audio_control_engine.s (module 278), the xr_screen.py shape at -O3 -Xr.
   AnalogIn_DebounceChange(now, old, st): debounce an analog input.  The state byte holds a 2-bit repeat count
   (bits 0-1), a pending bit (2) and a confirmed bit (3).  |now - old| <= 2 clears count and pending; <= 6 confirms
   when pending, else sets pending; a larger change counts up and confirms on the fourth.  Bit fields of a byte
   (the ROM's and 0xfc / or, res 2 / set 2 / set 3 on the byte). */

struct dbst { unsigned char cnt : 2; unsigned char pend : 1; unsigned char conf : 1; };
extern int __cdecl Math_AbsInt16(int);
extern void AnalogIn_DebounceChange(unsigned char, unsigned char, struct dbst *);

void AnalogIn_DebounceChange(unsigned char now, unsigned char old, struct dbst *st)
{
    if (Math_AbsInt16(now - old) <= 2) {
        st->cnt = 0;
        st->pend = 0;
    } else if (Math_AbsInt16(now - old) <= 6) {
        if (st->pend) {
            st->cnt = 0;
            st->pend = 0;
            st->conf = 1;
        } else
            st->pend = 1;
    } else if (st->cnt == 3) {
        st->cnt = 0;
        st->pend = 0;
        st->conf = 1;
    } else {
        st->cnt++;
        st->pend = 0;
    }
}
