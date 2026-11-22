/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_T_32r1m278b.c (2026-11-22-17-p6-r84)
   sha256 09e968204535fde8aa00cfc781030efaca4c80bf3afac40521ff839dcdc7a7f9 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_128;
extern unsigned char __near ram_129;
extern unsigned char __near ANALOG_EXPRESSION_PEDAL_VALUE;
extern unsigned char __near ANALOG_AFTERTOUCH_VALUE;
extern unsigned char __near ADC_AN0_OUTPUT[];
extern unsigned char __near ADC_AN1_OUTPUT[];
extern unsigned char AnalogIn_ReadAdcHigh(unsigned int);
extern unsigned char CPanel_EncoderDispatch(unsigned char, unsigned int);
void MidiParam_ForceResync(void)
{
    unsigned char *a;
    unsigned char r;

    ram_129 = 0x83;
    ram_128 = 7;
    CPanel_EncoderDispatch(AnalogIn_ReadAdcHigh(0), 2);
    ANALOG_EXPRESSION_PEDAL_VALUE = ~ANALOG_EXPRESSION_PEDAL_VALUE;
    r = CPanel_EncoderDispatch(AnalogIn_ReadAdcHigh(0), 2);
    a = ADC_AN0_OUTPUT;
    *a = r;
    a[1] |= 0x80;
    CPanel_EncoderDispatch(AnalogIn_ReadAdcHigh(1), 5);
    ANALOG_AFTERTOUCH_VALUE = ~ANALOG_AFTERTOUCH_VALUE;
    r = CPanel_EncoderDispatch(AnalogIn_ReadAdcHigh(1), 5);
    a = ADC_AN1_OUTPUT;
    *a = r;
    a[1] |= 0x80;
}
