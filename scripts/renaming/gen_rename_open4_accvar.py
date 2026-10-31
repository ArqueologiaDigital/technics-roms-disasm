import re,glob,sys
labels=set()
for t in ['v10','v9','v7','v6','v5']:
    for f in glob.glob(t+'/maincpu/**/*.s',recursive=True):
        for m in re.finditer(rb'^([A-Za-z_][A-Za-z0-9_]*):',open(f,'rb').read(),re.M):
            labels.add(m.group(1).decode())
# (old_prefix, new_prefix, exact_only)
P=[
('AccPedal_EventDispatch','AccStyleCtl_OnSwitchEvent',1),
('AccPedal_TypeSustainOrExpr','AccStyleCtl_OnSwitchEvent_Field5or6',1),
('AccPedal_ParseValue','AccStyleCtl_OnSwitchEvent_StoreMask',1),
('AccPedal_CheckType0','AccStyleCtl_OnSwitchEvent_CheckField0',1),
('AccPedal_SavePosition','AccStyleCtl_OnSwitchEvent_SavePos',1),
('AccPedal_EventReturn','AccStyleCtl_OnSwitchEvent_Return',1),
('AccPedal_SustainHandler','AccStyleCtl_StartStopButton',1),
('AccPedal_Sustain_','AccStyleCtl_StartStop_',0),
('AccPedal_SustainReturn','AccStyleCtl_StartStop_Return',1),
('AccPedal_SustainPadding','AccStyleCtl_StartStop_Padding',1),
('AccPedal_StyleCheck','AccStyleCtl_IsStartStopBlocked',1),
('AccPedal_StyleCheck_','AccStyleCtl_IsStartStopBlocked_',0),
('AccPedal_StyleCheckReturn','AccStyleCtl_IsStartStopBlocked_Return',1),
('AccPedal_ExprToggle','AccStyleCtl_SynchroButton',1),
('AccPedal_ExprReturn','AccStyleCtl_SynchroButton_Return',1),
('AccPedal_ExprPadding','AccStyleCtl_SynchroButton_Padding',1),
('AccPedal_DistributeParams','AccStyleCtl_SectionButtons',1),
('AccPedal_Distribute_','AccStyleCtl_SectionButtons_',0),
('AccPedal_DistributeReturn','AccStyleCtl_SectionButtons_Return',1),
('AccPedal_DistributePadding','AccStyleCtl_SectionButtons_Padding',1),
('AccPedal_SendEvents','AccStyleCtl_SendSectionEvents',1),
('AccPedal_SendEvents_Group2','AccStyleCtl_SendSectionEvents_Pass2',1),
('AccPedal_SendEvents_OnSustain','AccStyleCtl_SendSectionEvents_Pass3',1),
('AccPedal_SendEvents_OnExpr','AccStyleCtl_SendSectionEvents_Pass4',1),
('AccPedal_SendEventsReturn','AccStyleCtl_SendSectionEvents_Return',1),
('AccPedal_ProcessAllBits','AccStyleCtl_DispatchSectionButtons',1),
('AccPedal_ProcessBitsPadding','AccStyleCtl_DispatchSectionButtons_Padding',1),
('AccPedal_Bit2_Sustain','AccStyleCtl_IntroEnding1Button',1),
('AccPedal_Bit2_CheckPlay','AccStyleCtl_IntroEnding1_CheckRunning',1),
('AccPedal_Bit2_Sostenuto','AccStyleCtl_IntroEnding1_Ending',1),
('AccPedal_Bit2_Off','AccStyleCtl_IntroEnding1_Release',1),
('AccPedal_Bit2_OffPlay','AccStyleCtl_IntroEnding1_ReleaseCheckRunning',1),
('AccPedal_Bit2_OffSostenuto','AccStyleCtl_IntroEnding1_ReleaseEnding',1),
('AccPedal_Bit2_Return','AccStyleCtl_IntroEnding1_Return',1),
('AccPedal_Bit2_Expression','AccStyleCtl_IntroEnding2Button',1),
('AccPedal_Expr_CheckPlay','AccStyleCtl_IntroEnding2_CheckRunning',1),
('AccPedal_Expr_Soft','AccStyleCtl_IntroEnding2_Ending',1),
('AccPedal_Expr_Off','AccStyleCtl_IntroEnding2_Release',1),
('AccPedal_Expr_OffPlay','AccStyleCtl_IntroEnding2_ReleaseCheckRunning',1),
('AccPedal_Expr_OffSoft','AccStyleCtl_IntroEnding2_ReleaseEnding',1),
('AccPedal_Expr_Return','AccStyleCtl_IntroEnding2_Return',1),
('AccPedal_Bit7_Portamento','AccStyleCtl_FillIn2Button',1),
('AccPedal_Bit7_Damper','AccStyleCtl_FillIn2_CountIn',1),
('AccPedal_Bit7_Off','AccStyleCtl_FillIn2_Release',1),
('AccPedal_Bit7_OffDamper','AccStyleCtl_FillIn2_ReleaseCountIn',1),
('AccPedal_Bit7_Return','AccStyleCtl_FillIn2_Return',1),
('AccPedal_Bit6_Hold','AccStyleCtl_FillIn1Button',1),
('AccPedal_Bit6_HoldOff','AccStyleCtl_FillIn1_Release',1),
('AccPedal_Bit6_Return','AccStyleCtl_FillIn1_Return',1),
('AccPedal_Bit4_Sostenuto','AccStyleCtl_Ending1Bit',1),
('AccPedal_Bit4_Off','AccStyleCtl_Ending1Bit_Release',1),
('AccPedal_Bit4_Return','AccStyleCtl_Ending1Bit_Return',1),
('AccPedal_Bit5_Soft','AccStyleCtl_Ending2Bit',1),
('AccPedal_Bit5_Off','AccStyleCtl_Ending2Bit_Release',1),
('AccPedal_Bit5_Return','AccStyleCtl_Ending2Bit_Return',1),
('AccPedal_Bit3_Damper','AccStyleCtl_CountInBit',1),
('AccPedal_Bit3_Off','AccStyleCtl_CountInBit_Release',1),
('AccPedal_Bit3_Return','AccStyleCtl_CountInBit_Return',1),
('AccPedal_StateSync','AccStyleCtl_SyncSectionEvents',1),
('AccPedal_Sync_','AccStyleCtl_SyncSectionEvents_',0),
]
for old,new in [('SustainOn','RequestIntro1'),('SustainOff','ReleaseIntro1'),('ExprOn','RequestIntro2'),('ExprOff','ReleaseIntro2'),
                ('SostenutoOn','RequestEnding1'),('SostenutoOff','ReleaseEnding1'),('SoftOn','RequestEnding2'),('SoftOff','ReleaseEnding2'),
                ('HoldOn','RequestFillIn1'),('HoldOff','ReleaseFillIn1'),('DamperOn','RequestCountIn'),('DamperOff','ReleaseCountIn'),
                ('PortamentoOn','RequestFillIn2'),('PortamentoOff','ReleaseFillIn2')]:
    P.append(('AccPedal_'+old,'AccSection_'+new,1)); P.append(('AccPedal_'+old+'_','AccSection_'+new+'_',0))
