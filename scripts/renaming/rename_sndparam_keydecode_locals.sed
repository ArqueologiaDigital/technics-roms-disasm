# The six local labels that followed SndParam_DecodeMidiAddr (now SndParam_KeyToLswPartNumber) but sit inside the
# next routine, SndParam_ResolveWidgetVariant2_Data (rename_orphan_locals.py --args, v10's plan, applied to v9/v7 too).
s/\bSndParam_DecodeMidiAddr_Loop\b/SndParam_ResolveWidgetVariant2_Data_Loop/g
s/\bSndParam_DecodeMidiAddr_Skip\b/SndParam_ResolveWidgetVariant2_Data_Skip/g
s/\bSndParam_DecodeMidiAddr_Join\b/SndParam_ResolveWidgetVariant2_Data_Join/g
s/\bSndParam_DecodeMidiAddr_Join2\b/SndParam_ResolveWidgetVariant2_Data_Join2/g
s/\bSndParam_DecodeMidiAddr_Skip2\b/SndParam_ResolveWidgetVariant2_Data_Skip2/g
s/\bSndParam_DecodeMidiAddr_Skip3\b/SndParam_ResolveWidgetVariant2_Data_Skip3/g
