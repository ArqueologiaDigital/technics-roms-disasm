/* Probe round 32r1, helper T, form b: audio/audio_control_engine.s (module 278), as form a with the dispatch
   result stored straight through the pointer (no int local) and an unsigned char result type. */
/* cc900-module: AnalogIn_ReadAdcHigh */

extern unsigned char __near ram_128;
extern unsigned char __near ram_129;
extern unsigned char __near ANALOG_EXPRESSION_PEDAL_VALUE;
extern unsigned char __near ANALOG_AFTERTOUCH_VALUE;
extern unsigned char __near ADC_AN0_OUTPUT[];
extern unsigned char __near ADC_AN1_OUTPUT[];
extern unsigned char AnalogIn_ReadAdcHigh(unsigned int);
extern unsigned char CPanel_EncoderDispatch(unsigned char, unsigned int);
extern void MidiParam_ForceResync(void);

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
