/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_B_9c.c (2026-11-16-86-sub-r9)
   sha256 c655b307137bde535cb67786fc1a57a6aa509204f62f5d613ffa89cb8e340de1 (name+funcs); compiled at -Xr */
/* lane_sub helper B, round 9, form c: Voice_InitVoiceState (core/06_voice_envelopes_and_channels.s, KN5000 sub-CPU
   payload v1.42) with the output-level read held in the pseudo-register __BC.  Round 4's int local landed in DE (the
   ROM uses BC), and without a local V4.23 doubles with sla where the ROM adds BC to itself.  A file of its own in case
   __BC crashes V4.23. */

extern int ram_41360;
extern int ram_41362;
extern int ram_41364;
extern unsigned char ram_4308e[][0x47];

extern unsigned int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned int ram_451d2;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451d8;
extern unsigned int ram_451da;
extern unsigned int ram_451dc;
extern unsigned int ram_451de;
extern unsigned int ram_451e0;
extern unsigned int ram_451e2;
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451ea;
extern unsigned int ram_451ec;
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;

extern unsigned char Voice_OutputLevel_Table[];

void Voice_InitVoiceState(unsigned char slot)
{
    ram_451ce = 0;
    ram_451da = ram_41360;
    ram_451ec = 0;
    ram_451ee = 0;
    ram_451f0 = 0;
    ram_451d4 = 0x17f;
    ram_451d6 = 0x7f7f;
    ram_451f2 = 0;
    ram_451f4 = 0;
    ram_451f6 = 0;
    ram_451e2 = 0;
    ram_451ea = 0;
    ram_451dc = 0;
    ram_451de = 0;
    ram_451d8 = 0x40;
    ram_451e0 = 0;
    ram_451d2 = 0;
    ram_451e4 = 0xff7f;
    ram_451e6 = ram_41362;
    ram_451e8 = ram_41362;
    __BC = ram_41364;
    __BC += __BC;
    __BC = *(unsigned int *)&Voice_OutputLevel_Table[(int)__BC];
    __BC += __BC;
    ram_451d0 = __BC;
    *(unsigned int *)&ram_4308e[slot][0x2d] = 0xf000;
}
