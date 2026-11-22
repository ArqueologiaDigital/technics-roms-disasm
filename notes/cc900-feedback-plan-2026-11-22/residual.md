## Functions V4.23 compiled from our C, by state on main

| state (best attempt) | functions | ROM B   |
|----------------------|-----------|---------|
| built                | 12773     | 1240291 |
| MATCH                | 41        | 4641    |
| NEAR                 | 553       | 98563   |
| DIFF                 | 271       | 32958   |
| error                | 289       | 0       |

`built`: from the build table (every image, v8 included), V4.23 MATCH, also under a name cut to 31.  The other rows: functions of the index (no v8 tree) not built, by best attempt: `MATCH` a matching attempt exists (ready.tsv), NEAR / DIFF / error never matched.  Distinct names: built 2631, residual NEAR + DIFF 772.

## Residual by image

| image    | NEAR functions | NEAR ROM B | DIFF functions | DIFF ROM B |
|----------|----------------|------------|----------------|------------|
| v10      | 422            | 72798      | 236            | 31563      |
| v142     | 52             | 15327      | 12             | 1048       |
| v5       | 32             | 3530       | 5              | 76         |
| hdae5000 | 3              | 3148       | 3              | 59         |
| v6       | 22             | 2364       | 5              | 76         |
| v7       | 22             | 1396       | 10             | 136        |

## Residual NEAR: 553 functions, 98563 ROM B, by class

| class        | functions | ROM B | sole | sole ROM B |
|--------------|-----------|-------|------|------------|
| register     | 316       | 72835 | 46   | 10374      |
| other        | 360       | 69309 | 87   | 5902       |
| order        | 184       | 46399 | 12   | 1574       |
| operand      | 99        | 26809 | 18   | 3604       |
| extend       | 106       | 24480 | 2    | 196        |
| call-form    | 27        | 12312 | 1    | 44         |
| loop-shape   | 46        | 11609 | 1    | 145        |
| size         | 26        | 8068  | 6    | 1610       |
| address-form | 29        | 6159  | 3    | 162        |
| swap         | 26        | 5891  | 0    | 0          |
| return-form  | 43        | 2654  | 23   | 747        |
| length-only  | 18        | 2559  | 6    | 375        |
| arith-type   | 10        | 1782  | 1    | 63         |
| bit-form     | 12        | 1402  | 4    | 209        |
| idiom        | 2         | 178   | 0    | 0          |
| width        | 2         | 64    | 1    | 16         |
| encoding     | 1         | 21    | 1    | 21         |

## Residual DIFF: 271 functions, 32958 ROM B, by class

| class        | functions | ROM B | sole | sole ROM B |
|--------------|-----------|-------|------|------------|
| register     | 225       | 31538 | 5    | 344        |
| other        | 226       | 31482 | 10   | 238        |
| order        | 119       | 24731 | 0    | 0          |
| extend       | 126       | 20696 | 0    | 0          |
| operand      | 91        | 19712 | 1    | 14         |
| loop-shape   | 96        | 18070 | 0    | 0          |
| call-form    | 31        | 7205  | 0    | 0          |
| address-form | 23        | 6793  | 0    | 0          |
| size         | 22        | 6208  | 0    | 0          |
| swap         | 28        | 4153  | 0    | 0          |
| arith-type   | 7         | 1728  | 0    | 0          |
| return-form  | 37        | 1681  | 0    | 0          |
| bit-form     | 13        | 659   | 0    | 0          |
| length-only  | 9         | 645   | 0    | 0          |
| idiom        | 3         | 451   | 0    | 0          |
| width        | 12        | 360   | 2    | 42         |
| staging      | 1         | 37    | 0    | 0          |

## The 20 largest residual NEAR functions

| function                           | ROM B | eq % | classes                                                       | first diff | best run                      |
|------------------------------------|-------|------|---------------------------------------------------------------|------------|-------------------------------|
| hdae5000 HDAE5000_SelectListProc   | 2641  | 99.3 | register                                                      | 23         | 2026-11-18-20-hd-r55          |
| v142 EFF_DspChannel_InitFlags      | 1844  | 97.9 | register,operand,other                                        | 51         | 2026-11-17-7-sub-r18          |
| v10 TrAsGridCheck                  | 1318  | 77.1 | register,operand,extend,order,address-form,other              | 15         | 2026-11-22-1-p6-r69           |
| v10 AcTrAsGridBoxProc              | 1261  | 86.6 | register,operand,extend,order,size,other                      | 16         | 2026-11-22-1-p6-r69           |
| v10 SingleLoadDstFunc              | 1229  | 99.1 | order,size,other                                              | 65         | 2026-11-18-1-p6-r33           |
| v10 FmmSmfMedleyFunc               | 1228  | 83.1 | call-form,register,order,swap,other                           | 3          | 2026-11-21-9-p6-r64           |
| v10 FmmDocMedleyFunc               | 1064  | 78.7 | call-form,register,extend,order,loop-shape,other              | 1          | 2026-11-21-9-p6-r64           |
| v10 FmmPdMedleyFunc                | 1038  | 78.5 | call-form,register,extend,order,loop-shape,other              | 1          | 2026-11-21-9-p6-r64           |
| v5 SeqEvent_MainHandler            | 1019  | 99.0 | operand                                                       | 866        | 2026-11-21-22-p6-r67          |
| v6 SeqEvent_MainHandler            | 1019  | 99.0 | operand                                                       | 866        | 2026-11-21-22-p6-r67          |
| v10 MidiSysEx_SendAllParams        | 1003  | 99.6 | size                                                          | 15         | 2026-11-21-7-p6-r62           |
| v10 PsRadioBoxProc                 | 988   | 94.2 | register,extend,order,other                                   | 33         | 2026-11-16-100-p6-r19         |
| v10 ProcessLayeredNoteOn_WriteReg4 | 965   | 93.0 | register                                                      | 23         | 2026-11-22-21-p6-r88          |
| v142 Voice_SetVelocity             | 954   | 94.0 | call-form,operand,length-only,other                           | 44         | 2026-11-19-69-sub-r36q        |
| v10 FmmWallpaperLoadFunc           | 900   | 96.4 | register,extend,order,other                                   | 55         | 2026-11-21-27-p6-r68          |
| v10 FmmSaveFilterFunc              | 891   | 91.1 | register,extend,order,other                                   | 36         | 2026-11-21-7-p6-r62           |
| v142 ExtVoice_Build_SlotRegisters  | 862   | 99.5 | register,order                                                | 754        | 2026-11-19-93-sub-r40as       |
| v10 ClassProc                      | 852   | 75.9 | call-form,register,operand,extend,order,loop-shape,swap,other | 54         | 2026-11-22-1-p6-r69           |
| v142 ToneGen_WriteVoiceParams      | 794   | 99.1 | register                                                      | 424        | 2026-11-19-16-sub-r23o-tg-dsp |
| v142 Voice_Calc_LevelPair_Mono     | 772   | 92.9 | call-form,register,other                                      | 65         | 2026-11-18-29-sub-r21f        |