P+= [
('AccVoice_ProcessPedalChanges','AccSection_LatchIntroRequests',1),
('AccVoice_Pedal0_','AccSection_LatchIntro1_',0),('AccVoice_Pedal1_','AccSection_LatchCountIn_',0),('AccVoice_Pedal2_','AccSection_LatchIntro2_',0),
('AccVoice_ProcessLeftPedalChanges','AccSection_LatchFillInRequests',1),
('AccVoice_LeftPedal0_','AccSection_LatchFillIn1_',0),('AccVoice_LeftPedal1_','AccSection_LatchFillIn2_',0),
('AccChord_ProcessKeyChanges','AccSection_LatchEndingRequests',1),
('AccChord_KeyChange0_','AccSection_LatchEnding1_',0),('AccChord_KeyChange1_','AccSection_LatchEnding2_',0),
('AccVoice_CheckBitsAndSetFlags','AccSection_DeferToBarIfLastBeat',1),
('AccVoice_BitsCheckDone','AccSection_DeferToBarIfLastBeat_Return',1),
('AccChannel_SetDirtyIfActive','AccSection_DeferToBarUnlessFirstBeat',1),
('AccChannel_SetDirtyDone','AccSection_DeferToBarUnlessFirstBeat_Return',1),
('AccVoice_ResetAll','AccSection_StartIntro',1),('AccVoice_Reset_','AccSection_StartIntro_',0),
('AccVoice_Reassign','AccSection_StartComposerIntro',1),('AccVoice_Reassign_','AccSection_StartComposerIntro_',0),
('AccVoice_SplitPointSetup','AccSection_StartFillIn',1),('AccVoice_Split_','AccSection_StartFillIn_',0),
('AccVoice_SplitReassign','AccSection_StartComposerFillIn',1),('AccVoice_SplitReassign_','AccSection_StartComposerFillIn_',0),
('AccVoice_ThirdLayer','AccSection_StartEnding',1),('AccVoice_ThirdLayer_','AccSection_StartEnding_',0),
('AccVoice_ThirdLayerReassign','AccSection_StartComposerEnding',1),('AccVoice_ThirdReassign_','AccSection_StartComposerEnding_',0),
('AccFlags_Aggregate','AccSection_SwitchAtBarLine',1),
('AccFlags_CheckDecay','AccSection_SwitchAtBarLine_VariationUp',1),
('AccFlags_BuildIndex','AccSection_SwitchAtBarLine_BuildIndex',1),
('AccFlags_CheckDir65','AccSection_SwitchAtBarLine_CheckFillIn',1),
('AccFlags_CheckDir67','AccSection_SwitchAtBarLine_CheckEnding',1),
('AccFlags_CheckNoteOn','AccSection_SwitchAtBarLine_CheckArrangerStep',1),
('AccFlags_PedalBit7','AccSection_SwitchAtBarLine_CheckFillIn2Held',1),
('AccFlags_CheckSync69','AccSection_SwitchAtBarLine_CheckVariation',1),
('AccFlags_CheckSync71','AccSection_SwitchAtBarLine_CheckRestart',1),
('AccFlags_Dispatch','AccSection_SwitchAtBarLine_Dispatch',1),
('AccFlags_JumpTable','AccSection_BarLineSwitchTable',1),
('AccFlags_Handler0','AccSection_ToVariation',1),
('AccFlags_Handler1','AccSection_ToIntro',1),
('AccFlags_Handler2','AccSection_ToFillIn',1),
('AccFlags_Handler4','AccSection_ToEnding',1),
('AccFlags_Handler8','AccSection_ToNewVariationEnding',1),
('AccFlags_Handler9','AccSection_ToNewVariationIntro',1),
('AccFlags_Handler9_Join','AccSection_Switch_Common',1),
('AccFlags_Handler10','AccSection_ToNewVariationFillIn',1),
('AccPedal_CheckCombined','AccSection_SwitchNowUnlessDeferred',1),
('AccPedal_CheckFlags','AccSection_SwitchNowUnlessDeferred_CheckEndingDefer',1),
('AccPedal_CheckDirection','AccSection_SwitchNowUnlessDeferred_CheckIntroFill',1),
('AccPedal_CheckCounter','AccSection_SwitchNowUnlessDeferred_CheckDefer',1),
('AccPedal_TriggerReInit','AccSection_SwitchNowUnlessDeferred_Switch',1),
('AccPedal_CombinedReturn','AccSection_SwitchNowUnlessDeferred_Return',1),
('AccInit_FullReInit','AccSection_SwitchNow',1),('AccInit_ReInit_','AccSection_SwitchNow_',0),
('Rhythm_VoiceAssignDetect','Rhythm_SaveState_CheckFillIn1Done',1),
('Rhythm_VoiceAssign_PartAOn','Rhythm_SaveState_FillIn1Done',1),
('Rhythm_VoiceAssign_PartBDetect','Rhythm_SaveState_CheckFillIn2Done',1),
('Rhythm_VoiceAssign_PartBOn','Rhythm_SaveState_FillIn2Done',1),
('Rhythm_VoiceAssign_Ext1Detect','Rhythm_SaveState_CheckIntro1Done',1),
('Rhythm_VoiceAssign_Ext2Detect','Rhythm_SaveState_CheckCountInDone',1),
('Rhythm_VoiceAssign_Ext3Detect','Rhythm_SaveState_CheckIntro2Done',1),
('Rhythm_VoiceAssign_Perc1Detect','Rhythm_SaveState_CheckEnding1Done',1),
('Rhythm_VoiceAssign_Perc2Detect','Rhythm_SaveState_CheckEnding2Done',1),
('Rhythm_VoiceAssign_SaveShadow','Rhythm_SaveState_SaveLaneShadows',1),
('SeqCtl_StorePedalFlags','SeqTick_ReadControlState_StoreIntroBits',1),
('ACC_SECTION_REQUEST','ACC_VARIATION_REQUEST',1),
]
m={}
for old,new,exact in P:
    if exact:
        if old in labels or old=='ACC_SECTION_REQUEST': m[old]=new
        else: print('MISSING',old,file=sys.stderr)
    else:
        for l in sorted(labels):
            if l.startswith(old):
                n=new+l[len(old):]
                if l not in m: m[l]=n
# exact entries take priority over prefix-derived
for old,new,exact in P:
    if exact and old in m: m[old]=new
bad=[n for n in m.values() if n in labels]
if bad: print('COLLIDE',bad,file=sys.stderr)
if len(set(m.values()))!=len(m): print('DUP targets',file=sys.stderr)
for o in sorted(m,key=len,reverse=True):
    print('s/\\b%s\\b/%s/g'%(o,m[o]))
print(len(m),'rules',file=sys.stderr)
