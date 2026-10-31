# Labels lane kn5000-a (c2 batch) and lane kn5000-b (cpanel) both renamed, differently: kn5000-b's name,
# already in main, wins (merge of 37ecc2a2b into open4/kn5000-a).
s/\bEncoder_TouchSettingsListener_Threshold\b/Encoder_SetAfterTouchThreshold/g
s/\bPanelAction_ExpressionPedal_PartExpr\b/PanelAction_ExpressionPedal_Skip/g
s/\bEncoder_TouchSettingsListener_Curve\b/Encoder_SetAfterTouchCurve/g
s/\bPanelAction_ExpressionPedal_Post\b/PanelAction_ExpressionPedal_Join/g
s/\bEncoder_ProcessPitchBend_Scaled\b/Encoder_ProcessPitchBend_ScaleToBendRange/g
s/\bEncoder_ProcessPitchBend_Direct\b/Encoder_ProcessPitchBend_Passthrough/g
s/\bEncoder_TouchSettingsListener\b/Encoder_OnTouchSensitivityChange/g
s/\bENCODER_LUT_AFTERTOUCH_CURVE\b/ENCODER_LUT_AFTERTOUCH_CURVE_MULT/g
s/\bPanelAction_PitchBend_Split\b/PanelAction_PitchBend_Skip/g
s/\bPanelAction_PitchBend_Post\b/PanelAction_PitchBend_Join/g
s/\bENCODER_LUT_PITCH_BEND\b/ENCODER_LUT_PITCHBEND/g
# the encoder RAM .equ names of the c2 batch, as lane kn5000-b's cpanel sub-lane named them
s/\bTOTAL_EXPRESSION_PENDING\b/ANALOG_EXPRESSION_PEDAL_PENDING/g
s/\bMAIN_VOLUME_PENDING\b/ANALOG_MAIN_VOLUME_PENDING/g
s/\bEXPRESSION_PEDAL_VALUE\b/ANALOG_EXPRESSION_PEDAL_VALUE/g
s/\bMAIN_VOLUME_VALUE\b/ANALOG_MAIN_VOLUME_VALUE/g
s/\bPITCH_BEND_VALUE\b/ANALOG_PITCHBEND_VALUE/g
s/\bMODULATION_VALUE\b/ANALOG_MODULATION_VALUE/g
s/\bAFTERTOUCH_VALUE\b/ANALOG_AFTERTOUCH_VALUE/g
s/\bENCODER_RAW_PITCH_BEND\b/ENCODER_RAW_PITCHBEND/g
s/\bCOMPOSER_BEND_RANGE\b/ENCODER_BEND_RANGE/g
s/\bAFTERTOUCH_CURVE\b/ENCODER_AFTERTOUCH_CURVE/g
s/\bAFTERTOUCH_THRESHOLD\b/ENCODER_AFTERTOUCH_THRESHOLD/g
s/\bPANEL_LED_IMAGE\b/CPANEL_LED_IMAGE/g
