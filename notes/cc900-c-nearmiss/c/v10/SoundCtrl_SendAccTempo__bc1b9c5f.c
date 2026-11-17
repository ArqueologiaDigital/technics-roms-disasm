/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/accompaniment_engine.c (2026-11-16-55-p6-r10)
   sha256 bc1b9c5f81977c1c3e3ca3aa0451f79a0f8e53b470427b60dbbb68bb1a654c94 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ACTIVE_TITLE;
void SoundCtrl_SendAccTempo(void)
{
    if (ACTIVE_TITLE == 181)
        ApDeliveryEvent(0xb5001eL, 0x1c0000bL, 0L);
}
