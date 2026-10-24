
; PartParam_StepFieldById: (field id H = (XIZ+8), part L = (XIZ+10)): the high nibble of H, in pairs, picks the step table -- ids
;   0x00-0x1F PartParamStep_Ids00to1F, 0x20-0x3F PartParamStep_Ids20to3F at H-0x20, ... 0xA0-0xBF PartParamStep_IdsA0toBF; 0xC0 and up
;   do nothing -- and calls the entry with the part.  Called by the COMBINATION EDIT INTERNAL SOUND / CONFIGURE
;   soft keys and T_PartParam_StepFieldById.
PartParam_StepFieldById:
	link XIZ,0x0000                                      ; FBB800  ee 0c 00 00
	pushw hl                                             ; FBB804  2b
	ld L,(XIZ+0x0a)                                      ; FBB805  8e 0a 27
	ld H,(XIZ+0x08)                                      ; FBB808  8e 08 26
	ld C,H                                               ; FBB80B  ce 8b
	and C,0xf0                                           ; FBB80D  cb cc f0
	extz BC                                              ; FBB810  d9 12
	cp bc, 0x00:i3                                         ; FBB812  d9 d8
	jrl z, .LFBB883                                      ; FBB814  76 6c 00
	cp BC,0x0010                                         ; FBB817  d9 cf 10 00
	jrl z, .LFBB883                                      ; FBB81B  76 65 00
	cp BC,0x0020                                         ; FBB81E  d9 cf 20 00
	jrl z, .LFBB89D                                      ; FBB822  76 78 00
	cp BC,0x0030                                         ; FBB825  d9 cf 30 00
	jrl z, .LFBB89D                                      ; FBB829  76 71 00
	cp BC,0x0040                                         ; FBB82C  d9 cf 40 00
	jrl z, .LFBB8BD                                      ; FBB830  76 8a 00
	cp BC,0x0050                                         ; FBB833  d9 cf 50 00
	jrl z, .LFBB8BD                                      ; FBB837  76 83 00
	cp BC,0x0060                                         ; FBB83A  d9 cf 60 00
	jrl z, .LFBB8DC                                      ; FBB83E  76 9b 00
	cp BC,0x0070                                         ; FBB841  d9 cf 70 00
	jrl z, .LFBB8DC                                      ; FBB845  76 94 00
	cp BC,0x0080                                         ; FBB848  d9 cf 80 00
	jrl z, .LFBB8FB                                      ; FBB84C  76 ac 00
	cp BC,0x0090                                         ; FBB84F  d9 cf 90 00
	jrl z, .LFBB8FB                                      ; FBB853  76 a5 00
	cp BC,0x00a0                                         ; FBB856  d9 cf a0 00
	jrl z, .LFBB91A                                      ; FBB85A  76 bd 00
	cp BC,0x00b0                                         ; FBB85D  d9 cf b0 00
	jrl z, .LFBB91A                                      ; FBB861  76 b6 00
	cp BC,0x00c0                                         ; FBB864  d9 cf c0 00
	jrl z, .LFBB938                                      ; FBB868  76 cd 00
	cp BC,0x00d0                                         ; FBB86B  d9 cf d0 00
	jrl z, .LFBB938                                      ; FBB86F  76 c6 00
	cp BC,0x00e0                                         ; FBB872  d9 cf e0 00
	jrl z, .LFBB938                                      ; FBB876  76 bf 00
	cp BC,0x00f0                                         ; FBB879  d9 cf f0 00
	jrl z, .LFBB938                                      ; FBB87D  76 b8 00
	jrl .LFBB938                                         ; FBB880  78 b5 00
.LFBB883:
	pushw hl                                             ; FBB883  2b
	ld c, 0x04:opc                                          ; FBB884  23 04
	mul bc, h                                          ; FBB886  ce 43
	extz XBC                                             ; FBB888  e9 12
	add XBC,PartParamStep_Ids00to1F                              ; FBB88A  e9 c8 13 ab f1 00
	ld XBC,(XBC)                                         ; FBB890  a1 21
	lda xiy, (.LFBB89A:24)                               ; FBB892  f2 9a b8 fb 35
	push XIY                                             ; FBB897  3d
	jp (xbc)                                             ; FBB898  b1 d8
.LFBB89A:
	jrl .LFBB937                                         ; FBB89A  78 9a 00
.LFBB89D:
	pushw hl                                             ; FBB89D  2b
	ld c, 0x04:opc                                          ; FBB89E  23 04
	mul bc, h                                          ; FBB8A0  ce 43
	extz XBC                                             ; FBB8A2  e9 12
	sub XBC,0x00000080                                   ; FBB8A4  e9 ca 80 00 00 00
	add XBC,PartParamStep_Ids20to3F                              ; FBB8AA  e9 c8 4b ab f1 00
	ld XBC,(XBC)                                         ; FBB8B0  a1 21
	lda xiy, (.LFBB8BA:24)                               ; FBB8B2  f2 ba b8 fb 35
	push XIY                                             ; FBB8B7  3d
	jp (xbc)                                             ; FBB8B8  b1 d8
.LFBB8BA:
	jrl .LFBB937                                         ; FBB8BA  78 7a 00
.LFBB8BD:
	pushw hl                                             ; FBB8BD  2b
	ld c, 0x04:opc                                          ; FBB8BE  23 04
	mul bc, h                                          ; FBB8C0  ce 43
	extz XBC                                             ; FBB8C2  e9 12
	sub XBC,0x00000100                                   ; FBB8C4  e9 ca 00 01 00 00
	add XBC,PartParamStep_Ids40to5F                              ; FBB8CA  e9 c8 6f ab f1 00
	ld XBC,(XBC)                                         ; FBB8D0  a1 21
	lda xiy, (.LFBB8DA:24)                               ; FBB8D2  f2 da b8 fb 35
	push XIY                                             ; FBB8D7  3d
	jp (xbc)                                             ; FBB8D8  b1 d8
.LFBB8DA:
	jr .LFBB937                                          ; FBB8DA  68 5b
.LFBB8DC:
	pushw hl                                             ; FBB8DC  2b
	ld c, 0x04:opc                                          ; FBB8DD  23 04
	mul bc, h                                          ; FBB8DF  ce 43
	extz XBC                                             ; FBB8E1  e9 12
	sub XBC,0x00000180                                   ; FBB8E3  e9 ca 80 01 00 00
	add XBC,PartParamStep_Ids60to7F                              ; FBB8E9  e9 c8 97 ab f1 00
	ld XBC,(XBC)                                         ; FBB8EF  a1 21
	lda xiy, (.LFBB8F9:24)                               ; FBB8F1  f2 f9 b8 fb 35
	push XIY                                             ; FBB8F6  3d
	jp (xbc)                                             ; FBB8F7  b1 d8
.LFBB8F9:
	jr .LFBB937                                          ; FBB8F9  68 3c
.LFBB8FB:
	pushw hl                                             ; FBB8FB  2b
	ld c, 0x04:opc                                          ; FBB8FC  23 04
	mul bc, h                                          ; FBB8FE  ce 43
	extz XBC                                             ; FBB900  e9 12
	sub XBC,0x00000200                                   ; FBB902  e9 ca 00 02 00 00
	add XBC,PartParamStep_Ids80to9F                              ; FBB908  e9 c8 a3 ab f1 00
	ld XBC,(XBC)                                         ; FBB90E  a1 21
	lda xiy, (.LFBB918:24)                               ; FBB910  f2 18 b9 fb 35
	push XIY                                             ; FBB915  3d
	jp (xbc)                                             ; FBB916  b1 d8
.LFBB918:
	jr .LFBB937                                          ; FBB918  68 1d
.LFBB91A:
	pushw hl                                             ; FBB91A  2b
	ld c, 0x04:opc                                          ; FBB91B  23 04
	mul bc, h                                          ; FBB91D  ce 43
	extz XBC                                             ; FBB91F  e9 12
	sub XBC,0x00000280                                   ; FBB921  e9 ca 80 02 00 00
	add XBC,PartParamStep_IdsA0toBF                              ; FBB927  e9 c8 e7 ab f1 00
	ld XBC,(XBC)                                         ; FBB92D  a1 21
	lda xiy, (.LFBB937:24)                               ; FBB92F  f2 37 b9 fb 35
	push XIY                                             ; FBB934  3d
	jp (xbc)                                             ; FBB935  b1 d8
.LFBB937:
	popw bc                                              ; FBB937  49
.LFBB938:
	popw hl                                              ; FBB938  4b
	unlk XIZ                                             ; FBB939  ee 0d
	ret                                                  ; FBB93B  0e
; PartParam_EnterFieldById: PartParam_StepFieldById's number-pad twin over PartParamEnter_Ids00to1F .. PartParamEnter_IdsA0toBF, the same id ranges.
;   Called by NumberPadKey_CombiEditInternalSound and T_PartParam_EnterFieldById.
PartParam_EnterFieldById:
	link XIZ,0x0000                                      ; FBB93C  ee 0c 00 00
	pushw hl                                             ; FBB940  2b
	pushw de                                             ; FBB941  2a
	ld L,(XIZ+0x0a)                                      ; FBB942  8e 0a 27
	ld H,(XIZ+0x08)                                      ; FBB945  8e 08 26
	ld C,H                                               ; FBB948  ce 8b
	and C,0xf0                                           ; FBB94A  cb cc f0
	extz BC                                              ; FBB94D  d9 12
	cp bc, 0x00:i3                                         ; FBB94F  d9 d8
	jrl z, .LFBB9C0                                      ; FBB951  76 6c 00
	cp BC,0x0010                                         ; FBB954  d9 cf 10 00
	jrl z, .LFBB9C0                                      ; FBB958  76 65 00
	cp BC,0x0020                                         ; FBB95B  d9 cf 20 00
	jrl z, .LFBB9DB                                      ; FBB95F  76 79 00
	cp BC,0x0030                                         ; FBB962  d9 cf 30 00
	jrl z, .LFBB9DB                                      ; FBB966  76 72 00
	cp BC,0x0040                                         ; FBB969  d9 cf 40 00
	jrl z, .LFBB9FC                                      ; FBB96D  76 8c 00
	cp BC,0x0050                                         ; FBB970  d9 cf 50 00
	jrl z, .LFBB9FC                                      ; FBB974  76 85 00
	cp BC,0x0060                                         ; FBB977  d9 cf 60 00
	jrl z, .LFBBA1C                                      ; FBB97B  76 9e 00
	cp BC,0x0070                                         ; FBB97E  d9 cf 70 00
	jrl z, .LFBBA1C                                      ; FBB982  76 97 00
	cp BC,0x0080                                         ; FBB985  d9 cf 80 00
	jrl z, .LFBBA3C                                      ; FBB989  76 b0 00
	cp BC,0x0090                                         ; FBB98C  d9 cf 90 00
	jrl z, .LFBBA3C                                      ; FBB990  76 a9 00
	cp BC,0x00a0                                         ; FBB993  d9 cf a0 00
	jrl z, .LFBBA5C                                      ; FBB997  76 c2 00
	cp BC,0x00b0                                         ; FBB99A  d9 cf b0 00
	jrl z, .LFBBA5C                                      ; FBB99E  76 bb 00
	cp BC,0x00c0                                         ; FBB9A1  d9 cf c0 00
	jrl z, .LFBBA7C                                      ; FBB9A5  76 d4 00
	cp BC,0x00d0                                         ; FBB9A8  d9 cf d0 00
	jrl z, .LFBBA7C                                      ; FBB9AC  76 cd 00
	cp BC,0x00e0                                         ; FBB9AF  d9 cf e0 00
	jrl z, .LFBBA7C                                      ; FBB9B3  76 c6 00
	cp BC,0x00f0                                         ; FBB9B6  d9 cf f0 00
	jrl z, .LFBBA7C                                      ; FBB9BA  76 bf 00
	jrl .LFBBA7C                                         ; FBB9BD  78 bc 00
.LFBB9C0:
	pushw hl                                             ; FBB9C0  2b
	ld c, 0x04:opc                                          ; FBB9C1  23 04
	mul bc, h                                          ; FBB9C3  ce 43
	extz XBC                                             ; FBB9C5  e9 12
	add XBC,PartParamEnter_Ids00to1F                              ; FBB9C7  e9 c8 07 ac f1 00
	ld XBC,(XBC)                                         ; FBB9CD  a1 21
	lda xiy, (.LFBB9D7:24)                               ; FBB9CF  f2 d7 b9 fb 35
	push XIY                                             ; FBB9D4  3d
	jp (xbc)                                             ; FBB9D5  b1 d8
.LFBB9D7:
	popw bc                                              ; FBB9D7  49
	jrl .LFBBA7E                                         ; FBB9D8  78 a3 00
.LFBB9DB:
	pushw hl                                             ; FBB9DB  2b
	ld c, 0x04:opc                                          ; FBB9DC  23 04
	mul bc, h                                          ; FBB9DE  ce 43
	extz XBC                                             ; FBB9E0  e9 12
	sub XBC,0x00000080                                   ; FBB9E2  e9 ca 80 00 00 00
	add XBC,PartParamEnter_Ids20to3F                              ; FBB9E8  e9 c8 3f ac f1 00
	ld XBC,(XBC)                                         ; FBB9EE  a1 21
	lda xiy, (.LFBB9F8:24)                               ; FBB9F0  f2 f8 b9 fb 35
	push XIY                                             ; FBB9F5  3d
	jp (xbc)                                             ; FBB9F6  b1 d8
.LFBB9F8:
	popw bc                                              ; FBB9F8  49
	jrl .LFBBA7E                                         ; FBB9F9  78 82 00
.LFBB9FC:
	pushw hl                                             ; FBB9FC  2b
	ld c, 0x04:opc                                          ; FBB9FD  23 04
	mul bc, h                                          ; FBB9FF  ce 43
	extz XBC                                             ; FBBA01  e9 12
	sub XBC,0x00000100                                   ; FBBA03  e9 ca 00 01 00 00
	add XBC,PartParamEnter_Ids40to5F                              ; FBBA09  e9 c8 63 ac f1 00
	ld XBC,(XBC)                                         ; FBBA0F  a1 21
	lda xiy, (.LFBBA19:24)                               ; FBBA11  f2 19 ba fb 35
	push XIY                                             ; FBBA16  3d
	jp (xbc)                                             ; FBBA17  b1 d8
.LFBBA19:
	popw bc                                              ; FBBA19  49
	jr .LFBBA7E                                          ; FBBA1A  68 62
.LFBBA1C:
	pushw hl                                             ; FBBA1C  2b
	ld c, 0x04:opc                                          ; FBBA1D  23 04
	mul bc, h                                          ; FBBA1F  ce 43
	extz XBC                                             ; FBBA21  e9 12
	sub XBC,0x00000180                                   ; FBBA23  e9 ca 80 01 00 00
	add XBC,PartParamEnter_Ids60to7F                              ; FBBA29  e9 c8 8b ac f1 00
	ld XBC,(XBC)                                         ; FBBA2F  a1 21
	lda xiy, (.LFBBA39:24)                               ; FBBA31  f2 39 ba fb 35
	push XIY                                             ; FBBA36  3d
	jp (xbc)                                             ; FBBA37  b1 d8
.LFBBA39:
	popw bc                                              ; FBBA39  49
	jr .LFBBA7E                                          ; FBBA3A  68 42
.LFBBA3C:
	pushw hl                                             ; FBBA3C  2b
	ld c, 0x04:opc                                          ; FBBA3D  23 04
	mul bc, h                                          ; FBBA3F  ce 43
	extz XBC                                             ; FBBA41  e9 12
	sub XBC,0x00000200                                   ; FBBA43  e9 ca 00 02 00 00
	add XBC,PartParamEnter_Ids80to9F                              ; FBBA49  e9 c8 97 ac f1 00
	ld XBC,(XBC)                                         ; FBBA4F  a1 21
	lda xiy, (.LFBBA59:24)                               ; FBBA51  f2 59 ba fb 35
	push XIY                                             ; FBBA56  3d
	jp (xbc)                                             ; FBBA57  b1 d8
.LFBBA59:
	popw bc                                              ; FBBA59  49
	jr .LFBBA7E                                          ; FBBA5A  68 22
.LFBBA5C:
	pushw hl                                             ; FBBA5C  2b
	ld c, 0x04:opc                                          ; FBBA5D  23 04
	mul bc, h                                          ; FBBA5F  ce 43
	extz XBC                                             ; FBBA61  e9 12
	sub XBC,0x00000280                                   ; FBBA63  e9 ca 80 02 00 00
	add XBC,PartParamEnter_IdsA0toBF                              ; FBBA69  e9 c8 db ac f1 00
	ld XBC,(XBC)                                         ; FBBA6F  a1 21
	lda xiy, (.LFBBA79:24)                               ; FBBA71  f2 79 ba fb 35
	push XIY                                             ; FBBA76  3d
	jp (xbc)                                             ; FBBA77  b1 d8
.LFBBA79:
	popw bc                                              ; FBBA79  49
	jr .LFBBA7E                                          ; FBBA7A  68 02
.LFBBA7C:
	ld A,D                                               ; FBBA7C  cc 89
.LFBBA7E:
	popw de                                              ; FBBA7E  4a
	popw hl                                              ; FBBA7F  4b
	unlk XIZ                                             ; FBBA80  ee 0d
	ret                                                  ; FBBA82  0e
; PartParam_RefuseNumberEntry: the number-entry slot of a field that takes none: Blink_SetEnable(0), returns 0 (notes/prom_ab_part_param_fields.py)
PartParam_RefuseNumberEntry:
	pushw 0x00                                           ; FBBA83  0b 00 00
	call T_Blink_SetEnable                               ; FBBA86  1d 28 2e f4
	popw bc                                              ; FBBA8A  49
	sub A,A                                              ; FBBA8B  c9 a1
	ret                                                  ; FBBA8D  0e
; PartParam_StepSound: PartParamStep_Ids00to1F[0], the field before VOLUME on the INTERNAL SOUND page: sets UI_RequestBits bit 3 and calls
;   PartSound_StepBankGroupMember(part).
PartParam_StepSound:
	link XIZ,0x0000                                      ; FBBA8E  ee 0c 00 00
	set	3, (UI_RequestBits:16)                               ; FBBA92  f1 75 20 bb
	push 0x00                                            ; FBBA96  09 00
	push	(xiz+8)                                      ; FBBA98  8e 08 04
	call PartSound_StepBankGroupMember                                      ; FBBA9B  1d 2e f0 f4
	popw bc                                              ; FBBA9F  49
	unlk XIZ                                             ; FBBAA0  ee 0d
	ret                                                  ; FBBAA2  0e
; PartParam_StepVolume: the adjust handler of PartParamField_Volume (VOLUME), slot PartParamStep_Ids00to1F[1] (notes/prom_ab_part_param_fields.py)
PartParam_StepVolume:
	link XIZ,0x0000                                      ; FBBAA3  ee 0c 00 00
	lda xbc, (PartParamField_Volume:24)                          ; FBBAA7  f2 fb ac f1 31
	push XBC                                             ; FBBAAC  39
	push 0x00                                            ; FBBAAD  09 00
	push	(xiz+8)                                      ; FBBAAF  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBAB2  1d 94 2c f4
	inc 6,XSP                                            ; FBBAB6  ef 66
	unlk XIZ                                             ; FBBAB8  ee 0d
	ret                                                  ; FBBABA  0e
; PartParam_EnterVolume: the number-entry handler of PartParamField_Volume (VOLUME), slot PartParamEnter_Ids00to1F[1] (notes/prom_ab_part_param_fields.py)
PartParam_EnterVolume:
	link XIZ,0x0000                                      ; FBBABB  ee 0c 00 00
	lda xbc, (PartParamField_Volume:24)                          ; FBBABF  f2 fb ac f1 31
	push XBC                                             ; FBBAC4  39
	push 0x00                                            ; FBBAC5  09 00
	push	(xiz+8)                                      ; FBBAC7  8e 08 04
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBBACA  1d a8 2c f4
	inc 6,XSP                                            ; FBBACE  ef 66
	unlk XIZ                                             ; FBBAD0  ee 0d
	ret                                                  ; FBBAD2  0e
; PartParam_StepPanpot: the adjust handler of PartParamField_Panpot (PANPOT), slot PartParamStep_Ids00to1F[2] (notes/prom_ab_part_param_fields.py)
PartParam_StepPanpot:
	link XIZ,0x0000                                      ; FBBAD3  ee 0c 00 00
	lda xbc, (PartParamField_Panpot:24)                          ; FBBAD7  f2 04 ad f1 31
	push XBC                                             ; FBBADC  39
	push 0x00                                            ; FBBADD  09 00
	push	(xiz+8)                                      ; FBBADF  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBAE2  1d 94 2c f4
	inc 6,XSP                                            ; FBBAE6  ef 66
	unlk XIZ                                             ; FBBAE8  ee 0d
	ret                                                  ; FBBAEA  0e
; PartParam_StepKeyShift: the adjust handler of PartParamField_KeyShift (KEY SHIFT), slot PartParamStep_Ids00to1F[3] (notes/prom_ab_part_param_fields.py)
PartParam_StepKeyShift:
	link XIZ,0x0000                                      ; FBBAEB  ee 0c 00 00
	lda xbc, (PartParamField_KeyShift:24)                          ; FBBAEF  f2 0d ad f1 31
	push XBC                                             ; FBBAF4  39
	push 0x00                                            ; FBBAF5  09 00
	push	(xiz+8)                                      ; FBBAF7  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBAFA  1d 94 2c f4
	inc 6,XSP                                            ; FBBAFE  ef 66
	unlk XIZ                                             ; FBBB00  ee 0d
	ret                                                  ; FBBB02  0e
; PartParam_EnterKeyShift: the number-entry handler of PartParamField_KeyShift (KEY SHIFT), slot PartParamEnter_Ids00to1F[3] (notes/prom_ab_part_param_fields.py)
PartParam_EnterKeyShift:
	link XIZ,0x0000                                      ; FBBB03  ee 0c 00 00
	lda xbc, (PartParamField_KeyShift:24)                          ; FBBB07  f2 0d ad f1 31
	push XBC                                             ; FBBB0C  39
	push 0x00                                            ; FBBB0D  09 00
	push	(xiz+8)                                      ; FBBB0F  8e 08 04
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBBB12  1d a8 2c f4
	inc 6,XSP                                            ; FBBB16  ef 66
	unlk XIZ                                             ; FBBB18  ee 0d
	ret                                                  ; FBBB1A  0e
; PartParam_StepFineTune: the adjust handler of PartParamField_FineTune (FINE TUNE), slot PartParamStep_Ids00to1F[4] (notes/prom_ab_part_param_fields.py)
PartParam_StepFineTune:
	link XIZ,0x0000                                      ; FBBB1B  ee 0c 00 00
	lda xbc, (PartParamField_FineTune:24)                          ; FBBB1F  f2 16 ad f1 31
	push XBC                                             ; FBBB24  39
	push 0x00                                            ; FBBB25  09 00
	push	(xiz+8)                                      ; FBBB27  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBB2A  1d 94 2c f4
	inc 6,XSP                                            ; FBBB2E  ef 66
	unlk XIZ                                             ; FBBB30  ee 0d
	ret                                                  ; FBBB32  0e
; PartParam_EnterFineTune: the number-entry handler of PartParamField_FineTune (FINE TUNE), slot PartParamEnter_Ids00to1F[4] (notes/prom_ab_part_param_fields.py)
PartParam_EnterFineTune:
	link XIZ,0x0000                                      ; FBBB33  ee 0c 00 00
	lda xbc, (PartParamField_FineTune:24)                          ; FBBB37  f2 16 ad f1 31
	push XBC                                             ; FBBB3C  39
	push 0x00                                            ; FBBB3D  09 00
	push	(xiz+8)                                      ; FBBB3F  8e 08 04
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBBB42  1d a8 2c f4
	inc 6,XSP                                            ; FBBB46  ef 66
	unlk XIZ                                             ; FBBB48  ee 0d
	ret                                                  ; FBBB4A  0e
; PartParam_StepPitchBendRange: the adjust handler of PartParamField_PitchBendRange (PITCH BEND RANGE), slot PartParamStep_Ids00to1F[5] (notes/prom_ab_part_param_fields.py)
PartParam_StepPitchBendRange:
	link XIZ,0x0000                                      ; FBBB4B  ee 0c 00 00
	lda xbc, (PartParamField_PitchBendRange:24)                          ; FBBB4F  f2 1f ad f1 31
	push XBC                                             ; FBBB54  39
	push 0x00                                            ; FBBB55  09 00
	push	(xiz+8)                                      ; FBBB57  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBB5A  1d 94 2c f4
	inc 6,XSP                                            ; FBBB5E  ef 66
	unlk XIZ                                             ; FBBB60  ee 0d
	ret                                                  ; FBBB62  0e
; PartParam_EnterPitchBendRange: the number-entry handler of PartParamField_PitchBendRange (PITCH BEND RANGE), slot PartParamEnter_Ids00to1F[5] (notes/prom_ab_part_param_fields.py)
PartParam_EnterPitchBendRange:
	link XIZ,0x0000                                      ; FBBB63  ee 0c 00 00
	lda xbc, (PartParamField_PitchBendRange:24)                          ; FBBB67  f2 1f ad f1 31
	push XBC                                             ; FBBB6C  39
	push 0x00                                            ; FBBB6D  09 00
	push	(xiz+8)                                      ; FBBB6F  8e 08 04
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBBB72  1d a8 2c f4
	inc 6,XSP                                            ; FBBB76  ef 66
	unlk XIZ                                             ; FBBB78  ee 0d
	ret                                                  ; FBBB7A  0e
; PartParam_StepEffect1Send: the adjust handler of PartParamField_Effect1Send (EFFECT1 SEND), slot PartParamStep_Ids00to1F[6] (notes/prom_ab_part_param_fields.py)
PartParam_StepEffect1Send:
	link XIZ,0x0000                                      ; FBBB7B  ee 0c 00 00
	lda xbc, (PartParamField_Effect1Send:24)                          ; FBBB7F  f2 28 ad f1 31
	push XBC                                             ; FBBB84  39
	push 0x00                                            ; FBBB85  09 00
	push	(xiz+8)                                      ; FBBB87  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBB8A  1d 94 2c f4
	inc 6,XSP                                            ; FBBB8E  ef 66
	unlk XIZ                                             ; FBBB90  ee 0d
	ret                                                  ; FBBB92  0e
; PartParam_EnterEffect1Send: the number-entry handler of PartParamField_Effect1Send (EFFECT1 SEND), slot PartParamEnter_Ids00to1F[6] (notes/prom_ab_part_param_fields.py)
PartParam_EnterEffect1Send:
	link XIZ,0x0000                                      ; FBBB93  ee 0c 00 00
	lda xbc, (PartParamField_Effect1Send:24)                          ; FBBB97  f2 28 ad f1 31
	push XBC                                             ; FBBB9C  39
	push 0x00                                            ; FBBB9D  09 00
	push	(xiz+8)                                      ; FBBB9F  8e 08 04
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBBBA2  1d a8 2c f4
	inc 6,XSP                                            ; FBBBA6  ef 66
	unlk XIZ                                             ; FBBBA8  ee 0d
	ret                                                  ; FBBBAA  0e
; PartParam_StepEffect2: PartParamStep_Ids00to1F[7], EFFECT2 on the INTERNAL SOUND page: byte 6 of the part record toggles 0 <-> 0x7F (notes/prom_ab_part_param_fields.py)
PartParam_StepEffect2:
	link XIZ,0x0000                                      ; FBBBAB  ee 0c 00 00
	pushw hl                                             ; FBBBAF  2b
	push XIX                                             ; FBBBB0  3c
	ld L,(XIZ+0x08)                                      ; FBBBB1  8e 08 27
	pushw hl                                             ; FBBBB4  2b
	call T_IndexedTable_GetPtr                           ; FBBBB5  1d 8c 2c f4
	ld XIX,XIY                                           ; FBBBB9  ed 8c
	inc 6,XIY                                            ; FBBBBB  ed 66
	ld XIX,XIY                                           ; FBBBBD  ed 8c
	ld c, (PanelEvent_Flags:16)                                   ; FBBBBF  c1 b0 28 23
	and C,0x01                                           ; FBBBC3  cb cc 01
	popw wa                                              ; FBBBC6  48
	jr z, .LFBBBDA                                       ; FBBBC7  66 11
	ld C,(XIY)                                           ; FBBBC9  85 23
	res 0x07,C                                           ; FBBBCB  cb 30 07
	cp c, 0x00:i3                                          ; FBBBCE  cb d8
	jr z, .LFBBC26                                       ; FBBBD0  66 54
	pushw 0x7f                                           ; FBBBD2  0b 7f 00
	pushw 0x00                                           ; FBBBD5  0b 00 00
	jr .LFBBC1C                                          ; FBBBD8  68 42
.LFBBBDA:
	ld C,(XIX)                                           ; FBBBDA  84 23
	res 0x07,C                                           ; FBBBDC  cb 30 07
	cp C,0x7f                                            ; FBBBDF  cb cf 7f
	jr z, .LFBBC26                                       ; FBBBE2  66 42
	pushw 0x03                                           ; FBBBE4  0b 03 00
	ld C,L                                               ; FBBBE7  cf 8b
	extz BC                                              ; FBBBE9  d9 12
	add BC,0x0020                                        ; FBBBEB  d9 c8 20 00
	ld H,C                                               ; FBBBEF  cb 8e
	pushw bc                                             ; FBBBF1  29
	call T_IndexedTable_GetByte                          ; FBBBF2  1d 90 2c f4
	pop XIY                                              ; FBBBF6  5d
	cp a, 0x00:i3                                          ; FBBBF7  c9 d8
	jr z, .LFBBC16                                       ; FBBBF9  66 1b
	pushw 0x04                                           ; FBBBFB  0b 04 00
	push 0x00                                            ; FBBBFE  09 00
	push H                                               ; FBBC00  ce 04
	call T_IndexedTable_GetByte                          ; FBBC02  1d 90 2c f4
	pop XIY                                              ; FBBC06  5d
	cp a, 0x00:i3                                          ; FBBC07  c9 d8
	jr z, .LFBBC16                                       ; FBBC09  66 0b
	set	6, (UI_Request_Hi:16)                               ; FBBC0B  f1 71 20 be
	ld (UI_Request:16), 0xb6                                 ; FBBC0F  f1 70 20 00 b6
	jr .LFBBC26                                          ; FBBC14  68 10
.LFBBC16:
	pushw 0x7f                                           ; FBBC16  0b 7f 00
	pushw 0x7f                                           ; FBBC19  0b 7f 00
.LFBBC1C:
	pushw 0x06                                           ; FBBC1C  0b 06 00
	pushw hl                                             ; FBBC1F  2b
	call T_List2030_Append4                              ; FBBC20  1d 88 2c f4
	inc 8,XSP                                            ; FBBC24  ef 60
.LFBBC26:
	pop XIX                                              ; FBBC26  5c
	popw hl                                              ; FBBC27  4b
	unlk XIZ                                             ; FBBC28  ee 0d
	ret                                                  ; FBBC2A  0e
; PartParam_StepReverbSend: the adjust handler of PartParamField_ReverbSend (REVERB SEND), slot PartParamStep_Ids00to1F[8] (notes/prom_ab_part_param_fields.py)
PartParam_StepReverbSend:
	link XIZ,0x0000                                      ; FBBC2B  ee 0c 00 00
	lda xbc, (PartParamField_ReverbSend:24)                          ; FBBC2F  f2 31 ad f1 31
	push XBC                                             ; FBBC34  39
	push 0x00                                            ; FBBC35  09 00
	push	(xiz+8)                                      ; FBBC37  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBC3A  1d 94 2c f4
	inc 6,XSP                                            ; FBBC3E  ef 66
	unlk XIZ                                             ; FBBC40  ee 0d
	ret                                                  ; FBBC42  0e
; PartParam_EnterReverbSend: the number-entry handler of PartParamField_ReverbSend (REVERB SEND), slot PartParamEnter_Ids00to1F[8] (notes/prom_ab_part_param_fields.py)
PartParam_EnterReverbSend:
	link XIZ,0x0000                                      ; FBBC43  ee 0c 00 00
	lda xbc, (PartParamField_ReverbSend:24)                          ; FBBC47  f2 31 ad f1 31
	push XBC                                             ; FBBC4C  39
	push 0x00                                            ; FBBC4D  09 00
	push	(xiz+8)                                      ; FBBC4F  8e 08 04
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBBC52  1d a8 2c f4
	inc 6,XSP                                            ; FBBC56  ef 66
	unlk XIZ                                             ; FBBC58  ee 0d
	ret                                                  ; FBBC5A  0e
; PartParam_StepLocalControl: LOCAL CONTROL: forces bit 0x20 of byte 13 of part record E by the step direction (T_IndexedParam_SetBit, PartParamField_LocalControl); PartParamStep_Ids00to1F[9] (notes/prom_ab_part_param_switches.py)
PartParam_StepLocalControl:
	link XIZ,0x0000                                      ; FBBC5B  ee 0c 00 00
	lda xbc, (PartParamField_LocalControl:24)                          ; FBBC5F  f2 3a ad f1 31
	push XBC                                             ; FBBC64  39
	push 0x00                                            ; FBBC65  09 00
	push	(xiz+8)                                      ; FBBC67  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBC6A  1d 98 2c f4
	inc 6,XSP                                            ; FBBC6E  ef 66
	unlk XIZ                                             ; FBBC70  ee 0d
	ret                                                  ; FBBC72  0e
; PartParam_StepMidiOutSetting: MIDI OUT SETTING: forces bit 0x40 of byte 13 of part record E by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutSetting); PartParamStep_Ids00to1F[10] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutSetting:
	link XIZ,0x0000                                      ; FBBC73  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutSetting:24)                          ; FBBC77  f2 3d ad f1 31
	push XBC                                             ; FBBC7C  39
	push 0x00                                            ; FBBC7D  09 00
	push	(xiz+8)                                      ; FBBC7F  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBC82  1d 98 2c f4
	inc 6,XSP                                            ; FBBC86  ef 66
	unlk XIZ                                             ; FBBC88  ee 0d
	ret                                                  ; FBBC8A  0e
; PartParam_StepMidiInSetting: MIDI IN SETTING: forces bit 0x80 of byte 13 of part record E by the step direction (T_IndexedParam_SetBit, PartParamField_MidiInSetting); PartParamStep_Ids00to1F[11] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiInSetting:
	link XIZ,0x0000                                      ; FBBC8B  ee 0c 00 00
	lda xbc, (PartParamField_MidiInSetting:24)                          ; FBBC8F  f2 40 ad f1 31
	push XBC                                             ; FBBC94  39
	push 0x00                                            ; FBBC95  09 00
	push	(xiz+8)                                      ; FBBC97  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBC9A  1d 98 2c f4
	inc 6,XSP                                            ; FBBC9E  ef 66
	unlk XIZ                                             ; FBBCA0  ee 0d
	ret                                                  ; FBBCA2  0e
; PartParam_StepIgnored: PartParamStep_Ids00to1F[12]: a bare `ret` -- field id 12 has no adjust action (notes/prom_ab_part_param_switches.py)
PartParam_StepIgnored:
	ret                                                  ; FBBCA3  0e
; PartParam_StepKeyScaling: KEY SCALING: forces bit 0x08 of byte 12 of part record E by the step direction (T_IndexedParam_SetBit, PartParamField_KeyScaling); PartParamStep_Ids00to1F[13] (notes/prom_ab_part_param_switches.py)
PartParam_StepKeyScaling:
	link XIZ,0x0000                                      ; FBBCA4  ee 0c 00 00
	lda xbc, (PartParamField_KeyScaling:24)                          ; FBBCA8  f2 43 ad f1 31
	push XBC                                             ; FBBCAD  39
	push 0x00                                            ; FBBCAE  09 00
	push	(xiz+8)                                      ; FBBCB0  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBCB3  1d 98 2c f4
	inc 6,XSP                                            ; FBBCB7  ef 66
	unlk XIZ                                             ; FBBCB9  ee 0d
	ret                                                  ; FBBCBB  0e
; PartParam_StepMainOut: PartParamStep_Ids20to3F[0].  Steps byte 3 of part record E+0x20 (MAIN OUT: SysEx rec 32, offset 3) through T_EditValue_StepBitField
;   (EditValue_StepBitField) with PartParamField_MainOut.  If it moved, the new value is kept only when EFFECT2 is
;   off (byte 6 of record E, bit 7 masked, is 0), SUB OUT (byte 4 of E+0x20) is 0, or the new value is 0.
;   Otherwise it sets UI_Request_Hi bit 6 and UI_Request = 0xB6 instead.  So with EFFECT2 on, a part cannot
;   go to MAIN and SUB OUT at once.  A kept value is written back and posted to Queue2C00 (E+0x20, offset 3).
PartParam_StepMainOut:
	link XIZ,0xffff                                      ; FBBCBC  ee 0c ff ff
	pushw hl                                             ; FBBCC0  2b
	push XIX                                             ; FBBCC1  3c
	ld H,(XIZ+0x08)                                      ; FBBCC2  8e 08 26
	ld C,H                                               ; FBBCC5  ce 8b
	extz BC                                              ; FBBCC7  d9 12
	add BC,0x0020                                        ; FBBCC9  d9 c8 20 00
	pushw bc                                             ; FBBCCD  29
	call T_IndexedTable_GetPtr                           ; FBBCCE  1d 8c 2c f4
	ld XIX,XIY                                           ; FBBCD2  ed 8c
	inc 3,XIY                                            ; FBBCD4  ed 63
	ld XIX,XIY                                           ; FBBCD6  ed 8c
	ld C,(XIY)                                           ; FBBCD8  85 23
	ld (xiz-1), c                                        ; FBBCDA  be ff 43
	lda xbc, (PartParamField_MainOut:24)                          ; FBBCDD  f2 46 ad f1 31
	push XBC                                             ; FBBCE2  39
	lda xwa, (xiz-1)                                     ; FBBCE3  be ff 30
	push XWA                                             ; FBBCE6  38
	call T_EditValue_StepBitField                                        ; FBBCE7  1d 78 2c f4
	inc 8,XSP                                            ; FBBCEB  ef 60
	inc 2,XSP                                            ; FBBCED  ef 62
	cp a, 0x01:i3                                          ; FBBCEF  c9 d9
	jr nz, .LFBBD4A                                      ; FBBCF1  6e 57
	pushw 0x06                                           ; FBBCF3  0b 06 00
	push 0x00                                            ; FBBCF6  09 00
	push H                                               ; FBBCF8  ce 04
	call T_IndexedTable_GetByte                          ; FBBCFA  1d 90 2c f4
	res 0x07,A                                           ; FBBCFE  c9 30 07
	pop XIY                                              ; FBBD01  5d
	cp a, 0x00:i3                                          ; FBBD02  c9 d8
	jr z, .LFBBD2C                                       ; FBBD04  66 26
	pushw 0x04                                           ; FBBD06  0b 04 00
	ld C,H                                               ; FBBD09  ce 8b
	extz BC                                              ; FBBD0B  d9 12
	add BC,0x0020                                        ; FBBD0D  d9 c8 20 00
	pushw bc                                             ; FBBD11  29
	call T_IndexedTable_GetByte                          ; FBBD12  1d 90 2c f4
	pop XIY                                              ; FBBD16  5d
	cp a, 0x00:i3                                          ; FBBD17  c9 d8
	jr z, .LFBBD2C                                       ; FBBD19  66 11
	cp	(xiz-1), 0x00                                ; FBBD1B  8e ff 3f 00
	jr z, .LFBBD2C                                       ; FBBD1F  66 0b
	set	6, (UI_Request_Hi:16)                               ; FBBD21  f1 71 20 be
	ld (UI_Request:16), 0xb6                                 ; FBBD25  f1 70 20 00 b6
	jr .LFBBD4A                                          ; FBBD2A  68 1e
.LFBBD2C:
	ld c, (xiz-1)                                        ; FBBD2C  8e ff 23
	ld (XIX),C                                           ; FBBD2F  b4 43
	ld l, (xiz-1)                                        ; FBBD31  8e ff 27
	pushw 0xff                                           ; FBBD34  0b ff 00
	pushw hl                                             ; FBBD37  2b
	pushw 0x03                                           ; FBBD38  0b 03 00
	ld C,H                                               ; FBBD3B  ce 8b
	extz BC                                              ; FBBD3D  d9 12
	add BC,0x0020                                        ; FBBD3F  d9 c8 20 00
	pushw bc                                             ; FBBD43  29
	call T_Queue2C00_Append4                             ; FBBD44  1d 80 2c f4
	inc 8,XSP                                            ; FBBD48  ef 60
.LFBBD4A:
	pop XIX                                              ; FBBD4A  5c
	popw hl                                              ; FBBD4B  4b
	unlk XIZ                                             ; FBBD4C  ee 0d
	ret                                                  ; FBBD4E  0e
; PartParam_StepSubOut: PartParamStep_Ids20to3F[1]: PartParam_StepMainOut's twin on byte 4 (SUB OUT) with PartParamField_SubOut, testing MAIN
;   OUT (byte 3) instead of SUB OUT.  One difference: a step that lands on 1 is stepped again
;   (`cp (XIZ-1),1 / jr nz` at 0xFBBD87), so the panel never selects SUB OUT 1.
PartParam_StepSubOut:
	link XIZ,0xffff                                      ; FBBD4F  ee 0c ff ff
	pushw hl                                             ; FBBD53  2b
	push XIX                                             ; FBBD54  3c
	ld H,(XIZ+0x08)                                      ; FBBD55  8e 08 26
	ld C,H                                               ; FBBD58  ce 8b
	extz BC                                              ; FBBD5A  d9 12
	add BC,0x0020                                        ; FBBD5C  d9 c8 20 00
	pushw bc                                             ; FBBD60  29
	call T_IndexedTable_GetPtr                           ; FBBD61  1d 8c 2c f4
	ld XIX,XIY                                           ; FBBD65  ed 8c
	inc 4,XIY                                            ; FBBD67  ed 64
	ld XIX,XIY                                           ; FBBD69  ed 8c
	ld C,(XIY)                                           ; FBBD6B  85 23
	ld (xiz-1), c                                        ; FBBD6D  be ff 43
	lda xbc, (PartParamField_SubOut:24)                          ; FBBD70  f2 4f ad f1 31
	push XBC                                             ; FBBD75  39
	lda xwa, (xiz-1)                                     ; FBBD76  be ff 30
	push XWA                                             ; FBBD79  38
	call T_EditValue_StepBitField                                        ; FBBD7A  1d 78 2c f4
	inc 8,XSP                                            ; FBBD7E  ef 60
	inc 2,XSP                                            ; FBBD80  ef 62
	cp a, 0x01:i3                                          ; FBBD82  c9 d9
	jrl nz, .LFBBDF4                                     ; FBBD84  7e 6d 00
	cp	(xiz-1), 0x01                                ; FBBD87  8e ff 3f 01
	jr nz, .LFBBD9D                                      ; FBBD8B  6e 10
	lda xbc, (PartParamField_SubOut:24)                          ; FBBD8D  f2 4f ad f1 31
	push XBC                                             ; FBBD92  39
	lda xwa, (xiz-1)                                     ; FBBD93  be ff 30
	push XWA                                             ; FBBD96  38
	call T_EditValue_StepBitField                                        ; FBBD97  1d 78 2c f4
	inc 8,XSP                                            ; FBBD9B  ef 60
.LFBBD9D:
	pushw 0x06                                           ; FBBD9D  0b 06 00
	push 0x00                                            ; FBBDA0  09 00
	push H                                               ; FBBDA2  ce 04
	call T_IndexedTable_GetByte                          ; FBBDA4  1d 90 2c f4
	res 0x07,A                                           ; FBBDA8  c9 30 07
	pop XIY                                              ; FBBDAB  5d
	cp a, 0x00:i3                                          ; FBBDAC  c9 d8
	jr z, .LFBBDD6                                       ; FBBDAE  66 26
	pushw 0x03                                           ; FBBDB0  0b 03 00
	ld C,H                                               ; FBBDB3  ce 8b
	extz BC                                              ; FBBDB5  d9 12
	add BC,0x0020                                        ; FBBDB7  d9 c8 20 00
	pushw bc                                             ; FBBDBB  29
	call T_IndexedTable_GetByte                          ; FBBDBC  1d 90 2c f4
	pop XIY                                              ; FBBDC0  5d
	cp a, 0x00:i3                                          ; FBBDC1  c9 d8
	jr z, .LFBBDD6                                       ; FBBDC3  66 11
	cp	(xiz-1), 0x00                                ; FBBDC5  8e ff 3f 00
	jr z, .LFBBDD6                                       ; FBBDC9  66 0b
	set	6, (UI_Request_Hi:16)                               ; FBBDCB  f1 71 20 be
	ld (UI_Request:16), 0xb6                                 ; FBBDCF  f1 70 20 00 b6
	jr .LFBBDF4                                          ; FBBDD4  68 1e
.LFBBDD6:
	ld c, (xiz-1)                                        ; FBBDD6  8e ff 23
	ld (XIX),C                                           ; FBBDD9  b4 43
	ld l, (xiz-1)                                        ; FBBDDB  8e ff 27
	pushw 0xff                                           ; FBBDDE  0b ff 00
	pushw hl                                             ; FBBDE1  2b
	pushw 0x04                                           ; FBBDE2  0b 04 00
	ld C,H                                               ; FBBDE5  ce 8b
	extz BC                                              ; FBBDE7  d9 12
	add BC,0x0020                                        ; FBBDE9  d9 c8 20 00
	pushw bc                                             ; FBBDED  29
	call T_Queue2C00_Append4                             ; FBBDEE  1d 80 2c f4
	inc 8,XSP                                            ; FBBDF2  ef 60
.LFBBDF4:
	pop XIX                                              ; FBBDF4  5c
	popw hl                                              ; FBBDF5  4b
	unlk XIZ                                             ; FBBDF6  ee 0d
	ret                                                  ; FBBDF8  0e
; PartParam_StepAssignMode: the adjust handler of PartParamField_AssignMode (ASSIGN MODE), slot PartParamStep_Ids20to3F[2] (notes/prom_ab_part_param_fields.py)
PartParam_StepAssignMode:
	link XIZ,0x0000                                      ; FBBDF9  ee 0c 00 00
	lda xbc, (PartParamField_AssignMode:24)                          ; FBBDFD  f2 58 ad f1 31
	push XBC                                             ; FBBE02  39
	push 0x00                                            ; FBBE03  09 00
	push	(xiz+8)                                      ; FBBE05  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBE08  1d 94 2c f4
	inc 6,XSP                                            ; FBBE0C  ef 66
	unlk XIZ                                             ; FBBE0E  ee 0d
	ret                                                  ; FBBE10  0e
; PartParam_StepVelocityOffset: the adjust handler of PartParamField_VelocityOffset (VELOCITY OFFSET), slot PartParamStep_Ids20to3F[3] (notes/prom_ab_part_param_fields.py)
PartParam_StepVelocityOffset:
	link XIZ,0x0000                                      ; FBBE11  ee 0c 00 00
	lda xbc, (PartParamField_VelocityOffset:24)                          ; FBBE15  f2 61 ad f1 31
	push XBC                                             ; FBBE1A  39
	push 0x00                                            ; FBBE1B  09 00
	push	(xiz+8)                                      ; FBBE1D  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBE20  1d 94 2c f4
	inc 6,XSP                                            ; FBBE24  ef 66
	unlk XIZ                                             ; FBBE26  ee 0d
	ret                                                  ; FBBE28  0e
; PartParam_EnterVelocityOffset: the number-entry handler of PartParamField_VelocityOffset (VELOCITY OFFSET), slot PartParamEnter_Ids20to3F[3] (notes/prom_ab_part_param_fields.py)
PartParam_EnterVelocityOffset:
	link XIZ,0x0000                                      ; FBBE29  ee 0c 00 00
	lda xbc, (PartParamField_VelocityOffset:24)                          ; FBBE2D  f2 61 ad f1 31
	push XBC                                             ; FBBE32  39
	push 0x00                                            ; FBBE33  09 00
	push	(xiz+8)                                      ; FBBE35  8e 08 04
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBBE38  1d a8 2c f4
	inc 6,XSP                                            ; FBBE3C  ef 66
	unlk XIZ                                             ; FBBE3E  ee 0d
	ret                                                  ; FBBE40  0e
; PartParam_StepBasicChannel: the adjust handler of PartParamField_BasicChannel (BASIC CHANNEL), slot PartParamStep_Ids20to3F[4] (notes/prom_ab_part_param_fields.py)
PartParam_StepBasicChannel:
	link XIZ,0x0000                                      ; FBBE41  ee 0c 00 00
	lda xbc, (PartParamField_BasicChannel:24)                          ; FBBE45  f2 6a ad f1 31
	push XBC                                             ; FBBE4A  39
	push 0x00                                            ; FBBE4B  09 00
	push	(xiz+8)                                      ; FBBE4D  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBE50  1d 94 2c f4
	inc 6,XSP                                            ; FBBE54  ef 66
	unlk XIZ                                             ; FBBE56  ee 0d
	ret                                                  ; FBBE58  0e
; PartParam_StepKeyLayerLow: KEY LAYER LOW: steps byte 7 of part record E+0x20 with its maximum replaced by byte 8 (the HIGH end), so the pair cannot
;   cross; template PartParamField_KeyLayerLow; PartParamStep_Ids20to3F[5] (notes/prom_ab_part_param_switches.py)
PartParam_StepKeyLayerLow:
	link XIZ,0xfff7                                      ; FBBE59  ee 0c f7 ff
	push XIX                                             ; FBBE5D  3c
	ldw bc, 0x09                                         ; FBBE5E  31 09 00
	lda xiy, (PartParamField_KeyLayerLow:24)                          ; FBBE61  f2 7c aa f1 35
	lda xix, (xiz-9)                                     ; FBBE66  be f7 34
	ldir85                                               ; FBBE69  85 11
	pushw 0x08                                           ; FBBE6B  0b 08 00
	ld BC,(XIZ+0x08)                                     ; FBBE6E  9e 08 21
	extz BC                                              ; FBBE71  d9 12
	add BC,0x0020                                        ; FBBE73  d9 c8 20 00
	pushw bc                                             ; FBBE77  29
	call T_IndexedTable_GetByte                          ; FBBE78  1d 90 2c f4
	ld (xiz-6), a                                        ; FBBE7C  be fa 41
	lda xbc, (xiz-9)                                     ; FBBE7F  be f7 31
	push XBC                                             ; FBBE82  39
	push 0x00                                            ; FBBE83  09 00
	push	(xiz+8)                                      ; FBBE85  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBE88  1d 94 2c f4
	inc 8,XSP                                            ; FBBE8C  ef 60
	inc 2,XSP                                            ; FBBE8E  ef 62
	pop XIX                                              ; FBBE90  5c
	unlk XIZ                                             ; FBBE91  ee 0d
	ret                                                  ; FBBE93  0e
; PartParam_StepKeyLayerHigh: KEY LAYER HIGH: steps byte 8 of part record E+0x20 with its minimum replaced by byte 7 (the LOW end), so the pair cannot
;   cross; template PartParamField_KeyLayerHigh; PartParamStep_Ids20to3F[6] (notes/prom_ab_part_param_switches.py)
PartParam_StepKeyLayerHigh:
	link XIZ,0xfff7                                      ; FBBE94  ee 0c f7 ff
	push XIX                                             ; FBBE98  3c
	ldw bc, 0x09                                         ; FBBE99  31 09 00
	lda xiy, (PartParamField_KeyLayerHigh:24)                          ; FBBE9C  f2 85 aa f1 35
	lda xix, (xiz-9)                                     ; FBBEA1  be f7 34
	ldir85                                               ; FBBEA4  85 11
	pushw 0x07                                           ; FBBEA6  0b 07 00
	ld BC,(XIZ+0x08)                                     ; FBBEA9  9e 08 21
	extz BC                                              ; FBBEAC  d9 12
	add BC,0x0020                                        ; FBBEAE  d9 c8 20 00
	pushw bc                                             ; FBBEB2  29
	call T_IndexedTable_GetByte                          ; FBBEB3  1d 90 2c f4
	ld (xiz-5), a                                        ; FBBEB7  be fb 41
	lda xbc, (xiz-9)                                     ; FBBEBA  be f7 31
	push XBC                                             ; FBBEBD  39
	push 0x00                                            ; FBBEBE  09 00
	push	(xiz+8)                                      ; FBBEC0  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBEC3  1d 94 2c f4
	inc 8,XSP                                            ; FBBEC7  ef 60
	inc 2,XSP                                            ; FBBEC9  ef 62
	pop XIX                                              ; FBBECB  5c
	unlk XIZ                                             ; FBBECC  ee 0d
	ret                                                  ; FBBECE  0e
; PartParam_StepVelocityLayerLow: VELOCITY LAYER LOW: steps byte 9 of part record E+0x20 with its maximum replaced by byte 10 (the HIGH end), so the pair cannot
;   cross; template PartParamField_VelocityLayerLow; PartParamStep_Ids20to3F[7] (notes/prom_ab_part_param_switches.py)
PartParam_StepVelocityLayerLow:
	link XIZ,0xfff7                                      ; FBBECF  ee 0c f7 ff
	push XIX                                             ; FBBED3  3c
	ldw bc, 0x09                                         ; FBBED4  31 09 00
	lda xiy, (PartParamField_VelocityLayerLow:24)                          ; FBBED7  f2 8e aa f1 35
	lda xix, (xiz-9)                                     ; FBBEDC  be f7 34
	ldir85                                               ; FBBEDF  85 11
	pushw 0x0a                                           ; FBBEE1  0b 0a 00
	ld BC,(XIZ+0x08)                                     ; FBBEE4  9e 08 21
	extz BC                                              ; FBBEE7  d9 12
	add BC,0x0020                                        ; FBBEE9  d9 c8 20 00
	pushw bc                                             ; FBBEED  29
	call T_IndexedTable_GetByte                          ; FBBEEE  1d 90 2c f4
	ld (xiz-6), a                                        ; FBBEF2  be fa 41
	lda xbc, (xiz-9)                                     ; FBBEF5  be f7 31
	push XBC                                             ; FBBEF8  39
	push 0x00                                            ; FBBEF9  09 00
	push	(xiz+8)                                      ; FBBEFB  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBEFE  1d 94 2c f4
	inc 8,XSP                                            ; FBBF02  ef 60
	inc 2,XSP                                            ; FBBF04  ef 62
	pop XIX                                              ; FBBF06  5c
	unlk XIZ                                             ; FBBF07  ee 0d
	ret                                                  ; FBBF09  0e
; PartParam_StepVelocityLayerHigh: VELOCITY LAYER HIGH: steps byte 10 of part record E+0x20 with its minimum replaced by byte 9 (the LOW end), so the pair cannot
;   cross; template PartParamField_VelocityLayerHigh; PartParamStep_Ids20to3F[8] (notes/prom_ab_part_param_switches.py)
PartParam_StepVelocityLayerHigh:
	link XIZ,0xfff7                                      ; FBBF0A  ee 0c f7 ff
	push XIX                                             ; FBBF0E  3c
	ldw bc, 0x09                                         ; FBBF0F  31 09 00
	lda xiy, (PartParamField_VelocityLayerHigh:24)                          ; FBBF12  f2 97 aa f1 35
	lda xix, (xiz-9)                                     ; FBBF17  be f7 34
	ldir85                                               ; FBBF1A  85 11
	pushw 0x09                                           ; FBBF1C  0b 09 00
	ld BC,(XIZ+0x08)                                     ; FBBF1F  9e 08 21
	extz BC                                              ; FBBF22  d9 12
	add BC,0x0020                                        ; FBBF24  d9 c8 20 00
	pushw bc                                             ; FBBF28  29
	call T_IndexedTable_GetByte                          ; FBBF29  1d 90 2c f4
	ld (xiz-5), a                                        ; FBBF2D  be fb 41
	lda xbc, (xiz-9)                                     ; FBBF30  be f7 31
	push XBC                                             ; FBBF33  39
	push 0x00                                            ; FBBF34  09 00
	push	(xiz+8)                                      ; FBBF36  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBBF39  1d 94 2c f4
	inc 8,XSP                                            ; FBBF3D  ef 60
	inc 2,XSP                                            ; FBBF3F  ef 62
	pop XIX                                              ; FBBF41  5c
	unlk XIZ                                             ; FBBF42  ee 0d
	ret                                                  ; FBBF44  0e
; PartParam_StepControllerInternalFilterPitchBend: CONTROLLER INTERNAL FILTER: PITCH BEND: forces bit 0x40 of byte 11 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_ControllerInternalFilterPitchBend); PartParamStep_Ids40to5F[0] (notes/prom_ab_part_param_switches.py)
PartParam_StepControllerInternalFilterPitchBend:
	link XIZ,0x0000                                      ; FBBF45  ee 0c 00 00
	lda xbc, (PartParamField_ControllerInternalFilterPitchBend:24)                          ; FBBF49  f2 73 ad f1 31
	push XBC                                             ; FBBF4E  39
	push 0x00                                            ; FBBF4F  09 00
	push	(xiz+8)                                      ; FBBF51  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBF54  1d 98 2c f4
	inc 6,XSP                                            ; FBBF58  ef 66
	unlk XIZ                                             ; FBBF5A  ee 0d
	ret                                                  ; FBBF5C  0e
; PartParam_StepControllerInternalFilterModulation1: CONTROLLER INTERNAL FILTER: MODULATION1: forces bit 0x02 of byte 12 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_ControllerInternalFilterModulation1); PartParamStep_Ids40to5F[1] (notes/prom_ab_part_param_switches.py)
PartParam_StepControllerInternalFilterModulation1:
	link XIZ,0x0000                                      ; FBBF5D  ee 0c 00 00
	lda xbc, (PartParamField_ControllerInternalFilterModulation1:24)                          ; FBBF61  f2 76 ad f1 31
	push XBC                                             ; FBBF66  39
	push 0x00                                            ; FBBF67  09 00
	push	(xiz+8)                                      ; FBBF69  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBF6C  1d 98 2c f4
	inc 6,XSP                                            ; FBBF70  ef 66
	unlk XIZ                                             ; FBBF72  ee 0d
	ret                                                  ; FBBF74  0e
; PartParam_StepControllerInternalFilterModulation2: CONTROLLER INTERNAL FILTER: MODULATION2: forces bit 0x10 of byte 14 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_ControllerInternalFilterModulation2); PartParamStep_Ids40to5F[2] (notes/prom_ab_part_param_switches.py)
PartParam_StepControllerInternalFilterModulation2:
	link XIZ,0x0000                                      ; FBBF75  ee 0c 00 00
	lda xbc, (PartParamField_ControllerInternalFilterModulation2:24)                          ; FBBF79  f2 79 ad f1 31
	push XBC                                             ; FBBF7E  39
	push 0x00                                            ; FBBF7F  09 00
	push	(xiz+8)                                      ; FBBF81  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBF84  1d 98 2c f4
	inc 6,XSP                                            ; FBBF88  ef 66
	unlk XIZ                                             ; FBBF8A  ee 0d
	ret                                                  ; FBBF8C  0e
; PartParam_StepControllerInternalFilterRealTimeCreatorX: CONTROLLER INTERNAL FILTER: REAL-TIME CREATOR-X: forces bit 0x01 of byte 14 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_ControllerInternalFilterRealTimeCreatorX); PartParamStep_Ids40to5F[3] (notes/prom_ab_part_param_switches.py)
PartParam_StepControllerInternalFilterRealTimeCreatorX:
	link XIZ,0x0000                                      ; FBBF8D  ee 0c 00 00
	lda xbc, (PartParamField_ControllerInternalFilterRealTimeCreatorX:24)                          ; FBBF91  f2 7c ad f1 31
	push XBC                                             ; FBBF96  39
	push 0x00                                            ; FBBF97  09 00
	push	(xiz+8)                                      ; FBBF99  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBF9C  1d 98 2c f4
	inc 6,XSP                                            ; FBBFA0  ef 66
	unlk XIZ                                             ; FBBFA2  ee 0d
	ret                                                  ; FBBFA4  0e
; PartParam_StepControllerInternalFilterRealTimeCreatorY: CONTROLLER INTERNAL FILTER: REAL-TIME CREATOR-Y: forces bit 0x02 of byte 14 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_ControllerInternalFilterRealTimeCreatorY); PartParamStep_Ids40to5F[4] (notes/prom_ab_part_param_switches.py)
PartParam_StepControllerInternalFilterRealTimeCreatorY:
	link XIZ,0x0000                                      ; FBBFA5  ee 0c 00 00
	lda xbc, (PartParamField_ControllerInternalFilterRealTimeCreatorY:24)                          ; FBBFA9  f2 7f ad f1 31
	push XBC                                             ; FBBFAE  39
	push 0x00                                            ; FBBFAF  09 00
	push	(xiz+8)                                      ; FBBFB1  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBFB4  1d 98 2c f4
	inc 6,XSP                                            ; FBBFB8  ef 66
	unlk XIZ                                             ; FBBFBA  ee 0d
	ret                                                  ; FBBFBC  0e
; PartParam_StepControllerInternalFilterRealTimeControllerX: CONTROLLER INTERNAL FILTER: REAL-TIME CONTROLLER-X: forces bit 0x04 of byte 14 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_ControllerInternalFilterRealTimeControllerX); PartParamStep_Ids40to5F[5] (notes/prom_ab_part_param_switches.py)
PartParam_StepControllerInternalFilterRealTimeControllerX:
	link XIZ,0x0000                                      ; FBBFBD  ee 0c 00 00
	lda xbc, (PartParamField_ControllerInternalFilterRealTimeControllerX:24)                          ; FBBFC1  f2 82 ad f1 31
	push XBC                                             ; FBBFC6  39
	push 0x00                                            ; FBBFC7  09 00
	push	(xiz+8)                                      ; FBBFC9  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBFCC  1d 98 2c f4
	inc 6,XSP                                            ; FBBFD0  ef 66
	unlk XIZ                                             ; FBBFD2  ee 0d
	ret                                                  ; FBBFD4  0e
; PartParam_StepControllerInternalFilterRealTimeControllerY: CONTROLLER INTERNAL FILTER: REAL-TIME CONTROLLER-Y: forces bit 0x08 of byte 14 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_ControllerInternalFilterRealTimeControllerY); PartParamStep_Ids40to5F[6] (notes/prom_ab_part_param_switches.py)
PartParam_StepControllerInternalFilterRealTimeControllerY:
	link XIZ,0x0000                                      ; FBBFD5  ee 0c 00 00
	lda xbc, (PartParamField_ControllerInternalFilterRealTimeControllerY:24)                          ; FBBFD9  f2 85 ad f1 31
	push XBC                                             ; FBBFDE  39
	push 0x00                                            ; FBBFDF  09 00
	push	(xiz+8)                                      ; FBBFE1  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBFE4  1d 98 2c f4
	inc 6,XSP                                            ; FBBFE8  ef 66
	unlk XIZ                                             ; FBBFEA  ee 0d
	ret                                                  ; FBBFEC  0e
; PartParam_StepControllerInternalFilterHold1: CONTROLLER INTERNAL FILTER: HOLD1: forces bit 0x01 of byte 12 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_ControllerInternalFilterHold1); PartParamStep_Ids40to5F[7] (notes/prom_ab_part_param_switches.py)
PartParam_StepControllerInternalFilterHold1:
	link XIZ,0x0000                                      ; FBBFED  ee 0c 00 00
	lda xbc, (PartParamField_ControllerInternalFilterHold1:24)                          ; FBBFF1  f2 88 ad f1 31
	push XBC                                             ; FBBFF6  39
	push 0x00                                            ; FBBFF7  09 00
	push	(xiz+8)                                      ; FBBFF9  8e 08 04
	call T_IndexedParam_SetBit                           ; FBBFFC  1d 98 2c f4
	inc 6,XSP                                            ; FBC000  ef 66
	unlk XIZ                                             ; FBC002  ee 0d
	ret                                                  ; FBC004  0e
; PartParam_StepControllerInternalFilterControlPedal: CONTROLLER INTERNAL FILTER: CONTROL PEDAL: forces bit 0x20 of byte 14 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_ControllerInternalFilterControlPedal); PartParamStep_Ids40to5F[8] (notes/prom_ab_part_param_switches.py)
PartParam_StepControllerInternalFilterControlPedal:
	link XIZ,0x0000                                      ; FBC005  ee 0c 00 00
	lda xbc, (PartParamField_ControllerInternalFilterControlPedal:24)                          ; FBC009  f2 8b ad f1 31
	push XBC                                             ; FBC00E  39
	push 0x00                                            ; FBC00F  09 00
	push	(xiz+8)                                      ; FBC011  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC014  1d 98 2c f4
	inc 6,XSP                                            ; FBC018  ef 66
	unlk XIZ                                             ; FBC01A  ee 0d
	ret                                                  ; FBC01C  0e
; PartParam_StepControllerInternalFilterAfterTouch: CONTROLLER INTERNAL FILTER: AFTER TOUCH: forces bit 0x20 of byte 11 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_ControllerInternalFilterAfterTouch); PartParamStep_Ids40to5F[9] (notes/prom_ab_part_param_switches.py)
PartParam_StepControllerInternalFilterAfterTouch:
	link XIZ,0x0000                                      ; FBC01D  ee 0c 00 00
	lda xbc, (PartParamField_ControllerInternalFilterAfterTouch:24)                          ; FBC021  f2 8e ad f1 31
	push XBC                                             ; FBC026  39
	push 0x00                                            ; FBC027  09 00
	push	(xiz+8)                                      ; FBC029  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC02C  1d 98 2c f4
	inc 6,XSP                                            ; FBC030  ef 66
	unlk XIZ                                             ; FBC032  ee 0d
	ret                                                  ; FBC034  0e
; PartParam_StepMidiInputFilterProgramChange: MIDI INPUT FILTER: PROGRAM CHANGE: forces bit 0x10 of byte 15 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiInputFilterProgramChange); PartParamStep_Ids60to7F[0] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiInputFilterProgramChange:
	link XIZ,0x0000                                      ; FBC035  ee 0c 00 00
	lda xbc, (PartParamField_MidiInputFilterProgramChange:24)                          ; FBC039  f2 91 ad f1 31
	push XBC                                             ; FBC03E  39
	push 0x00                                            ; FBC03F  09 00
	push	(xiz+8)                                      ; FBC041  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC044  1d 98 2c f4
	inc 6,XSP                                            ; FBC048  ef 66
	unlk XIZ                                             ; FBC04A  ee 0d
	ret                                                  ; FBC04C  0e
; PartParam_StepMidiInputFilterBankSelect: MIDI INPUT FILTER: BANK SELECT: forces bit 0x80 of byte 16 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiInputFilterBankSelect); PartParamStep_Ids60to7F[1] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiInputFilterBankSelect:
	link XIZ,0x0000                                      ; FBC04D  ee 0c 00 00
	lda xbc, (PartParamField_MidiInputFilterBankSelect:24)                          ; FBC051  f2 94 ad f1 31
	push XBC                                             ; FBC056  39
	push 0x00                                            ; FBC057  09 00
	push	(xiz+8)                                      ; FBC059  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC05C  1d 98 2c f4
	inc 6,XSP                                            ; FBC060  ef 66
	unlk XIZ                                             ; FBC062  ee 0d
	ret                                                  ; FBC064  0e
; PartParam_StepMidiInputFilterVolume: MIDI INPUT FILTER: VOLUME: forces bit 0x04 of byte 16 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiInputFilterVolume); PartParamStep_Ids60to7F[2] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiInputFilterVolume:
	link XIZ,0x0000                                      ; FBC065  ee 0c 00 00
	lda xbc, (PartParamField_MidiInputFilterVolume:24)                          ; FBC069  f2 97 ad f1 31
	push XBC                                             ; FBC06E  39
	push 0x00                                            ; FBC06F  09 00
	push	(xiz+8)                                      ; FBC071  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC074  1d 98 2c f4
	inc 6,XSP                                            ; FBC078  ef 66
	unlk XIZ                                             ; FBC07A  ee 0d
	ret                                                  ; FBC07C  0e
; PartParam_StepMidiOutputFilterProgramChange: MIDI OUTPUT FILTER: PROGRAM CHANGE: forces bit 0x10 of byte 19 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterProgramChange); PartParamStep_Ids80to9F[0] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterProgramChange:
	link XIZ,0x0000                                      ; FBC07D  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterProgramChange:24)                          ; FBC081  f2 9a ad f1 31
	push XBC                                             ; FBC086  39
	push 0x00                                            ; FBC087  09 00
	push	(xiz+8)                                      ; FBC089  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC08C  1d 98 2c f4
	inc 6,XSP                                            ; FBC090  ef 66
	unlk XIZ                                             ; FBC092  ee 0d
	ret                                                  ; FBC094  0e
; PartParam_StepMidiOutputFilterBankSelect: MIDI OUTPUT FILTER: BANK SELECT: forces bit 0x80 of byte 20 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterBankSelect); PartParamStep_Ids80to9F[1] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterBankSelect:
	link XIZ,0x0000                                      ; FBC095  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterBankSelect:24)                          ; FBC099  f2 9d ad f1 31
	push XBC                                             ; FBC09E  39
	push 0x00                                            ; FBC09F  09 00
	push	(xiz+8)                                      ; FBC0A1  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC0A4  1d 98 2c f4
	inc 6,XSP                                            ; FBC0A8  ef 66
	unlk XIZ                                             ; FBC0AA  ee 0d
	ret                                                  ; FBC0AC  0e
; PartParam_StepMidiOutputFilterVolume: MIDI OUTPUT FILTER: VOLUME: forces bit 0x04 of byte 20 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterVolume); PartParamStep_Ids80to9F[2] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterVolume:
	link XIZ,0x0000                                      ; FBC0AD  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterVolume:24)                          ; FBC0B1  f2 a0 ad f1 31
	push XBC                                             ; FBC0B6  39
	push 0x00                                            ; FBC0B7  09 00
	push	(xiz+8)                                      ; FBC0B9  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC0BC  1d 98 2c f4
	inc 6,XSP                                            ; FBC0C0  ef 66
	unlk XIZ                                             ; FBC0C2  ee 0d
	ret                                                  ; FBC0C4  0e
; PartParam_StepMidiOutputFilterPanpot: MIDI OUTPUT FILTER: PANPOT: forces bit 0x10 of byte 20 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterPanpot); PartParamStep_Ids80to9F[3] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterPanpot:
	link XIZ,0x0000                                      ; FBC0C5  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterPanpot:24)                          ; FBC0C9  f2 a3 ad f1 31
	push XBC                                             ; FBC0CE  39
	push 0x00                                            ; FBC0CF  09 00
	push	(xiz+8)                                      ; FBC0D1  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC0D4  1d 98 2c f4
	inc 6,XSP                                            ; FBC0D8  ef 66
	unlk XIZ                                             ; FBC0DA  ee 0d
	ret                                                  ; FBC0DC  0e
; PartParam_StepMidiOutputFilterEffectDepth_FBC0DD: MIDI OUTPUT FILTER: EFFECT DEPTH: forces bit 0x20 of byte 20 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterEffectDepth_F1ADA6); PartParamStep_Ids80to9F[4] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterEffectDepth_FBC0DD:
	link XIZ,0x0000                                      ; FBC0DD  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterEffectDepth_F1ADA6:24)                          ; FBC0E1  f2 a6 ad f1 31
	push XBC                                             ; FBC0E6  39
	push 0x00                                            ; FBC0E7  09 00
	push	(xiz+8)                                      ; FBC0E9  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC0EC  1d 98 2c f4
	inc 6,XSP                                            ; FBC0F0  ef 66
	unlk XIZ                                             ; FBC0F2  ee 0d
	ret                                                  ; FBC0F4  0e
; PartParam_StepMidiOutputFilterEffectDepth_FBC0F5: MIDI OUTPUT FILTER: EFFECT DEPTH: forces bit 0x20 of byte 20 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterEffectDepth_F1ADA9); PartParamStep_Ids80to9F[5] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterEffectDepth_FBC0F5:
	link XIZ,0x0000                                      ; FBC0F5  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterEffectDepth_F1ADA9:24)                          ; FBC0F9  f2 a9 ad f1 31
	push XBC                                             ; FBC0FE  39
	push 0x00                                            ; FBC0FF  09 00
	push	(xiz+8)                                      ; FBC101  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC104  1d 98 2c f4
	inc 6,XSP                                            ; FBC108  ef 66
	unlk XIZ                                             ; FBC10A  ee 0d
	ret                                                  ; FBC10C  0e
; PartParam_StepMidiOutKeyTranspose_F1ADAC: the adjust handler of PartParamField_MidiOutKeyTranspose_F1ADAC (MIDI OUT KEY TRANSPOSE), slot PartParamStep_Ids80to9F[6] (notes/prom_ab_part_param_fields.py)
PartParam_StepMidiOutKeyTranspose_F1ADAC:
	link XIZ,0x0000                                      ; FBC10D  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutKeyTranspose_F1ADAC:24)                          ; FBC111  f2 ac ad f1 31
	push XBC                                             ; FBC116  39
	push 0x00                                            ; FBC117  09 00
	push	(xiz+8)                                      ; FBC119  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBC11C  1d 94 2c f4
	inc 6,XSP                                            ; FBC120  ef 66
	unlk XIZ                                             ; FBC122  ee 0d
	ret                                                  ; FBC124  0e
; PartParam_EnterMidiOutKeyTranspose_F1ADAC: the number-entry handler of PartParamField_MidiOutKeyTranspose_F1ADAC (MIDI OUT KEY TRANSPOSE), slot PartParamEnter_Ids80to9F[6] (notes/prom_ab_part_param_fields.py)
PartParam_EnterMidiOutKeyTranspose_F1ADAC:
	link XIZ,0x0000                                      ; FBC125  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutKeyTranspose_F1ADAC:24)                          ; FBC129  f2 ac ad f1 31
	push XBC                                             ; FBC12E  39
	push 0x00                                            ; FBC12F  09 00
	push	(xiz+8)                                      ; FBC131  8e 08 04
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBC134  1d a8 2c f4
	inc 6,XSP                                            ; FBC138  ef 66
	unlk XIZ                                             ; FBC13A  ee 0d
	ret                                                  ; FBC13C  0e
; PartParam_StepMidiOutputFilterPitchBend: MIDI OUTPUT FILTER: PITCH BEND: forces bit 0x40 of byte 19 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterPitchBend); PartParamStep_Ids80to9F[7] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterPitchBend:
	link XIZ,0x0000                                      ; FBC13D  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterPitchBend:24)                          ; FBC141  f2 b5 ad f1 31
	push XBC                                             ; FBC146  39
	push 0x00                                            ; FBC147  09 00
	push	(xiz+8)                                      ; FBC149  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC14C  1d 98 2c f4
	inc 6,XSP                                            ; FBC150  ef 66
	unlk XIZ                                             ; FBC152  ee 0d
	ret                                                  ; FBC154  0e
; PartParam_StepMidiOutputFilterModulation1: MIDI OUTPUT FILTER: MODULATION1: forces bit 0x02 of byte 20 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterModulation1); PartParamStep_Ids80to9F[8] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterModulation1:
	link XIZ,0x0000                                      ; FBC155  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterModulation1:24)                          ; FBC159  f2 b8 ad f1 31
	push XBC                                             ; FBC15E  39
	push 0x00                                            ; FBC15F  09 00
	push	(xiz+8)                                      ; FBC161  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC164  1d 98 2c f4
	inc 6,XSP                                            ; FBC168  ef 66
	unlk XIZ                                             ; FBC16A  ee 0d
	ret                                                  ; FBC16C  0e
; PartParam_StepMidiOutputFilterModulation2: MIDI OUTPUT FILTER: MODULATION2: forces bit 0x10 of byte 22 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterModulation2); PartParamStep_Ids80to9F[9] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterModulation2:
	link XIZ,0x0000                                      ; FBC16D  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterModulation2:24)                          ; FBC171  f2 bb ad f1 31
	push XBC                                             ; FBC176  39
	push 0x00                                            ; FBC177  09 00
	push	(xiz+8)                                      ; FBC179  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC17C  1d 98 2c f4
	inc 6,XSP                                            ; FBC180  ef 66
	unlk XIZ                                             ; FBC182  ee 0d
	ret                                                  ; FBC184  0e
; PartParam_StepMidiOutputFilterRealTimeCreatorX: MIDI OUTPUT FILTER: REAL-TIME CREATOR-X: forces bit 0x01 of byte 22 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterRealTimeCreatorX); PartParamStep_Ids80to9F[10] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterRealTimeCreatorX:
	link XIZ,0x0000                                      ; FBC185  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterRealTimeCreatorX:24)                          ; FBC189  f2 be ad f1 31
	push XBC                                             ; FBC18E  39
	push 0x00                                            ; FBC18F  09 00
	push	(xiz+8)                                      ; FBC191  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC194  1d 98 2c f4
	inc 6,XSP                                            ; FBC198  ef 66
	unlk XIZ                                             ; FBC19A  ee 0d
	ret                                                  ; FBC19C  0e
; PartParam_StepMidiOutputFilterRealTimeCreatorY: MIDI OUTPUT FILTER: REAL-TIME CREATOR-Y: forces bit 0x02 of byte 22 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterRealTimeCreatorY); PartParamStep_Ids80to9F[11] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterRealTimeCreatorY:
	link XIZ,0x0000                                      ; FBC19D  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterRealTimeCreatorY:24)                          ; FBC1A1  f2 c1 ad f1 31
	push XBC                                             ; FBC1A6  39
	push 0x00                                            ; FBC1A7  09 00
	push	(xiz+8)                                      ; FBC1A9  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC1AC  1d 98 2c f4
	inc 6,XSP                                            ; FBC1B0  ef 66
	unlk XIZ                                             ; FBC1B2  ee 0d
	ret                                                  ; FBC1B4  0e
; PartParam_StepMidiOutputFilterRealTimeControllerX: MIDI OUTPUT FILTER: REAL-TIME CONTROLLER-X: forces bit 0x04 of byte 22 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterRealTimeControllerX); PartParamStep_Ids80to9F[12] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterRealTimeControllerX:
	link XIZ,0x0000                                      ; FBC1B5  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterRealTimeControllerX:24)                          ; FBC1B9  f2 c4 ad f1 31
	push XBC                                             ; FBC1BE  39
	push 0x00                                            ; FBC1BF  09 00
	push	(xiz+8)                                      ; FBC1C1  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC1C4  1d 98 2c f4
	inc 6,XSP                                            ; FBC1C8  ef 66
	unlk XIZ                                             ; FBC1CA  ee 0d
	ret                                                  ; FBC1CC  0e
; PartParam_StepMidiOutputFilterRealTimeControllerY: MIDI OUTPUT FILTER: REAL-TIME CONTROLLER-Y: forces bit 0x08 of byte 22 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterRealTimeControllerY); PartParamStep_Ids80to9F[13] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterRealTimeControllerY:
	link XIZ,0x0000                                      ; FBC1CD  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterRealTimeControllerY:24)                          ; FBC1D1  f2 c7 ad f1 31
	push XBC                                             ; FBC1D6  39
	push 0x00                                            ; FBC1D7  09 00
	push	(xiz+8)                                      ; FBC1D9  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC1DC  1d 98 2c f4
	inc 6,XSP                                            ; FBC1E0  ef 66
	unlk XIZ                                             ; FBC1E2  ee 0d
	ret                                                  ; FBC1E4  0e
; PartParam_StepMidiOutputFilterHold1: MIDI OUTPUT FILTER: HOLD1: forces bit 0x01 of byte 20 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterHold1); PartParamStep_Ids80to9F[14] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterHold1:
	link XIZ,0x0000                                      ; FBC1E5  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterHold1:24)                          ; FBC1E9  f2 ca ad f1 31
	push XBC                                             ; FBC1EE  39
	push 0x00                                            ; FBC1EF  09 00
	push	(xiz+8)                                      ; FBC1F1  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC1F4  1d 98 2c f4
	inc 6,XSP                                            ; FBC1F8  ef 66
	unlk XIZ                                             ; FBC1FA  ee 0d
	ret                                                  ; FBC1FC  0e
; PartParam_StepMidiOutputFilterControlPedal: MIDI OUTPUT FILTER: CONTROL PEDAL: forces bit 0x20 of byte 22 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterControlPedal); PartParamStep_Ids80to9F[15] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterControlPedal:
	link XIZ,0x0000                                      ; FBC1FD  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterControlPedal:24)                          ; FBC201  f2 cd ad f1 31
	push XBC                                             ; FBC206  39
	push 0x00                                            ; FBC207  09 00
	push	(xiz+8)                                      ; FBC209  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC20C  1d 98 2c f4
	inc 6,XSP                                            ; FBC210  ef 66
	unlk XIZ                                             ; FBC212  ee 0d
	ret                                                  ; FBC214  0e
; PartParam_StepMidiOutputFilterAfterTouch: MIDI OUTPUT FILTER: AFTER TOUCH: forces bit 0x20 of byte 19 of part record E+0x20 by the step direction (T_IndexedParam_SetBit, PartParamField_MidiOutputFilterAfterTouch); PartParamStep_Ids80to9F[16] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiOutputFilterAfterTouch:
	link XIZ,0x0000                                      ; FBC215  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutputFilterAfterTouch:24)                          ; FBC219  f2 d0 ad f1 31
	push XBC                                             ; FBC21E  39
	push 0x00                                            ; FBC21F  09 00
	push	(xiz+8)                                      ; FBC221  8e 08 04
	call T_IndexedParam_SetBit                           ; FBC224  1d 98 2c f4
	inc 6,XSP                                            ; FBC228  ef 66
	unlk XIZ                                             ; FBC22A  ee 0d
	ret                                                  ; FBC22C  0e
; PartParam_StepMultipleMessagesOutputItem(part, 0, offset, bit): the common stepper of a MULTIPLE
;   MESSAGES OUTPUT item.  Index = 0 when bit <bit> of byte 0x15 is set, 1 when the byte at <offset> has bit
;   7, else byte+2; stepped within PartParamField_MidiMultipleMessagesOutputProgramChange's 0..129 (T_EditValue_StepBitField)
;   and written back the same way, both bytes posted to Queue2C00 (notes/prom_ab_part_param_switches.py)
PartParam_StepMultipleMessagesOutputItem:
	link XIZ,0xfff3                                      ; FBC22D  ee 0c f3 ff
	pushw hl                                             ; FBC231  2b
	pushw de                                             ; FBC232  2a
	push XIX                                             ; FBC233  3c
	ld E,(XIZ+0x0a)                                      ; FBC234  8e 0a 25
	ld D,(XIZ+0x0c)                                      ; FBC237  8e 0c 24
	push 0x00                                            ; FBC23A  09 00
	push	(xiz+8)                                      ; FBC23C  8e 08 04
	call T_IndexedTable_GetPtr                           ; FBC23F  1d 8c 2c f4
	ld (xiz-5), xiy                                      ; FBC243  be fb 65
	ld C,E                                               ; FBC246  cd 8b
	extz BC                                              ; FBC248  d9 12
	extz XBC                                             ; FBC24A  e9 12
	ld (xiz-9), xbc                                      ; FBC24C  be f7 61
	add XIY,XBC                                          ; FBC24F  e9 85
	ld (xiz-13), xiy                                     ; FBC251  be f3 65
	ld A,(XIY)                                           ; FBC254  85 21
	res 0x07,A                                           ; FBC256  c9 30 07
	inc 2,A                                              ; FBC259  c9 62
	ld (xiz-1), a                                        ; FBC25B  be ff 41
	ld W,(XIY)                                           ; FBC25E  85 20
	ld H,W                                               ; FBC260  c8 8e
	and H,0x80                                           ; FBC262  ce cc 80
	ld XWA,0x00000015                                    ; FBC265  40 15 00 00 00
	sub XWA,XBC                                          ; FBC26A  e9 a0
	ld XIX,XIY                                           ; FBC26C  ed 8c
	add XIX,XWA                                          ; FBC26E  e8 84
	popw bc                                              ; FBC270  49
	cp h, 0x00:i3                                          ; FBC271  ce d8
	jr z, .LFBC27B                                       ; FBC273  66 06
	ld (xiz-1), 0x01                                     ; FBC275  be ff 00 01
	jr .LFBC285                                          ; FBC279  68 0a
.LFBC27B:
	ld C,(XIX)                                           ; FBC27B  84 23
	and C,D                                              ; FBC27D  cc c3
	jr z, .LFBC285                                       ; FBC27F  66 04
	ld (xiz-1), 0x00                                     ; FBC281  be ff 00 00
.LFBC285:
	lda xbc, (PartParamField_MidiMultipleMessagesOutputProgramChange:24)                          ; FBC285  f2 d3 ad f1 31
	push XBC                                             ; FBC28A  39
	lda xwa, (xiz-1)                                     ; FBC28B  be ff 30
	push XWA                                             ; FBC28E  38
	call T_EditValue_StepBitField                                        ; FBC28F  1d 78 2c f4
	inc 8,XSP                                            ; FBC293  ef 60
	cp a, 0x01:i3                                          ; FBC295  c9 d9
	jr nz, .LFBC2F9                                      ; FBC297  6e 60
	cp	(xiz-1), 0x00                                ; FBC299  8e ff 3f 00
	jr nz, .LFBC2A5                                      ; FBC29D  6e 06
	ld h, 0x00:opc                                          ; FBC29F  26 00
	ld L,D                                               ; FBC2A1  cc 8f
	jr .LFBC2B4                                          ; FBC2A3  68 0f
.LFBC2A5:
	ld h, (xiz-1)                                        ; FBC2A5  8e ff 26
	dec 2,H                                              ; FBC2A8  ce 6a
	cp	(xiz-1), 0x01                                ; FBC2AA  8e ff 3f 01
	jr nz, .LFBC2B2                                      ; FBC2AE  6e 02
	ld h, 0x80:opc                                          ; FBC2B0  26 80
.LFBC2B2:
	ld l, 0x00:opc                                          ; FBC2B2  27 00
.LFBC2B4:
	ld C,D                                               ; FBC2B4  cc 8b
	cpl C                                                ; FBC2B6  cb 06
	and (XIX),C                                          ; FBC2B8  84 cb
	ld C,(XIX)                                           ; FBC2BA  84 23
	or C,L                                               ; FBC2BC  cf e3
	ld (XIX),C                                           ; FBC2BE  b4 43
	ld C,E                                               ; FBC2C0  cd 8b
	extz BC                                              ; FBC2C2  d9 12
	extz XBC                                             ; FBC2C4  e9 12
	ld XWA,0x00000015                                    ; FBC2C6  40 15 00 00 00
	sub XWA,XBC                                          ; FBC2CB  e9 a0
	ld XBC,XIX                                           ; FBC2CD  ec 89
	sub XBC,XWA                                          ; FBC2CF  e8 a1
	ld (XBC),H                                           ; FBC2D1  b1 46
	pushw 0xff                                           ; FBC2D3  0b ff 00
	push 0x00                                            ; FBC2D6  09 00
	push H                                               ; FBC2D8  ce 04
	pushw de                                             ; FBC2DA  2a
	push 0x00                                            ; FBC2DB  09 00
	push	(xiz+8)                                      ; FBC2DD  8e 08 04
	call T_Queue2C00_Append4                             ; FBC2E0  1d 80 2c f4
	push 0x00                                            ; FBC2E4  09 00
	push D                                               ; FBC2E6  cc 04
	pushw hl                                             ; FBC2E8  2b
	pushw 0x15                                           ; FBC2E9  0b 15 00
	push 0x00                                            ; FBC2EC  09 00
	push	(xiz+8)                                      ; FBC2EE  8e 08 04
	call T_Queue2C00_Append4                             ; FBC2F1  1d 80 2c f4
	inc 8,XSP                                            ; FBC2F5  ef 60
	inc 8,XSP                                            ; FBC2F7  ef 60
.LFBC2F9:
	pop XIX                                              ; FBC2F9  5c
	popw de                                              ; FBC2FA  4a
	popw hl                                              ; FBC2FB  4b
	unlk XIZ                                             ; FBC2FC  ee 0d
	ret                                                  ; FBC2FE  0e
; PartParam_StepMidiMultipleMessagesOutputProgramChange: MULTIPLE MESSAGES OUTPUT ProgramChange: PartParam_StepMultipleMessagesOutputItem on byte 14, enable bit 0x01 of
;   byte 0x15; PartParamStep_IdsA0toBF[0] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiMultipleMessagesOutputProgramChange:
	link XIZ,0x0000                                      ; FBC2FF  ee 0c 00 00
	pushw 0x01                                           ; FBC303  0b 01 00
	pushw 0x0e                                           ; FBC306  0b 0e 00
	push 0x00                                            ; FBC309  09 00
	push	(xiz+8)                                      ; FBC30B  8e 08 04
	calr PartParam_StepMultipleMessagesOutputItem                                      ; FBC30E  1e 1c ff
	inc 6,XSP                                            ; FBC311  ef 66
	unlk XIZ                                             ; FBC313  ee 0d
	ret                                                  ; FBC315  0e
; PartParam_EnterMidiMultipleMessagesOutputProgramChange: MULTIPLE MESSAGES OUTPUT ProgramChange: number entry into PartParamField_MidiMultipleMessagesOutputProgramChangeValue; PartParamEnter_IdsA0toBF[0] (notes/prom_ab_part_param_switches.py)
PartParam_EnterMidiMultipleMessagesOutputProgramChange:
	link XIZ,0x0000                                      ; FBC316  ee 0c 00 00
	pushw hl                                             ; FBC31A  2b
	ld L,(XIZ+0x08)                                      ; FBC31B  8e 08 27
	lda xbc, (PartParamField_MidiMultipleMessagesOutputProgramChangeValue:24)                          ; FBC31E  f2 dc ad f1 31
	push XBC                                             ; FBC323  39
	pushw hl                                             ; FBC324  2b
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBC325  1d a8 2c f4
	ld H,A                                               ; FBC329  c9 8e
	inc 6,XSP                                            ; FBC32B  ef 66
	cp a, 0x01:i3                                          ; FBC32D  c9 d9
	jr nz, .LFBC34C                                      ; FBC32F  6e 1b
	pushw hl                                             ; FBC331  2b
	call T_IndexedTable_GetPtr                           ; FBC332  1d 8c 2c f4
	and (XIY+0x15),0xfe                                  ; FBC336  8d 15 3c fe
	pushw 0x01                                           ; FBC33A  0b 01 00
	pushw 0x00                                           ; FBC33D  0b 00 00
	pushw 0x15                                           ; FBC340  0b 15 00
	pushw hl                                             ; FBC343  2b
	call T_Queue2C00_Append4                             ; FBC344  1d 80 2c f4
	inc 8,XSP                                            ; FBC348  ef 60
	inc 2,XSP                                            ; FBC34A  ef 62
.LFBC34C:
	ld A,H                                               ; FBC34C  ce 89
	popw hl                                              ; FBC34E  4b
	unlk XIZ                                             ; FBC34F  ee 0d
	ret                                                  ; FBC351  0e
; PartParam_StepMidiMultipleMessagesOutputBankSelectMsb: MULTIPLE MESSAGES OUTPUT BankSelectMsb: T_IndexedParam_AdjustField on PartParamField_MidiMultipleMessagesOutputBankSelectMsbValue, only while byte 15 holds a value (bit 7 clear) and BANK SELECT's enable bit 0x20 of byte 0x15 is clear; PartParamStep_IdsA0toBF[1] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiMultipleMessagesOutputBankSelectMsb:
	link XIZ,0x0000                                      ; FBC352  ee 0c 00 00
	push XIX                                             ; FBC356  3c
	push 0x00                                            ; FBC357  09 00
	push	(xiz+8)                                      ; FBC359  8e 08 04
	call T_IndexedTable_GetPtr                           ; FBC35C  1d 8c 2c f4
	ld XIX,XIY                                           ; FBC360  ed 8c
	add XIY,0x0000000f                                   ; FBC362  ed c8 0f 00 00 00
	ld XIX,XIY                                           ; FBC368  ed 8c
	ld C,(XIY)                                           ; FBC36A  85 23
	and C,0x80                                           ; FBC36C  cb cc 80
	popw wa                                              ; FBC36F  48
	jr nz, .LFBC38B                                      ; FBC370  6e 19
	ld C,(XIY+0x06)                                      ; FBC372  8d 06 23
	and C,0x20                                           ; FBC375  cb cc 20
	jr nz, .LFBC38B                                      ; FBC378  6e 11
	lda xbc, (PartParamField_MidiMultipleMessagesOutputBankSelectMsbValue:24)                          ; FBC37A  f2 e5 ad f1 31
	push XBC                                             ; FBC37F  39
	push 0x00                                            ; FBC380  09 00
	push	(xiz+8)                                      ; FBC382  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBC385  1d 94 2c f4
	inc 6,XSP                                            ; FBC389  ef 66
.LFBC38B:
	pop XIX                                              ; FBC38B  5c
	unlk XIZ                                             ; FBC38C  ee 0d
	ret                                                  ; FBC38E  0e
; PartParam_EnterMidiMultipleMessagesOutputBankSelectMsb: MULTIPLE MESSAGES OUTPUT BankSelectMsb: number entry into PartParamField_MidiMultipleMessagesOutputBankSelectMsbValue, only while byte 15 holds a value (bit 7 clear) and BANK SELECT's enable bit 0x20 of byte 0x15 is clear; PartParamEnter_IdsA0toBF[1] (notes/prom_ab_part_param_switches.py)
PartParam_EnterMidiMultipleMessagesOutputBankSelectMsb:
	link XIZ,0x0000                                      ; FBC38F  ee 0c 00 00
	push XIX                                             ; FBC393  3c
	push 0x00                                            ; FBC394  09 00
	push	(xiz+8)                                      ; FBC396  8e 08 04
	call T_IndexedTable_GetPtr                           ; FBC399  1d 8c 2c f4
	ld XIX,XIY                                           ; FBC39D  ed 8c
	add XIY,0x0000000f                                   ; FBC39F  ed c8 0f 00 00 00
	ld XIX,XIY                                           ; FBC3A5  ed 8c
	ld C,(XIY)                                           ; FBC3A7  85 23
	and C,0x80                                           ; FBC3A9  cb cc 80
	popw wa                                              ; FBC3AC  48
	jr nz, .LFBC3CA                                      ; FBC3AD  6e 1b
	ld C,(XIY+0x06)                                      ; FBC3AF  8d 06 23
	and C,0x20                                           ; FBC3B2  cb cc 20
	jr nz, .LFBC3CA                                      ; FBC3B5  6e 13
	lda xbc, (PartParamField_MidiMultipleMessagesOutputBankSelectMsbValue:24)                          ; FBC3B7  f2 e5 ad f1 31
	push XBC                                             ; FBC3BC  39
	push 0x00                                            ; FBC3BD  09 00
	push	(xiz+8)                                      ; FBC3BF  8e 08 04
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBC3C2  1d a8 2c f4
	inc 6,XSP                                            ; FBC3C6  ef 66
	jr .LFBC3D4                                          ; FBC3C8  68 0a
.LFBC3CA:
	pushw 0x00                                           ; FBC3CA  0b 00 00
	call T_Blink_SetEnable                               ; FBC3CD  1d 28 2e f4
	popw bc                                              ; FBC3D1  49
	sub A,A                                              ; FBC3D2  c9 a1
.LFBC3D4:
	pop XIX                                              ; FBC3D4  5c
	unlk XIZ                                             ; FBC3D5  ee 0d
	ret                                                  ; FBC3D7  0e
; PartParam_StepMidiMultipleMessagesOutputBankSelectLsb: MULTIPLE MESSAGES OUTPUT BankSelectLsb: PartParam_StepMultipleMessagesOutputItem on byte 15, enable bit 0x20 of
;   byte 0x15; PartParamStep_IdsA0toBF[2] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiMultipleMessagesOutputBankSelectLsb:
	link XIZ,0x0000                                      ; FBC3D8  ee 0c 00 00
	pushw 0x20                                           ; FBC3DC  0b 20 00
	pushw 0x0f                                           ; FBC3DF  0b 0f 00
	push 0x00                                            ; FBC3E2  09 00
	push	(xiz+8)                                      ; FBC3E4  8e 08 04
	calr PartParam_StepMultipleMessagesOutputItem                                      ; FBC3E7  1e 43 fe
	inc 6,XSP                                            ; FBC3EA  ef 66
	unlk XIZ                                             ; FBC3EC  ee 0d
	ret                                                  ; FBC3EE  0e
; PartParam_EnterMidiMultipleMessagesOutputBankSelectLsb: MULTIPLE MESSAGES OUTPUT BankSelectLsb: number entry into PartParamField_MidiMultipleMessagesOutputBankSelectLsbValue; PartParamEnter_IdsA0toBF[2] (notes/prom_ab_part_param_switches.py)
PartParam_EnterMidiMultipleMessagesOutputBankSelectLsb:
	link XIZ,0x0000                                      ; FBC3EF  ee 0c 00 00
	pushw hl                                             ; FBC3F3  2b
	ld L,(XIZ+0x08)                                      ; FBC3F4  8e 08 27
	lda xbc, (PartParamField_MidiMultipleMessagesOutputBankSelectLsbValue:24)                          ; FBC3F7  f2 ee ad f1 31
	push XBC                                             ; FBC3FC  39
	pushw hl                                             ; FBC3FD  2b
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBC3FE  1d a8 2c f4
	ld H,A                                               ; FBC402  c9 8e
	inc 6,XSP                                            ; FBC404  ef 66
	cp a, 0x01:i3                                          ; FBC406  c9 d9
	jr nz, .LFBC425                                      ; FBC408  6e 1b
	pushw hl                                             ; FBC40A  2b
	call T_IndexedTable_GetPtr                           ; FBC40B  1d 8c 2c f4
	and (XIY+0x15),0xdf                                  ; FBC40F  8d 15 3c df
	pushw 0x20                                           ; FBC413  0b 20 00
	pushw 0x00                                           ; FBC416  0b 00 00
	pushw 0x15                                           ; FBC419  0b 15 00
	pushw hl                                             ; FBC41C  2b
	call T_Queue2C00_Append4                             ; FBC41D  1d 80 2c f4
	inc 8,XSP                                            ; FBC421  ef 60
	inc 2,XSP                                            ; FBC423  ef 62
.LFBC425:
	ld A,H                                               ; FBC425  ce 89
	popw hl                                              ; FBC427  4b
	unlk XIZ                                             ; FBC428  ee 0d
	ret                                                  ; FBC42A  0e
; PartParam_StepMidiMultipleMessagesOutputVolume: MULTIPLE MESSAGES OUTPUT Volume: PartParam_StepMultipleMessagesOutputItem on byte 17, enable bit 0x02 of
;   byte 0x15; PartParamStep_IdsA0toBF[3] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiMultipleMessagesOutputVolume:
	link XIZ,0x0000                                      ; FBC42B  ee 0c 00 00
	pushw 0x02                                           ; FBC42F  0b 02 00
	pushw 0x11                                           ; FBC432  0b 11 00
	push 0x00                                            ; FBC435  09 00
	push	(xiz+8)                                      ; FBC437  8e 08 04
	calr PartParam_StepMultipleMessagesOutputItem                                      ; FBC43A  1e f0 fd
	inc 6,XSP                                            ; FBC43D  ef 66
	unlk XIZ                                             ; FBC43F  ee 0d
	ret                                                  ; FBC441  0e
; PartParam_EnterMidiMultipleMessagesOutputVolume: MULTIPLE MESSAGES OUTPUT Volume: number entry into PartParamField_MidiMultipleMessagesOutputVolumeValue; PartParamEnter_IdsA0toBF[3] (notes/prom_ab_part_param_switches.py)
PartParam_EnterMidiMultipleMessagesOutputVolume:
	link XIZ,0x0000                                      ; FBC442  ee 0c 00 00
	pushw hl                                             ; FBC446  2b
	ld L,(XIZ+0x08)                                      ; FBC447  8e 08 27
	lda xbc, (PartParamField_MidiMultipleMessagesOutputVolumeValue:24)                          ; FBC44A  f2 f7 ad f1 31
	push XBC                                             ; FBC44F  39
	pushw hl                                             ; FBC450  2b
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBC451  1d a8 2c f4
	ld H,A                                               ; FBC455  c9 8e
	inc 6,XSP                                            ; FBC457  ef 66
	cp a, 0x01:i3                                          ; FBC459  c9 d9
	jr nz, .LFBC478                                      ; FBC45B  6e 1b
	pushw hl                                             ; FBC45D  2b
	call T_IndexedTable_GetPtr                           ; FBC45E  1d 8c 2c f4
	and (XIY+0x15),0xfd                                  ; FBC462  8d 15 3c fd
	pushw 0x02                                           ; FBC466  0b 02 00
	pushw 0x00                                           ; FBC469  0b 00 00
	pushw 0x15                                           ; FBC46C  0b 15 00
	pushw hl                                             ; FBC46F  2b
	call T_Queue2C00_Append4                             ; FBC470  1d 80 2c f4
	inc 8,XSP                                            ; FBC474  ef 60
	inc 2,XSP                                            ; FBC476  ef 62
.LFBC478:
	ld A,H                                               ; FBC478  ce 89
	popw hl                                              ; FBC47A  4b
	unlk XIZ                                             ; FBC47B  ee 0d
	ret                                                  ; FBC47D  0e
; PartParam_StepMidiMultipleMessagesOutputPanpot: MULTIPLE MESSAGES OUTPUT Panpot: PartParam_StepMultipleMessagesOutputItem on byte 18, enable bit 0x04 of
;   byte 0x15; PartParamStep_IdsA0toBF[4] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiMultipleMessagesOutputPanpot:
	link XIZ,0x0000                                      ; FBC47E  ee 0c 00 00
	pushw 0x04                                           ; FBC482  0b 04 00
	pushw 0x12                                           ; FBC485  0b 12 00
	push 0x00                                            ; FBC488  09 00
	push	(xiz+8)                                      ; FBC48A  8e 08 04
	calr PartParam_StepMultipleMessagesOutputItem                                      ; FBC48D  1e 9d fd
	inc 6,XSP                                            ; FBC490  ef 66
	unlk XIZ                                             ; FBC492  ee 0d
	ret                                                  ; FBC494  0e
; PartParam_StepMidiMultipleMessagesOutputReverbDepth: MULTIPLE MESSAGES OUTPUT ReverbDepth: PartParam_StepMultipleMessagesOutputItem on byte 20, enable bit 0x10 of
;   byte 0x15; PartParamStep_IdsA0toBF[5] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiMultipleMessagesOutputReverbDepth:
	link XIZ,0x0000                                      ; FBC495  ee 0c 00 00
	pushw 0x10                                           ; FBC499  0b 10 00
	pushw 0x14                                           ; FBC49C  0b 14 00
	push 0x00                                            ; FBC49F  09 00
	push	(xiz+8)                                      ; FBC4A1  8e 08 04
	calr PartParam_StepMultipleMessagesOutputItem                                      ; FBC4A4  1e 86 fd
	inc 6,XSP                                            ; FBC4A7  ef 66
	unlk XIZ                                             ; FBC4A9  ee 0d
	ret                                                  ; FBC4AB  0e
; PartParam_EnterMidiMultipleMessagesOutputReverbDepth: MULTIPLE MESSAGES OUTPUT ReverbDepth: number entry into PartParamField_MidiMultipleMessagesOutputReverbDepthValue; PartParamEnter_IdsA0toBF[5] (notes/prom_ab_part_param_switches.py)
PartParam_EnterMidiMultipleMessagesOutputReverbDepth:
	link XIZ,0x0000                                      ; FBC4AC  ee 0c 00 00
	pushw hl                                             ; FBC4B0  2b
	ld L,(XIZ+0x08)                                      ; FBC4B1  8e 08 27
	lda xbc, (PartParamField_MidiMultipleMessagesOutputReverbDepthValue:24)                          ; FBC4B4  f2 00 ae f1 31
	push XBC                                             ; FBC4B9  39
	pushw hl                                             ; FBC4BA  2b
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBC4BB  1d a8 2c f4
	ld H,A                                               ; FBC4BF  c9 8e
	inc 6,XSP                                            ; FBC4C1  ef 66
	cp a, 0x01:i3                                          ; FBC4C3  c9 d9
	jr nz, .LFBC4E2                                      ; FBC4C5  6e 1b
	pushw hl                                             ; FBC4C7  2b
	call T_IndexedTable_GetPtr                           ; FBC4C8  1d 8c 2c f4
	and (XIY+0x15),0xef                                  ; FBC4CC  8d 15 3c ef
	pushw 0x10                                           ; FBC4D0  0b 10 00
	pushw 0x00                                           ; FBC4D3  0b 00 00
	pushw 0x15                                           ; FBC4D6  0b 15 00
	pushw hl                                             ; FBC4D9  2b
	call T_Queue2C00_Append4                             ; FBC4DA  1d 80 2c f4
	inc 8,XSP                                            ; FBC4DE  ef 60
	inc 2,XSP                                            ; FBC4E0  ef 62
.LFBC4E2:
	ld A,H                                               ; FBC4E2  ce 89
	popw hl                                              ; FBC4E4  4b
	unlk XIZ                                             ; FBC4E5  ee 0d
	ret                                                  ; FBC4E7  0e
; PartParam_StepMidiMultipleMessagesOutputChorusDepth: MULTIPLE MESSAGES OUTPUT ChorusDepth: PartParam_StepMultipleMessagesOutputItem on byte 19, enable bit 0x08 of
;   byte 0x15; PartParamStep_IdsA0toBF[6] (notes/prom_ab_part_param_switches.py)
PartParam_StepMidiMultipleMessagesOutputChorusDepth:
	link XIZ,0x0000                                      ; FBC4E8  ee 0c 00 00
	pushw 0x08                                           ; FBC4EC  0b 08 00
	pushw 0x13                                           ; FBC4EF  0b 13 00
	push 0x00                                            ; FBC4F2  09 00
	push	(xiz+8)                                      ; FBC4F4  8e 08 04
	calr PartParam_StepMultipleMessagesOutputItem                                      ; FBC4F7  1e 33 fd
	inc 6,XSP                                            ; FBC4FA  ef 66
	unlk XIZ                                             ; FBC4FC  ee 0d
	ret                                                  ; FBC4FE  0e
; PartParam_EnterMidiMultipleMessagesOutputChorusDepth: MULTIPLE MESSAGES OUTPUT ChorusDepth: number entry into PartParamField_MidiMultipleMessagesOutputChorusDepthValue; PartParamEnter_IdsA0toBF[6] (notes/prom_ab_part_param_switches.py)
PartParam_EnterMidiMultipleMessagesOutputChorusDepth:
	link XIZ,0x0000                                      ; FBC4FF  ee 0c 00 00
	pushw hl                                             ; FBC503  2b
	ld L,(XIZ+0x08)                                      ; FBC504  8e 08 27
	lda xbc, (PartParamField_MidiMultipleMessagesOutputChorusDepthValue:24)                          ; FBC507  f2 09 ae f1 31
	push XBC                                             ; FBC50C  39
	pushw hl                                             ; FBC50D  2b
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBC50E  1d a8 2c f4
	ld H,A                                               ; FBC512  c9 8e
	inc 6,XSP                                            ; FBC514  ef 66
	cp a, 0x01:i3                                          ; FBC516  c9 d9
	jr nz, .LFBC535                                      ; FBC518  6e 1b
	pushw hl                                             ; FBC51A  2b
	call T_IndexedTable_GetPtr                           ; FBC51B  1d 8c 2c f4
	and (XIY+0x15),0xf7                                  ; FBC51F  8d 15 3c f7
	pushw 0x08                                           ; FBC523  0b 08 00
	pushw 0x00                                           ; FBC526  0b 00 00
	pushw 0x15                                           ; FBC529  0b 15 00
	pushw hl                                             ; FBC52C  2b
	call T_Queue2C00_Append4                             ; FBC52D  1d 80 2c f4
	inc 8,XSP                                            ; FBC531  ef 60
	inc 2,XSP                                            ; FBC533  ef 62
.LFBC535:
	ld A,H                                               ; FBC535  ce 89
	popw hl                                              ; FBC537  4b
	unlk XIZ                                             ; FBC538  ee 0d
	ret                                                  ; FBC53A  0e
; PartParam_StepMidiOutKeyTranspose_F1AE12: the adjust handler of PartParamField_MidiOutKeyTranspose_F1AE12 (MIDI OUT KEY TRANSPOSE), slot PartParamStep_IdsA0toBF[7] (notes/prom_ab_part_param_fields.py)
PartParam_StepMidiOutKeyTranspose_F1AE12:
	link XIZ,0x0000                                      ; FBC53B  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutKeyTranspose_F1AE12:24)                          ; FBC53F  f2 12 ae f1 31
	push XBC                                             ; FBC544  39
	push 0x00                                            ; FBC545  09 00
	push	(xiz+8)                                      ; FBC547  8e 08 04
	call T_IndexedParam_AdjustField                      ; FBC54A  1d 94 2c f4
	inc 6,XSP                                            ; FBC54E  ef 66
	unlk XIZ                                             ; FBC550  ee 0d
	ret                                                  ; FBC552  0e
; PartParam_EnterMidiOutKeyTranspose_F1AE12: the number-entry handler of PartParamField_MidiOutKeyTranspose_F1AE12 (MIDI OUT KEY TRANSPOSE), slot PartParamEnter_IdsA0toBF[7] (notes/prom_ab_part_param_fields.py)
PartParam_EnterMidiOutKeyTranspose_F1AE12:
	link XIZ,0x0000                                      ; FBC553  ee 0c 00 00
	lda xbc, (PartParamField_MidiOutKeyTranspose_F1AE12:24)                          ; FBC557  f2 12 ae f1 31
	push XBC                                             ; FBC55C  39
	push 0x00                                            ; FBC55D  09 00
	push	(xiz+8)                                      ; FBC55F  8e 08 04
	call T_IndexedParam_SetFieldFromAsciiEntry           ; FBC562  1d a8 2c f4
	inc 6,XSP                                            ; FBC566  ef 66
	unlk XIZ                                             ; FBC568  ee 0d
	ret                                                  ; FBC56A  0e
; ScreenEnter_CombiEditConfigure_B2: the +0 ENTER method of the screen object for screen id 0xB2 -- PanelScreen_VtableTable entry 0xD2
;   (ViewB entry 0xB2) points at the thunk triple starting at T_ScreenEnter_CombiEditConfigure_B2, and slot T_ScreenEnter_CombiEditConfigure_B2 jumps here.
ScreenEnter_CombiEditConfigure_B2:
	calr ScreenEnterBody_CombiEditConfigure_Call                                          ; FBC56B  1e 70 2d
	ret                                                  ; FBC56E  0e
; ScreenLeave_CombiEditConfigure_B2: the +4 LEAVE method of the screen object for screen id 0xB2 -- PanelScreen_VtableTable entry 0xD2
;   (ViewB entry 0xB2) points at the thunk triple starting at T_ScreenEnter_CombiEditConfigure_B2, and slot T_ScreenLeave_CombiEditConfigure_B2 jumps here.
ScreenLeave_CombiEditConfigure_B2:
	calr ScreenLeaveBody_CombiEditConfigure_Call                                          ; FBC56F  1e b0 2e
	ret                                                  ; FBC572  0e
; ScreenButton_CombiEditConfigure_B2: the +8 BUTTON method of the screen object for screen id 0xB2 -- PanelScreen_VtableTable entry 0xD2
;   (ViewB entry 0xB2) points at the thunk triple starting at T_ScreenEnter_CombiEditConfigure_B2, and slot T_ScreenButton_CombiEditConfigure_B2 jumps here.
ScreenButton_CombiEditConfigure_B2:
	link XIZ,0x0000                                      ; FBC573  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBC577  9e 0a 04
	pushw	(xiz+8)                                      ; FBC57A  9e 08 04
	calr ScreenButtonBody_CombiEditConfigure_Call                                          ; FBC57D  1e c2 2e
	pop XBC                                              ; FBC580  59
	unlk XIZ                                             ; FBC581  ee 0d
	ret                                                  ; FBC583  0e
T_F41874_Nop:
	ret                                                  ; FBC584  0e
; ScreenEnter_CombiEditConfigure_35: the +0 ENTER method of the screen object for screen id 0x35 -- PanelScreen_VtableTable entry 0x55
;   (ViewB entry 0x35) points at the thunk triple starting at T_F41A28, and slot T_F41A28 jumps here.
ScreenEnter_CombiEditConfigure_35:
	calr ScreenEnterBody_CombiEditConfigure                                          ; FBC585  1e 5a 2d
	ret                                                  ; FBC588  0e
; ScreenLeave_CombiEditConfigure_35: the +4 LEAVE method of the screen object for screen id 0x35 -- PanelScreen_VtableTable entry 0x55
;   (ViewB entry 0x35) points at the thunk triple starting at T_F41A28, and slot T_F41A2C jumps here.
ScreenLeave_CombiEditConfigure_35:
	calr ScreenLeaveBody_CombiEditConfigure                                          ; FBC589  1e 9a 2e
	ret                                                  ; FBC58C  0e
; ScreenButton_CombiEditConfigure_35: the +8 BUTTON method of the screen object for screen id 0x35 -- PanelScreen_VtableTable entry 0x55
;   (ViewB entry 0x35) points at the thunk triple starting at T_F41A28, and slot T_F41A30 jumps here.
ScreenButton_CombiEditConfigure_35:
	link XIZ,0x0000                                      ; FBC58D  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBC591  9e 0a 04
	pushw	(xiz+8)                                      ; FBC594  9e 08 04
	calr ScreenButtonBody_CombiEditConfigure                                          ; FBC597  1e b9 2e
	pop XBC                                              ; FBC59A  59
	unlk XIZ                                             ; FBC59B  ee 0d
	ret                                                  ; FBC59D  0e
T_F41A34_Nop:
	ret                                                  ; FBC59E  0e
; ScreenEnter_CombinationNaming: the +0 ENTER method of the screen object for screen id 0x36 -- PanelScreen_VtableTable entry 0x56
;   (ViewB entry 0x36) points at the thunk triple starting at T_ScreenEnter_CombinationNaming, and slot T_ScreenEnter_CombinationNaming jumps here.
; ScreenEnter_CombinationNaming: screen 0x36's +0 ENTER.  0x36 is COMBINATION NAMING: its body ScreenEnterBody_CombinationNaming
;   calls Paint_CombinationNamingWrite, which runs DL_CombinationNaming_F19BE5 ("COMBI.EDIT" / "COMBINATION NAMING" / "WRITE").
ScreenEnter_CombinationNaming:
	calr ScreenEnterBody_CombinationNaming                                          ; FBC59F  1e e9 2b
	ret                                                  ; FBC5A2  0e
; ScreenLeave_CombinationNaming: the +4 LEAVE method of the screen object for screen id 0x36 -- PanelScreen_VtableTable entry 0x56
;   (ViewB entry 0x36) points at the thunk triple starting at T_ScreenEnter_CombinationNaming, and slot T_ScreenLeave_CombinationNaming jumps here.
ScreenLeave_CombinationNaming:
	calr ScreenLeaveBody_CombinationNaming                                          ; FBC5A3  1e 59 2c
	ret                                                  ; FBC5A6  0e
; ScreenButton_CombinationNaming: the +8 BUTTON method of the screen object for screen id 0x36 -- PanelScreen_VtableTable entry 0x56
;   (ViewB entry 0x36) points at the thunk triple starting at T_ScreenEnter_CombinationNaming, and slot T_ScreenButton_CombinationNaming jumps here.
ScreenButton_CombinationNaming:
	link XIZ,0x0000                                      ; FBC5A7  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBC5AB  9e 0a 04
	pushw	(xiz+8)                                      ; FBC5AE  9e 08 04
	calr ScreenButtonBody_CombinationNaming                                          ; FBC5B1  1e 82 2c
	pop XBC                                              ; FBC5B4  59
	unlk XIZ                                             ; FBC5B5  ee 0d
	ret                                                  ; FBC5B7  0e
T_F41A44_Nop:
	ret                                                  ; FBC5B8  0e
T_F41A88_Nop:
	ret                                                  ; FBC5B9  0e
T_F41A8C_Nop:
	ret                                                  ; FBC5BA  0e
T_F41A90_Nop:
	ret                                                  ; FBC5BB  0e
T_F41A94_Nop:
	ret                                                  ; FBC5BC  0e
; ScreenEnter_WriteProtectError: the +0 ENTER method of the screen object for screen id 0xB3 -- PanelScreen_VtableTable entry 0xD3
;   (ViewB entry 0xB3) points at the thunk triple starting at T_ScreenEnter_WriteProtectError, and slot T_ScreenEnter_WriteProtectError jumps here.
; ScreenEnter_WriteProtectError: screen 0xB3's +0 ENTER.  Its painter (posted by ScreenEnterBody_WriteProtectError) runs
;   DL_Err0rTheS0undOrC0mbinati0n: "ERR0R! The S0UND or C0MBINATI0N memories are write protected." with YES / NO.
ScreenEnter_WriteProtectError:
	calr ScreenEnterBody_WriteProtectError                                          ; FBC5BD  1e f9 38
	ret                                                  ; FBC5C0  0e
; ---------------------------------------------------------------------
; Var2075_ClrBit7_Entry -- a PURE WRAPPER for Var2075_ClrBit7: it IS that
; routine, so it is named for it.  Its whole extent is
; one `calr` and the `ret` that follows it, and the routine
; ends at 0xFBC5C5, where the next top-level label begins.
; Evidence: the `calr` at 0xFBC5C1 targets 0xFBFED5, which carries the
;          label Var2075_ClrBit7.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

Var2075_ClrBit7_Entry:
	calr Var2075_ClrBit7                                          ; FBC5C1  1e 11 39
	ret                                                  ; FBC5C4  0e
; ScreenButton_WriteProtectError: the +8 BUTTON method of the screen object for screen id 0xB3 -- PanelScreen_VtableTable entry 0xD3
;   (ViewB entry 0xB3) points at the thunk triple starting at T_ScreenEnter_WriteProtectError, and slot T_ScreenButton_WriteProtectError jumps here.
ScreenButton_WriteProtectError:
	link XIZ,0x0000                                      ; FBC5C5  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBC5C9  9e 0a 04
	pushw	(xiz+8)                                      ; FBC5CC  9e 08 04
	calr ScreenButtonBody_WriteProtectError                                          ; FBC5CF  1e 08 39
	pop XBC                                              ; FBC5D2  59
	unlk XIZ                                             ; FBC5D3  ee 0d
	ret                                                  ; FBC5D5  0e
T_F41884_Nop:
	ret                                                  ; FBC5D6  0e
; ScreenEnter_Effect2OutputConflict: the +0 ENTER method of the screen object for screen id 0xB6 -- PanelScreen_VtableTable entry 0xD6
;   (ViewB entry 0xB6) points at the thunk triple starting at T_ScreenEnter_Effect2OutputConflict, and slot T_ScreenEnter_Effect2OutputConflict jumps here.
; ScreenEnter_Effect2OutputConflict: screen 0xB6's +0 ENTER.  Its painter runs DL_F1A84F / ExitKey_Effect2OutputConflict_DL: "It is impossible
;   to use both the Main and Sub outputs if Effect2 is turned on.  Please select either the Main or Sub outputs."
ScreenEnter_Effect2OutputConflict:
	calr ScreenEnterBody_Effect2OutputConflict                                          ; FBC5D7  1e e6 37
	ret                                                  ; FBC5DA  0e
; ScreenLeave_Effect2OutputConflict: the +4 LEAVE method of the screen object for screen id 0xB6 -- PanelScreen_VtableTable entry 0xD6
;   (ViewB entry 0xB6) points at the thunk triple starting at T_ScreenEnter_Effect2OutputConflict, and slot T_ScreenLeave_Effect2OutputConflict jumps here.
ScreenLeave_Effect2OutputConflict:
	calr ScreenLeaveBody_Effect2OutputConflict                                          ; FBC5DB  1e f6 37
	ret                                                  ; FBC5DE  0e
; ScreenButton_Effect2OutputConflict: the +8 BUTTON method of the screen object for screen id 0xB6 -- PanelScreen_VtableTable entry 0xD6
;   (ViewB entry 0xB6) points at the thunk triple starting at T_ScreenEnter_Effect2OutputConflict, and slot T_ScreenButton_Effect2OutputConflict jumps here.
ScreenButton_Effect2OutputConflict:
	link XIZ,0x0000                                      ; FBC5DF  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBC5E3  9e 0a 04
	pushw	(xiz+8)                                      ; FBC5E6  9e 08 04
	calr ScreenButtonBody_Effect2OutputConflict                                          ; FBC5E9  1e 0b 38
	pop XBC                                              ; FBC5EC  59
	unlk XIZ                                             ; FBC5ED  ee 0d
	ret                                                  ; FBC5EF  0e
T_F418B4_Nop:
	ret                                                  ; FBC5F0  0e
; CombiEdit_OnPartParamEvent: T_CombiEdit_OnPartParamEvent, UiListB_Class00..3F (every part record): by the COMBINATION EDIT screen -- 0x33 / 0x34 / 0x37 / 0x38 /
;   0xB0 / 0xB1 / 0xB4 / 0xB5 CombiEditPage_OnPartParamEvent, 0x3A / 0xB7 (MIXER) CombiEditMixer_OnPartParamEvent,
;   0x35 / 0xB2 (CONFIGURE) CombiEditConfigure_OnPartParamEvent; other screens nothing.
CombiEdit_OnPartParamEvent:
	ld bc, (UI_ScreenId:16)                                 ; FBC5F1  d1 7c 20 21
	extz BC                                              ; FBC5F5  d9 12
	cp BC,0x0033                                         ; FBC5F7  d9 cf 33 00
	jr z, .LFBC641                                       ; FBC5FB  66 44
	cp BC,0x0034                                         ; FBC5FD  d9 cf 34 00
	jr z, .LFBC641                                       ; FBC601  66 3e
	cp BC,0x0035                                         ; FBC603  d9 cf 35 00
	jr z, .LFBC64B                                       ; FBC607  66 42
	cp BC,0x0037                                         ; FBC609  d9 cf 37 00
	jr z, .LFBC641                                       ; FBC60D  66 32
	cp BC,0x0038                                         ; FBC60F  d9 cf 38 00
	jr z, .LFBC641                                       ; FBC613  66 2c
	cp BC,0x003a                                         ; FBC615  d9 cf 3a 00
	jr z, .LFBC646                                       ; FBC619  66 2b
	cp BC,0x00b0                                         ; FBC61B  d9 cf b0 00
	jr z, .LFBC641                                       ; FBC61F  66 20
	cp BC,0x00b1                                         ; FBC621  d9 cf b1 00
	jr z, .LFBC641                                       ; FBC625  66 1a
	cp BC,0x00b2                                         ; FBC627  d9 cf b2 00
	jr z, .LFBC64B                                       ; FBC62B  66 1e
	cp BC,0x00b4                                         ; FBC62D  d9 cf b4 00
	jr z, .LFBC641                                       ; FBC631  66 0e
	cp BC,0x00b5                                         ; FBC633  d9 cf b5 00
	jr z, .LFBC641                                       ; FBC637  66 08
	cp BC,0x00b7                                         ; FBC639  d9 cf b7 00
	jr z, .LFBC646                                       ; FBC63D  66 07
	jr .LFBC64E                                          ; FBC63F  68 0d
.LFBC641:
	calr CombiEditPage_OnPartParamEvent                                      ; FBC641  1e 8c 00
	jr .LFBC64E                                          ; FBC644  68 08
.LFBC646:
	calr CombiEditMixer_OnPartParamEvent                                      ; FBC646  1e 06 01
	jr .LFBC64E                                          ; FBC649  68 03
.LFBC64B:
	calr CombiEditConfigure_OnPartParamEvent                                      ; FBC64B  1e e3 03
.LFBC64E:
	ret                                                  ; FBC64E  0e
; CombiEdit_RunPendingRepaint: T_CombiEdit_RunPendingRepaint's body: when (0x277D) is 1 and the screen is one of COMBINATION EDIT's (0x33-0x3A, 0xB0-0xB7), posts
;   that page's repaint routine to the callback queue and signals semaphore 1; (0x277D) = 0.
CombiEdit_RunPendingRepaint:
	cp	(0x277d:16), 0x01                            ; FBC64F  c1 7d 27 3f 01
	jrl nz, .LFBC6CF                                     ; FBC654  7e 78 00
	ld bc, (UI_ScreenId:16)                                 ; FBC657  d1 7c 20 21
	extz BC                                              ; FBC65B  d9 12
	cp BC,0x0033                                         ; FBC65D  d9 cf 33 00
	jr z, .LFBC6A7                                       ; FBC661  66 44
	cp BC,0x0034                                         ; FBC663  d9 cf 34 00
	jr z, .LFBC6A7                                       ; FBC667  66 3e
	cp BC,0x0035                                         ; FBC669  d9 cf 35 00
	jr z, .LFBC6B7                                       ; FBC66D  66 48
	cp BC,0x0037                                         ; FBC66F  d9 cf 37 00
	jr z, .LFBC6A7                                       ; FBC673  66 32
	cp BC,0x0038                                         ; FBC675  d9 cf 38 00
	jr z, .LFBC6A7                                       ; FBC679  66 2c
	cp BC,0x003a                                         ; FBC67B  d9 cf 3a 00
	jr z, .LFBC6AF                                       ; FBC67F  66 2e
	cp BC,0x00b0                                         ; FBC681  d9 cf b0 00
	jr z, .LFBC6A7                                       ; FBC685  66 20
	cp BC,0x00b1                                         ; FBC687  d9 cf b1 00
	jr z, .LFBC6A7                                       ; FBC68B  66 1a
	cp BC,0x00b2                                         ; FBC68D  d9 cf b2 00
	jr z, .LFBC6B7                                       ; FBC691  66 24
	cp BC,0x00b4                                         ; FBC693  d9 cf b4 00
	jr z, .LFBC6A7                                       ; FBC697  66 0e
	cp BC,0x00b5                                         ; FBC699  d9 cf b5 00
	jr z, .LFBC6A7                                       ; FBC69D  66 08
	cp BC,0x00b7                                         ; FBC69F  d9 cf b7 00
	jr z, .LFBC6AF                                       ; FBC6A3  66 0a
	jr .LFBC6CA                                          ; FBC6A5  68 23
.LFBC6A7:
	lda xbc, (.LFBCCF0:24)                               ; FBC6A7  f2 f0 cc fb 31
	push XBC                                             ; FBC6AC  39
	jr .LFBC6BD                                          ; FBC6AD  68 0e
.LFBC6AF:
	lda xbc, (CombiEditMixer_RepaintMarkedSound:24)                               ; FBC6AF  f2 c4 e6 fb 31
	push XBC                                             ; FBC6B4  39
	jr .LFBC6BD                                          ; FBC6B5  68 06
.LFBC6B7:
	lda xbc, (CombiEditConfigure_RepaintMarkedSounds:24)                             ; FBC6B7  f2 9c f7 fb 31
	push XBC                                             ; FBC6BC  39
.LFBC6BD:
	call T_CallbackQueue_Post                            ; FBC6BD  1d 84 2e f4
	pushw 0x01                                           ; FBC6C1  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBC6C4  1d c0 2d f4
	inc 6,XSP                                            ; FBC6C8  ef 66
.LFBC6CA:
	ld (0x277d:16), 0x00                                 ; FBC6CA  f1 7d 27 00 00
.LFBC6CF:
	ret                                                  ; FBC6CF  0e
; CombiEditPage_OnPartParamEvent: for the edited part ((0x2765) = class & 0x1F) the byte index, + 0x80 for the second record: 0, 1 and 0x9B..0x9D set
;   (0x277D) = 1; any other sets UI_ScreenFlags bit 4 (repaint) when the current page's field list
;   (PtrTable_F1AE71[CombiEditSound_PageIndex()], 0xFF-terminated) holds it.
CombiEditPage_OnPartParamEvent:
	pushw hl                                             ; FBC6D0  2b
	pushw de                                             ; FBC6D1  2a
	push XIX                                             ; FBC6D2  3c
	ld e, (UiEvent_Class:16)                                   ; FBC6D3  c1 bb 20 25
	cp E,0x3f                                            ; FBC6D7  cd cf 3f
	jrl ugt, .LFBC74B                                    ; FBC6DA  7b 6e 00
	ld C,E                                               ; FBC6DD  cd 8b
	and C,0x1f                                           ; FBC6DF  cb cc 1f
	cp	c, (CombiEdit_Part:16)                               ; FBC6E2  c1 65 27 f3
	jrl nz, .LFBC74B                                     ; FBC6E6  7e 62 00
	ld d, (UiEvent_Byte1:16)                                   ; FBC6E9  c1 b8 20 24
	ld C,E                                               ; FBC6ED  cd 8b
	and C,0x20                                           ; FBC6EF  cb cc 20
	jr z, .LFBC6F7                                       ; FBC6F2  66 03
	add D,0x80                                           ; FBC6F4  cc c8 80
.LFBC6F7:
	cp d, 0x00:i3                                          ; FBC6F7  cc d8
	jr z, .LFBC70E                                       ; FBC6F9  66 13
	cp d, 0x01:i3                                          ; FBC6FB  cc d9
	jr z, .LFBC70E                                       ; FBC6FD  66 0f
	cp D,0x9b                                            ; FBC6FF  cc cf 9b
	jr z, .LFBC70E                                       ; FBC702  66 0a
	cp D,0x9c                                            ; FBC704  cc cf 9c
	jr z, .LFBC70E                                       ; FBC707  66 05
	cp D,0x9d                                            ; FBC709  cc cf 9d
	jr nz, .LFBC715                                      ; FBC70C  6e 07
.LFBC70E:
	ld (0x277d:16), 0x01                                 ; FBC70E  f1 7d 27 00 01
	jr .LFBC74B                                          ; FBC713  68 36
.LFBC715:
	calr CombiEditSound_PageIndex                                      ; FBC715  1e 0f 0a
	ld H,A                                               ; FBC718  c9 8e
	cp A,0xff                                            ; FBC71A  c9 cf ff
	jr z, .LFBC74B                                       ; FBC71D  66 2c
	ld l, 0x00:opc                                          ; FBC71F  27 00
	mul A,0x04                                           ; FBC721  c9 08 04
	extz XWA                                             ; FBC724  e8 12
	add XWA,PtrTable_F1AE71                              ; FBC726  e8 c8 71 ae f1 00
	ld XBC,(XWA)                                         ; FBC72C  a0 21
	ld XIX,XBC                                           ; FBC72E  e9 8c
.LFBC730:
	ld C,L                                               ; FBC730  cf 8b
	extz BC                                              ; FBC732  d9 12
	extz XBC                                             ; FBC734  e9 12
	add XBC,XIX                                          ; FBC736  ec 81
	ld H,(XBC)                                           ; FBC738  81 26
	cp H,0xff                                            ; FBC73A  ce cf ff
	jr z, .LFBC74B                                       ; FBC73D  66 0c
	cp H,D                                               ; FBC73F  cc f6
	jr nz, .LFBC747                                      ; FBC741  6e 04
	set	4, (UI_ScreenFlags:16)                               ; FBC743  f1 95 20 bc
.LFBC747:
	inc 1,L                                              ; FBC747  cf 61
	jr .LFBC730                                          ; FBC749  68 e5
.LFBC74B:
	pop XIX                                              ; FBC74B  5c
	popw de                                              ; FBC74C  4a
	popw hl                                              ; FBC74D  4b
	ret                                                  ; FBC74E  0e
; CombiEditMixer_OnPartParamEvent: the MIXER screens' handler: calls PtrTable_F1AE89[(0x2767)], one routine per mixer page.
CombiEditMixer_OnPartParamEvent:
	ld c, 0x04:opc                                          ; FBC74F  23 04
	mul	bc, (CombiEdit_Page:16)                              ; FBC751  c1 67 27 43
	extz XBC                                             ; FBC755  e9 12
	add XBC,PtrTable_F1AE89                              ; FBC757  e9 c8 89 ae f1 00
	ld XBC,(XBC)                                         ; FBC75D  a1 21
	lda xiy, (.LFBC767:24)                               ; FBC75F  f2 67 c7 fb 35
	push XIY                                             ; FBC764  3d
	jp (xbc)                                             ; FBC765  b1 d8
.LFBC767:
	ret                                                  ; FBC767  0e
; CombiEditMixer_OnSoundPanVolumePageEvent: PtrTable_F1AE89[0], run by CombiEditMixer_OnPartParamEvent on page 0, for a part of the edited group: byte 0 / 1
;   / 0x9B-0x9D (the sound) -> CombiEdit_DirtySound and (0x277D) = 1; 13 (LOCAL CONTROL, panel-mode group 0x16)
;   / 8 (PANPOT) / 3 (VOLUME) -> the part's bit in that cell's dirty mask and its CombiEditMixer_RepaintMarked*
;   callback posted (T_CallbackQueue_Post, T_Kernel_SemaSignal_StackArg).  Basis: body.
CombiEditMixer_OnSoundPanVolumePageEvent:
	pushw hl                                             ; FBC768  2b
	pushw de                                             ; FBC769  2a
	ld d, (UiEvent_Class:16)                                   ; FBC76A  c1 bb 20 24
	cp D,0x3f                                            ; FBC76E  cc cf 3f
	jrl ugt, .LFBC829                                    ; FBC771  7b b5 00
	cp D,0x20                                            ; FBC774  cc cf 20
	jr c, .LFBC787                                       ; FBC777  67 0e
	ld H,D                                               ; FBC779  cc 8e
	and H,0x1f                                           ; FBC77B  ce cc 1f
	ld l, (UiEvent_Byte1:16)                                   ; FBC77E  c1 b8 20 27
	add L,0x80                                           ; FBC782  cf c8 80
	jr .LFBC78D                                          ; FBC785  68 06
.LFBC787:
	ld H,D                                               ; FBC787  cc 8e
	ld l, (UiEvent_Byte1:16)                                   ; FBC789  c1 b8 20 27
.LFBC78D:
	ld E,H                                               ; FBC78D  ce 8d
	and E,0xf8                                           ; FBC78F  cd cc f8
	ld c, (CombiEdit_Part:16)                                   ; FBC792  c1 65 27 23
	and C,0xf8                                           ; FBC796  cb cc f8
	cp C,E                                               ; FBC799  cd f3
	jrl nz, .LFBC829                                     ; FBC79B  7e 8b 00
	ld C,H                                               ; FBC79E  ce 8b
	and C,0x07                                           ; FBC7A0  cb cc 07
	mul C,0x04                                           ; FBC7A3  cb 08 04
	extz XBC                                             ; FBC7A6  e9 12
	add XBC,BitTable_F1AE95                              ; FBC7A8  e9 c8 95 ae f1 00
	ld H,(XBC)                                           ; FBC7AE  81 26
	ld C,L                                               ; FBC7B0  cf 8b
	extz BC                                              ; FBC7B2  d9 12
	cp bc, 0x00:i3                                         ; FBC7B4  d9 d8
	jr z, .LFBC7E0                                       ; FBC7B6  66 28
	cp bc, 0x01:i3                                         ; FBC7B8  d9 d9
	jr z, .LFBC7E0                                       ; FBC7BA  66 24
	cp bc, 0x03:i3                                         ; FBC7BC  d9 db
	jr z, .LFBC810                                       ; FBC7BE  66 50
	cp BC,0x0008                                         ; FBC7C0  d9 cf 08 00
	jr z, .LFBC802                                       ; FBC7C4  66 3c
	cp BC,0x000d                                         ; FBC7C6  d9 cf 0d 00
	jr z, .LFBC7ED                                       ; FBC7CA  66 21
	cp BC,0x009b                                         ; FBC7CC  d9 cf 9b 00
	jr z, .LFBC7E0                                       ; FBC7D0  66 0e
	cp BC,0x009c                                         ; FBC7D2  d9 cf 9c 00
	jr z, .LFBC7E0                                       ; FBC7D6  66 08
	cp BC,0x009d                                         ; FBC7D8  d9 cf 9d 00
	jr z, .LFBC7E0                                       ; FBC7DC  66 02
	jr .LFBC829                                          ; FBC7DE  68 49
.LFBC7E0:
	ld C,H                                               ; FBC7E0  ce 8b
	or (CombiEdit_DirtySound:16), c                                   ; FBC7E2  c1 70 27 eb
	ld (0x277d:16), 0x01                                 ; FBC7E6  f1 7d 27 00 01
	jr .LFBC829                                          ; FBC7EB  68 3c
.LFBC7ED:
	cp	(PanelModeGroup:16), 0x16                            ; FBC7ED  c1 76 20 3f 16
	jr nz, .LFBC829                                      ; FBC7F2  6e 35
	ld C,H                                               ; FBC7F4  ce 8b
	or (CombiEditMixer_DirtyLocalControl:16), c                                   ; FBC7F6  c1 71 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedLocalControl:24)                               ; FBC7FA  f2 4d e7 fb 31
	push XBC                                             ; FBC7FF  39
	jr .LFBC81C                                          ; FBC800  68 1a
.LFBC802:
	ld C,H                                               ; FBC802  ce 8b
	or (CombiEditMixer_DirtyPanpot:16), c                                   ; FBC804  c1 72 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedPanpot:24)                               ; FBC808  f2 e0 e7 fb 31
	push XBC                                             ; FBC80D  39
	jr .LFBC81C                                          ; FBC80E  68 0c
.LFBC810:
	ld C,H                                               ; FBC810  ce 8b
	or (CombiEditMixer_DirtyVolume:16), c                                   ; FBC812  c1 73 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedVolume:24)                               ; FBC816  f2 68 e8 fb 31
	push XBC                                             ; FBC81B  39
.LFBC81C:
	call T_CallbackQueue_Post                            ; FBC81C  1d 84 2e f4
	pushw 0x01                                           ; FBC820  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBC823  1d c0 2d f4
	inc 6,XSP                                            ; FBC827  ef 66
.LFBC829:
	popw de                                              ; FBC829  4a
	popw hl                                              ; FBC82A  4b
	ret                                                  ; FBC82B  0e
; CombiEditMixer_OnSendsPageEvent: PtrTable_F1AE89[1], page 1: the sound bytes as on page 0; 7 REVERB SEND, 5 EFFECT1 SEND, 6 EFFECT2 ON/OFF, 0x83
;   (second record byte 3, MAIN OUT), 9 KEY SHIFT -> dirty mask + callback.  Basis: body.
CombiEditMixer_OnSendsPageEvent:
	pushw hl                                             ; FBC82C  2b
	pushw de                                             ; FBC82D  2a
	ld d, (UiEvent_Class:16)                                   ; FBC82E  c1 bb 20 24
	cp D,0x3f                                            ; FBC832  cc cf 3f
	jrl ugt, .LFBC90A                                    ; FBC835  7b d2 00
	cp D,0x20                                            ; FBC838  cc cf 20
	jr c, .LFBC84B                                       ; FBC83B  67 0e
	ld H,D                                               ; FBC83D  cc 8e
	and H,0x1f                                           ; FBC83F  ce cc 1f
	ld l, (UiEvent_Byte1:16)                                   ; FBC842  c1 b8 20 27
	add L,0x80                                           ; FBC846  cf c8 80
	jr .LFBC851                                          ; FBC849  68 06
.LFBC84B:
	ld H,D                                               ; FBC84B  cc 8e
	ld l, (UiEvent_Byte1:16)                                   ; FBC84D  c1 b8 20 27
.LFBC851:
	ld E,H                                               ; FBC851  ce 8d
	and E,0xf8                                           ; FBC853  cd cc f8
	ld c, (CombiEdit_Part:16)                                   ; FBC856  c1 65 27 23
	and C,0xf8                                           ; FBC85A  cb cc f8
	cp C,E                                               ; FBC85D  cd f3
	jrl nz, .LFBC90A                                     ; FBC85F  7e a8 00
	ld C,H                                               ; FBC862  ce 8b
	and C,0x07                                           ; FBC864  cb cc 07
	mul C,0x04                                           ; FBC867  cb 08 04
	extz XBC                                             ; FBC86A  e9 12
	add XBC,BitTable_F1AE95                              ; FBC86C  e9 c8 95 ae f1 00
	ld H,(XBC)                                           ; FBC872  81 26
	ld C,L                                               ; FBC874  cf 8b
	extz BC                                              ; FBC876  d9 12
	cp bc, 0x00:i3                                         ; FBC878  d9 d8
	jr z, .LFBC8AC                                       ; FBC87A  66 30
	cp bc, 0x01:i3                                         ; FBC87C  d9 d9
	jr z, .LFBC8AC                                       ; FBC87E  66 2c
	cp bc, 0x05:i3                                         ; FBC880  d9 dd
	jr z, .LFBC8C7                                       ; FBC882  66 43
	cp bc, 0x06:i3                                         ; FBC884  d9 de
	jr z, .LFBC8D5                                       ; FBC886  66 4d
	cp bc, 0x07:i3                                         ; FBC888  d9 df
	jr z, .LFBC8B9                                       ; FBC88A  66 2d
	cp BC,0x0009                                         ; FBC88C  d9 cf 09 00
	jr z, .LFBC8F1                                       ; FBC890  66 5f
	cp BC,0x0083                                         ; FBC892  d9 cf 83 00
	jr z, .LFBC8E3                                       ; FBC896  66 4b
	cp BC,0x009b                                         ; FBC898  d9 cf 9b 00
	jr z, .LFBC8AC                                       ; FBC89C  66 0e
	cp BC,0x009c                                         ; FBC89E  d9 cf 9c 00
	jr z, .LFBC8AC                                       ; FBC8A2  66 08
	cp BC,0x009d                                         ; FBC8A4  d9 cf 9d 00
	jr z, .LFBC8AC                                       ; FBC8A8  66 02
	jr .LFBC90A                                          ; FBC8AA  68 5e
.LFBC8AC:
	ld C,H                                               ; FBC8AC  ce 8b
	or (CombiEdit_DirtySound:16), c                                   ; FBC8AE  c1 70 27 eb
	ld (0x277d:16), 0x01                                 ; FBC8B2  f1 7d 27 00 01
	jr .LFBC90A                                          ; FBC8B7  68 51
.LFBC8B9:
	ld C,H                                               ; FBC8B9  ce 8b
	or (CombiEditMixer_DirtyReverbSend:16), c                                   ; FBC8BB  c1 74 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedReverbSend:24)                               ; FBC8BF  f2 f0 e8 fb 31
	push XBC                                             ; FBC8C4  39
	jr .LFBC8FD                                          ; FBC8C5  68 36
.LFBC8C7:
	ld C,H                                               ; FBC8C7  ce 8b
	or (CombiEditMixer_DirtyEffect1Send:16), c                                   ; FBC8C9  c1 75 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedEffect1Send:24)                               ; FBC8CD  f2 78 e9 fb 31
	push XBC                                             ; FBC8D2  39
	jr .LFBC8FD                                          ; FBC8D3  68 28
.LFBC8D5:
	ld C,H                                               ; FBC8D5  ce 8b
	or (CombiEditMixer_DirtyEffect2OnOff:16), c                                   ; FBC8D7  c1 76 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedEffect2OnOff:24)                               ; FBC8DB  f2 e7 e9 fb 31
	push XBC                                             ; FBC8E0  39
	jr .LFBC8FD                                          ; FBC8E1  68 1a
.LFBC8E3:
	ld C,H                                               ; FBC8E3  ce 8b
	or (CombiEditMixer_DirtyMainOut:16), c                                   ; FBC8E5  c1 78 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedMainOut:24)                               ; FBC8E9  f2 5b ea fb 31
	push XBC                                             ; FBC8EE  39
	jr .LFBC8FD                                          ; FBC8EF  68 0c
.LFBC8F1:
	ld C,H                                               ; FBC8F1  ce 8b
	or (CombiEditMixer_DirtyKeyShift:16), c                                   ; FBC8F3  c1 7c 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedKeyShift:24)                               ; FBC8F7  f2 88 ec fb 31
	push XBC                                             ; FBC8FC  39
.LFBC8FD:
	call T_CallbackQueue_Post                            ; FBC8FD  1d 84 2e f4
	pushw 0x01                                           ; FBC901  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBC904  1d c0 2d f4
	inc 6,XSP                                            ; FBC908  ef 66
.LFBC90A:
	popw de                                              ; FBC90A  4a
	popw hl                                              ; FBC90B  4b
	ret                                                  ; FBC90C  0e
; CombiEditMixer_OnMidiPageEvent: PtrTable_F1AE89[2], page 2: the sound bytes as on page 0; 13 (LOCAL CONTROL, MIDI OUT / MIDI IN SETTING, BASIC
;   CHANNEL, each by its bits) and 0x84 (second record byte 4, SUB OUT) -> dirty mask + callback.  Basis: body.
CombiEditMixer_OnMidiPageEvent:
	pushw hl                                             ; FBC90D  2b
	pushw de                                             ; FBC90E  2a
	push XIX                                             ; FBC90F  3c
	ld d, (UiEvent_Class:16)                                   ; FBC910  c1 bb 20 24
	cp D,0x3f                                            ; FBC914  cc cf 3f
	jrl ugt, .LFBCA2D                                    ; FBC917  7b 13 01
	cp D,0x20                                            ; FBC91A  cc cf 20
	jr c, .LFBC92D                                       ; FBC91D  67 0e
	ld L,D                                               ; FBC91F  cc 8f
	and L,0x1f                                           ; FBC921  cf cc 1f
	ld h, (UiEvent_Byte1:16)                                   ; FBC924  c1 b8 20 26
	add H,0x80                                           ; FBC928  ce c8 80
	jr .LFBC933                                          ; FBC92B  68 06
.LFBC92D:
	ld L,D                                               ; FBC92D  cc 8f
	ld h, (UiEvent_Byte1:16)                                   ; FBC92F  c1 b8 20 26
.LFBC933:
	ld E,L                                               ; FBC933  cf 8d
	and E,0xf8                                           ; FBC935  cd cc f8
	ld c, (CombiEdit_Part:16)                                   ; FBC938  c1 65 27 23
	and C,0xf8                                           ; FBC93C  cb cc f8
	cp C,E                                               ; FBC93F  cd f3
	jrl nz, .LFBCA2D                                     ; FBC941  7e e9 00
	ld C,L                                               ; FBC944  cf 8b
	and C,0x07                                           ; FBC946  cb cc 07
	mul C,0x04                                           ; FBC949  cb 08 04
	extz XBC                                             ; FBC94C  e9 12
	add XBC,BitTable_F1AE95                              ; FBC94E  e9 c8 95 ae f1 00
	ld L,(XBC)                                           ; FBC954  81 27
	ld C,H                                               ; FBC956  ce 8b
	extz BC                                              ; FBC958  d9 12
	cp bc, 0x00:i3                                         ; FBC95A  d9 d8
	jr z, .LFBC984                                       ; FBC95C  66 26
	cp bc, 0x01:i3                                         ; FBC95E  d9 d9
	jr z, .LFBC984                                       ; FBC960  66 22
	cp BC,0x000d                                         ; FBC962  d9 cf 0d 00
	jr z, .LFBC992                                       ; FBC966  66 2a
	cp BC,0x0084                                         ; FBC968  d9 cf 84 00
	jrl z, .LFBCA14                                      ; FBC96C  76 a5 00
	cp BC,0x009b                                         ; FBC96F  d9 cf 9b 00
	jr z, .LFBC984                                       ; FBC973  66 0f
	cp BC,0x009c                                         ; FBC975  d9 cf 9c 00
	jr z, .LFBC984                                       ; FBC979  66 09
	cp BC,0x009d                                         ; FBC97B  d9 cf 9d 00
	jr z, .LFBC984                                       ; FBC97F  66 03
	jrl .LFBCA2D                                         ; FBC981  78 a9 00
.LFBC984:
	ld C,L                                               ; FBC984  cf 8b
	or (CombiEdit_DirtySound:16), c                                   ; FBC986  c1 70 27 eb
	ld (0x277d:16), 0x01                                 ; FBC98A  f1 7d 27 00 01
	jrl .LFBCA2D                                         ; FBC98F  78 9b 00
.LFBC992:
	lda xix, (UiEvent_Byte3:16)                                ; FBC992  f1 ba 20 34
	ld c, (UiEvent_Byte3:16)                                   ; FBC996  c1 ba 20 23
	and C,0x20                                           ; FBC99A  cb cc 20
	jr z, .LFBC9BF                                       ; FBC99D  66 20
	cp	(PanelModeGroup:16), 0x16                            ; FBC99F  c1 76 20 3f 16
	jr z, .LFBC9BF                                       ; FBC9A4  66 19
	ld C,L                                               ; FBC9A6  cf 8b
	or (CombiEditMixer_DirtyLocalControl:16), c                                   ; FBC9A8  c1 71 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedLocalControl:24)                               ; FBC9AC  f2 4d e7 fb 31
	push XBC                                             ; FBC9B1  39
	call T_CallbackQueue_Post                            ; FBC9B2  1d 84 2e f4
	pushw 0x01                                           ; FBC9B6  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBC9B9  1d c0 2d f4
	inc 6,XSP                                            ; FBC9BD  ef 66
.LFBC9BF:
	ld C,(XIX)                                           ; FBC9BF  84 23
	and C,0x40                                           ; FBC9C1  cb cc 40
	jr z, .LFBC9DF                                       ; FBC9C4  66 19
	ld C,L                                               ; FBC9C6  cf 8b
	or (CombiEditMixer_DirtyMidiOutSetting:16), c                                   ; FBC9C8  c1 79 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedMidiOutSetting:24)                               ; FBC9CC  f2 c8 ea fb 31
	push XBC                                             ; FBC9D1  39
	call T_CallbackQueue_Post                            ; FBC9D2  1d 84 2e f4
	pushw 0x01                                           ; FBC9D6  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBC9D9  1d c0 2d f4
	inc 6,XSP                                            ; FBC9DD  ef 66
.LFBC9DF:
	ld C,(XIX)                                           ; FBC9DF  84 23
	and C,0x80                                           ; FBC9E1  cb cc 80
	jr z, .LFBC9FF                                       ; FBC9E4  66 19
	ld C,L                                               ; FBC9E6  cf 8b
	or (CombiEditMixer_DirtyMidiInSetting:16), c                                   ; FBC9E8  c1 7a 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedMidiInSetting:24)                               ; FBC9EC  f2 35 eb fb 31
	push XBC                                             ; FBC9F1  39
	call T_CallbackQueue_Post                            ; FBC9F2  1d 84 2e f4
	pushw 0x01                                           ; FBC9F6  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBC9F9  1d c0 2d f4
	inc 6,XSP                                            ; FBC9FD  ef 66
.LFBC9FF:
	ld C,(XIX)                                           ; FBC9FF  84 23
	and C,0x1f                                           ; FBCA01  cb cc 1f
	jr z, .LFBCA2D                                       ; FBCA04  66 27
	ld C,L                                               ; FBCA06  cf 8b
	or (CombiEditMixer_DirtyBasicChannel:16), c                                   ; FBCA08  c1 7b 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedBasicChannel:24)                               ; FBCA0C  f2 a6 eb fb 31
	push XBC                                             ; FBCA11  39
	jr .LFBCA20                                          ; FBCA12  68 0c
.LFBCA14:
	ld C,L                                               ; FBCA14  cf 8b
	or (CombiEditMixer_DirtySubOut:16), c                                   ; FBCA16  c1 77 27 eb
	lda xbc, (CombiEditMixer_RepaintMarkedSubOut:24)                               ; FBCA1A  f2 1c ec fb 31
	push XBC                                             ; FBCA1F  39
.LFBCA20:
	call T_CallbackQueue_Post                            ; FBCA20  1d 84 2e f4
	pushw 0x01                                           ; FBCA24  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBCA27  1d c0 2d f4
	inc 6,XSP                                            ; FBCA2B  ef 66
.LFBCA2D:
	pop XIX                                              ; FBCA2D  5c
	popw de                                              ; FBCA2E  4a
	popw hl                                              ; FBCA2F  4b
	ret                                                  ; FBCA30  0e
; CombiEditConfigure_OnPartParamEvent: the CONFIGURE screens' handler: for a part in the edited group of 8 ((0x2765) & 0xF8), byte indices 0, 1 and
;   0x9B..0x9D OR its bit (BitTable_F1AE95) into (0x2770) and set (0x277D) = 1; then by the page (0x2767) a repaint
;   (UI_ScreenFlags bit 4): page 0 byte 13 (parts up to 31, or 7 in panel-mode group 0x16), page 1 bytes 7 / 8 and
;   page 2 bytes 9 / 10 of classes 0x20-0x27.
CombiEditConfigure_OnPartParamEvent:
	link XIZ,0xfffe                                      ; FBCA31  ee 0c fe ff
	pushw hl                                             ; FBCA35  2b
	pushw de                                             ; FBCA36  2a
	ld e, (UiEvent_Byte1:16)                                   ; FBCA37  c1 b8 20 25
	ld d, (UiEvent_Class:16)                                   ; FBCA3B  c1 bb 20 24
	cp D,0x3f                                            ; FBCA3F  cc cf 3f
	jrl ugt, .LFBCAAA                                    ; FBCA42  7b 65 00
	cp D,0x20                                            ; FBCA45  cc cf 20
	jr c, .LFBCA56                                       ; FBCA48  67 0c
	ld H,D                                               ; FBCA4A  cc 8e
	and H,0x1f                                           ; FBCA4C  ce cc 1f
	ld L,E                                               ; FBCA4F  cd 8f
	add L,0x80                                           ; FBCA51  cf c8 80
	jr .LFBCA5A                                          ; FBCA54  68 04
.LFBCA56:
	ld H,D                                               ; FBCA56  cc 8e
	ld L,E                                               ; FBCA58  cd 8f
.LFBCA5A:
	ld C,H                                               ; FBCA5A  ce 8b
	and C,0xf8                                           ; FBCA5C  cb cc f8
	ld (xiz-2), c                                        ; FBCA5F  be fe 43
	ld a, (CombiEdit_Part:16)                                   ; FBCA62  c1 65 27 21
	and A,0xf8                                           ; FBCA66  c9 cc f8
	cp A,C                                               ; FBCA69  cb f1
	jr nz, .LFBCAAA                                      ; FBCA6B  6e 3d
	ld C,H                                               ; FBCA6D  ce 8b
	and C,0x07                                           ; FBCA6F  cb cc 07
	mul C,0x04                                           ; FBCA72  cb 08 04
	extz XBC                                             ; FBCA75  e9 12
	add XBC,BitTable_F1AE95                              ; FBCA77  e9 c8 95 ae f1 00
	ld H,(XBC)                                           ; FBCA7D  81 26
	ld C,L                                               ; FBCA7F  cf 8b
	extz BC                                              ; FBCA81  d9 12
	cp bc, 0x00:i3                                         ; FBCA83  d9 d8
	jr z, .LFBCA9F                                       ; FBCA85  66 18
	cp bc, 0x01:i3                                         ; FBCA87  d9 d9
	jr z, .LFBCA9F                                       ; FBCA89  66 14
	cp BC,0x009b                                         ; FBCA8B  d9 cf 9b 00
	jr z, .LFBCA9F                                       ; FBCA8F  66 0e
	cp BC,0x009c                                         ; FBCA91  d9 cf 9c 00
	jr z, .LFBCA9F                                       ; FBCA95  66 08
	cp BC,0x009d                                         ; FBCA97  d9 cf 9d 00
	jr z, .LFBCA9F                                       ; FBCA9B  66 02
	jr .LFBCAAA                                          ; FBCA9D  68 0b
.LFBCA9F:
	ld C,H                                               ; FBCA9F  ce 8b
	or (CombiEdit_DirtySound:16), c                                   ; FBCAA1  c1 70 27 eb
	ld (0x277d:16), 0x01                                 ; FBCAA5  f1 7d 27 00 01
.LFBCAAA:
	ld bc, (CombiEdit_Page:16)                                 ; FBCAAA  d1 67 27 21
	extz BC                                              ; FBCAAE  d9 12
	cp bc, 0x00:i3                                         ; FBCAB0  d9 d8
	jr z, .LFBCABE                                       ; FBCAB2  66 0a
	cp bc, 0x01:i3                                         ; FBCAB4  d9 d9
	jr z, .LFBCAD4                                       ; FBCAB6  66 1c
	cp bc, 0x02:i3                                         ; FBCAB8  d9 da
	jr z, .LFBCAE9                                       ; FBCABA  66 2d
	jr .LFBCB01                                          ; FBCABC  68 43
.LFBCABE:
	ld h, 0x1f:opc                                          ; FBCABE  26 1f
	cp	(PanelModeGroup:16), 0x16                            ; FBCAC0  c1 76 20 3f 16
	jr nz, .LFBCAC9                                      ; FBCAC5  6e 02
	ld h, 0x07:opc                                          ; FBCAC7  26 07
.LFBCAC9:
	cp D,H                                               ; FBCAC9  ce f4
	jr ugt, .LFBCB01                                     ; FBCACB  6b 34
	cp E,0x0d                                            ; FBCACD  cd cf 0d
	jr nz, .LFBCB01                                      ; FBCAD0  6e 2f
	jr .LFBCAFD                                          ; FBCAD2  68 29
.LFBCAD4:
	cp D,0x20                                            ; FBCAD4  cc cf 20
	jr c, .LFBCB01                                       ; FBCAD7  67 28
	cp D,0x27                                            ; FBCAD9  cc cf 27
	jr ugt, .LFBCB01                                     ; FBCADC  6b 23
	cp e, 0x07:i3                                          ; FBCADE  cd df
	jr z, .LFBCAFD                                       ; FBCAE0  66 1b
	cp E,0x08                                            ; FBCAE2  cd cf 08
	jr nz, .LFBCB01                                      ; FBCAE5  6e 1a
	jr .LFBCAFD                                          ; FBCAE7  68 14
.LFBCAE9:
	cp D,0x20                                            ; FBCAE9  cc cf 20
	jr c, .LFBCB01                                       ; FBCAEC  67 13
	cp D,0x27                                            ; FBCAEE  cc cf 27
	jr ugt, .LFBCB01                                     ; FBCAF1  6b 0e
	cp E,0x09                                            ; FBCAF3  cd cf 09
	jr z, .LFBCAFD                                       ; FBCAF6  66 05
	cp E,0x0a                                            ; FBCAF8  cd cf 0a
	jr nz, .LFBCB01                                      ; FBCAFB  6e 04
.LFBCAFD:
	set	4, (UI_ScreenFlags:16)                               ; FBCAFD  f1 95 20 bc
.LFBCB01:
	popw de                                              ; FBCB01  4a
	popw hl                                              ; FBCB02  4b
	unlk XIZ                                             ; FBCB03  ee 0d
	ret                                                  ; FBCB05  0e
; ModeEnter_CombiEditPart: the +0 ENTER of panel mode 9 (T_ModeEnter_CombiEditPart); PanelMode_ToScreenIdMap[9] = 0xB0, the COMBINATION
;   EDIT part menu.  Seeds the part copies (0x2765/66/6D) from UI_PartIndex, T_SoundGroup_ReloadSelection.
ModeEnter_CombiEditPart:
	pushw hl                                             ; FBCB06  2b
	set	1, (0x2134:16)                               ; FBCB07  f1 34 21 b9
	ld h, (UI_PartIndex:16)                                   ; FBCB0B  c1 50 22 26
	ld (CombiEdit_EntryPart:16), h                                   ; FBCB0F  f1 6d 27 46
	ld (0x2766:16), h                                   ; FBCB13  f1 66 27 46
	ld (CombiEdit_Part:16), h                                   ; FBCB17  f1 65 27 46
	ld C,H                                               ; FBCB1B  ce 8b
	inc 1,C                                              ; FBCB1D  cb 61
	ld (0x2766:16), c                                   ; FBCB1F  f1 66 27 43
	push XDE                                             ; FBCB23  3a
	push XHL                                             ; FBCB24  3b
	push XIX                                             ; FBCB25  3c
	push XIZ                                             ; FBCB26  3e
	call T_SoundGroup_ReloadSelection                                        ; FBCB27  1d c8 15 f4
	pop XIZ                                              ; FBCB2B  5e
	pop XIX                                              ; FBCB2C  5c
	pop XHL                                              ; FBCB2D  5b
	pop XDE                                              ; FBCB2E  5a
	popw hl                                              ; FBCB2F  4b
	ret                                                  ; FBCB30  0e
sub_FBCB31:
	set	1, (0x2134:16)                               ; FBCB31  f1 34 21 b9
	ld	(UI_PartIndex:16), (CombiEdit_EntryPart:16)             ; FBCB35  c1 6d 27 19 50 22
	call T_PartIndex_PostChangeEvent                                        ; FBCB3B  1d 9c 2c f4
	ret                                                  ; FBCB3F  0e
; ScreenEnter_CombiEditPartMenu: the +0 ENTER method of the screen object for screen id 0xB0 -- PanelScreen_VtableTable entry 0xD0
;   (ViewB entry 0xB0) points at the thunk triple starting at T_ScreenEnter_CombiEditPartMenu, and slot T_ScreenEnter_CombiEditPartMenu jumps here.
; ScreenEnter_CombiEditPartMenu: screen 0xB0's +0 ENTER.  Its painter runs DL_InternalSound_F18A1D .. DL_CopyFromSoundPlay:
;   "PART", "INTERNAL SOUND", "CONFIGURE", "MIDI OUTPUT" / "FILTER", "MIXER", "DSP EFFECT" -- the per-part menu.
ScreenEnter_CombiEditPartMenu:
	calr CombiEdit_TakePartIndex                                      ; FBCB40  1e 6e 01
	ld c, (UI_ScreenFlags:16)                                   ; FBCB43  c1 95 20 23
	and C,0x10                                           ; FBCB47  cb cc 10
	jr nz, .LFBCB6D                                      ; FBCB4A  6e 21
	ld c, (UI_ScreenId:16)                                   ; FBCB4C  c1 7c 20 23
	cp	c, (UI_ScreenId_Previous:16)                               ; FBCB50  c1 7d 20 f3
	jr z, .LFBCB6D                                       ; FBCB54  66 17
	call T_CallbackQueue_ResetAndRestartTask2            ; FBCB56  1d 80 2e f4
	lda xbc, (.LFBCCC2:24)                               ; FBCB5A  f2 c2 cc fb 31
	push XBC                                             ; FBCB5F  39
	call T_CallbackQueue_Post                            ; FBCB60  1d 84 2e f4
	pushw 0x01                                           ; FBCB64  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBCB67  1d c0 2d f4
	inc 6,XSP                                            ; FBCB6B  ef 66
.LFBCB6D:
	lda xbc, (.LFBCCF0:24)                               ; FBCB6D  f2 f0 cc fb 31
	push XBC                                             ; FBCB72  39
	call T_CallbackQueue_Post                            ; FBCB73  1d 84 2e f4
	pushw 0x01                                           ; FBCB77  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBCB7A  1d c0 2d f4
	inc 6,XSP                                            ; FBCB7E  ef 66
	ret                                                  ; FBCB80  0e
T_F4184C_Nop:
	ret                                                  ; FBCB81  0e
; ScreenButton_CombiEditPartMenu: the +8 BUTTON method of the screen object for screen id 0xB0 -- PanelScreen_VtableTable entry 0xD0
;   (ViewB entry 0xB0) points at the thunk triple starting at T_ScreenEnter_CombiEditPartMenu, and slot T_ScreenButton_CombiEditPartMenu jumps here.
ScreenButton_CombiEditPartMenu:
	link XIZ,0x0000                                      ; FBCB82  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBCB86  9e 0a 04
	pushw	(xiz+8)                                      ; FBCB89  9e 08 04
	call T_PanelCode_ToSlotAndFlags                                        ; FBCB8C  1d 74 2c f4
	mul A,0x04                                           ; FBCB90  c9 08 04
	extz XWA                                             ; FBCB93  e8 12
	add XWA,ScreenButtons_CombiEditPartMenu                              ; FBCB95  e8 c8 b5 ae f1 00
	ld XBC,(XWA)                                         ; FBCB9B  a0 21
	lda xiy, (.LFBCBA5:24)                               ; FBCB9D  f2 a5 cb fb 35
	push XIY                                             ; FBCBA2  3d
	jp (xbc)                                             ; FBCBA3  b1 d8
.LFBCBA5:
	pop XBC                                              ; FBCBA5  59
	unlk XIZ                                             ; FBCBA6  ee 0d
	ret                                                  ; FBCBA8  0e
T_F41854_Nop:
	ret                                                  ; FBCBA9  0e
; LcdKeyRow1_CombiEditPartSelect: slot 8 (LCD key row 1, prom_a_panel_control_map.py) of ScreenButtons_CombiEditPartMenu and
;   ScreenButtons_CombiEditInternalSound: on the press, UI_PartIndex stepped through Record_F1AE1B (Record_F1AE24 in
;   panel-mode group 0x16) by T_EditValue_StepBitField; when it moved, T_PartIndex_PostChangeEvent, CombiEdit_Part = UI_PartIndex and a
;   repaint.  Basis: table (button code) + body.
LcdKeyRow1_CombiEditPartSelect:
	pushw hl                                             ; FBCBAA  2b
	push XIX                                             ; FBCBAB  3c
	lda xix, (PanelEvent_Flags:16)                                ; FBCBAC  f1 b0 28 34
	ld C,(XIX)                                           ; FBCBB0  84 23
	and C,0x01                                           ; FBCBB2  cb cc 01
	jr z, .LFBCBEE                                       ; FBCBB5  66 37
	and (XIX),0xfe                                       ; FBCBB7  84 3c fe
	cp	(PanelModeGroup:16), 0x16                            ; FBCBBA  c1 76 20 3f 16
	jr z, .LFBCBC9                                       ; FBCBBF  66 08
	lda xbc, (Record_F1AE1B:24)                          ; FBCBC1  f2 1b ae f1 31
	push XBC                                             ; FBCBC6  39
	jr .LFBCBCF                                          ; FBCBC7  68 06
.LFBCBC9:
	lda xbc, (Record_F1AE24:24)                          ; FBCBC9  f2 24 ae f1 31
	push XBC                                             ; FBCBCE  39
.LFBCBCF:
	lda xbc, (UI_PartIndex:16)                                ; FBCBCF  f1 50 22 31
	push XBC                                             ; FBCBD3  39
	call T_EditValue_StepBitField                                        ; FBCBD4  1d 78 2c f4
	ld H,A                                               ; FBCBD8  c9 8e
	inc 8,XSP                                            ; FBCBDA  ef 60
	cp a, 0x01:i3                                          ; FBCBDC  c9 d9
	jr nz, .LFBCBEE                                      ; FBCBDE  6e 0e
	call T_PartIndex_PostChangeEvent                                        ; FBCBE0  1d 9c 2c f4
	ld	(CombiEdit_Part:16), (UI_PartIndex:16)             ; FBCBE4  c1 50 22 19 65 27
	set	4, (UI_Request_Hi:16)                               ; FBCBEA  f1 71 20 bc
.LFBCBEE:
	pop XIX                                              ; FBCBEE  5c
	popw hl                                              ; FBCBEF  4b
	ret                                                  ; FBCBF0  0e
; LcdKeyRow2_CombiEditPartSelect: slot 9 (LCD key row 2) of the same two tables: the same part step on the press; on the release in panel-mode group
;   0x16, CombiEdit_ToggleSolo.  Basis: table (button code) + body.
LcdKeyRow2_CombiEditPartSelect:
	pushw hl                                             ; FBCBF1  2b
	ld c, (PanelEvent_Flags:16)                                   ; FBCBF2  c1 b0 28 23
	and C,0x01                                           ; FBCBF6  cb cc 01
	jr z, .LFBCC31                                       ; FBCBF9  66 36
	cp	(PanelModeGroup:16), 0x16                            ; FBCBFB  c1 76 20 3f 16
	jr z, .LFBCC0A                                       ; FBCC00  66 08
	lda xbc, (Record_F1AE1B:24)                          ; FBCC02  f2 1b ae f1 31
	push XBC                                             ; FBCC07  39
	jr .LFBCC10                                          ; FBCC08  68 06
.LFBCC0A:
	lda xbc, (Record_F1AE24:24)                          ; FBCC0A  f2 24 ae f1 31
	push XBC                                             ; FBCC0F  39
.LFBCC10:
	lda xbc, (UI_PartIndex:16)                                ; FBCC10  f1 50 22 31
	push XBC                                             ; FBCC14  39
	call T_EditValue_StepBitField                                        ; FBCC15  1d 78 2c f4
	ld H,A                                               ; FBCC19  c9 8e
	inc 8,XSP                                            ; FBCC1B  ef 60
	cp a, 0x01:i3                                          ; FBCC1D  c9 d9
	jr nz, .LFBCC3B                                      ; FBCC1F  6e 1a
	call T_PartIndex_PostChangeEvent                                        ; FBCC21  1d 9c 2c f4
	ld	(CombiEdit_Part:16), (UI_PartIndex:16)             ; FBCC25  c1 50 22 19 65 27
	set	4, (UI_Request_Hi:16)                               ; FBCC2B  f1 71 20 bc
	jr .LFBCC3B                                          ; FBCC2F  68 0a
.LFBCC31:
	cp	(PanelModeGroup:16), 0x16                            ; FBCC31  c1 76 20 3f 16
	jr nz, .LFBCC3B                                      ; FBCC36  6e 03
	calr CombiEdit_ToggleSolo                                          ; FBCC38  1e f7 2f
.LFBCC3B:
	popw hl                                              ; FBCC3B  4b
	ret                                                  ; FBCC3C  0e
; LcdKeyRow3_CombiEditPartMenu: ScreenButtons_CombiEditPartMenu[10], the 23-slot button table ScreenButton_CombiEditPartMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow3 handler of CombiEditPartMenu (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow3_CombiEditPartMenu:
	pushw hl                                             ; FBCC3D  2b
	push XIX                                             ; FBCC3E  3c
	lda xix, (UI_Request_Hi:16)                                ; FBCC3F  f1 71 20 34
	ld H,(XIX)                                           ; FBCC43  84 26
	set 0x07,H                                           ; FBCC45  ce 31 07
	ld c, (PanelEvent_Flags:16)                                   ; FBCC48  c1 b0 28 23
	and C,0x01                                           ; FBCC4C  cb cc 01
	jr z, .LFBCC5A                                       ; FBCC4F  66 09
	ld (XIX),H                                           ; FBCC51  b4 46
	ld (UI_Request:16), 0xb4                                 ; FBCC53  f1 70 20 00 b4
	jr .LFBCC61                                          ; FBCC58  68 07
.LFBCC5A:
	ld (XIX),H                                           ; FBCC5A  b4 46
	ld (UI_Request:16), 0xb2                                 ; FBCC5C  f1 70 20 00 b2
.LFBCC61:
	pop XIX                                              ; FBCC61  5c
	popw hl                                              ; FBCC62  4b
	ret                                                  ; FBCC63  0e
; LcdKeyRow4_CombiEditPartMenu: ScreenButtons_CombiEditPartMenu[11], the 23-slot button table ScreenButton_CombiEditPartMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow4 handler of CombiEditPartMenu (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow4_CombiEditPartMenu:
	pushw hl                                             ; FBCC64  2b
	push XIX                                             ; FBCC65  3c
	lda xix, (UI_Request_Hi:16)                                ; FBCC66  f1 71 20 34
	ld H,(XIX)                                           ; FBCC6A  84 26
	set 0x07,H                                           ; FBCC6C  ce 31 07
	ld c, (PanelEvent_Flags:16)                                   ; FBCC6F  c1 b0 28 23
	and C,0x01                                           ; FBCC73  cb cc 01
	jr z, .LFBCC81                                       ; FBCC76  66 09
	ld (XIX),H                                           ; FBCC78  b4 46
	ld (UI_Request:16), 0xb5                                 ; FBCC7A  f1 70 20 00 b5
	jr .LFBCC88                                          ; FBCC7F  68 07
.LFBCC81:
	ld (XIX),H                                           ; FBCC81  b4 46
	ld (UI_Request:16), 0xb7                                 ; FBCC83  f1 70 20 00 b7
.LFBCC88:
	pop XIX                                              ; FBCC88  5c
	popw hl                                              ; FBCC89  4b
	ret                                                  ; FBCC8A  0e
; LcdKeyRow5_CombiEditPartMenu: ScreenButtons_CombiEditPartMenu[12], the 23-slot button table ScreenButton_CombiEditPartMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow5 handler of CombiEditPartMenu (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow5_CombiEditPartMenu:
	ld c, (PanelEvent_Flags:16)                                   ; FBCC8B  c1 b0 28 23
	and C,0x01                                           ; FBCC8F  cb cc 01
	jr nz, .LFBCC9D                                      ; FBCC92  6e 09
	set	7, (UI_Request_Hi:16)                               ; FBCC94  f1 71 20 bf
	ld (UI_Request:16), 0x66                                 ; FBCC98  f1 70 20 00 66
.LFBCC9D:
	ret                                                  ; FBCC9D  0e
; ExitKey_CombiEditPartMenu: ScreenButtons_CombiEditPartMenu[15], the 23-slot button table ScreenButton_CombiEditPartMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   ExitKey handler of CombiEditPartMenu (notes/prom_ab_promb_slot23_targets.py).
ExitKey_CombiEditPartMenu:
	ld c, (PanelEvent_Flags:16)                                   ; FBCC9E  c1 b0 28 23
	and C,0x01                                           ; FBCCA2  cb cc 01
	jr nz, .LFBCCB0                                      ; FBCCA5  6e 09
	set	1, (UI_Request_Hi:16)                               ; FBCCA7  f1 71 20 b9
	ld (UI_Request:16), 0x01                                 ; FBCCAB  f1 70 20 00 01
.LFBCCB0:
	ret                                                  ; FBCCB0  0e
; CombiEdit_TakePartIndex: CombiEdit_Part := UI_PartIndex (written only when they differ). The COMBINATION EDIT menu /
;   part menu / internal sound / configure screens run it first on entry. Basis: callers + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_a.json)
CombiEdit_TakePartIndex:
	pushw hl                                             ; FBCCB1  2b
	ld h, (UI_PartIndex:16)                                   ; FBCCB2  c1 50 22 26
	cp	h, (CombiEdit_Part:16)                               ; FBCCB6  c1 65 27 f6
	jr z, .LFBCCC0                                       ; FBCCBA  66 04
	ld (CombiEdit_Part:16), h                                   ; FBCCBC  f1 65 27 46
.LFBCCC0:
	popw hl                                              ; FBCCC0  4b
	ret                                                  ; FBCCC1  0e
.LFBCCC2:
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; FBCCC2  1d 10 2e f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBCCC6  f1 40 25 00 02
	lda xbc, (DL_CopyFromSoundPlay:24)                   ; FBCCCB  f2 b7 8a f1 31
	push XBC                                             ; FBCCD0  39
	lda xwa, (DL_InternalSound_F18A1D:24)                ; FBCCD1  f2 1d 8a f1 30
	push XWA                                             ; FBCCD6  38
	call T_DisplayList_Run_Stack                         ; FBCCD7  1d 00 2e f4
	lda xbc, (DL_F18CD5:24)                              ; FBCCDB  f2 d5 8c f1 31
	push XBC                                             ; FBCCE0  39
	lda xwa, (DL_Part_F18C69:24)                         ; FBCCE1  f2 69 8c f1 30
	push XWA                                             ; FBCCE6  38
	call T_DisplayList_Run_Stack                         ; FBCCE7  1d 00 2e f4
	inc 8,XSP                                            ; FBCCEB  ef 60
	inc 8,XSP                                            ; FBCCED  ef 60
	ret                                                  ; FBCCEF  0e
.LFBCCF0:
	link XIZ,0xfffc                                      ; FBCCF0  ee 0c fc ff
	pushw hl                                             ; FBCCF4  2b
	push XIX                                             ; FBCCF5  3c
	lda xix, (CombiEdit_Part:16)                                ; FBCCF6  f1 65 27 34
	pushw 0x1d                                           ; FBCCFA  0b 1d 00
	ld C,(XIX)                                           ; FBCCFD  84 23
	extz BC                                              ; FBCCFF  d9 12
	add BC,0x0020                                        ; FBCD01  d9 c8 20 00
	pushw bc                                             ; FBCD05  29
	call T_IndexedTable_GetByte                          ; FBCD06  1d 90 2c f4
	ld (UI_DrawScratch:16), a                                   ; FBCD0A  f1 40 26 41
	pushw 0x0d                                           ; FBCD0E  0b 0d 00
	ld C,(XIX)                                           ; FBCD11  84 23
	pushw bc                                             ; FBCD13  29
	call T_IndexedTable_GetByte                          ; FBCD14  1d 90 2c f4
	ld (UI_DrawScratch+1:16), a                                   ; FBCD18  f1 41 26 41
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBCD1C  f1 40 25 00 02
	lda xbc, (StringTable_F19238:24)                     ; FBCD21  f2 38 92 f1 31
	push XBC                                             ; FBCD26  39
	lda xwa, (DL_F19207:24)                              ; FBCD27  f2 07 92 f1 30
	push XWA                                             ; FBCD2C  38
	call T_DisplayListB_Run_Stack                        ; FBCD2D  1d 04 2e f4
	ld C,(XIX)                                           ; FBCD31  84 23
	pushw bc                                             ; FBCD33  29
	call T_PartSound_CopyNameToDrawScratch                                        ; FBCD34  1d a0 2c f4
	lda xbc, (DL_F191F8:24)                              ; FBCD38  f2 f8 91 f1 31
	push XBC                                             ; FBCD3D  39
	call T_DisplayListB_RunOne_Stack                     ; FBCD3E  1d 0c 2e f4
	calr CombiEditSound_PageIndex                                      ; FBCD42  1e e2 03
	add XSP,0x00000016                                   ; FBCD45  ef c8 16 00 00 00
	cp a, 0x00:i3                                          ; FBCD4B  c9 d8
	jrl nz, .LFBCDE3                                     ; FBCD4D  7e 93 00
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBCD50  f1 40 25 00 00
	lda xbc, (UI_DrawScratch:16)                                ; FBCD55  f1 40 26 31
	ld (xiz-4), xbc                                      ; FBCD59  be fc 61
	lda xwa, (CombiEdit_TakePartIndex_DL:24)                              ; FBCD5C  f2 45 97 f1 30
	push XWA                                             ; FBCD61  38
	call T_DisplayListB_RunOne_Stack                     ; FBCD62  1d 0c 2e f4
	pushw 0x1b                                           ; FBCD66  0b 1b 00
	ld C,(XIX)                                           ; FBCD69  84 23
	extz BC                                              ; FBCD6B  d9 12
	add BC,0x0020                                        ; FBCD6D  d9 c8 20 00
	pushw bc                                             ; FBCD71  29
	call T_IndexedTable_GetByte                          ; FBCD72  1d 90 2c f4
	ld H,A                                               ; FBCD76  c9 8e
	ld xbc, (xiz-4)                                      ; FBCD78  ae fc 21
	ld (XBC),A                                           ; FBCD7B  b1 41
	ld C,H                                               ; FBCD7D  ce 8b
	sll c, 0x03                                          ; FBCD7F  cb ee 03
	ld H,C                                               ; FBCD82  cb 8e
	ld xbc, (xiz-4)                                      ; FBCD84  ae fc 21
	ld (XBC),H                                           ; FBCD87  b1 46
	pushw 0x1c                                           ; FBCD89  0b 1c 00
	ld C,(XIX)                                           ; FBCD8C  84 23
	extz BC                                              ; FBCD8E  d9 12
	add BC,0x0020                                        ; FBCD90  d9 c8 20 00
	pushw bc                                             ; FBCD94  29
	call T_IndexedTable_GetByte                          ; FBCD95  1d 90 2c f4
	ld xbc, (xiz-4)                                      ; FBCD99  ae fc 21
	add (XBC),A                                          ; FBCD9C  81 89
	ld xbc, (xiz-4)                                      ; FBCD9E  ae fc 21
	ld A,(XBC)                                           ; FBCDA1  81 21
	inc 1,A                                              ; FBCDA3  c9 61
	ld (XBC),A                                           ; FBCDA5  b1 41
	push XDE                                             ; FBCDA7  3a
	push XHL                                             ; FBCDA8  3b
	push XIX                                             ; FBCDA9  3c
	push XIZ                                             ; FBCDAA  3e
	ld a, (UI_DrawScratch:16)                                   ; FBCDAB  c1 40 26 21
	extz WA                                              ; FBCDAF  d8 12
	call T_Value_ToAsciiDigits3                          ; FBCDB1  1d 00 1b f4
	pop XIZ                                              ; FBCDB5  5e
	pop XIX                                              ; FBCDB6  5c
	pop XHL                                              ; FBCDB7  5b
	pop XDE                                              ; FBCDB8  5a
	pushw 0x1d                                           ; FBCDB9  0b 1d 00
	ld C,(XIX)                                           ; FBCDBC  84 23
	extz BC                                              ; FBCDBE  d9 12
	add BC,0x0020                                        ; FBCDC0  d9 c8 20 00
	pushw bc                                             ; FBCDC4  29
	call T_IndexedTable_GetByte                          ; FBCDC5  1d 90 2c f4
	ld (UI_DrawScratch:16), a                                   ; FBCDC9  f1 40 26 41
	lda xbc, (DL_F19772:24)                              ; FBCDCD  f2 72 97 f1 31
	push XBC                                             ; FBCDD2  39
	lda xwa, (DL_Rd1Rd2Ud1Ud2Ed1:24)                     ; FBCDD3  f2 54 97 f1 30
	push XWA                                             ; FBCDD8  38
	call T_DisplayListB_Run_Stack                        ; FBCDD9  1d 04 2e f4
	add XSP,0x00000018                                   ; FBCDDD  ef c8 18 00 00 00
.LFBCDE3:
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; FBCDE3  1d 14 2e f4
	pop XIX                                              ; FBCDE7  5c
	popw hl                                              ; FBCDE8  4b
	unlk XIZ                                             ; FBCDE9  ee 0d
	ret                                                  ; FBCDEB  0e
; ScreenEnter_CombiEditInternalSound_B4: the +0 ENTER method of the screen object for screen id 0xB4 -- PanelScreen_VtableTable entry 0xD4
;   (ViewB entry 0xB4) points at the thunk triple starting at T_ScreenEnter_CombiEditInternalSound_B4, and slot T_ScreenEnter_CombiEditInternalSound_B4 jumps here.
ScreenEnter_CombiEditInternalSound_B4:
	calr ScreenEnter_CombiEditInternalSound                                      ; FBCDEC  1e 0d 00
	ret                                                  ; FBCDEF  0e
; ScreenEnter_CombiEditInternalSound_B5: the +0 ENTER method of the screen object for screen id 0xB5 -- PanelScreen_VtableTable entry 0xD5
;   (ViewB entry 0xB5) points at the thunk triple starting at T_ScreenEnter_CombiEditInternalSound_B5, and slot T_ScreenEnter_CombiEditInternalSound_B5 jumps here.
ScreenEnter_CombiEditInternalSound_B5:
	calr ScreenEnter_CombiEditInternalSound                                      ; FBCDF0  1e 09 00
	ret                                                  ; FBCDF3  0e
; ScreenEnter_CombiEditInternalSound_37: the +0 ENTER method of the screen object for screen id 0x37 -- PanelScreen_VtableTable entry 0x57
;   (ViewB entry 0x37) points at the thunk triple starting at T_F41A48, and slot T_F41A48 jumps here.
ScreenEnter_CombiEditInternalSound_37:
	calr ScreenEnter_CombiEditInternalSound                                      ; FBCDF4  1e 05 00
	ret                                                  ; FBCDF7  0e
; ScreenEnter_CombiEditInternalSound_38: the +0 ENTER method of the screen object for screen id 0x38 -- PanelScreen_VtableTable entry 0x58
;   (ViewB entry 0x38) points at the thunk triple starting at T_F41A58, and slot T_F41A58 jumps here.
ScreenEnter_CombiEditInternalSound_38:
	calr ScreenEnter_CombiEditInternalSound                                      ; FBCDF8  1e 01 00
	ret                                                  ; FBCDFB  0e
; ScreenEnter_CombiEditInternalSound: the +0 ENTER method of the screen object for screen id 0xB1 -- PanelScreen_VtableTable entry 0xD1
;   (ViewB entry 0xB1) points at the thunk triple starting at T_ScreenEnter_CombiEditInternalSound, and slot T_ScreenEnter_CombiEditInternalSound jumps here.
; ScreenEnter_CombiEditInternalSound: screen 0xB1's +0 ENTER; 0x37, 0x38, 0xB4 and 0xB5 forward to it and to its
;   button method.  Its painters draw DL_CombiEdit ("PART", "COMBI.EDIT", "SOLO") and DL_InternalSound_F18CDD ("PAGE1/3",
;   "INTERNAL SOUND", "S0UND :", "V0LUME :", "PAN :", "KEY SHIFT :", ...) -- COMBINATION EDIT's INTERNAL SOUND pages.
ScreenEnter_CombiEditInternalSound:
	push XIX                                             ; FBCDFC  3c
	lda xix, (T_CallbackQueue_Post:24)                   ; FBCDFD  f2 84 2e f4 34
	ld c, (UI_ScreenLatch:16)                                   ; FBCE02  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FBCE06  c1 7b 20 f3
	jr z, .LFBCE20                                       ; FBCE0A  66 14
	ld (0x2768:16), 0x00                                 ; FBCE0C  f1 68 27 00 00
	ld (CombiEdit_Page:16), 0x00                                 ; FBCE11  f1 67 27 00 00
	ld (0x276a:16), 0x00                                 ; FBCE16  f1 6a 27 00 00
	ld (CombiEdit_Row:16), 0x00                                 ; FBCE1B  f1 69 27 00 00
.LFBCE20:
	ld c, (UI_ScreenId:16)                                   ; FBCE20  c1 7c 20 23
	cp	c, (UI_ScreenId_Previous:16)                               ; FBCE24  c1 7d 20 f3
	jr z, .LFBCE3C                                       ; FBCE28  66 12
	inc 0x01, (0x2768:16)                                ; FBCE2A  c1 68 27 61
	inc 0x01, (0x276a:16)                                ; FBCE2E  c1 6a 27 61
	ld (PanelDial_DownButton:16), 0x84                                 ; FBCE32  f1 9b 20 00 84
	ld (PanelDial_UpButton:16), 0x04                                 ; FBCE37  f1 9c 20 00 04
.LFBCE3C:
	set	0, (UI_RequestBits:16)                               ; FBCE3C  f1 75 20 b8
	calr CombiEdit_TakePartIndex                                      ; FBCE40  1e 6e fe
	calr CombiEditSound_SetRowFieldBlink                                      ; FBCE43  1e a8 02
	ld c, (UI_ScreenFlags:16)                                   ; FBCE46  c1 95 20 23
	and C,0x10                                           ; FBCE4A  cb cc 10
	jrl nz, .LFBCECE                                     ; FBCE4D  7e 7e 00
	ld c, (UI_ScreenId:16)                                   ; FBCE50  c1 7c 20 23
	cp	c, (UI_ScreenId_Previous:16)                               ; FBCE54  c1 7d 20 f3
	jr z, .LFBCE75                                       ; FBCE58  66 1b
	call T_CallbackQueue_ResetAndRestartTask2            ; FBCE5A  1d 80 2e f4
	lda xbc, (.LFBD19B:24)                               ; FBCE5E  f2 9b d1 fb 31
	push XBC                                             ; FBCE63  39
	lda xiy, (.LFBCE6C:24)                               ; FBCE64  f2 6c ce fb 35
	push XIY                                             ; FBCE69  3d
	jp (xix)                                             ; FBCE6A  b4 d8
.LFBCE6C:
	pushw 0x01                                           ; FBCE6C  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBCE6F  1d c0 2d f4
	inc 6,XSP                                            ; FBCE73  ef 66
.LFBCE75:
	ld c, (CombiEdit_Page:16)                                   ; FBCE75  c1 67 27 23
	cp	c, (0x2768:16)                               ; FBCE79  c1 68 27 f3
	jr z, .LFBCE96                                       ; FBCE7D  66 17
	lda xbc, (.LFBD222:24)                               ; FBCE7F  f2 22 d2 fb 31
	push XBC                                             ; FBCE84  39
	lda xiy, (.LFBCE8D:24)                               ; FBCE85  f2 8d ce fb 35
	push XIY                                             ; FBCE8A  3d
	jp (xix)                                             ; FBCE8B  b4 d8
.LFBCE8D:
	pushw 0x01                                           ; FBCE8D  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBCE90  1d c0 2d f4
	inc 6,XSP                                            ; FBCE94  ef 66
.LFBCE96:
	ld c, (CombiEdit_Row:16)                                   ; FBCE96  c1 69 27 23
	cp	c, (0x276a:16)                               ; FBCE9A  c1 6a 27 f3
	jr z, .LFBCEB7                                       ; FBCE9E  66 17
	lda xbc, (.LFBD302:24)                               ; FBCEA0  f2 02 d3 fb 31
	push XBC                                             ; FBCEA5  39
	lda xiy, (.LFBCEAE:24)                               ; FBCEA6  f2 ae ce fb 35
	push XIY                                             ; FBCEAB  3d
	jp (xix)                                             ; FBCEAC  b4 d8
.LFBCEAE:
	pushw 0x01                                           ; FBCEAE  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBCEB1  1d c0 2d f4
	inc 6,XSP                                            ; FBCEB5  ef 66
.LFBCEB7:
	lda xbc, (.LFBCCF0:24)                               ; FBCEB7  f2 f0 cc fb 31
	push XBC                                             ; FBCEBC  39
	lda xiy, (.LFBCEC5:24)                               ; FBCEBD  f2 c5 ce fb 35
	push XIY                                             ; FBCEC2  3d
	jp (xix)                                             ; FBCEC3  b4 d8
.LFBCEC5:
	pushw 0x01                                           ; FBCEC5  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBCEC8  1d c0 2d f4
	inc 6,XSP                                            ; FBCECC  ef 66
.LFBCECE:
	lda xbc, (.LFBD397:24)                               ; FBCECE  f2 97 d3 fb 31
	push XBC                                             ; FBCED3  39
	lda xiy, (.LFBCEDC:24)                               ; FBCED4  f2 dc ce fb 35
	push XIY                                             ; FBCED9  3d
	jp (xix)                                             ; FBCEDA  b4 d8
.LFBCEDC:
	pushw 0x01                                           ; FBCEDC  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBCEDF  1d c0 2d f4
	inc 6,XSP                                            ; FBCEE3  ef 66
	pop XIX                                              ; FBCEE5  5c
	ret                                                  ; FBCEE6  0e
; ScreenLeave_CombiEditInternalSound_B4: the +4 LEAVE method of the screen object for screen id 0xB4 -- PanelScreen_VtableTable entry 0xD4
;   (ViewB entry 0xB4) points at the thunk triple starting at T_ScreenEnter_CombiEditInternalSound_B4, and slot T_ScreenLeave_CombiEditInternalSound_B4 jumps here.
ScreenLeave_CombiEditInternalSound_B4:
	calr T_F4185C_Nop                                      ; FBCEE7  1e 0d 00
	ret                                                  ; FBCEEA  0e
; ScreenLeave_CombiEditInternalSound_B5: the +4 LEAVE method of the screen object for screen id 0xB5 -- PanelScreen_VtableTable entry 0xD5
;   (ViewB entry 0xB5) points at the thunk triple starting at T_ScreenEnter_CombiEditInternalSound_B5, and slot T_ScreenLeave_CombiEditInternalSound_B5 jumps here.
ScreenLeave_CombiEditInternalSound_B5:
	calr T_F4185C_Nop                                      ; FBCEEB  1e 09 00
	ret                                                  ; FBCEEE  0e
; ScreenLeave_CombiEditInternalSound_37: the +4 LEAVE method of the screen object for screen id 0x37 -- PanelScreen_VtableTable entry 0x57
;   (ViewB entry 0x37) points at the thunk triple starting at T_F41A48, and slot T_F41A4C jumps here.
ScreenLeave_CombiEditInternalSound_37:
	calr T_F4185C_Nop                                      ; FBCEEF  1e 05 00
	ret                                                  ; FBCEF2  0e
; ScreenLeave_CombiEditInternalSound_38: the +4 LEAVE method of the screen object for screen id 0x38 -- PanelScreen_VtableTable entry 0x58
;   (ViewB entry 0x38) points at the thunk triple starting at T_F41A58, and slot T_F41A5C jumps here.
ScreenLeave_CombiEditInternalSound_38:
	calr T_F4185C_Nop                                      ; FBCEF3  1e 01 00
	ret                                                  ; FBCEF6  0e
T_F4185C_Nop:
	ret                                                  ; FBCEF7  0e
; ScreenButton_CombiEditInternalSound_B4: the +8 BUTTON method of the screen object for screen id 0xB4 -- PanelScreen_VtableTable entry 0xD4
;   (ViewB entry 0xB4) points at the thunk triple starting at T_ScreenEnter_CombiEditInternalSound_B4, and slot T_ScreenButton_CombiEditInternalSound_B4 jumps here.
ScreenButton_CombiEditInternalSound_B4:
	link XIZ,0x0000                                      ; FBCEF8  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBCEFC  9e 0a 04
	pushw	(xiz+8)                                      ; FBCEFF  9e 08 04
	calr ScreenButton_CombiEditInternalSound                                      ; FBCF02  1e 37 00
	pop XBC                                              ; FBCF05  59
	unlk XIZ                                             ; FBCF06  ee 0d
	ret                                                  ; FBCF08  0e
; ScreenButton_CombiEditInternalSound_B5: the +8 BUTTON method of the screen object for screen id 0xB5 -- PanelScreen_VtableTable entry 0xD5
;   (ViewB entry 0xB5) points at the thunk triple starting at T_ScreenEnter_CombiEditInternalSound_B5, and slot T_ScreenButton_CombiEditInternalSound_B5 jumps here.
ScreenButton_CombiEditInternalSound_B5:
	link XIZ,0x0000                                      ; FBCF09  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBCF0D  9e 0a 04
	pushw	(xiz+8)                                      ; FBCF10  9e 08 04
	calr ScreenButton_CombiEditInternalSound                                      ; FBCF13  1e 26 00
	pop XBC                                              ; FBCF16  59
	unlk XIZ                                             ; FBCF17  ee 0d
	ret                                                  ; FBCF19  0e
; ScreenButton_CombiEditInternalSound_37: the +8 BUTTON method of the screen object for screen id 0x37 -- PanelScreen_VtableTable entry 0x57
;   (ViewB entry 0x37) points at the thunk triple starting at T_F41A48, and slot T_F41A50 jumps here.
ScreenButton_CombiEditInternalSound_37:
	link XIZ,0x0000                                      ; FBCF1A  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBCF1E  9e 0a 04
	pushw	(xiz+8)                                      ; FBCF21  9e 08 04
	calr ScreenButton_CombiEditInternalSound                                      ; FBCF24  1e 15 00
	pop XBC                                              ; FBCF27  59
	unlk XIZ                                             ; FBCF28  ee 0d
	ret                                                  ; FBCF2A  0e
; ScreenButton_CombiEditInternalSound_38: the +8 BUTTON method of the screen object for screen id 0x38 -- PanelScreen_VtableTable entry 0x58
;   (ViewB entry 0x38) points at the thunk triple starting at T_F41A58, and slot T_F41A60 jumps here.
ScreenButton_CombiEditInternalSound_38:
	link XIZ,0x0000                                      ; FBCF2B  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBCF2F  9e 0a 04
	pushw	(xiz+8)                                      ; FBCF32  9e 08 04
	calr ScreenButton_CombiEditInternalSound                                      ; FBCF35  1e 04 00
	pop XBC                                              ; FBCF38  59
	unlk XIZ                                             ; FBCF39  ee 0d
	ret                                                  ; FBCF3B  0e
; ScreenButton_CombiEditInternalSound: the +8 BUTTON method of the screen object for screen id 0xB1 -- PanelScreen_VtableTable entry 0xD1
;   (ViewB entry 0xB1) points at the thunk triple starting at T_ScreenEnter_CombiEditInternalSound, and slot T_ScreenButton_CombiEditInternalSound jumps here.
ScreenButton_CombiEditInternalSound:
	link XIZ,0x0000                                      ; FBCF3C  ee 0c 00 00
	cp	(PanelModeGroup:16), 0x16                            ; FBCF40  c1 76 20 3f 16
	jr nz, .LFBCF5A                                      ; FBCF45  6e 13
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBCF47  c1 7f 27 3f 01
	jr nz, .LFBCF5A                                      ; FBCF4C  6e 0c
	cpw	(xiz+8), 0x001e                              ; FBCF4E  9e 08 3f 1e 00
	jr nz, .LFBCF7A                                      ; FBCF53  6e 25
	calr CompareKey_CombiEdit                                          ; FBCF55  1e 66 1e
	jr .LFBCF7A                                          ; FBCF58  68 20
.LFBCF5A:
	pushw	(xiz+10)                                     ; FBCF5A  9e 0a 04
	pushw	(xiz+8)                                      ; FBCF5D  9e 08 04
	call T_PanelCode_ToSlotAndFlags                                        ; FBCF60  1d 74 2c f4
	mul A,0x04                                           ; FBCF64  c9 08 04
	extz XWA                                             ; FBCF67  e8 12
	add XWA,ScreenButtons_CombiEditInternalSound                              ; FBCF69  e8 c8 11 af f1 00
	ld XBC,(XWA)                                         ; FBCF6F  a0 21
	lda xiy, (.LFBCF79:24)                               ; FBCF71  f2 79 cf fb 35
	push XIY                                             ; FBCF76  3d
	jp (xbc)                                             ; FBCF77  b1 d8
.LFBCF79:
	pop XIY                                              ; FBCF79  5d
.LFBCF7A:
	unlk XIZ                                             ; FBCF7A  ee 0d
	ret                                                  ; FBCF7C  0e
T_F41894_Nop:
	ret                                                  ; FBCF7D  0e
T_F418A4_Nop:
	ret                                                  ; FBCF7E  0e
T_F41A54_Nop:
	ret                                                  ; FBCF7F  0e
T_F41A64_Nop:
	ret                                                  ; FBCF80  0e
T_F41864_Nop:
	ret                                                  ; FBCF81  0e
; SoftKeyCols1to4_CombiEditInternalSound: ScreenButtons_CombiEditInternalSound slots [0, 1, 2, 3], the 23-slot button table ScreenButton_CombiEditInternalSound reads through T_PanelCode_ToSlotAndFlags --
;   one handler for soft keys 1, 2, 3, 4 of CombiEditInternalSound (notes/prom_ab_promb_slot23_targets.py).
SoftKeyCols1to4_CombiEditInternalSound:
	link XIZ,0xfff6                                      ; FBCF82  ee 0c f6 ff
	pushw hl                                             ; FBCF86  2b
	push XIX                                             ; FBCF87  3c
	ldw bc, 0x09                                         ; FBCF88  31 09 00
	lda xiy, (Record_F1AAA0:24)                          ; FBCF8B  f2 a0 aa f1 35
	lda xix, (xiz-10)                                    ; FBCF90  be f6 34
	ldir85                                               ; FBCF93  85 11
	calr CombiEditSound_PageIndex                                      ; FBCF95  1e 8f 01
	ld H,A                                               ; FBCF98  c9 8e
	ld (xiz-1), a                                        ; FBCF9A  be ff 41
	cp H,0xff                                            ; FBCF9D  ce cf ff
	jr z, SoftKeyCols1to4_CombiEditInternalSound_Skip                                     ; FBCFA0  66 2a
	extz WA                                              ; FBCFA2  d8 12
	extz XWA                                             ; FBCFA4  e8 12
	add XWA,IndexMap_F1AF6D                              ; FBCFA6  e8 c8 6d af f1 00
	ld C,(XWA)                                           ; FBCFAC  80 23
	ld (xiz-7), c                                        ; FBCFAE  be f9 43
	lda xbc, (xiz-10)                                    ; FBCFB1  be f6 31
	push XBC                                             ; FBCFB4  39
	lda xwa, (CombiEdit_Row:16)                                ; FBCFB5  f1 69 27 30
	push XWA                                             ; FBCFB9  38
	call T_EditValue_StepBitField                                        ; FBCFBA  1d 78 2c f4
	inc 8,XSP                                            ; FBCFBE  ef 60
	cp a, 0x01:i3                                          ; FBCFC0  c9 d9
	jr nz, SoftKeyCols1to4_CombiEditInternalSound_Skip                                    ; FBCFC2  6e 08
	call T_Blink_Stop                                    ; FBCFC4  1d 24 2e f4
	set	4, (UI_Request_Hi:16)                               ; FBCFC8  f1 71 20 bc
SoftKeyCols1to4_CombiEditInternalSound_Skip:
	pop XIX                                              ; FBCFCC  5c
	popw hl                                              ; FBCFCD  4b
	unlk XIZ                                             ; FBCFCE  ee 0d
	ret                                                  ; FBCFD0  0e
; SoftKeyCols5to8_CombiEditInternalSound: ScreenButtons_CombiEditInternalSound slots [4, 5, 6, 7], the 23-slot button table ScreenButton_CombiEditInternalSound reads through T_PanelCode_ToSlotAndFlags --
;   one handler for soft keys 5, 6, 7, 8 of CombiEditInternalSound (notes/prom_ab_promb_slot23_targets.py).
SoftKeyCols5to8_CombiEditInternalSound:
	pushw hl                                             ; FBCFD1  2b
	push XIX                                             ; FBCFD2  3c
	calr CombiEditSound_PageIndex                                      ; FBCFD3  1e 51 01
	ld H,A                                               ; FBCFD6  c9 8e
	cp A,0xff                                            ; FBCFD8  c9 cf ff
	jr z, .LFBD003                                       ; FBCFDB  66 26
	push 0x00                                            ; FBCFDD  09 00
	push	(CombiEdit_Part:16)                                  ; FBCFDF  c1 65 27 04
	mul A,0x04                                           ; FBCFE3  c9 08 04
	extz XWA                                             ; FBCFE6  e8 12
	add XWA,PtrTable_F1AFA5                              ; FBCFE8  e8 c8 a5 af f1 00
	ld XBC,(XWA)                                         ; FBCFEE  a0 21
	ld XIX,XBC                                           ; FBCFF0  e9 8c
	ld wa, (CombiEdit_Row:16)                                 ; FBCFF2  d1 69 27 20
	extz WA                                              ; FBCFF6  d8 12
	extz XWA                                             ; FBCFF8  e8 12
	add XBC,XWA                                          ; FBCFFA  e8 81
	ld A,(XBC)                                           ; FBCFFC  81 21
	pushw wa                                             ; FBCFFE  28
	calr PartParam_StepFieldById                                      ; FBCFFF  1e fe e7
	pop XIY                                              ; FBD002  5d
.LFBD003:
	call T_Blink_GetState                                ; FBD003  1d 30 2e f4
	cp a, 0x02:i3                                          ; FBD007  c9 da
	jr nz, .LFBD013                                      ; FBD009  6e 08
	call T_Blink_Stop                                    ; FBD00B  1d 24 2e f4
	set	4, (UI_ScreenFlags:16)                               ; FBD00F  f1 95 20 bc
.LFBD013:
	pop XIX                                              ; FBD013  5c
	popw hl                                              ; FBD014  4b
	ret                                                  ; FBD015  0e
; ExitKey_CombiEditInternalSound: ScreenButtons_CombiEditInternalSound[15], the 23-slot button table ScreenButton_CombiEditInternalSound reads through T_PanelCode_ToSlotAndFlags -- the
;   ExitKey handler of CombiEditInternalSound (notes/prom_ab_promb_slot23_targets.py).
ExitKey_CombiEditInternalSound:
	pushw hl                                             ; FBD016  2b
	push XIX                                             ; FBD017  3c
	lda xix, (UI_Request_Hi:16)                                ; FBD018  f1 71 20 34
	ld c, (PanelEvent_Flags:16)                                   ; FBD01C  c1 b0 28 23
	and C,0x01                                           ; FBD020  cb cc 01
	jr nz, .LFBD041                                      ; FBD023  6e 1c
	ld H,(XIX)                                           ; FBD025  84 26
	set 0x07,H                                           ; FBD027  ce 31 07
	cp	(PanelModeGroup:16), 0x09                            ; FBD02A  c1 76 20 3f 09
	jr nz, .LFBD03A                                      ; FBD02F  6e 09
	ld (XIX),H                                           ; FBD031  b4 46
	ld (UI_Request:16), 0xb0                                 ; FBD033  f1 70 20 00 b0
	jr .LFBD041                                          ; FBD038  68 07
.LFBD03A:
	ld (XIX),H                                           ; FBD03A  b4 46
	ld (UI_Request:16), 0x34                                 ; FBD03C  f1 70 20 00 34
.LFBD041:
	pop XIX                                              ; FBD041  5c
	popw hl                                              ; FBD042  4b
	ret                                                  ; FBD043  0e
; PageKey_CombiEditInternalSound: ScreenButtons_CombiEditInternalSound[16], the 23-slot button table ScreenButton_CombiEditInternalSound reads through T_PanelCode_ToSlotAndFlags -- the
;   PageKey handler of CombiEditInternalSound (notes/prom_ab_promb_slot23_targets.py).
PageKey_CombiEditInternalSound:
	ld bc, (UI_ScreenId:16)                                 ; FBD044  d1 7c 20 21
	extz BC                                              ; FBD048  d9 12
	cp BC,0x0037                                         ; FBD04A  d9 cf 37 00
	jr z, .LFBD064                                       ; FBD04E  66 14
	cp BC,0x0038                                         ; FBD050  d9 cf 38 00
	jr z, .LFBD064                                       ; FBD054  66 0e
	cp BC,0x00b4                                         ; FBD056  d9 cf b4 00
	jr z, .LFBD064                                       ; FBD05A  66 08
	cp BC,0x00b5                                         ; FBD05C  d9 cf b5 00
	jr z, .LFBD07B                                       ; FBD060  66 19
	jr .LFBD0A3                                          ; FBD062  68 3f
.LFBD064:
	lda xbc, (Record_F1AE2D:24)                          ; FBD064  f2 2d ae f1 31
	push XBC                                             ; FBD069  39
	lda xwa, (CombiEdit_Page:16)                                ; FBD06A  f1 67 27 30
	push XWA                                             ; FBD06E  38
	call T_EditValue_StepBitField                                        ; FBD06F  1d 78 2c f4
	inc 8,XSP                                            ; FBD073  ef 60
	cp a, 0x01:i3                                          ; FBD075  c9 d9
	jr nz, .LFBD0A3                                      ; FBD077  6e 2a
	jr .LFBD090                                          ; FBD079  68 15
.LFBD07B:
	lda xbc, (Record_F1AE36:24)                          ; FBD07B  f2 36 ae f1 31
	push XBC                                             ; FBD080  39
	lda xwa, (CombiEdit_Page:16)                                ; FBD081  f1 67 27 30
	push XWA                                             ; FBD085  38
	call T_EditValue_StepBitField                                        ; FBD086  1d 78 2c f4
	inc 8,XSP                                            ; FBD08A  ef 60
	cp a, 0x01:i3                                          ; FBD08C  c9 d9
	jr nz, .LFBD0A3                                      ; FBD08E  6e 13
.LFBD090:
	ld (0x276a:16), 0x00                                 ; FBD090  f1 6a 27 00 00
	ld (CombiEdit_Row:16), 0x00                                 ; FBD095  f1 69 27 00 00
	ld (0x276a:16), 0x01                                 ; FBD09A  f1 6a 27 00 01
	set	4, (UI_Request_Hi:16)                               ; FBD09F  f1 71 20 bc
.LFBD0A3:
	ret                                                  ; FBD0A3  0e
; NumberPadKey_CombiEditInternalSound: ScreenButtons_CombiEditInternalSound[18], the 23-slot button table ScreenButton_CombiEditInternalSound reads through T_PanelCode_ToSlotAndFlags -- the
;   NumberPadKey handler of CombiEditInternalSound (notes/prom_ab_promb_slot23_targets.py).
NumberPadKey_CombiEditInternalSound:
	pushw hl                                             ; FBD0A4  2b
	push XIX                                             ; FBD0A5  3c
	calr CombiEditSound_PageIndex                                      ; FBD0A6  1e 7e 00
	ld H,A                                               ; FBD0A9  c9 8e
	cp A,0xff                                            ; FBD0AB  c9 cf ff
	jr z, .LFBD0EB                                       ; FBD0AE  66 3b
	ld c, (PanelEvent_Flags:16)                                   ; FBD0B0  c1 b0 28 23
	and C,0x20                                           ; FBD0B4  cb cc 20
	jr z, .LFBD0E7                                       ; FBD0B7  66 2e
	push 0x00                                            ; FBD0B9  09 00
	push	(CombiEdit_Part:16)                                  ; FBD0BB  c1 65 27 04
	mul A,0x04                                           ; FBD0BF  c9 08 04
	extz XWA                                             ; FBD0C2  e8 12
	add XWA,PtrTable_F1AFA5                              ; FBD0C4  e8 c8 a5 af f1 00
	ld XBC,(XWA)                                         ; FBD0CA  a0 21
	ld XIX,XBC                                           ; FBD0CC  e9 8c
	ld wa, (CombiEdit_Row:16)                                 ; FBD0CE  d1 69 27 20
	extz WA                                              ; FBD0D2  d8 12
	extz XWA                                             ; FBD0D4  e8 12
	add XBC,XWA                                          ; FBD0D6  e8 81
	ld A,(XBC)                                           ; FBD0D8  81 21
	pushw wa                                             ; FBD0DA  28
	calr PartParam_EnterFieldById                                      ; FBD0DB  1e 5e e8
	pop XIY                                              ; FBD0DE  5d
	cp a, 0x01:i3                                          ; FBD0DF  c9 d9
	jr nz, .LFBD0E7                                      ; FBD0E1  6e 04
	call T_Blink_Stop                                    ; FBD0E3  1d 24 2e f4
.LFBD0E7:
	set	4, (UI_ScreenFlags:16)                               ; FBD0E7  f1 95 20 bc
.LFBD0EB:
	pop XIX                                              ; FBD0EB  5c
	popw hl                                              ; FBD0EC  4b
	ret                                                  ; FBD0ED  0e
; CombiEditSound_SetRowFieldBlink: On the INTERNAL SOUND pages (CombiEditSound_PageIndex != 0xFF): sets
;   PanelEvent_Flags bit 6, then PartParam_EnterFieldById(field id PtrTable_F1AFA5[page][CombiEdit_Row],
;   CombiEdit_Part) -- every Enter arm is IndexedParam_SetFieldFromAsciiEntry(descriptor), which with bit 6 only sets
;   T_Blink_SetEnable 0/1 and clears the bit, or PartParam_RefuseNumberEntry (blink 0). Called by
;   ScreenEnter_CombiEditInternalSound. Basis: caller + body + the bit-6 arm. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
CombiEditSound_SetRowFieldBlink:
	pushw hl                                             ; FBD0EE  2b
	push XIX                                             ; FBD0EF  3c
	calr CombiEditSound_PageIndex                                      ; FBD0F0  1e 34 00
	ld H,A                                               ; FBD0F3  c9 8e
	cp A,0xff                                            ; FBD0F5  c9 cf ff
	jr z, .LFBD124                                       ; FBD0F8  66 2a
	set	6, (PanelEvent_Flags:16)                               ; FBD0FA  f1 b0 28 be
	push 0x00                                            ; FBD0FE  09 00
	push	(CombiEdit_Part:16)                                  ; FBD100  c1 65 27 04
	mul A,0x04                                           ; FBD104  c9 08 04
	extz XWA                                             ; FBD107  e8 12
	add XWA,PtrTable_F1AFA5                              ; FBD109  e8 c8 a5 af f1 00
	ld XBC,(XWA)                                         ; FBD10F  a0 21
	ld XIX,XBC                                           ; FBD111  e9 8c
	ld wa, (CombiEdit_Row:16)                                 ; FBD113  d1 69 27 20
	extz WA                                              ; FBD117  d8 12
	extz XWA                                             ; FBD119  e8 12
	add XBC,XWA                                          ; FBD11B  e8 81
	ld A,(XBC)                                           ; FBD11D  81 21
	pushw wa                                             ; FBD11F  28
	calr PartParam_EnterFieldById                                      ; FBD120  1e 19 e8
	pop XIY                                              ; FBD123  5d
.LFBD124:
	pop XIX                                              ; FBD124  5c
	popw hl                                              ; FBD125  4b
	ret                                                  ; FBD126  0e
; CombiEditSound_PageIndex: A = the INTERNAL SOUND page painter's index for the screen and CombiEdit_Page: screens 0x37 / 0xB4 pages 0 / 1 / 2
;   -> 0 / 1 / 2, screen 0xB5 pages 0 / 1 -> 3 / 4, screen 0x38 pages 0 / 1 / 2 -> 5 / 3 / 4, else 0xFF.  Callers include
;   CombiEditPage_OnPartParamEvent and the INTERNAL SOUND soft keys.  Basis: body.
CombiEditSound_PageIndex:
	pushw hl                                             ; FBD127  2b
	ld h, (CombiEdit_Page:16)                                   ; FBD128  c1 67 27 26
	ld bc, (UI_ScreenId:16)                                 ; FBD12C  d1 7c 20 21
	extz BC                                              ; FBD130  d9 12
	cp BC,0x0037                                         ; FBD132  d9 cf 37 00
	jr z, .LFBD14D                                       ; FBD136  66 15
	cp BC,0x0038                                         ; FBD138  d9 cf 38 00
	jr z, .LFBD179                                       ; FBD13C  66 3b
	cp BC,0x00b4                                         ; FBD13E  d9 cf b4 00
	jr z, .LFBD14D                                       ; FBD142  66 09
	cp BC,0x00b5                                         ; FBD144  d9 cf b5 00
	jr z, .LFBD16B                                       ; FBD148  66 21
	jrl .LFBD197                                         ; FBD14A  78 4a 00
.LFBD14D:
	ld C,H                                               ; FBD14D  ce 8b
	extz BC                                              ; FBD14F  d9 12
	cp bc, 0x00:i3                                         ; FBD151  d9 d8
	jr z, .LFBD15F                                       ; FBD153  66 0a
	cp bc, 0x01:i3                                         ; FBD155  d9 d9
	jr z, .LFBD163                                       ; FBD157  66 0a
	cp bc, 0x02:i3                                         ; FBD159  d9 da
	jr z, .LFBD167                                       ; FBD15B  66 0a
	jr .LFBD197                                          ; FBD15D  68 38
.LFBD15F:
	sub A,A                                              ; FBD15F  c9 a1
	jr .LFBD199                                          ; FBD161  68 36
.LFBD163:
	ld a, 0x01:opc                                          ; FBD163  21 01
	jr .LFBD199                                          ; FBD165  68 32
.LFBD167:
	ld a, 0x02:opc                                          ; FBD167  21 02
	jr .LFBD199                                          ; FBD169  68 2e
.LFBD16B:
	ld C,H                                               ; FBD16B  ce 8b
	extz BC                                              ; FBD16D  d9 12
	cp bc, 0x00:i3                                         ; FBD16F  d9 d8
	jr z, .LFBD18F                                       ; FBD171  66 1c
	cp bc, 0x01:i3                                         ; FBD173  d9 d9
	jr z, .LFBD193                                       ; FBD175  66 1c
	jr .LFBD197                                          ; FBD177  68 1e
.LFBD179:
	ld C,H                                               ; FBD179  ce 8b
	extz BC                                              ; FBD17B  d9 12
	cp bc, 0x00:i3                                         ; FBD17D  d9 d8
	jr z, .LFBD18B                                       ; FBD17F  66 0a
	cp bc, 0x01:i3                                         ; FBD181  d9 d9
	jr z, .LFBD18F                                       ; FBD183  66 0a
	cp bc, 0x02:i3                                         ; FBD185  d9 da
	jr z, .LFBD193                                       ; FBD187  66 0a
	jr .LFBD197                                          ; FBD189  68 0c
.LFBD18B:
	ld a, 0x05:opc                                          ; FBD18B  21 05
	jr .LFBD199                                          ; FBD18D  68 0a
.LFBD18F:
	ld a, 0x03:opc                                          ; FBD18F  21 03
	jr .LFBD199                                          ; FBD191  68 06
.LFBD193:
	ld a, 0x04:opc                                          ; FBD193  21 04
	jr .LFBD199                                          ; FBD195  68 02
.LFBD197:
	ld a, 0xff:opc                                          ; FBD197  21 ff
.LFBD199:
	popw hl                                              ; FBD199  4b
	ret                                                  ; FBD19A  0e
.LFBD19B:
	push XIX                                             ; FBD19B  3c
	lda xix, (T_DisplayList_Run_Stack:24)                ; FBD19C  f2 00 2e f4 34
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; FBD1A1  1d 10 2e f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBD1A5  f1 40 25 00 02
	lda xbc, (DL_F18CD5:24)                              ; FBD1AA  f2 d5 8c f1 31
	push XBC                                             ; FBD1AF  39
	lda xwa, (DL_Part_F18C69:24)                         ; FBD1B0  f2 69 8c f1 30
	push XWA                                             ; FBD1B5  38
	lda xiy, (.LFBD1BE:24)                               ; FBD1B6  f2 be d1 fb 35
	push XIY                                             ; FBD1BB  3d
	jp (xix)                                             ; FBD1BC  b4 d8
.LFBD1BE:
	lda xbc, (DL_Part_F18C69:24)                         ; FBD1BE  f2 69 8c f1 31
	push XBC                                             ; FBD1C3  39
	lda xwa, (CombiEditSound_PageIndex_DL:24)                              ; FBD1C4  f2 1c 8c f1 30
	push XWA                                             ; FBD1C9  38
	lda xiy, (.LFBD1D2:24)                               ; FBD1CA  f2 d2 d1 fb 35
	push XIY                                             ; FBD1CF  3d
	jp (xix)                                             ; FBD1D0  b4 d8
.LFBD1D2:
	inc 8,XSP                                            ; FBD1D2  ef 60
	inc 8,XSP                                            ; FBD1D4  ef 60
	cp	(PanelModeGroup:16), 0x09                            ; FBD1D6  c1 76 20 3f 09
	jr nz, .LFBD1EB                                      ; FBD1DB  6e 0e
	lda xbc, (DL_CombiEdit:24)                           ; FBD1DD  f2 ce 8b f1 31
	push XBC                                             ; FBD1E2  39
	lda xwa, (DL_Part_F18BBA:24)                         ; FBD1E3  f2 ba 8b f1 30
	push XWA                                             ; FBD1E8  38
	jr .LFBD212                                          ; FBD1E9  68 27
.LFBD1EB:
	lda xbc, (DL_Solo_F18BE8:24)                         ; FBD1EB  f2 e8 8b f1 31
	push XBC                                             ; FBD1F0  39
	lda xwa, (DL_CombiEdit:24)                           ; FBD1F1  f2 ce 8b f1 30
	push XWA                                             ; FBD1F6  38
	lda xiy, (.LFBD1FF:24)                               ; FBD1F7  f2 ff d1 fb 35
	push XIY                                             ; FBD1FC  3d
	jp (xix)                                             ; FBD1FD  b4 d8
.LFBD1FF:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBD1FF  f1 40 25 00 00
	inc 8,XSP                                            ; FBD204  ef 60
	lda xbc, (DL_F18C08:24)                              ; FBD206  f2 08 8c f1 31
	push XBC                                             ; FBD20B  39
	lda xwa, (DL_Solo_F18BE8:24)                         ; FBD20C  f2 e8 8b f1 30
	push XWA                                             ; FBD211  38
.LFBD212:
	lda xiy, (.LFBD21A:24)                               ; FBD212  f2 1a d2 fb 35
	push XIY                                             ; FBD217  3d
	jp (xix)                                             ; FBD218  b4 d8
.LFBD21A:
	call T_UiPaint_PageLabelBackdrop                                        ; FBD21A  1d 18 2e f4
	inc 8,XSP                                            ; FBD21E  ef 60
	pop XIX                                              ; FBD220  5c
	ret                                                  ; FBD221  0e
.LFBD222:
	pushw hl                                             ; FBD222  2b
	ld h, 0x00:opc                                          ; FBD223  26 00
.LFBD225:
	ld (LCD_CurrentLayer:16), h                                   ; FBD225  f1 40 25 46
	lda xbc, (DL_InternalSound_F18CDD:24)                ; FBD229  f2 dd 8c f1 31
	push XBC                                             ; FBD22E  39
	lda xwa, (DL_F18CD5:24)                              ; FBD22F  f2 d5 8c f1 30
	push XWA                                             ; FBD234  38
	call T_DisplayList_Run_Stack                         ; FBD235  1d 00 2e f4
	inc 1,H                                              ; FBD239  ce 61
	inc 8,XSP                                            ; FBD23B  ef 60
	cp h, 0x02:i3                                          ; FBD23D  ce da
	jr ule, .LFBD225                                     ; FBD23F  63 e4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBD241  f1 40 25 00 00
	calr CombiEditSound_PageIndex                                      ; FBD246  1e de fe
	extz WA                                              ; FBD249  d8 12
	extz XWA                                             ; FBD24B  e8 12
	cp wa, 0x05:i3                                         ; FBD24D  d8 dd
	jrl ugt, .LFBD2FA                                        ; FBD24F  7b a8 00
	sll wa, 0x02                                         ; FBD252  d8 ee 02
	add XWA,CombiEditSound_PageTextHandlers                             ; FBD255  e8 c8 5f d2 fb 00
	ld XWA,(XWA)                                         ; FBD25B  a0 20
	jp (xwa)                                             ; FBD25D  b0 d8

; ---------------------------------------------------------------------
; CombiEditSound_PageTextHandlers -- 6 LE32 code addresses, an INLINE jump table
;
; Read by: ONE site, `add XWA,0x00FBD25F / ld XWA,(XWA) / jp (XWA)` at
;          0xFBD255-0xFBD25D.
; ENTRY COUNT 6: `cps wa,0x05 / jrl ugt` at 0xFBD24D.  ★ LAST-ENTRY TEST: entry
;          5 is 0x00FBD2E8 and 0xFBD25F + 6*4 = 0xFBD277 = entry 0's target.
; Evidence: the base is named by exactly one instruction, the `add Xrr,imm32`
;          quoted above, and the ENTRY COUNT is the ROM's own bound on the
;          index, not a guess at where the values stop looking like
;          addresses; the LAST-ENTRY TEST above is what makes the two agree.
; Unknown:  what the arms DO.  A jump table names its targets, not its
;          operations.
; ---------------------------------------------------------------------
; CombiEditSound_PageTextHandlers: COMBINATION EDIT INTERNAL SOUND / MIDI SOUND pages: draws the static text of page
;   CombiEditSound_PageIndex (0..5, PtrTable_F1AFBD's order) on layer 0; then (0x2768) := CombiEdit_Page. Basis: table
;   index + the display lists each arm runs. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_PageTextHandlers:
	.long CombiEditSound_DrawLevelsPageText                                 ; FBD25F  [  0]
	.long CombiEditSound_DrawControllerFilterPageText                                 ; FBD263  [  1]
	.long CombiEditSound_DrawAssignAndInputFilterPageText                                 ; FBD267  [  2]
	.long CombiEditSound_DrawMidiOutPageText                                 ; FBD26B  [  3]
	.long CombiEditSound_DrawMidiOutFilterPageText                                 ; FBD26F  [  4]
	.long Draw_ReverbDepth                                 ; FBD273  [  5]
; CombiEditSound_DrawLevelsPageText: CombiEditSound_PageTextHandlers[0]: runs the page-0 display lists on layer 0 --
;   PAGE1/3 INTERNAL SOUND: SOUND, VOLUME, EFFECT1 SEND, PAN ... BEND RANGE, SUB OUT. Basis: table index + body
;   (display-list text). (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_DrawLevelsPageText:   ; entry: named by 1 `.long` operand, first at 0xFBD25F
	lda xbc, (DL_InternalSound_F18DBD:24)                ; FBD277  f2 bd 8d f1 31
	push XBC                                             ; FBD27C  39
	lda xwa, (DL_InternalSound_F18CDD:24)                ; FBD27D  f2 dd 8c f1 30
	push XWA                                             ; FBD282  38
	jrl .LFBD2F4                                         ; FBD283  78 6e 00
; CombiEditSound_DrawControllerFilterPageText: CombiEditSound_PageTextHandlers[1]: runs the page-1 display lists on
;   layer 0 -- PAGE2/3 INTERNAL SOUND: PITCH BEND, MODULATION1/2, R.T.CREAT/CTRL X/Y, HOLD, CTRL.PEDAL, AFTER TOUCH.
;   Basis: table index + body (display-list text). (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_DrawControllerFilterPageText:   ; entry: named by 1 `.long` operand, first at 0xFBD263
	lda xbc, (DL_BankSelectMidiIn:24)                    ; FBD286  f2 84 8e f1 31
	push XBC                                             ; FBD28B  39
	lda xwa, (DL_InternalSound_F18DBD:24)                ; FBD28C  f2 bd 8d f1 30
	push XWA                                             ; FBD291  38
	jr .LFBD2F4                                          ; FBD292  68 60
; CombiEditSound_DrawAssignAndInputFilterPageText: CombiEditSound_PageTextHandlers[2]: runs the page-2 display lists
;   on layer 0 -- PAGE3/3 INTERNAL SOUND: MONOPHONIC, KEY SCALING, VELOCITY OFFSET, PROGRAM CNG / BANK SELECT / VOLUME
;   MIDI IN. Basis: table index + body (display-list text). (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_DrawAssignAndInputFilterPageText:   ; entry: named by 1 `.long` operand, first at 0xFBD267
	lda xbc, (DL_MidiOutFilter_F18F36:24)                ; FBD294  f2 36 8f f1 31
	push XBC                                             ; FBD299  39
	lda xwa, (DL_BankSelectMidiIn:24)                    ; FBD29A  f2 84 8e f1 30
	push XWA                                             ; FBD29F  38
	jr .LFBD2F4                                          ; FBD2A0  68 52
; CombiEditSound_DrawMidiOutPageText: CombiEditSound_PageTextHandlers[3] (the MIDI OUT FILTER page 1 -- screen 0xB5
;   page 0 or 0x38 page 1): BANK SELECT, PROG CHANGE, VOLUME, PAN, EFFECT DEPTH, MIDI OUT KEY TRANSPOSE, titled 'MIDI
;   OUT FILTER PAGE1/2' (0xB5) or 'MIDI SOUND PAGE2/3' (0x38). Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_DrawMidiOutPageText:   ; entry: named by 1 `.long` operand, first at 0xFBD26B
	cp	(UI_ScreenId:16), 0x38                            ; FBD2A2  c1 7c 20 3f 38
	jr z, .LFBD2B7                                       ; FBD2A7  66 0e
	lda xbc, (DL_MidiOutFilter_F18FC8:24)                ; FBD2A9  f2 c8 8f f1 31
	push XBC                                             ; FBD2AE  39
	lda xwa, (DL_MidiOutFilter_F18F36:24)                ; FBD2AF  f2 36 8f f1 30
	push XWA                                             ; FBD2B4  38
	jr .LFBD2F4                                          ; FBD2B5  68 3d
.LFBD2B7:
	lda xbc, (DL_ReverbDepth:24)                         ; FBD2B7  f2 0f 90 f1 31
	push XBC                                             ; FBD2BC  39
	lda xwa, (DL_EffectDepth:24)                         ; FBD2BD  f2 59 8f f1 30
	push XWA                                             ; FBD2C2  38
	jr .LFBD2F4                                          ; FBD2C3  68 2f
; CombiEditSound_DrawMidiOutFilterPageText: CombiEditSound_PageTextHandlers[4] (MIDI OUT FILTER page 2 -- screen 0xB5
;   page 1 or 0x38 page 2): PITCH BEND, MODULATION1/2, R.T.CREAT/CTRL X/Y, HOLD, CTRL.PEDAL, AFTER TOUCH, titled 'MIDI
;   OUT FILTER PAGE2/2' or 'MIDI SOUND PAGE3/3'. Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_DrawMidiOutFilterPageText:   ; entry: named by 1 `.long` operand, first at 0xFBD26F
	cp	(UI_ScreenId:16), 0x38                            ; FBD2C5  c1 7c 20 3f 38
	jr z, .LFBD2DA                                       ; FBD2CA  66 0e
	lda xbc, (DL_MidiOutFilter_F191B1:24)                ; FBD2CC  f2 b1 91 f1 31
	push XBC                                             ; FBD2D1  39
	lda xwa, (DL_MidiOutFilter_F190E9:24)                ; FBD2D2  f2 e9 90 f1 30
	push XWA                                             ; FBD2D7  38
	jr .LFBD2F4                                          ; FBD2D8  68 1a
.LFBD2DA:
	lda xbc, (DL_F191F8:24)                              ; FBD2DA  f2 f8 91 f1 31
	push XBC                                             ; FBD2DF  39
	lda xwa, (DL_Modulation1:24)                         ; FBD2E0  f2 0c 91 f1 30
	push XWA                                             ; FBD2E5  38
	jr .LFBD2F4                                          ; FBD2E6  68 0c
Draw_ReverbDepth:   ; entry: named by 1 `.long` operand, first at 0xFBD273
	lda xbc, (DL_MidiOutFilter_F190E9:24)                ; FBD2E8  f2 e9 90 f1 31
	push XBC                                             ; FBD2ED  39
	lda xwa, (DL_ReverbDepth:24)                         ; FBD2EE  f2 0f 90 f1 30
	push XWA                                             ; FBD2F3  38
.LFBD2F4:
	call T_DisplayList_Run_Stack                         ; FBD2F4  1d 00 2e f4
	inc 8,XSP                                            ; FBD2F8  ef 60
.LFBD2FA:
	ld	(0x2768:16), (CombiEdit_Page:16)             ; FBD2FA  c1 67 27 19 68 27
	popw hl                                              ; FBD300  4b
	ret                                                  ; FBD301  0e
.LFBD302:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FBD302  f1 40 25 00 01
	calr CombiEditSound_PageIndex                                          ; FBD307  1e 1d fe
	extz WA                                              ; FBD30A  d8 12
	extz XWA                                             ; FBD30C  e8 12
	cp wa, 0x05:i3                                         ; FBD30E  d8 dd
	jrl ugt, .LFBD390                                        ; FBD310  7b 7d 00
	sll wa, 0x02                                         ; FBD313  d8 ee 02
	add XWA,CombiEditSound_PageRowCursorHandlers                             ; FBD316  e8 c8 20 d3 fb 00
	ld XWA,(XWA)                                         ; FBD31C  a0 20
	jp (xwa)                                             ; FBD31E  b0 d8

; ---------------------------------------------------------------------
; CombiEditSound_PageRowCursorHandlers -- 6 LE32 code addresses, an INLINE jump table
;
; Read by: ONE site, `add XWA,0x00FBD320 / ld XWA,(XWA) / jp (XWA)` at
;          0xFBD316-0xFBD31E.
; ENTRY COUNT 6: `cps wa,0x05 / jrl ugt` at 0xFBD30E.  ★ LAST-ENTRY TEST: entry
;          5 is 0x00FBD37E and 0xFBD320 + 6*4 = 0xFBD338 = entry 0's target.
;          ⚠ These are the two bytes the linear decode reports as `db`
;          (0xFBD321, 0xFBD329): a table that even the disassembler cannot spell.
; Evidence: the base is named by exactly one instruction, the `add Xrr,imm32`
;          quoted above, and the ENTRY COUNT is the ROM's own bound on the
;          index, not a guess at where the values stop looking like
;          addresses; the LAST-ENTRY TEST above is what makes the two agree.
; Unknown:  what the arms DO.  A jump table names its targets, not its
;          operations.
; ---------------------------------------------------------------------
; CombiEditSound_PageRowCursorHandlers: COMBINATION EDIT INTERNAL SOUND / MIDI SOUND pages: moves the row highlight of
;   page CombiEditSound_PageIndex (0..5) -- erase rect at old row (0x276A), fill rect at CombiEdit_Row, through that
;   page's IndexMap -- then (0x276A) := CombiEdit_Row. Basis: table index + the arms' display lists. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_PageRowCursorHandlers:
	.long CombiEditSound_MoveLevelsPageRowCursor                                 ; FBD320  [  0]
	.long CombiEditSound_MoveControllerFilterPageRowCursor                                 ; FBD324  [  1]
	.long CombiEditSound_MoveAssignAndInputFilterPageRowCursor                                 ; FBD328  [  2]
	.long CombiEditSound_MoveMidiOutPageRowCursor                                 ; FBD32C  [  3]
	.long CombiEditSound_MoveMidiOutFilterPageRowCursor                                 ; FBD330  [  4]
	.long CombiEditSound_MoveMultipleMessagesPageRowCursor                                 ; FBD334  [  5]
; CombiEditSound_MoveLevelsPageRowCursor: CombiEditSound_PageRowCursorHandlers[0] (PtrTable_F1AFBD[0]'s page): runs
;   that page's row-highlight list (erase old row (0x276A), fill CombiEdit_Row) with its own row-rectangle IndexMap.
;   Basis: table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_MoveLevelsPageRowCursor:   ; entry: named by 1 `.long` operand, first at 0xFBD320
	lda xbc, (IndexMap_F19497:24)                        ; FBD338  f2 97 94 f1 31
	push XBC                                             ; FBD33D  39
	lda xwa, (CombiEditSound_MoveLevelsPageRowCursor_DL:24)                              ; FBD33E  f2 81 94 f1 30
	push XWA                                             ; FBD343  38
	jr .LFBD38A                                          ; FBD344  68 44
; CombiEditSound_MoveControllerFilterPageRowCursor: CombiEditSound_PageRowCursorHandlers[1] (PtrTable_F1AFBD[1]'s
;   page): runs that page's row-highlight list (erase old row (0x276A), fill CombiEdit_Row) with its own row-rectangle
;   IndexMap. Basis: table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_MoveControllerFilterPageRowCursor:   ; entry: named by 1 `.long` operand, first at 0xFBD324
	lda xbc, (IndexMap_F1952D:24)                        ; FBD346  f2 2d 95 f1 31
	push XBC                                             ; FBD34B  39
	lda xwa, (CombiEditSound_MoveControllerFilterPageRowCursor_DL:24)                              ; FBD34C  f2 17 95 f1 30
	push XWA                                             ; FBD351  38
	jr .LFBD38A                                          ; FBD352  68 36
; CombiEditSound_MoveAssignAndInputFilterPageRowCursor: CombiEditSound_PageRowCursorHandlers[2] (PtrTable_F1AFBD[2]'s
;   page): runs that page's row-highlight list (erase old row (0x276A), fill CombiEdit_Row) with its own row-rectangle
;   IndexMap. Basis: table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_MoveAssignAndInputFilterPageRowCursor:   ; entry: named by 1 `.long` operand, first at 0xFBD328
	lda xbc, (IndexMap_F195C3:24)                        ; FBD354  f2 c3 95 f1 31
	push XBC                                             ; FBD359  39
	lda xwa, (CombiEditSound_MoveAssignAndInputFilterPageRowCursor_DL:24)                              ; FBD35A  f2 ad 95 f1 30
	push XWA                                             ; FBD35F  38
	jr .LFBD38A                                          ; FBD360  68 28
; CombiEditSound_MoveMidiOutPageRowCursor: CombiEditSound_PageRowCursorHandlers[3] (PtrTable_F1AFBD[3]'s page): runs
;   that page's row-highlight list (erase old row (0x276A), fill CombiEdit_Row) with its own row-rectangle IndexMap.
;   Basis: table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_MoveMidiOutPageRowCursor:   ; entry: named by 1 `.long` operand, first at 0xFBD32C
	lda xbc, (IndexMap_F19619:24)                        ; FBD362  f2 19 96 f1 31
	push XBC                                             ; FBD367  39
	lda xwa, (CombiEditSound_MoveMidiOutPageRowCursor_DL:24)                              ; FBD368  f2 03 96 f1 30
	push XWA                                             ; FBD36D  38
	jr .LFBD38A                                          ; FBD36E  68 1a
; CombiEditSound_MoveMidiOutFilterPageRowCursor: CombiEditSound_PageRowCursorHandlers[4] (PtrTable_F1AFBD[4]'s page):
;   runs that page's row-highlight list (erase old row (0x276A), fill CombiEdit_Row) with its own row-rectangle
;   IndexMap. Basis: table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_MoveMidiOutFilterPageRowCursor:   ; entry: named by 1 `.long` operand, first at 0xFBD330
	lda xbc, (IndexMap_F1966F:24)                        ; FBD370  f2 6f 96 f1 31
	push XBC                                             ; FBD375  39
	lda xwa, (CombiEditSound_MoveMidiOutFilterPageRowCursor_DL:24)                              ; FBD376  f2 59 96 f1 30
	push XWA                                             ; FBD37B  38
	jr .LFBD38A                                          ; FBD37C  68 0c
; CombiEditSound_MoveMultipleMessagesPageRowCursor: CombiEditSound_PageRowCursorHandlers[5] (PtrTable_F1AFBD[5]'s
;   page): runs that page's row-highlight list (erase old row (0x276A), fill CombiEdit_Row) with its own row-rectangle
;   IndexMap. Basis: table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CombiEditSound_MoveMultipleMessagesPageRowCursor:   ; entry: named by 1 `.long` operand, first at 0xFBD334
	lda xbc, (IndexMap_F19705:24)                        ; FBD37E  f2 05 97 f1 31
	push XBC                                             ; FBD383  39
	lda xwa, (CombiEditSound_MoveMultipleMessagesPageRowCursor_DL:24)                              ; FBD384  f2 ef 96 f1 30
	push XWA                                             ; FBD389  38
.LFBD38A:
	call T_DisplayListB_Run_Stack                        ; FBD38A  1d 04 2e f4
	inc 8,XSP                                            ; FBD38E  ef 60
.LFBD390:
	ld	(0x276a:16), (CombiEdit_Row:16)             ; FBD390  c1 69 27 19 6a 27
	ret                                                  ; FBD396  0e
.LFBD397:
	pushw hl                                             ; FBD397  2b
	cp	(PanelModeGroup:16), 0x16                            ; FBD398  c1 76 20 3f 16
	jr nz, .LFBD3BE                                      ; FBD39D  6e 1f
	ld (LCD_CurrentLayer:16), 0x01                                 ; FBD39F  f1 40 25 00 01
	cp	(0x276f:16), 0x00                            ; FBD3A4  c1 6f 27 3f 00
	jr nz, .LFBD3B3                                      ; FBD3A9  6e 08
	lda xbc, (DL_F18C08:24)                              ; FBD3AB  f2 08 8c f1 31
	push XBC                                             ; FBD3B0  39
	jr .LFBD3B9                                          ; FBD3B1  68 06
.LFBD3B3:
	lda xbc, (DL_F18C12:24)                              ; FBD3B3  f2 12 8c f1 31
	push XBC                                             ; FBD3B8  39
.LFBD3B9:
	call T_DisplayList_RunOne_Stack                      ; FBD3B9  1d 08 2e f4
	pop XIY                                              ; FBD3BD  5d
.LFBD3BE:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBD3BE  f1 40 25 00 00
	calr CombiEditSound_PageIndex                                          ; FBD3C3  1e 61 fd
	ld H,A                                               ; FBD3C6  c9 8e
	cp A,0xff                                            ; FBD3C8  c9 cf ff
	jr z, .LFBD3E2                                       ; FBD3CB  66 15
	mul A,0x04                                           ; FBD3CD  c9 08 04
	extz XWA                                             ; FBD3D0  e8 12
	add XWA,PtrTable_F1AFBD                              ; FBD3D2  e8 c8 bd af f1 00
	ld XBC,(XWA)                                         ; FBD3D8  a0 21
	lda xiy, (.LFBD3E2:24)                               ; FBD3DA  f2 e2 d3 fb 35
	push XIY                                             ; FBD3DF  3d
	jp (xbc)                                             ; FBD3E0  b1 d8
.LFBD3E2:
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; FBD3E2  1d 14 2e f4
	popw hl                                              ; FBD3E6  4b
	ret                                                  ; FBD3E7  0e
; CombiEditSound_PaintLevelsPage: PtrTable_F1AFBD[0]: the edited part's VOLUME (first record 3), PANPOT (8), EFFECT1 SEND (5), EFFECT2 ON/OFF (6),
;   REVERB SEND (7), KEY SHIFT (9), FINE TUNE (10), PITCH BEND RANGE (11) and MAIN OUT (second record 3), each through
;   its display list.  Basis: table (descriptor match of every byte it reads).
CombiEditSound_PaintLevelsPage:
	push XIX                                             ; FBD3E8  3c
	lda xix, (UI_DrawScratch:16)                                ; FBD3E9  f1 40 26 34
	pushw 0x03                                           ; FBD3ED  0b 03 00
	push 0x00                                            ; FBD3F0  09 00
	push	(CombiEdit_Part:16)                                  ; FBD3F2  c1 65 27 04
	call T_IndexedTable_GetByte                          ; FBD3F6  1d 90 2c f4
	ld (XIX),A                                           ; FBD3FA  b4 41
	pop XIY                                              ; FBD3FC  5d
	lda xbc, (CombiEditSound_PaintLevelsPage_DL1:24)                              ; FBD3FD  f2 ae 97 f1 31
	push XBC                                             ; FBD402  39
	cp	(CombiEdit_Row:16), 0x01                            ; FBD403  c1 69 27 3f 01
	jr z, .LFBD410                                       ; FBD408  66 06
	call T_DisplayListB_RunOne_Stack                     ; FBD40A  1d 0c 2e f4
	jr .LFBD414                                          ; FBD40E  68 04
.LFBD410:
	call T_Blink_Command                                 ; FBD410  1d 20 2e f4
.LFBD414:
	pop XIY                                              ; FBD414  5d
	pushw 0x08                                           ; FBD415  0b 08 00
	push 0x00                                            ; FBD418  09 00
	push	(CombiEdit_Part:16)                                  ; FBD41A  c1 65 27 04
	call T_IndexedTable_GetByte                          ; FBD41E  1d 90 2c f4
	ld (XIX),A                                           ; FBD422  b4 41
	lda xbc, (DL_F19772:24)                              ; FBD424  f2 72 97 f1 31
	push XBC                                             ; FBD429  39
	call T_DisplayListB_RunOne_Stack                     ; FBD42A  1d 0c 2e f4
	pushw 0x05                                           ; FBD42E  0b 05 00
	push 0x00                                            ; FBD431  09 00
	push	(CombiEdit_Part:16)                                  ; FBD433  c1 65 27 04
	call T_IndexedTable_GetByte                          ; FBD437  1d 90 2c f4
	ld (XIX),A                                           ; FBD43B  b4 41
	inc 8,XSP                                            ; FBD43D  ef 60
	inc 4,XSP                                            ; FBD43F  ef 64
	lda xbc, (CombiEditSound_PaintLevelsPage_DL2:24)                              ; FBD441  f2 b8 97 f1 31
	push XBC                                             ; FBD446  39
	cp	(CombiEdit_Row:16), 0x06                            ; FBD447  c1 69 27 3f 06
	jr z, .LFBD454                                       ; FBD44C  66 06
	call T_DisplayListB_RunOne_Stack                     ; FBD44E  1d 0c 2e f4
	jr .LFBD458                                          ; FBD452  68 04
.LFBD454:
	call T_Blink_Command                                 ; FBD454  1d 20 2e f4
.LFBD458:
	pop XIY                                              ; FBD458  5d
	pushw 0x06                                           ; FBD459  0b 06 00
	push 0x00                                            ; FBD45C  09 00
	push	(CombiEdit_Part:16)                                  ; FBD45E  c1 65 27 04
	call T_IndexedTable_GetByte                          ; FBD462  1d 90 2c f4
	res 0x07,A                                           ; FBD466  c9 30 07
	pop XIY                                              ; FBD469  5d
	cp a, 0x00:i3                                          ; FBD46A  c9 d8
	jr z, .LFBD473                                       ; FBD46C  66 05
	ld (XIX),0x01                                        ; FBD46E  b4 00 01
	jr .LFBD476                                          ; FBD471  68 03
.LFBD473:
	ld (XIX),0x00                                        ; FBD473  b4 00 00
.LFBD476:
	lda xbc, (CombiEditSound_PaintLevelsPage_DL3:24)                              ; FBD476  f2 81 97 f1 31
	push XBC                                             ; FBD47B  39
	call T_DisplayListB_RunOne_Stack                     ; FBD47C  1d 0c 2e f4
	pushw 0x07                                           ; FBD480  0b 07 00
	push 0x00                                            ; FBD483  09 00
	push	(CombiEdit_Part:16)                                  ; FBD485  c1 65 27 04
	call T_IndexedTable_GetByte                          ; FBD489  1d 90 2c f4
	ld (XIX),A                                           ; FBD48D  b4 41
	inc 8,XSP                                            ; FBD48F  ef 60
	lda xbc, (CombiEditSound_PaintLevelsPage_DL4:24)                              ; FBD491  f2 c2 97 f1 31
	push XBC                                             ; FBD496  39
	cp	(CombiEdit_Row:16), 0x08                            ; FBD497  c1 69 27 3f 08
	jr z, .LFBD4A4                                       ; FBD49C  66 06
	call T_DisplayListB_RunOne_Stack                     ; FBD49E  1d 0c 2e f4
	jr .LFBD4A8                                          ; FBD4A2  68 04
.LFBD4A4:
	call T_Blink_Command                                 ; FBD4A4  1d 20 2e f4
.LFBD4A8:
	pop XIY                                              ; FBD4A8  5d
	pushw 0x09                                           ; FBD4A9  0b 09 00
	push 0x00                                            ; FBD4AC  09 00
	push	(CombiEdit_Part:16)                                  ; FBD4AE  c1 65 27 04
	call T_IndexedTable_GetByte                          ; FBD4B2  1d 90 2c f4
	ld (XIX),A                                           ; FBD4B6  b4 41
	pop XIY                                              ; FBD4B8  5d
	lda xbc, (CombiEditSound_PaintLevelsPage_DL5:24)                              ; FBD4B9  f2 cc 97 f1 31
	push XBC                                             ; FBD4BE  39
	cp	(CombiEdit_Row:16), 0x03                            ; FBD4BF  c1 69 27 3f 03
	jr z, .LFBD4CC                                       ; FBD4C4  66 06
	call T_DisplayListB_RunOne_Stack                     ; FBD4C6  1d 0c 2e f4
	jr .LFBD4D0                                          ; FBD4CA  68 04
.LFBD4CC:
	call T_Blink_Command                                 ; FBD4CC  1d 20 2e f4
.LFBD4D0:
	pop XIY                                              ; FBD4D0  5d
	pushw 0x0a                                           ; FBD4D1  0b 0a 00
	push 0x00                                            ; FBD4D4  09 00
	push	(CombiEdit_Part:16)                                  ; FBD4D6  c1 65 27 04
	call T_IndexedTable_GetByte                          ; FBD4DA  1d 90 2c f4
	ld (XIX),A                                           ; FBD4DE  b4 41
	pop XIY                                              ; FBD4E0  5d
	lda xbc, (CombiEditSound_PaintLevelsPage_DL6:24)                              ; FBD4E1  f2 d7 97 f1 31
	push XBC                                             ; FBD4E6  39
	cp	(CombiEdit_Row:16), 0x04                            ; FBD4E7  c1 69 27 3f 04
	jr z, .LFBD4F4                                       ; FBD4EC  66 06
	call T_DisplayListB_RunOne_Stack                     ; FBD4EE  1d 0c 2e f4
	jr .LFBD4F8                                          ; FBD4F2  68 04
.LFBD4F4:
	call T_Blink_Command                                 ; FBD4F4  1d 20 2e f4
.LFBD4F8:
	pop XIY                                              ; FBD4F8  5d
	pushw 0x0b                                           ; FBD4F9  0b 0b 00
	push 0x00                                            ; FBD4FC  09 00
	push	(CombiEdit_Part:16)                                  ; FBD4FE  c1 65 27 04
	call T_IndexedTable_GetByte                          ; FBD502  1d 90 2c f4
	ld (XIX),A                                           ; FBD506  b4 41
	pop XIY                                              ; FBD508  5d
	lda xbc, (CombiEditSound_PaintLevelsPage_DL7:24)                              ; FBD509  f2 e2 97 f1 31
	push XBC                                             ; FBD50E  39
	cp	(CombiEdit_Row:16), 0x05                            ; FBD50F  c1 69 27 3f 05
	jr z, .LFBD51C                                       ; FBD514  66 06
	call T_DisplayListB_RunOne_Stack                     ; FBD516  1d 0c 2e f4
	jr .LFBD520                                          ; FBD51A  68 04
.LFBD51C:
	call T_Blink_Command                                 ; FBD51C  1d 20 2e f4
.LFBD520:
	pop XIY                                              ; FBD520  5d
	pushw 0x03                                           ; FBD521  0b 03 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD524  d1 65 27 21
	extz BC                                              ; FBD528  d9 12
	add BC,0x0020                                        ; FBD52A  d9 c8 20 00
	pushw bc                                             ; FBD52E  29
	call T_IndexedTable_GetByte                          ; FBD52F  1d 90 2c f4
	ld (XIX),A                                           ; FBD533  b4 41
	pushw 0x06                                           ; FBD535  0b 06 00
	push 0x00                                            ; FBD538  09 00
	push	(CombiEdit_Part:16)                                  ; FBD53A  c1 65 27 04
	call T_IndexedTable_GetByte                          ; FBD53E  1d 90 2c f4
	res 0x07,A                                           ; FBD542  c9 30 07
	inc 8,XSP                                            ; FBD545  ef 60
	cp a, 0x00:i3                                          ; FBD547  c9 d8
	jr z, .LFBD565                                       ; FBD549  66 1a
	pushw 0x04                                           ; FBD54B  0b 04 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD54E  d1 65 27 21
	extz BC                                              ; FBD552  d9 12
	add BC,0x0020                                        ; FBD554  d9 c8 20 00
	pushw bc                                             ; FBD558  29
	call T_IndexedTable_GetByte                          ; FBD559  1d 90 2c f4
	pop XIY                                              ; FBD55D  5d
	cp a, 0x00:i3                                          ; FBD55E  c9 d8
	jr z, .LFBD565                                       ; FBD560  66 03
	ld (XIX),0x00                                        ; FBD562  b4 00 00
.LFBD565:
	lda xbc, (CombiEditSound_PaintLevelsPage_DL8:24)                              ; FBD565  f2 90 97 f1 31
	push XBC                                             ; FBD56A  39
	call T_DisplayListB_RunOne_Stack                     ; FBD56B  1d 0c 2e f4
	pushw 0x04                                           ; FBD56F  0b 04 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD572  d1 65 27 21
	extz BC                                              ; FBD576  d9 12
	add BC,0x0020                                        ; FBD578  d9 c8 20 00
	pushw bc                                             ; FBD57C  29
	call T_IndexedTable_GetByte                          ; FBD57D  1d 90 2c f4
	ld (XIX),A                                           ; FBD581  b4 41
	lda xbc, (DL_OffMainSub1Sub2Sub3Eff2:24)             ; FBD583  f2 9f 97 f1 31
	push XBC                                             ; FBD588  39
	call T_DisplayListB_RunOne_Stack                     ; FBD589  1d 0c 2e f4
	inc 8,XSP                                            ; FBD58D  ef 60
	inc 4,XSP                                            ; FBD58F  ef 64
	pop XIX                                              ; FBD591  5c
	ret                                                  ; FBD592  0e
; CombiEditSound_PaintControllerFilterPage: PtrTable_F1AFBD[1]: second record bytes 11-14 -- the CONTROLLER INTERNAL FILTER bits -- into UI_DrawScratch, drawn
;   by CombiEditSound_PaintControllerFilterPage_DL.  Basis: table (descriptor match).
CombiEditSound_PaintControllerFilterPage:
	link XIZ,0xfffc                                      ; FBD593  ee 0c fc ff
	push XIX                                             ; FBD597  3c
	lda xix, (UI_DrawScratch:16)                                ; FBD598  f1 40 26 34
	ld bc, (CombiEdit_Part:16)                                 ; FBD59C  d1 65 27 21
	extz BC                                              ; FBD5A0  d9 12
	add BC,0x0020                                        ; FBD5A2  d9 c8 20 00
	pushw bc                                             ; FBD5A6  29
	call T_IndexedTable_GetPtr                           ; FBD5A7  1d 8c 2c f4
	ld (xiz-4), xiy                                      ; FBD5AB  be fc 65
	ld C,(XIY+0x0b)                                      ; FBD5AE  8d 0b 23
	ld (XIX),C                                           ; FBD5B1  b4 43
	ld xbc, (xiz-4)                                      ; FBD5B3  ae fc 21
	ld A,(XBC+0x0c)                                      ; FBD5B6  89 0c 21
	extz XIX                                             ; FBD5B9  ec 12
	ld (XIX+0x01),A                                      ; FBD5BB  bc 01 41
	ld xbc, (xiz-4)                                      ; FBD5BE  ae fc 21
	ld A,(XBC+0x0d)                                      ; FBD5C1  89 0d 21
	ld (XIX+0x02),A                                      ; FBD5C4  bc 02 41
	ld xbc, (xiz-4)                                      ; FBD5C7  ae fc 21
	ld A,(XBC+0x0e)                                      ; FBD5CA  89 0e 21
	ld (XIX+0x03),A                                      ; FBD5CD  bc 03 41
	lda xbc, (DL_F198AE:24)                              ; FBD5D0  f2 ae 98 f1 31
	push XBC                                             ; FBD5D5  39
	lda xwa, (CombiEditSound_PaintControllerFilterPage_DL:24)                              ; FBD5D6  f2 18 98 f1 30
	push XWA                                             ; FBD5DB  38
	call T_DisplayListB_Run_Stack                        ; FBD5DC  1d 04 2e f4
	inc 8,XSP                                            ; FBD5E0  ef 60
	inc 2,XSP                                            ; FBD5E2  ef 62
	pop XIX                                              ; FBD5E4  5c
	unlk XIZ                                             ; FBD5E5  ee 0d
	ret                                                  ; FBD5E7  0e
; CombiEditSound_PaintAssignAndInputFilterPage: PtrTable_F1AFBD[2]: ASSIGN MODE (second record 6), KEY SCALING (first record 12), VELOCITY OFFSET (second 5) and the
;   MIDI INPUT FILTER bytes (second 15, 16).  Basis: table (descriptor match).
CombiEditSound_PaintAssignAndInputFilterPage:
	push XIX                                             ; FBD5E8  3c
	lda xix, (UI_DrawScratch:16)                                ; FBD5E9  f1 40 26 34
	pushw 0x06                                           ; FBD5ED  0b 06 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD5F0  d1 65 27 21
	extz BC                                              ; FBD5F4  d9 12
	add BC,0x0020                                        ; FBD5F6  d9 c8 20 00
	pushw bc                                             ; FBD5FA  29
	call T_IndexedTable_GetByte                          ; FBD5FB  1d 90 2c f4
	ld (XIX),A                                           ; FBD5FF  b4 41
	lda xbc, (DL_F198AE:24)                              ; FBD601  f2 ae 98 f1 31
	push XBC                                             ; FBD606  39
	call T_DisplayListB_RunOne_Stack                     ; FBD607  1d 0c 2e f4
	pushw 0x0c                                           ; FBD60B  0b 0c 00
	push 0x00                                            ; FBD60E  09 00
	push	(CombiEdit_Part:16)                                  ; FBD610  c1 65 27 04
	call T_IndexedTable_GetByte                          ; FBD614  1d 90 2c f4
	ld (XIX),A                                           ; FBD618  b4 41
	lda xbc, (CombiEditSound_PaintAssignAndInputFilterPage_DL1:24)                              ; FBD61A  f2 bd 98 f1 31
	push XBC                                             ; FBD61F  39
	call T_DisplayListB_RunOne_Stack                     ; FBD620  1d 0c 2e f4
	pushw 0x05                                           ; FBD624  0b 05 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD627  d1 65 27 21
	extz BC                                              ; FBD62B  d9 12
	add BC,0x0020                                        ; FBD62D  d9 c8 20 00
	pushw bc                                             ; FBD631  29
	call T_IndexedTable_GetByte                          ; FBD632  1d 90 2c f4
	ld (XIX),A                                           ; FBD636  b4 41
	add XSP,0x00000014                                   ; FBD638  ef c8 14 00 00 00
	lda xbc, (CombiEditSound_PaintAssignAndInputFilterPage_DL2:24)                              ; FBD63E  f2 cc 98 f1 31
	push XBC                                             ; FBD643  39
	cp	(CombiEdit_Row:16), 0x02                            ; FBD644  c1 69 27 3f 02
	jr z, .LFBD651                                       ; FBD649  66 06
	call T_DisplayListB_RunOne_Stack                     ; FBD64B  1d 0c 2e f4
	jr .LFBD655                                          ; FBD64F  68 04
.LFBD651:
	call T_Blink_Command                                 ; FBD651  1d 20 2e f4
.LFBD655:
	pop XIY                                              ; FBD655  5d
	pushw 0x0f                                           ; FBD656  0b 0f 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD659  d1 65 27 21
	extz BC                                              ; FBD65D  d9 12
	add BC,0x0020                                        ; FBD65F  d9 c8 20 00
	pushw bc                                             ; FBD663  29
	call T_IndexedTable_GetByte                          ; FBD664  1d 90 2c f4
	ld (XIX),A                                           ; FBD668  b4 41
	lda xbc, (CombiEditSound_PaintAssignAndInputFilterPage_DL3:24)                              ; FBD66A  f2 d7 98 f1 31
	push XBC                                             ; FBD66F  39
	call T_DisplayListB_RunOne_Stack                     ; FBD670  1d 0c 2e f4
	pushw 0x10                                           ; FBD674  0b 10 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD677  d1 65 27 21
	extz BC                                              ; FBD67B  d9 12
	add BC,0x0020                                        ; FBD67D  d9 c8 20 00
	pushw bc                                             ; FBD681  29
	call T_IndexedTable_GetByte                          ; FBD682  1d 90 2c f4
	ld (XIX),A                                           ; FBD686  b4 41
	lda xbc, (CombiEditSound_PaintAssignAndInputFilterPage_DL4:24)                              ; FBD688  f2 e6 98 f1 31
	push XBC                                             ; FBD68D  39
	call T_DisplayListB_RunOne_Stack                     ; FBD68E  1d 0c 2e f4
	pushw 0x10                                           ; FBD692  0b 10 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD695  d1 65 27 21
	extz BC                                              ; FBD699  d9 12
	add BC,0x0020                                        ; FBD69B  d9 c8 20 00
	pushw bc                                             ; FBD69F  29
	call T_IndexedTable_GetByte                          ; FBD6A0  1d 90 2c f4
	ld (XIX),A                                           ; FBD6A4  b4 41
	lda xbc, (CombiEditSound_PaintAssignAndInputFilterPage_DL5:24)                              ; FBD6A6  f2 f5 98 f1 31
	push XBC                                             ; FBD6AB  39
	call T_DisplayListB_RunOne_Stack                     ; FBD6AC  1d 0c 2e f4
	add XSP,0x00000018                                   ; FBD6B0  ef c8 18 00 00 00
	pop XIX                                              ; FBD6B6  5c
	ret                                                  ; FBD6B7  0e
; CombiEditSound_PaintMidiOutPage: PtrTable_F1AFBD[3]: MIDI OUTPUT FILTER bytes (second record 19, 20, the latter four times for its bits) and MIDI OUT
;   KEY TRANSPOSE (second 23), the last field blinking when CombiEdit_Row is 5.  Basis: table (descriptor match).
CombiEditSound_PaintMidiOutPage:
	pushw hl                                             ; FBD6B8  2b
	pushw de                                             ; FBD6B9  2a
	push XIX                                             ; FBD6BA  3c
	lda xix, (UI_DrawScratch:16)                                ; FBD6BB  f1 40 26 34
	pushw 0x13                                           ; FBD6BF  0b 13 00
	ld hl, (CombiEdit_Part:16)                                 ; FBD6C2  d1 65 27 23
	extz HL                                              ; FBD6C6  db 12
	ldw de, 0x20                                         ; FBD6C8  32 20 00
	ld BC,HL                                             ; FBD6CB  db 89
	add BC,DE                                            ; FBD6CD  da 81
	pushw bc                                             ; FBD6CF  29
	call T_IndexedTable_GetByte                          ; FBD6D0  1d 90 2c f4
	ld (XIX),A                                           ; FBD6D4  b4 41
	lda xbc, (CombiEditSound_PaintMidiOutPage_DL1:24)                              ; FBD6D6  f2 04 99 f1 31
	push XBC                                             ; FBD6DB  39
	call T_DisplayListB_RunOne_Stack                     ; FBD6DC  1d 0c 2e f4
	pushw 0x14                                           ; FBD6E0  0b 14 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD6E3  d1 65 27 21
	extz BC                                              ; FBD6E7  d9 12
	add BC,DE                                            ; FBD6E9  da 81
	pushw bc                                             ; FBD6EB  29
	call T_IndexedTable_GetByte                          ; FBD6EC  1d 90 2c f4
	ld (XIX),A                                           ; FBD6F0  b4 41
	lda xbc, (CombiEditSound_PaintMidiOutPage_DL2:24)                              ; FBD6F2  f2 31 99 f1 31
	push XBC                                             ; FBD6F7  39
	call T_DisplayListB_RunOne_Stack                     ; FBD6F8  1d 0c 2e f4
	pushw 0x14                                           ; FBD6FC  0b 14 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD6FF  d1 65 27 21
	extz BC                                              ; FBD703  d9 12
	add BC,DE                                            ; FBD705  da 81
	pushw bc                                             ; FBD707  29
	call T_IndexedTable_GetByte                          ; FBD708  1d 90 2c f4
	ld (XIX),A                                           ; FBD70C  b4 41
	lda xbc, (CombiEditSound_PaintMidiOutPage_DL3:24)                              ; FBD70E  f2 13 99 f1 31
	push XBC                                             ; FBD713  39
	call T_DisplayListB_RunOne_Stack                     ; FBD714  1d 0c 2e f4
	pushw 0x14                                           ; FBD718  0b 14 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD71B  d1 65 27 21
	extz BC                                              ; FBD71F  d9 12
	add BC,DE                                            ; FBD721  da 81
	pushw bc                                             ; FBD723  29
	call T_IndexedTable_GetByte                          ; FBD724  1d 90 2c f4
	ld (XIX),A                                           ; FBD728  b4 41
	lda xbc, (CombiEditSound_PaintMidiOutPage_DL4:24)                              ; FBD72A  f2 40 99 f1 31
	push XBC                                             ; FBD72F  39
	call T_DisplayListB_RunOne_Stack                     ; FBD730  1d 0c 2e f4
	pushw 0x14                                           ; FBD734  0b 14 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD737  d1 65 27 21
	extz BC                                              ; FBD73B  d9 12
	add BC,DE                                            ; FBD73D  da 81
	pushw bc                                             ; FBD73F  29
	call T_IndexedTable_GetByte                          ; FBD740  1d 90 2c f4
	ld (XIX),A                                           ; FBD744  b4 41
	lda xbc, (CombiEditSound_PaintMidiOutPage_DL5:24)                              ; FBD746  f2 22 99 f1 31
	push XBC                                             ; FBD74B  39
	call T_DisplayListB_RunOne_Stack                     ; FBD74C  1d 0c 2e f4
	pushw 0x17                                           ; FBD750  0b 17 00
	ld bc, (CombiEdit_Part:16)                                 ; FBD753  d1 65 27 21
	extz BC                                              ; FBD757  d9 12
	add BC,DE                                            ; FBD759  da 81
	pushw bc                                             ; FBD75B  29
	call T_IndexedTable_GetByte                          ; FBD75C  1d 90 2c f4
	ld (XIX),A                                           ; FBD760  b4 41
	add XSP,0x0000002c                                   ; FBD762  ef c8 2c 00 00 00
	lda xbc, (CombiEditSound_PaintMidiOutPage_DL6:24)                              ; FBD768  f2 4f 99 f1 31
	push XBC                                             ; FBD76D  39
	cp	(CombiEdit_Row:16), 0x05                            ; FBD76E  c1 69 27 3f 05
	jr z, .LFBD77B                                       ; FBD773  66 06
	call T_DisplayListB_RunOne_Stack                     ; FBD775  1d 0c 2e f4
	jr .LFBD77F                                          ; FBD779  68 04
.LFBD77B:
	call T_Blink_Command                                 ; FBD77B  1d 20 2e f4
.LFBD77F:
	pop XIY                                              ; FBD77F  5d
	pop XIX                                              ; FBD780  5c
	popw de                                              ; FBD781  4a
	popw hl                                              ; FBD782  4b
	ret                                                  ; FBD783  0e
; CombiEditSound_PaintMidiOutFilterPage: PtrTable_F1AFBD[4]: second record bytes 19-22 -- the MIDI OUTPUT FILTER bits -- into UI_DrawScratch, drawn by
;   CombiEditSound_PaintMidiOutFilterPage_DL.  Basis: table (descriptor match).
CombiEditSound_PaintMidiOutFilterPage:
	link XIZ,0xfffc                                      ; FBD784  ee 0c fc ff
	push XIX                                             ; FBD788  3c
	lda xix, (UI_DrawScratch:16)                                ; FBD789  f1 40 26 34
	ld bc, (CombiEdit_Part:16)                                 ; FBD78D  d1 65 27 21
	extz BC                                              ; FBD791  d9 12
	add BC,0x0020                                        ; FBD793  d9 c8 20 00
	pushw bc                                             ; FBD797  29
	call T_IndexedTable_GetPtr                           ; FBD798  1d 8c 2c f4
	ld (xiz-4), xiy                                      ; FBD79C  be fc 65
	ld C,(XIY+0x13)                                      ; FBD79F  8d 13 23
	ld (XIX),C                                           ; FBD7A2  b4 43
	ld xbc, (xiz-4)                                      ; FBD7A4  ae fc 21
	ld A,(XBC+0x14)                                      ; FBD7A7  89 14 21
	extz XIX                                             ; FBD7AA  ec 12
	ld (XIX+0x01),A                                      ; FBD7AC  bc 01 41
	ld xbc, (xiz-4)                                      ; FBD7AF  ae fc 21
	ld A,(XBC+0x15)                                      ; FBD7B2  89 15 21
	ld (XIX+0x02),A                                      ; FBD7B5  bc 02 41
	ld xbc, (xiz-4)                                      ; FBD7B8  ae fc 21
	ld A,(XBC+0x16)                                      ; FBD7BB  89 16 21
	ld (XIX+0x03),A                                      ; FBD7BE  bc 03 41
	lda xbc, (DL_F199F0:24)                              ; FBD7C1  f2 f0 99 f1 31
	push XBC                                             ; FBD7C6  39
	lda xwa, (CombiEditSound_PaintMidiOutFilterPage_DL:24)                              ; FBD7C7  f2 5a 99 f1 30
	push XWA                                             ; FBD7CC  38
	call T_DisplayListB_Run_Stack                        ; FBD7CD  1d 04 2e f4
	inc 8,XSP                                            ; FBD7D1  ef 60
	inc 2,XSP                                            ; FBD7D3  ef 62
	pop XIX                                              ; FBD7D5  5c
	unlk XIZ                                             ; FBD7D6  ee 0d
	ret                                                  ; FBD7D8  0e
; CombiEditSound_PaintMultipleMessagesPage: PtrTable_F1AFBD[5]: first record bytes 14-21 -- MIDI MULTIPLE MESSAGES OUTPUT (PROGRAM CHANGE, BANK SELECT, VOLUME,
;   PANPOT, CHORUS DEPTH, REVERB DEPTH) -- copied to UI_DrawScratch, the first blinking when CombiEdit_Row is 0.
;   Basis: table (descriptor match).
CombiEditSound_PaintMultipleMessagesPage:
	link XIZ,0xfff2                                      ; FBD7D9  ee 0c f2 ff
	pushw hl                                             ; FBD7DD  2b
	pushw de                                             ; FBD7DE  2a
	push XIX                                             ; FBD7DF  3c
	lda xix, (UI_DrawScratch:16)                                ; FBD7E0  f1 40 26 34
	push 0x00                                            ; FBD7E4  09 00
	push	(CombiEdit_Part:16)                                  ; FBD7E6  c1 65 27 04
	call T_IndexedTable_GetPtr                           ; FBD7EA  1d 8c 2c f4
	add XIY,0x0000000e                                   ; FBD7EE  ed c8 0e 00 00 00
	ld (xiz-4), xiy                                      ; FBD7F4  be fc 65
	ld (xiz-8), xix                                      ; FBD7F7  be f8 64
	ld h, 0x08:opc                                          ; FBD7FA  26 08
	popw bc                                              ; FBD7FC  49
.LFBD7FD:
	ld xbc, (xiz-4)                                      ; FBD7FD  ae fc 21
	ld A,(XBC)                                           ; FBD800  81 21
	ld L,A                                               ; FBD802  c9 8f
	ld xwa, (xiz-8)                                      ; FBD804  ae f8 20
	ld (XWA),L                                           ; FBD807  b0 47
	sub XBC,XBC                                          ; FBD809  e9 a1
	inc 1,XBC                                            ; FBD80B  e9 61
	add (xiz-8), xbc                                     ; FBD80D  ae f8 89
	add (xiz-4), xbc                                     ; FBD810  ae fc 89
	sub H,C                                              ; FBD813  cb a6
	jr nz, .LFBD7FD                                      ; FBD815  6e e6
	cp	(CombiEdit_Row:16), 0x00                            ; FBD817  c1 69 27 3f 00
	jr nz, .LFBD833                                      ; FBD81C  6e 15
	ld a, (0x2823:16)                                   ; FBD81E  c1 23 28 21
	cp A,0x20                                            ; FBD822  c9 cf 20
	jr z, .LFBD833                                       ; FBD825  66 0c
	lda xwa, (CombiEditSound_PaintMultipleMessagesPage_DL1:24)                              ; FBD827  f2 ff 99 f1 30
	push XWA                                             ; FBD82C  38
	call T_Blink_Command                                 ; FBD82D  1d 20 2e f4
	jr .LFBD860                                          ; FBD831  68 2d
.LFBD833:
	ld C,(XIX)                                           ; FBD833  84 23
	and C,0x80                                           ; FBD835  cb cc 80
	jr z, .LFBD83F                                       ; FBD838  66 05
	ld (XIX),0x01                                        ; FBD83A  b4 00 01
	jr .LFBD84C                                          ; FBD83D  68 0d
.LFBD83F:
	extz XIX                                             ; FBD83F  ec 12
	ld C,(XIX+0x07)                                      ; FBD841  8c 07 23
	and C,0x01                                           ; FBD844  cb cc 01
	jr z, .LFBD854                                       ; FBD847  66 0b
	ld (XIX),0x00                                        ; FBD849  b4 00 00
.LFBD84C:
	lda xbc, (DL_F199F0:24)                              ; FBD84C  f2 f0 99 f1 31
	push XBC                                             ; FBD851  39
	jr .LFBD85C                                          ; FBD852  68 08
.LFBD854:
	incm8 0x01, (xix)                                    ; FBD854  84 61
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL1:24)                              ; FBD856  f2 ff 99 f1 31
	push XBC                                             ; FBD85B  39
.LFBD85C:
	call T_DisplayListB_RunOne_Stack                     ; FBD85C  1d 0c 2e f4
.LFBD860:
	pop XIY                                              ; FBD860  5d
	extz XIX                                             ; FBD861  ec 12
	ld C,(XIX+0x01)                                      ; FBD863  8c 01 23
	and C,0x80                                           ; FBD866  cb cc 80
	jrl z, .LFBD8DB                                      ; FBD869  76 6f 00
	extz XIX                                             ; FBD86C  ec 12
	ld (XIX+0x01),0x01                                   ; FBD86E  bc 01 00 01
	cp	(CombiEdit_Row:16), 0x02                            ; FBD872  c1 69 27 3f 02
	jr nz, .LFBD88E                                      ; FBD877  6e 15
	ld c, (0x2823:16)                                   ; FBD879  c1 23 28 23
	cp C,0x20                                            ; FBD87D  cb cf 20
	jr z, .LFBD88E                                       ; FBD880  66 0c
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL2:24)                              ; FBD882  f2 31 9a f1 31
	push XBC                                             ; FBD887  39
	call T_Blink_Command                                 ; FBD888  1d 20 2e f4
	jr .LFBD898                                          ; FBD88C  68 0a
.LFBD88E:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL3:24)                              ; FBD88E  f2 22 9a f1 31
	push XBC                                             ; FBD893  39
	call T_DisplayListB_RunOne_Stack                     ; FBD894  1d 0c 2e f4
.LFBD898:
	pop XIY                                              ; FBD898  5d
	extz XIX                                             ; FBD899  ec 12
	ld (XIX+0x02),0x02                                   ; FBD89B  bc 02 00 02
	cp	(CombiEdit_Row:16), 0x01                            ; FBD89F  c1 69 27 3f 01
	jr nz, .LFBD8BB                                      ; FBD8A4  6e 15
	ld c, (0x2823:16)                                   ; FBD8A6  c1 23 28 23
	cp C,0x20                                            ; FBD8AA  cb cf 20
	jr z, .LFBD8BB                                       ; FBD8AD  66 0c
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL4:24)                              ; FBD8AF  f2 18 9a f1 31
	push XBC                                             ; FBD8B4  39
	call T_Blink_Command                                 ; FBD8B5  1d 20 2e f4
	jr .LFBD8C5                                          ; FBD8B9  68 0a
.LFBD8BB:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL5:24)                              ; FBD8BB  f2 09 9a f1 31
	push XBC                                             ; FBD8C0  39
	call T_DisplayListB_RunOne_Stack                     ; FBD8C1  1d 0c 2e f4
.LFBD8C5:
	pop XIY                                              ; FBD8C5  5d
	extz XIX                                             ; FBD8C6  ec 12
	ld (XIX+0x10),0x20                                   ; FBD8C8  bc 10 00 20
	ld (XIX+0x11),0x4f                                   ; FBD8CC  bc 11 00 4f
	ld (XIX+0x12),0x46                                   ; FBD8D0  bc 12 00 46
	ld (XIX+0x13),0x46                                   ; FBD8D4  bc 13 00 46
	jrl .LFBD952                                         ; FBD8D8  78 77 00
.LFBD8DB:
	extz XIX                                             ; FBD8DB  ec 12
	ld C,(XIX+0x07)                                      ; FBD8DD  8c 07 23
	and C,0x20                                           ; FBD8E0  cb cc 20
	jrl z, .LFBD95B                                      ; FBD8E3  76 75 00
	extz XIX                                             ; FBD8E6  ec 12
	ld (XIX+0x01),0x00                                   ; FBD8E8  bc 01 00 00
	cp	(CombiEdit_Row:16), 0x02                            ; FBD8EC  c1 69 27 3f 02
	jr nz, .LFBD908                                      ; FBD8F1  6e 15
	ld c, (0x2823:16)                                   ; FBD8F3  c1 23 28 23
	cp C,0x20                                            ; FBD8F7  cb cf 20
	jr z, .LFBD908                                       ; FBD8FA  66 0c
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL2:24)                              ; FBD8FC  f2 31 9a f1 31
	push XBC                                             ; FBD901  39
	call T_Blink_Command                                 ; FBD902  1d 20 2e f4
	jr .LFBD912                                          ; FBD906  68 0a
.LFBD908:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL3:24)                              ; FBD908  f2 22 9a f1 31
	push XBC                                             ; FBD90D  39
	call T_DisplayListB_RunOne_Stack                     ; FBD90E  1d 0c 2e f4
.LFBD912:
	pop XIY                                              ; FBD912  5d
	extz XIX                                             ; FBD913  ec 12
	ld (XIX+0x02),0x02                                   ; FBD915  bc 02 00 02
	cp	(CombiEdit_Row:16), 0x01                            ; FBD919  c1 69 27 3f 01
	jr nz, .LFBD935                                      ; FBD91E  6e 15
	ld c, (0x2823:16)                                   ; FBD920  c1 23 28 23
	cp C,0x20                                            ; FBD924  cb cf 20
	jr z, .LFBD935                                       ; FBD927  66 0c
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL4:24)                              ; FBD929  f2 18 9a f1 31
	push XBC                                             ; FBD92E  39
	call T_Blink_Command                                 ; FBD92F  1d 20 2e f4
	jr .LFBD93F                                          ; FBD933  68 0a
.LFBD935:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL5:24)                              ; FBD935  f2 09 9a f1 31
	push XBC                                             ; FBD93A  39
	call T_DisplayListB_RunOne_Stack                     ; FBD93B  1d 0c 2e f4
.LFBD93F:
	pop XIY                                              ; FBD93F  5d
	extz XIX                                             ; FBD940  ec 12
	ld (XIX+0x10),0x20                                   ; FBD942  bc 10 00 20
	ld (XIX+0x11),0x49                                   ; FBD946  bc 11 00 49
	ld (XIX+0x12),0x4e                                   ; FBD94A  bc 12 00 4e
	ld (XIX+0x13),0x54                                   ; FBD94E  bc 13 00 54
.LFBD952:
	extz XIX                                             ; FBD952  ec 12
	ld (XIX+0x14),0x20                                   ; FBD954  bc 14 00 20
	jrl .LFBDA58                                         ; FBD958  78 fd 00
.LFBD95B:
	cp	(CombiEdit_Row:16), 0x02                            ; FBD95B  c1 69 27 3f 02
	jr nz, .LFBD977                                      ; FBD960  6e 15
	ld c, (0x2823:16)                                   ; FBD962  c1 23 28 23
	cp C,0x20                                            ; FBD966  cb cf 20
	jr z, .LFBD977                                       ; FBD969  66 0c
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL2:24)                              ; FBD96B  f2 31 9a f1 31
	push XBC                                             ; FBD970  39
	call T_Blink_Command                                 ; FBD971  1d 20 2e f4
	jr .LFBD981                                          ; FBD975  68 0a
.LFBD977:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL2:24)                              ; FBD977  f2 31 9a f1 31
	push XBC                                             ; FBD97C  39
	call T_DisplayListB_RunOne_Stack                     ; FBD97D  1d 0c 2e f4
.LFBD981:
	pop XIY                                              ; FBD981  5d
	cp	(CombiEdit_Row:16), 0x01                            ; FBD982  c1 69 27 3f 01
	jr nz, .LFBD99E                                      ; FBD987  6e 15
	ld c, (0x2823:16)                                   ; FBD989  c1 23 28 23
	cp C,0x20                                            ; FBD98D  cb cf 20
	jr z, .LFBD99E                                       ; FBD990  66 0c
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL4:24)                              ; FBD992  f2 18 9a f1 31
	push XBC                                             ; FBD997  39
	call T_Blink_Command                                 ; FBD998  1d 20 2e f4
	jr .LFBD9A8                                          ; FBD99C  68 0a
.LFBD99E:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL4:24)                              ; FBD99E  f2 18 9a f1 31
	push XBC                                             ; FBD9A3  39
	call T_DisplayListB_RunOne_Stack                     ; FBD9A4  1d 0c 2e f4
.LFBD9A8:
	pop XIY                                              ; FBD9A8  5d
	extz XIX                                             ; FBD9A9  ec 12
	ld C,(XIX+0x01)                                      ; FBD9AB  8c 01 23
	extz BC                                              ; FBD9AE  d9 12
	ld HL,BC                                             ; FBD9B0  d9 8b
	ld A,(XIX+0x02)                                      ; FBD9B2  8c 02 21
	mul A,0x80                                           ; FBD9B5  c9 08 80
	ld DE,WA                                             ; FBD9B8  d8 8a
	add DE,BC                                            ; FBD9BA  d9 82
	ld BC,DE                                             ; FBD9BC  da 89
	extz XBC                                             ; FBD9BE  e9 12
	div BC,0x03e8                                        ; FBD9C0  d9 0a e8 03
	ld HL,BC                                             ; FBD9C4  d9 8b
	mul BC,0x03e8                                        ; FBD9C6  d9 08 e8 03
	ld WA,DE                                             ; FBD9CA  da 88
	sub WA,BC                                            ; FBD9CC  d9 a0
	ld (xiz-10), wa                                      ; FBD9CE  be f6 50
	ld BC,IX                                             ; FBD9D1  dc 89
	add BC,0x0016                                        ; FBD9D3  d9 c8 16 00
	extz XBC                                             ; FBD9D7  e9 12
	ld (xiz-14), xbc                                     ; FBD9D9  be f2 61
	ld (XBC),HL                                          ; FBD9DC  b1 53
	ld xbc, (xiz-14)                                     ; FBD9DE  ae f2 21
	ld wa, (xiz-10)                                      ; FBD9E1  9e f6 20
	ld (XBC+0x02),WA                                     ; FBD9E4  b9 02 50
	cp hl, 0x00:i3                                         ; FBD9E7  db d8
	jr nz, .LFBDA07                                      ; FBD9E9  6e 1c
	extz XIX                                             ; FBD9EB  ec 12
	ld (XIX+0x10),0x20                                   ; FBD9ED  bc 10 00 20
	ld (XIX+0x11),0x20                                   ; FBD9F1  bc 11 00 20
	push XDE                                             ; FBD9F5  3a
	push XHL                                             ; FBD9F6  3b
	push XIX                                             ; FBD9F7  3c
	push XIZ                                             ; FBD9F8  3e
	ld wa, (UI_DrawScratch+24:16)                                 ; FBD9F9  d1 58 26 20
	call T_Value_ToAsciiDigits3_RightJustified                                        ; FBD9FD  1d f0 1a f4
	pop XIZ                                              ; FBDA01  5e
	pop XIX                                              ; FBDA02  5c
	pop XHL                                              ; FBDA03  5b
	pop XDE                                              ; FBDA04  5a
	jr .LFBDA41                                          ; FBDA05  68 3a
.LFBDA07:
	push XDE                                             ; FBDA07  3a
	push XHL                                             ; FBDA08  3b
	push XIX                                             ; FBDA09  3c
	push XIZ                                             ; FBDA0A  3e
	ld wa, (UI_DrawScratch+22:16)                                 ; FBDA0B  d1 56 26 20
	call T_Value_ToAsciiDigits3_RightJustified                                        ; FBDA0F  1d f0 1a f4
	pop XIZ                                              ; FBDA13  5e
	pop XIX                                              ; FBDA14  5c
	pop XHL                                              ; FBDA15  5b
	pop XDE                                              ; FBDA16  5a
	ldw bc, Value_AsciiDigits                                       ; FBDA17  31 61 26
	inc 1,BC                                             ; FBDA1A  d9 61
	extz XBC                                             ; FBDA1C  e9 12
	ld (xiz-12), xbc                                     ; FBDA1E  be f4 61
	ld A,(XBC)                                           ; FBDA21  81 21
	extz XIX                                             ; FBDA23  ec 12
	ld (XIX+0x10),A                                      ; FBDA25  bc 10 41
	ld xbc, (xiz-12)                                     ; FBDA28  ae f4 21
	ld A,(XBC+0x01)                                      ; FBDA2B  89 01 21
	ld (XIX+0x11),A                                      ; FBDA2E  bc 11 41
	push XDE                                             ; FBDA31  3a
	push XHL                                             ; FBDA32  3b
	push XIX                                             ; FBDA33  3c
	push XIZ                                             ; FBDA34  3e
	ld wa, (UI_DrawScratch+24:16)                                 ; FBDA35  d1 58 26 20
	call T_Value_ToAsciiDigits3                          ; FBDA39  1d 00 1b f4
	pop XIZ                                              ; FBDA3D  5e
	pop XIX                                              ; FBDA3E  5c
	pop XHL                                              ; FBDA3F  5b
	pop XDE                                              ; FBDA40  5a
.LFBDA41:
	ld c, (Value_AsciiDigits:16)                                   ; FBDA41  c1 61 26 23
	extz XIX                                             ; FBDA45  ec 12
	ld (XIX+0x12),C                                      ; FBDA47  bc 12 43
	ld c, (Value_AsciiDigits+1:16)                                   ; FBDA4A  c1 62 26 23
	ld (XIX+0x13),C                                      ; FBDA4E  bc 13 43
	ld c, (Value_AsciiDigits+2:16)                                   ; FBDA51  c1 63 26 23
	ld (XIX+0x14),C                                      ; FBDA55  bc 14 43
.LFBDA58:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL6:24)                              ; FBDA58  f2 3b 9a f1 31
	push XBC                                             ; FBDA5D  39
	call T_DisplayListB_RunOne_Stack                     ; FBDA5E  1d 0c 2e f4
	pop XIY                                              ; FBDA62  5d
	cp	(CombiEdit_Row:16), 0x03                            ; FBDA63  c1 69 27 3f 03
	jr nz, .LFBDA7F                                      ; FBDA68  6e 15
	ld c, (0x2823:16)                                   ; FBDA6A  c1 23 28 23
	cp C,0x20                                            ; FBDA6E  cb cf 20
	jr z, .LFBDA7F                                       ; FBDA71  66 0c
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL7:24)                              ; FBDA73  f2 59 9a f1 31
	push XBC                                             ; FBDA78  39
	call T_Blink_Command                                 ; FBDA79  1d 20 2e f4
	jr .LFBDAB3                                          ; FBDA7D  68 34
.LFBDA7F:
	extz XIX                                             ; FBDA7F  ec 12
	ld C,(XIX+0x03)                                      ; FBDA81  8c 03 23
	and C,0x80                                           ; FBDA84  cb cc 80
	jr z, .LFBDA91                                       ; FBDA87  66 08
	extz XIX                                             ; FBDA89  ec 12
	ld (XIX+0x03),0x01                                   ; FBDA8B  bc 03 00 01
	jr .LFBDAA1                                          ; FBDA8F  68 10
.LFBDA91:
	extz XIX                                             ; FBDA91  ec 12
	ld C,(XIX+0x07)                                      ; FBDA93  8c 07 23
	and C,0x02                                           ; FBDA96  cb cc 02
	jr z, .LFBDAA9                                       ; FBDA99  66 0e
	extz XIX                                             ; FBDA9B  ec 12
	ld (XIX+0x03),0x00                                   ; FBDA9D  bc 03 00 00
.LFBDAA1:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL8:24)                              ; FBDAA1  f2 4a 9a f1 31
	push XBC                                             ; FBDAA6  39
	jr .LFBDAAF                                          ; FBDAA7  68 06
.LFBDAA9:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL7:24)                              ; FBDAA9  f2 59 9a f1 31
	push XBC                                             ; FBDAAE  39
.LFBDAAF:
	call T_DisplayListB_RunOne_Stack                     ; FBDAAF  1d 0c 2e f4
.LFBDAB3:
	pop XIY                                              ; FBDAB3  5d
	extz XIX                                             ; FBDAB4  ec 12
	ld C,(XIX+0x04)                                      ; FBDAB6  8c 04 23
	and C,0x80                                           ; FBDAB9  cb cc 80
	jr z, .LFBDAC6                                       ; FBDABC  66 08
	extz XIX                                             ; FBDABE  ec 12
	ld (XIX+0x04),0x01                                   ; FBDAC0  bc 04 00 01
	jr .LFBDAD6                                          ; FBDAC4  68 10
.LFBDAC6:
	extz XIX                                             ; FBDAC6  ec 12
	ld C,(XIX+0x07)                                      ; FBDAC8  8c 07 23
	and C,0x04                                           ; FBDACB  cb cc 04
	jr z, .LFBDADE                                       ; FBDACE  66 0e
	extz XIX                                             ; FBDAD0  ec 12
	ld (XIX+0x04),0x00                                   ; FBDAD2  bc 04 00 00
.LFBDAD6:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL9:24)                              ; FBDAD6  f2 63 9a f1 31
	push XBC                                             ; FBDADB  39
	jr .LFBDAE4                                          ; FBDADC  68 06
.LFBDADE:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL10:24)                              ; FBDADE  f2 72 9a f1 31
	push XBC                                             ; FBDAE3  39
.LFBDAE4:
	call T_DisplayListB_RunOne_Stack                     ; FBDAE4  1d 0c 2e f4
	pop XIY                                              ; FBDAE8  5d
	cp	(CombiEdit_Row:16), 0x05                            ; FBDAE9  c1 69 27 3f 05
	jr nz, .LFBDB05                                      ; FBDAEE  6e 15
	ld c, (0x2823:16)                                   ; FBDAF0  c1 23 28 23
	cp C,0x20                                            ; FBDAF4  cb cf 20
	jr z, .LFBDB05                                       ; FBDAF7  66 0c
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL11:24)                              ; FBDAF9  f2 90 9a f1 31
	push XBC                                             ; FBDAFE  39
	call T_Blink_Command                                 ; FBDAFF  1d 20 2e f4
	jr .LFBDB39                                          ; FBDB03  68 34
.LFBDB05:
	extz XIX                                             ; FBDB05  ec 12
	ld C,(XIX+0x06)                                      ; FBDB07  8c 06 23
	and C,0x80                                           ; FBDB0A  cb cc 80
	jr z, .LFBDB17                                       ; FBDB0D  66 08
	extz XIX                                             ; FBDB0F  ec 12
	ld (XIX+0x06),0x01                                   ; FBDB11  bc 06 00 01
	jr .LFBDB27                                          ; FBDB15  68 10
.LFBDB17:
	extz XIX                                             ; FBDB17  ec 12
	ld C,(XIX+0x07)                                      ; FBDB19  8c 07 23
	and C,0x10                                           ; FBDB1C  cb cc 10
	jr z, .LFBDB2F                                       ; FBDB1F  66 0e
	extz XIX                                             ; FBDB21  ec 12
	ld (XIX+0x06),0x00                                   ; FBDB23  bc 06 00 00
.LFBDB27:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL12:24)                              ; FBDB27  f2 81 9a f1 31
	push XBC                                             ; FBDB2C  39
	jr .LFBDB35                                          ; FBDB2D  68 06
.LFBDB2F:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL11:24)                              ; FBDB2F  f2 90 9a f1 31
	push XBC                                             ; FBDB34  39
.LFBDB35:
	call T_DisplayListB_RunOne_Stack                     ; FBDB35  1d 0c 2e f4
.LFBDB39:
	pop XIY                                              ; FBDB39  5d
	cp	(CombiEdit_Row:16), 0x06                            ; FBDB3A  c1 69 27 3f 06
	jr nz, .LFBDB56                                      ; FBDB3F  6e 15
	ld c, (0x2823:16)                                   ; FBDB41  c1 23 28 23
	cp C,0x20                                            ; FBDB45  cb cf 20
	jr z, .LFBDB56                                       ; FBDB48  66 0c
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL13:24)                              ; FBDB4A  f2 a9 9a f1 31
	push XBC                                             ; FBDB4F  39
	call T_Blink_Command                                 ; FBDB50  1d 20 2e f4
	jr .LFBDB8A                                          ; FBDB54  68 34
.LFBDB56:
	extz XIX                                             ; FBDB56  ec 12
	ld C,(XIX+0x05)                                      ; FBDB58  8c 05 23
	and C,0x80                                           ; FBDB5B  cb cc 80
	jr z, .LFBDB68                                       ; FBDB5E  66 08
	extz XIX                                             ; FBDB60  ec 12
	ld (XIX+0x05),0x01                                   ; FBDB62  bc 05 00 01
	jr .LFBDB78                                          ; FBDB66  68 10
.LFBDB68:
	extz XIX                                             ; FBDB68  ec 12
	ld C,(XIX+0x07)                                      ; FBDB6A  8c 07 23
	and C,0x08                                           ; FBDB6D  cb cc 08
	jr z, .LFBDB80                                       ; FBDB70  66 0e
	extz XIX                                             ; FBDB72  ec 12
	ld (XIX+0x05),0x00                                   ; FBDB74  bc 05 00 00
.LFBDB78:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL14:24)                              ; FBDB78  f2 9a 9a f1 31
	push XBC                                             ; FBDB7D  39
	jr .LFBDB86                                          ; FBDB7E  68 06
.LFBDB80:
	lda xbc, (CombiEditSound_PaintMultipleMessagesPage_DL13:24)                              ; FBDB80  f2 a9 9a f1 31
	push XBC                                             ; FBDB85  39
.LFBDB86:
	call T_DisplayListB_RunOne_Stack                     ; FBDB86  1d 0c 2e f4
.LFBDB8A:
	pop XIY                                              ; FBDB8A  5d
	pop XIX                                              ; FBDB8B  5c
	popw de                                              ; FBDB8C  4a
	popw hl                                              ; FBDB8D  4b
	unlk XIZ                                             ; FBDB8E  ee 0d
	ret                                                  ; FBDB90  0e
; ScreenEnter_CombiEditMixer: the +0 ENTER method of the screen object for screen id 0x3A -- PanelScreen_VtableTable entry 0x5A
;   (ViewB entry 0x3A) points at the thunk triple starting at T_ScreenEnter_CombiEditMixer, and slot T_ScreenEnter_CombiEditMixer jumps here.
; ScreenEnter_CombiEditMixer: screen 0x3A's +0 ENTER.  Its body posts painters that draw DL_Mixer ("MIXER", "SOUND:") and
;   the list at 0xF17E2E ("PAGE1/3", "SOUND", "PAN", "VOL") -- the MIXER page of the COMBINATION EDIT group 0x34-0x3A.
ScreenEnter_CombiEditMixer:
	calr ScreenEnterBody_CombiEditMixer                                      ; FBDB91  1e 01 00
	ret                                                  ; FBDB94  0e
ScreenEnterBody_CombiEditMixer:
	pushw hl                                             ; FBDB95  2b
	push XIX                                             ; FBDB96  3c
	lda xix, (0x276a:16)                                ; FBDB97  f1 6a 27 34
	ld c, (UI_ScreenLatch:16)                                   ; FBDB9B  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FBDB9F  c1 7b 20 f3
	jr z, .LFBDBEC                                       ; FBDBA3  66 47
	ld (0x2768:16), 0x00                                 ; FBDBA5  f1 68 27 00 00
	ld (CombiEdit_Page:16), 0x00                                 ; FBDBAA  f1 67 27 00 00
	ld (XIX),0x03                                        ; FBDBAF  b4 00 03
	ld (CombiEdit_Row:16), 0x03                                 ; FBDBB2  f1 69 27 00 03
	cp	(PanelModeGroup:16), 0x0a                            ; FBDBB7  c1 76 20 3f 0a
	jr nz, .LFBDBEC                                      ; FBDBBC  6e 2e
	ld h, (UI_PartIndex:16)                                   ; FBDBBE  c1 50 22 26
	ld (CombiEdit_EntryPart:16), h                                   ; FBDBC2  f1 6d 27 46
	ld (0x2766:16), h                                   ; FBDBC6  f1 66 27 46
	ld (CombiEdit_Part:16), h                                   ; FBDBCA  f1 65 27 46
	ld (0x2768:16), 0x00                                 ; FBDBCE  f1 68 27 00 00
	ld (CombiEdit_Page:16), 0x00                                 ; FBDBD3  f1 67 27 00 00
	ld (XIX),0x03                                        ; FBDBD8  b4 00 03
	ld (CombiEdit_Row:16), 0x03                                 ; FBDBDB  f1 69 27 00 03
	push XDE                                             ; FBDBE0  3a
	push XHL                                             ; FBDBE1  3b
	push XIX                                             ; FBDBE2  3c
	push XIZ                                             ; FBDBE3  3e
	call T_SoundGroup_ReloadSelection                                        ; FBDBE4  1d c8 15 f4
	pop XIZ                                              ; FBDBE8  5e
	pop XIX                                              ; FBDBE9  5c
	pop XHL                                              ; FBDBEA  5b
	pop XDE                                              ; FBDBEB  5a
.LFBDBEC:
	ld c, (UI_ScreenId:16)                                   ; FBDBEC  c1 7c 20 23
	cp	c, (UI_ScreenId_Previous:16)                               ; FBDBF0  c1 7d 20 f3
	jr z, .LFBDC3E                                       ; FBDBF4  66 48
	ld a, (UI_ScreenHoldState:16)                                   ; FBDBF6  c1 92 20 21
	and A,0x01                                           ; FBDBFA  c9 cc 01
	jr z, .LFBDC28                                       ; FBDBFD  66 29
	cp	(0x277e:16), 0x02                            ; FBDBFF  c1 7e 27 3f 02
	jr z, .LFBDC28                                       ; FBDC04  66 22
	ld h, (UI_PartIndex:16)                                   ; FBDC06  c1 50 22 26
	ld (CombiEdit_EntryPart:16), h                                   ; FBDC0A  f1 6d 27 46
	ld (0x2766:16), h                                   ; FBDC0E  f1 66 27 46
	ld (CombiEdit_Part:16), h                                   ; FBDC12  f1 65 27 46
	ld (0x2768:16), 0x00                                 ; FBDC16  f1 68 27 00 00
	ld (CombiEdit_Page:16), 0x00                                 ; FBDC1B  f1 67 27 00 00
	ld (XIX),0x03                                        ; FBDC20  b4 00 03
	ld (CombiEdit_Row:16), 0x03                                 ; FBDC23  f1 69 27 00 03
.LFBDC28:
	inc 0x01, (0x2768:16)                                ; FBDC28  c1 68 27 61
	incm8 0x01, (xix)                                    ; FBDC2C  84 61
	ld c, (CombiEdit_Part:16)                                   ; FBDC2E  c1 65 27 23
	add C,0x10                                           ; FBDC32  cb c8 10
	ld (0x2766:16), c                                   ; FBDC35  f1 66 27 43
	ld (0x277e:16), 0x00                                 ; FBDC39  f1 7e 27 00 00
.LFBDC3E:
	set	0, (UI_RequestBits:16)                               ; FBDC3E  f1 75 20 b8
	calr CombiEditMixer_SetDialButtons                                      ; FBDC42  1e aa 04
	ld h, (UI_PartIndex:16)                                   ; FBDC45  c1 50 22 26
	cp	h, (CombiEdit_Part:16)                               ; FBDC49  c1 65 27 f6
	jr z, .LFBDC57                                       ; FBDC4D  66 08
	ld (CombiEdit_Part:16), h                                   ; FBDC4F  f1 65 27 46
	res	4, (UI_ScreenFlags:16)                               ; FBDC53  f1 95 20 b4
.LFBDC57:
	ld c, (UI_ScreenHoldState:16)                                   ; FBDC57  c1 92 20 23
	and C,0x01                                           ; FBDC5B  cb cc 01
	jr z, ScreenEnterBody_CombiEditMixer_Skip                                     ; FBDC5E  66 04
	set	7, (UI_RequestBits:16)                               ; FBDC60  f1 75 20 bf
ScreenEnterBody_CombiEditMixer_Skip:
	ld c, (CombiEdit_Page:16)                                   ; FBDC64  c1 67 27 23
	cp	c, (0x2768:16)                               ; FBDC68  c1 68 27 f3
	jr nz, .LFBDC80                                      ; FBDC6C  6e 12
	ld a, (CombiEdit_Part:16)                                   ; FBDC6E  c1 65 27 21
	cp	a, (0x2766:16)                               ; FBDC72  c1 66 27 f1
	jr nz, .LFBDC80                                      ; FBDC76  6e 08
	ld B,(XIX)                                           ; FBDC78  84 22
	cp (CombiEdit_Row:16), b                                    ; FBDC7A  c1 69 27 fa
	jr z, .LFBDC90                                       ; FBDC7E  66 10
.LFBDC80:
	cp	(0x277e:16), 0x01                            ; FBDC80  c1 7e 27 3f 01
	jr nz, .LFBDC90                                      ; FBDC85  6e 09
	call T_CallbackQueue_ResetAndRestartTask2            ; FBDC87  1d 80 2e f4
	ld (0x277e:16), 0x00                                 ; FBDC8B  f1 7e 27 00 00
.LFBDC90:
	ld c, (UI_ScreenFlags:16)                                   ; FBDC90  c1 95 20 23
	and C,0x10                                           ; FBDC94  cb cc 10
	jr nz, .LFBDCF7                                      ; FBDC97  6e 5e
	ld c, (CombiEdit_Page:16)                                   ; FBDC99  c1 67 27 23
	cp	c, (0x2768:16)                               ; FBDC9D  c1 68 27 f3
	jr z, .LFBDCBF                                       ; FBDCA1  66 1c
	call T_CallbackQueue_ResetAndRestartTask2            ; FBDCA3  1d 80 2e f4
	ld (0x277e:16), 0x00                                 ; FBDCA7  f1 7e 27 00 00
	lda xbc, (.LFBE135:24)                               ; FBDCAC  f2 35 e1 fb 31
	push XBC                                             ; FBDCB1  39
	call T_CallbackQueue_Post                            ; FBDCB2  1d 84 2e f4
	pushw 0x01                                           ; FBDCB6  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBDCB9  1d c0 2d f4
	inc 6,XSP                                            ; FBDCBD  ef 66
.LFBDCBF:
	ld c, (CombiEdit_Part:16)                                   ; FBDCBF  c1 65 27 23
	cp	c, (0x2766:16)                               ; FBDCC3  c1 66 27 f3
	jr z, .LFBDCDC                                       ; FBDCC7  66 13
	lda xbc, (.LFBE2E9:24)                               ; FBDCC9  f2 e9 e2 fb 31
	push XBC                                             ; FBDCCE  39
	call T_CallbackQueue_Post                            ; FBDCCF  1d 84 2e f4
	pushw 0x01                                           ; FBDCD3  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBDCD6  1d c0 2d f4
	inc 6,XSP                                            ; FBDCDA  ef 66
.LFBDCDC:
	ld C,(XIX)                                           ; FBDCDC  84 23
	cp (CombiEdit_Row:16), c                                    ; FBDCDE  c1 69 27 fb
	jr z, .LFBDCF7                                       ; FBDCE2  66 13
	lda xbc, (.LFBE374:24)                               ; FBDCE4  f2 74 e3 fb 31
	push XBC                                             ; FBDCE9  39
	call T_CallbackQueue_Post                            ; FBDCEA  1d 84 2e f4
	pushw 0x01                                           ; FBDCEE  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBDCF1  1d c0 2d f4
	inc 6,XSP                                            ; FBDCF5  ef 66
.LFBDCF7:
	lda xbc, (.LFBE3B0:24)                               ; FBDCF7  f2 b0 e3 fb 31
	push XBC                                             ; FBDCFC  39
	call T_CallbackQueue_Post                            ; FBDCFD  1d 84 2e f4
	pushw 0x01                                           ; FBDD01  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBDD04  1d c0 2d f4
	inc 6,XSP                                            ; FBDD08  ef 66
	pop XIX                                              ; FBDD0A  5c
	popw hl                                              ; FBDD0B  4b
	ret                                                  ; FBDD0C  0e
; ScreenLeave_CombiEditMixer: the +4 LEAVE method of the screen object for screen id 0x3A -- PanelScreen_VtableTable entry 0x5A
;   (ViewB entry 0x3A) points at the thunk triple starting at T_ScreenEnter_CombiEditMixer, and slot T_ScreenLeave_CombiEditMixer jumps here.
ScreenLeave_CombiEditMixer:
	calr ScreenLeaveBody_CombiEditMixer                                      ; FBDD0D  1e 01 00
	ret                                                  ; FBDD10  0e
ScreenLeaveBody_CombiEditMixer:
	pushw hl                                             ; FBDD11  2b
	push XIX                                             ; FBDD12  3c
	lda xix, (PanelModeGroup_Previous:16)                                ; FBDD13  f1 77 20 34
	ld h, (UI_ScreenId:16)                                   ; FBDD17  c1 7c 20 26
	ld c, (UI_ScreenLatch_Previous:16)                                   ; FBDD1B  c1 7b 20 23
	cp	c, (UI_ScreenId_Previous:16)                               ; FBDD1F  c1 7d 20 f3
	jr z, .LFBDD2E                                       ; FBDD23  66 09
	cp H,0xa1                                            ; FBDD25  ce cf a1
	jr z, .LFBDD2E                                       ; FBDD28  66 04
	res	7, (UI_RequestBits:16)                               ; FBDD2A  f1 75 20 b7
.LFBDD2E:
	ld C,(XIX)                                           ; FBDD2E  84 23
	cp C,0x08                                            ; FBDD30  cb cf 08
	jr z, .LFBDD42                                       ; FBDD33  66 0d
	ld C,(XIX)                                           ; FBDD35  84 23
	cp c, 0x03:i3                                          ; FBDD37  cb db
	jr z, .LFBDD42                                       ; FBDD39  66 07
	ld C,(XIX)                                           ; FBDD3B  84 23
	cp C,0x15                                            ; FBDD3D  cb cf 15
	jr nz, .LFBDD56                                      ; FBDD40  6e 14
.LFBDD42:
	cp H,0xb6                                            ; FBDD42  ce cf b6
	jr z, .LFBDD56                                       ; FBDD45  66 0f
	cp H,0xa1                                            ; FBDD47  ce cf a1
	jr z, .LFBDD56                                       ; FBDD4A  66 0a
	ld	(UI_PartIndex:16), (CombiEdit_EntryPart:16)             ; FBDD4C  c1 6d 27 19 50 22
	call T_PartIndex_PostChangeEvent                                        ; FBDD52  1d 9c 2c f4
.LFBDD56:
	ld c, (UI_ScreenLatch:16)                                   ; FBDD56  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FBDD5A  c1 7b 20 f3
	jr z, .LFBDD7D                                       ; FBDD5E  66 1d
	ld A,(XIX)                                           ; FBDD60  84 21
	cp A,0x0a                                            ; FBDD62  c9 cf 0a
	jr nz, .LFBDD7D                                      ; FBDD65  6e 16
	ld	(UI_PartIndex:16), (CombiEdit_EntryPart:16)             ; FBDD67  c1 6d 27 19 50 22
	call T_PartIndex_PostChangeEvent                                        ; FBDD6D  1d 9c 2c f4
	push XDE                                             ; FBDD71  3a
	push XHL                                             ; FBDD72  3b
	push XIX                                             ; FBDD73  3c
	push XIZ                                             ; FBDD74  3e
	call T_SoundGroup_ReloadSelection                                        ; FBDD75  1d c8 15 f4
	pop XIZ                                              ; FBDD79  5e
	pop XIX                                              ; FBDD7A  5c
	pop XHL                                              ; FBDD7B  5b
	pop XDE                                              ; FBDD7C  5a
.LFBDD7D:
	pop XIX                                              ; FBDD7D  5c
	popw hl                                              ; FBDD7E  4b
	ret                                                  ; FBDD7F  0e
; ScreenButton_CombiEditMixer: the +8 BUTTON method of the screen object for screen id 0x3A -- PanelScreen_VtableTable entry 0x5A
;   (ViewB entry 0x3A) points at the thunk triple starting at T_ScreenEnter_CombiEditMixer, and slot T_ScreenButton_CombiEditMixer jumps here.
ScreenButton_CombiEditMixer:
	link XIZ,0x0000                                      ; FBDD80  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBDD84  9e 0a 04
	pushw	(xiz+8)                                      ; FBDD87  9e 08 04
	calr ScreenButtonBody_CombiEditMixer                                      ; FBDD8A  1e 04 00
	pop XBC                                              ; FBDD8D  59
	unlk XIZ                                             ; FBDD8E  ee 0d
	ret                                                  ; FBDD90  0e
ScreenButtonBody_CombiEditMixer:
	link XIZ,0x0000                                      ; FBDD91  ee 0c 00 00
	cp	(PanelModeGroup:16), 0x16                            ; FBDD95  c1 76 20 3f 16
	jr nz, .LFBDDAF                                      ; FBDD9A  6e 13
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBDD9C  c1 7f 27 3f 01
	jr nz, .LFBDDAF                                      ; FBDDA1  6e 0c
	cpw	(xiz+8), 0x001e                              ; FBDDA3  9e 08 3f 1e 00
	jr nz, .LFBDDCF                                      ; FBDDA8  6e 25
	calr CompareKey_CombiEdit                                      ; FBDDAA  1e 11 10
	jr .LFBDDCF                                          ; FBDDAD  68 20
.LFBDDAF:
	pushw	(xiz+10)                                     ; FBDDAF  9e 0a 04
	pushw	(xiz+8)                                      ; FBDDB2  9e 08 04
	call T_PanelCode_ToSlotAndFlags                                        ; FBDDB5  1d 74 2c f4
	mul A,0x04                                           ; FBDDB9  c9 08 04
	extz XWA                                             ; FBDDBC  e8 12
	add XWA,ScreenButtons_CombiEditMixer                              ; FBDDBE  e8 c8 d5 af f1 00
	ld XBC,(XWA)                                         ; FBDDC4  a0 21
	lda xiy, (.LFBDDCE:24)                               ; FBDDC6  f2 ce dd fb 35
	push XIY                                             ; FBDDCB  3d
	jp (xbc)                                             ; FBDDCC  b1 d8
.LFBDDCE:
	pop XIY                                              ; FBDDCE  5d
.LFBDDCF:
	unlk XIZ                                             ; FBDDCF  ee 0d
	ret                                                  ; FBDDD1  0e
sub_FBDDD2:
	calr T_F418C4_Nop                                      ; FBDDD2  1e 01 00
	ret                                                  ; FBDDD5  0e
T_F418C4_Nop:
	ret                                                  ; FBDDD6  0e
; SoftKeyCols1to8_CombiEditMixer: ScreenButtons_CombiEditMixer slots [0, 1, 2, 3, 4, 5, 6, 7], the 23-slot button table ScreenButtonBody_CombiEditMixer reads through T_PanelCode_ToSlotAndFlags --
;   one handler for soft keys 1, 2, 3, 4, 5, 6, 7, 8 of CombiEditMixer (notes/prom_ab_promb_slot23_targets.py).
SoftKeyCols1to8_CombiEditMixer:
	pushw hl                                             ; FBDDD7  2b
	ld l, (PanelEvent_ButtonCode:16)                                   ; FBDDD8  c1 b1 28 27
	cp L,0x11                                            ; FBDDDC  cf cf 11
	jr c, .LFBDDED                                       ; FBDDDF  67 0c
	cp L,0x19                                            ; FBDDE1  cf cf 19
	jr ugt, .LFBDDED                                     ; FBDDE4  6b 07
	ld H,L                                               ; FBDDE6  cf 8e
	sub H,0x11                                           ; FBDDE8  ce ca 11
	jr .LFBDDEF                                          ; FBDDEB  68 02
.LFBDDED:
	ld H,L                                               ; FBDDED  cf 8e
.LFBDDEF:
	push 0x00                                            ; FBDDEF  09 00
	push H                                               ; FBDDF1  ce 04
	calr CombiEditMixer_ColumnKey                                      ; FBDDF3  1e 67 02
	popw bc                                              ; FBDDF6  49
	popw hl                                              ; FBDDF7  4b
	ret                                                  ; FBDDF8  0e
; LcdKeyRow1_CombiEditMixer: ScreenButtons_CombiEditMixer[8], the 23-slot button table ScreenButtonBody_CombiEditMixer reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow1 handler of CombiEditMixer (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow1_CombiEditMixer:
	pushw hl                                             ; FBDDF9  2b
	push XIX                                             ; FBDDFA  3c
	lda xix, (CombiEdit_Row:16)                                ; FBDDFB  f1 69 27 34
	ld h, (PanelEvent_Flags:16)                                   ; FBDDFF  c1 b0 28 26
	ld bc, (CombiEdit_Page:16)                                 ; FBDE03  d1 67 27 21
	extz BC                                              ; FBDE07  d9 12
	cp bc, 0x00:i3                                         ; FBDE09  d9 d8
	jr z, .LFBDE17                                       ; FBDE0B  66 0a
	cp bc, 0x01:i3                                         ; FBDE0D  d9 d9
	jr z, .LFBDE29                                       ; FBDE0F  66 18
	cp bc, 0x02:i3                                         ; FBDE11  d9 da
	jr z, .LFBDE3B                                       ; FBDE13  66 26
	jr .LFBDE57                                          ; FBDE15  68 40
.LFBDE17:
	ld C,H                                               ; FBDE17  ce 8b
	and C,0x01                                           ; FBDE19  cb cc 01
	jr z, .LFBDE57                                       ; FBDE1C  66 39
	ld C,(XIX)                                           ; FBDE1E  84 23
	cp c, 0x00:i3                                          ; FBDE20  cb d8
	jr z, .LFBDE57                                       ; FBDE22  66 33
	ld (XIX),0x00                                        ; FBDE24  b4 00 00
	jr .LFBDE53                                          ; FBDE27  68 2a
.LFBDE29:
	ld C,H                                               ; FBDE29  ce 8b
	and C,0x01                                           ; FBDE2B  cb cc 01
	jr z, .LFBDE57                                       ; FBDE2E  66 27
	ld C,(XIX)                                           ; FBDE30  84 23
	cp c, 0x04:i3                                          ; FBDE32  cb dc
	jr z, .LFBDE57                                       ; FBDE34  66 21
	ld (XIX),0x04                                        ; FBDE36  b4 00 04
	jr .LFBDE53                                          ; FBDE39  68 18
.LFBDE3B:
	cp	(PanelModeGroup:16), 0x16                            ; FBDE3B  c1 76 20 3f 16
	jr z, .LFBDE57                                       ; FBDE40  66 15
	ld C,H                                               ; FBDE42  ce 8b
	and C,0x01                                           ; FBDE44  cb cc 01
	jr z, .LFBDE57                                       ; FBDE47  66 0e
	ld C,(XIX)                                           ; FBDE49  84 23
	cp C,0x09                                            ; FBDE4B  cb cf 09
	jr z, .LFBDE57                                       ; FBDE4E  66 07
	ld (XIX),0x09                                        ; FBDE50  b4 00 09
.LFBDE53:
	set	4, (UI_Request_Hi:16)                               ; FBDE53  f1 71 20 bc
.LFBDE57:
	ld C,H                                               ; FBDE57  ce 8b
	and C,0x01                                           ; FBDE59  cb cc 01
	jr nz, .LFBDE68                                      ; FBDE5C  6e 0a
	cp	(PanelModeGroup:16), 0x16                            ; FBDE5E  c1 76 20 3f 16
	jr nz, .LFBDE68                                      ; FBDE63  6e 03
	calr CombiEdit_ToggleSolo                                      ; FBDE65  1e ca 1d
.LFBDE68:
	pop XIX                                              ; FBDE68  5c
	popw hl                                              ; FBDE69  4b
	ret                                                  ; FBDE6A  0e
; LcdKeyRow2_CombiEditMixer: ScreenButtons_CombiEditMixer[9], the 23-slot button table ScreenButtonBody_CombiEditMixer reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow2 handler of CombiEditMixer (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow2_CombiEditMixer:
	pushw hl                                             ; FBDE6B  2b
	push XIX                                             ; FBDE6C  3c
	lda xix, (CombiEdit_Row:16)                                ; FBDE6D  f1 69 27 34
	ld h, (PanelEvent_Flags:16)                                   ; FBDE71  c1 b0 28 26
	ld bc, (CombiEdit_Page:16)                                 ; FBDE75  d1 67 27 21
	extz BC                                              ; FBDE79  d9 12
	cp bc, 0x00:i3                                         ; FBDE7B  d9 d8
	jr z, .LFBDE89                                       ; FBDE7D  66 0a
	cp bc, 0x01:i3                                         ; FBDE7F  d9 d9
	jr z, .LFBDEA2                                       ; FBDE81  66 1f
	cp bc, 0x02:i3                                         ; FBDE83  d9 da
	jr z, .LFBDEB4                                       ; FBDE85  66 2d
	jr .LFBDEC9                                          ; FBDE87  68 40
.LFBDE89:
	cp	(PanelModeGroup:16), 0x16                            ; FBDE89  c1 76 20 3f 16
	jr nz, .LFBDEC9                                      ; FBDE8E  6e 39
	ld C,H                                               ; FBDE90  ce 8b
	and C,0x01                                           ; FBDE92  cb cc 01
	jr z, .LFBDEC9                                       ; FBDE95  66 32
	ld C,(XIX)                                           ; FBDE97  84 23
	cp c, 0x01:i3                                          ; FBDE99  cb d9
	jr z, .LFBDEC9                                       ; FBDE9B  66 2c
	ld (XIX),0x01                                        ; FBDE9D  b4 00 01
	jr .LFBDEC5                                          ; FBDEA0  68 23
.LFBDEA2:
	ld C,H                                               ; FBDEA2  ce 8b
	and C,0x01                                           ; FBDEA4  cb cc 01
	jr z, .LFBDEC9                                       ; FBDEA7  66 20
	ld C,(XIX)                                           ; FBDEA9  84 23
	cp c, 0x05:i3                                          ; FBDEAB  cb dd
	jr z, .LFBDEC9                                       ; FBDEAD  66 1a
	ld (XIX),0x05                                        ; FBDEAF  b4 00 05
	jr .LFBDEC5                                          ; FBDEB2  68 11
.LFBDEB4:
	ld C,H                                               ; FBDEB4  ce 8b
	and C,0x01                                           ; FBDEB6  cb cc 01
	jr z, .LFBDEC9                                       ; FBDEB9  66 0e
	ld C,(XIX)                                           ; FBDEBB  84 23
	cp C,0x0a                                            ; FBDEBD  cb cf 0a
	jr z, .LFBDEC9                                       ; FBDEC0  66 07
	ld (XIX),0x0a                                        ; FBDEC2  b4 00 0a
.LFBDEC5:
	set	4, (UI_Request_Hi:16)                               ; FBDEC5  f1 71 20 bc
.LFBDEC9:
	pop XIX                                              ; FBDEC9  5c
	popw hl                                              ; FBDECA  4b
	ret                                                  ; FBDECB  0e
; LcdKeyRow3_CombiEditMixer: ScreenButtons_CombiEditMixer[10], the 23-slot button table ScreenButtonBody_CombiEditMixer reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow3 handler of CombiEditMixer (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow3_CombiEditMixer:
	pushw hl                                             ; FBDECC  2b
	push XIX                                             ; FBDECD  3c
	lda xix, (CombiEdit_Row:16)                                ; FBDECE  f1 69 27 34
	ld h, (PanelEvent_Flags:16)                                   ; FBDED2  c1 b0 28 26
	ld bc, (CombiEdit_Page:16)                                 ; FBDED6  d1 67 27 21
	extz BC                                              ; FBDEDA  d9 12
	cp bc, 0x00:i3                                         ; FBDEDC  d9 d8
	jr z, .LFBDEEA                                       ; FBDEDE  66 0a
	cp bc, 0x01:i3                                         ; FBDEE0  d9 d9
	jr z, .LFBDEFC                                       ; FBDEE2  66 18
	cp bc, 0x02:i3                                         ; FBDEE4  d9 da
	jr z, .LFBDF0E                                       ; FBDEE6  66 26
	jr .LFBDF23                                          ; FBDEE8  68 39
.LFBDEEA:
	ld C,H                                               ; FBDEEA  ce 8b
	and C,0x01                                           ; FBDEEC  cb cc 01
	jr z, .LFBDF23                                       ; FBDEEF  66 32
	ld C,(XIX)                                           ; FBDEF1  84 23
	cp c, 0x02:i3                                          ; FBDEF3  cb da
	jr z, .LFBDF23                                       ; FBDEF5  66 2c
	ld (XIX),0x02                                        ; FBDEF7  b4 00 02
	jr .LFBDF1F                                          ; FBDEFA  68 23
.LFBDEFC:
	ld C,H                                               ; FBDEFC  ce 8b
	and C,0x01                                           ; FBDEFE  cb cc 01
	jr z, .LFBDF23                                       ; FBDF01  66 20
	ld C,(XIX)                                           ; FBDF03  84 23
	cp c, 0x06:i3                                          ; FBDF05  cb de
	jr z, .LFBDF23                                       ; FBDF07  66 1a
	ld (XIX),0x06                                        ; FBDF09  b4 00 06
	jr .LFBDF1F                                          ; FBDF0C  68 11
.LFBDF0E:
	ld C,H                                               ; FBDF0E  ce 8b
	and C,0x01                                           ; FBDF10  cb cc 01
	jr z, .LFBDF23                                       ; FBDF13  66 0e
	ld C,(XIX)                                           ; FBDF15  84 23
	cp C,0x0b                                            ; FBDF17  cb cf 0b
	jr z, .LFBDF23                                       ; FBDF1A  66 07
	ld (XIX),0x0b                                        ; FBDF1C  b4 00 0b
.LFBDF1F:
	set	4, (UI_Request_Hi:16)                               ; FBDF1F  f1 71 20 bc
.LFBDF23:
	pop XIX                                              ; FBDF23  5c
	popw hl                                              ; FBDF24  4b
	ret                                                  ; FBDF25  0e
; LcdKeyRow4_CombiEditMixer: ScreenButtons_CombiEditMixer[11], the 23-slot button table ScreenButtonBody_CombiEditMixer reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow4 handler of CombiEditMixer (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow4_CombiEditMixer:
	pushw hl                                             ; FBDF26  2b
	push XIX                                             ; FBDF27  3c
	lda xix, (CombiEdit_Row:16)                                ; FBDF28  f1 69 27 34
	ld h, (PanelEvent_Flags:16)                                   ; FBDF2C  c1 b0 28 26
	ld bc, (CombiEdit_Page:16)                                 ; FBDF30  d1 67 27 21
	extz BC                                              ; FBDF34  d9 12
	cp bc, 0x00:i3                                         ; FBDF36  d9 d8
	jr z, .LFBDF44                                       ; FBDF38  66 0a
	cp bc, 0x01:i3                                         ; FBDF3A  d9 d9
	jr z, .LFBDF56                                       ; FBDF3C  66 18
	cp bc, 0x02:i3                                         ; FBDF3E  d9 da
	jr z, .LFBDF69                                       ; FBDF40  66 27
	jr .LFBDF83                                          ; FBDF42  68 3f
.LFBDF44:
	ld C,H                                               ; FBDF44  ce 8b
	and C,0x01                                           ; FBDF46  cb cc 01
	jr z, .LFBDF80                                       ; FBDF49  66 35
	ld C,(XIX)                                           ; FBDF4B  84 23
	cp c, 0x03:i3                                          ; FBDF4D  cb db
	jr z, .LFBDF83                                       ; FBDF4F  66 32
	ld (XIX),0x03                                        ; FBDF51  b4 00 03
	jr .LFBDF7A                                          ; FBDF54  68 24
.LFBDF56:
	ld C,H                                               ; FBDF56  ce 8b
	and C,0x01                                           ; FBDF58  cb cc 01
	jr z, .LFBDF80                                       ; FBDF5B  66 23
	ld C,(XIX)                                           ; FBDF5D  84 23
	cp C,0x08                                            ; FBDF5F  cb cf 08
	jr z, .LFBDF83                                       ; FBDF62  66 1f
	ld (XIX),0x08                                        ; FBDF64  b4 00 08
	jr .LFBDF7A                                          ; FBDF67  68 11
.LFBDF69:
	ld C,H                                               ; FBDF69  ce 8b
	and C,0x01                                           ; FBDF6B  cb cc 01
	jr z, .LFBDF80                                       ; FBDF6E  66 10
	ld C,(XIX)                                           ; FBDF70  84 23
	cp C,0x0c                                            ; FBDF72  cb cf 0c
	jr z, .LFBDF83                                       ; FBDF75  66 0c
	ld (XIX),0x0c                                        ; FBDF77  b4 00 0c
.LFBDF7A:
	set	4, (UI_Request_Hi:16)                               ; FBDF7A  f1 71 20 bc
	jr .LFBDF83                                          ; FBDF7E  68 03
.LFBDF80:
	calr CombiEditMixer_ShowOtherParts                                      ; FBDF80  1e 83 01
.LFBDF83:
	pop XIX                                              ; FBDF83  5c
	popw hl                                              ; FBDF84  4b
	ret                                                  ; FBDF85  0e
; LcdKeyRow5_CombiEditMixer: ScreenButtons_CombiEditMixer[12], the 23-slot button table ScreenButtonBody_CombiEditMixer reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow5 handler of CombiEditMixer (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow5_CombiEditMixer:
	push XIX                                             ; FBDF86  3c
	lda xix, (CombiEdit_Row:16)                                ; FBDF87  f1 69 27 34
	ld bc, (CombiEdit_Page:16)                                 ; FBDF8B  d1 67 27 21
	extz BC                                              ; FBDF8F  d9 12
	cp bc, 0x00:i3                                         ; FBDF91  d9 d8
	jr z, .LFBDFCA                                       ; FBDF93  66 35
	cp bc, 0x01:i3                                         ; FBDF95  d9 d9
	jr z, .LFBDF9F                                       ; FBDF97  66 06
	cp bc, 0x02:i3                                         ; FBDF99  d9 da
	jr z, .LFBDFB4                                       ; FBDF9B  66 17
	jr .LFBDFCA                                          ; FBDF9D  68 2b
.LFBDF9F:
	ld c, (PanelEvent_Flags:16)                                   ; FBDF9F  c1 b0 28 23
	and C,0x01                                           ; FBDFA3  cb cc 01
	jr z, .LFBDFCA                                       ; FBDFA6  66 22
	ld C,(XIX)                                           ; FBDFA8  84 23
	cp C,0x0d                                            ; FBDFAA  cb cf 0d
	jr z, .LFBDFCA                                       ; FBDFAD  66 1b
	ld (XIX),0x0d                                        ; FBDFAF  b4 00 0d
	jr .LFBDFC6                                          ; FBDFB2  68 12
.LFBDFB4:
	ld c, (PanelEvent_Flags:16)                                   ; FBDFB4  c1 b0 28 23
	and C,0x01                                           ; FBDFB8  cb cc 01
	jr z, .LFBDFCA                                       ; FBDFBB  66 0d
	ld C,(XIX)                                           ; FBDFBD  84 23
	cp c, 0x07:i3                                          ; FBDFBF  cb df
	jr z, .LFBDFCA                                       ; FBDFC1  66 07
	ld (XIX),0x07                                        ; FBDFC3  b4 00 07
.LFBDFC6:
	set	4, (UI_Request_Hi:16)                               ; FBDFC6  f1 71 20 bc
.LFBDFCA:
	pop XIX                                              ; FBDFCA  5c
	ret                                                  ; FBDFCB  0e
; ExitKey_CombiEditMixer: ScreenButtons_CombiEditMixer[15], the 23-slot button table ScreenButtonBody_CombiEditMixer reads through T_PanelCode_ToSlotAndFlags -- the
;   ExitKey handler of CombiEditMixer (notes/prom_ab_promb_slot23_targets.py).
ExitKey_CombiEditMixer:
	pushw hl                                             ; FBDFCC  2b
	push XIX                                             ; FBDFCD  3c
	lda xix, (UI_Request_Hi:16)                                ; FBDFCE  f1 71 20 34
	ld c, (PanelEvent_Flags:16)                                   ; FBDFD2  c1 b0 28 23
	and C,0x01                                           ; FBDFD6  cb cc 01
	jr nz, .LFBE035                                      ; FBDFD9  6e 5a
	ld c, (UI_ScreenHoldState:16)                                   ; FBDFDB  c1 92 20 23
	and C,0x01                                           ; FBDFDF  cb cc 01
	jr z, .LFBDFEB                                       ; FBDFE2  66 07
	ld (UI_ScreenHoldPending:16), 0x01                                 ; FBDFE4  f1 9a 20 00 01
	jr .LFBE035                                          ; FBDFE9  68 4a
.LFBDFEB:
	ld bc, (PanelModeGroup:16)                                 ; FBDFEB  d1 76 20 21
	extz BC                                              ; FBDFEF  d9 12
	cp BC,0x0009                                         ; FBDFF1  d9 cf 09 00
	jr z, .LFBE005                                       ; FBDFF5  66 0e
	cp BC,0x000a                                         ; FBDFF7  d9 cf 0a 00
	jr z, .LFBE00F                                       ; FBDFFB  66 12
	cp BC,0x0016                                         ; FBDFFD  d9 cf 16 00
	jr z, .LFBE019                                       ; FBE001  66 16
	jr .LFBE035                                          ; FBE003  68 30
.LFBE005:
	or	(xix), 0x80                                  ; FBE005  84 3e 80
	ld (UI_Request:16), 0xb0                                 ; FBE008  f1 70 20 00 b0
	jr .LFBE035                                          ; FBE00D  68 26
.LFBE00F:
	or	(xix), 0x80                                  ; FBE00F  84 3e 80
	ld (UI_Request:16), 0x60                                 ; FBE012  f1 70 20 00 60
	jr .LFBE035                                          ; FBE017  68 1c
.LFBE019:
	ld H,(XIX)                                           ; FBE019  84 26
	set 0x07,H                                           ; FBE01B  ce 31 07
	cp	(UI_ScreenId:16), 0x3a                            ; FBE01E  c1 7c 20 3f 3a
	jr z, .LFBE02E                                       ; FBE023  66 09
	ld (XIX),H                                           ; FBE025  b4 46
	ld (UI_Request:16), 0x33                                 ; FBE027  f1 70 20 00 33
	jr .LFBE035                                          ; FBE02C  68 07
.LFBE02E:
	ld (XIX),H                                           ; FBE02E  b4 46
	ld (UI_Request:16), 0x34                                 ; FBE030  f1 70 20 00 34
.LFBE035:
	pop XIX                                              ; FBE035  5c
	popw hl                                              ; FBE036  4b
	ret                                                  ; FBE037  0e
; PageKey_CombiEditMixer: ScreenButtons_CombiEditMixer[16], the 23-slot button table ScreenButtonBody_CombiEditMixer reads through T_PanelCode_ToSlotAndFlags -- the
;   PageKey handler of CombiEditMixer (notes/prom_ab_promb_slot23_targets.py).
PageKey_CombiEditMixer:
	lda xbc, (Record_F1AE3F:24)                          ; FBE038  f2 3f ae f1 31
	push XBC                                             ; FBE03D  39
	lda xwa, (CombiEdit_Page:16)                                ; FBE03E  f1 67 27 30
	push XWA                                             ; FBE042  38
	call T_EditValue_StepBitField                                        ; FBE043  1d 78 2c f4
	inc 8,XSP                                            ; FBE047  ef 60
	cp a, 0x01:i3                                          ; FBE049  c9 d9
	jr nz, .LFBE05C                                      ; FBE04B  6e 0f
	calr CombiEditMixer_ResetRowForPage                                      ; FBE04D  1e 69 00
	inc 0x01, (0x276a:16)                                ; FBE050  c1 6a 27 61
	inc 0x08, (0x2766:16)                                ; FBE054  c1 66 27 60
	set	4, (UI_Request_Hi:16)                               ; FBE058  f1 71 20 bc
.LFBE05C:
	ret                                                  ; FBE05C  0e
; CombiEditMixer_ColumnKey: (column 0..7), from SoftKeyCols1to8_CombiEditMixer: the part = the edited group ((CombiEdit_Part) & 0xF8) +
;   column.  When it is already CombiEdit_Part (or while UI_RequestBits bit 2 is set) its field
;   IndexMap_F1B031[CombiEdit_Row] is stepped (PartParam_StepFieldById); otherwise it becomes the edited part
;   (UI_PartIndex and CombiEdit_Part, T_PartIndex_PostChangeEvent, a repaint request).  Basis: body + caller.
CombiEditMixer_ColumnKey:
	link XIZ,0x0000                                      ; FBE05D  ee 0c 00 00
	pushw hl                                             ; FBE061  2b
	push XIX                                             ; FBE062  3c
	lda xix, (UI_RequestBits:16)                                ; FBE063  f1 75 20 34
	cp (XIZ+0x08),0x08                                   ; FBE067  8e 08 3f 08
	jr nc, .LFBE0B4                                      ; FBE06B  6f 47
	ld h, (CombiEdit_Part:16)                                   ; FBE06D  c1 65 27 26
	and H,0xf8                                           ; FBE071  ce cc f8
	ld C,(XIZ+0x08)                                      ; FBE074  8e 08 23
	add H,C                                              ; FBE077  cb 86
	cp	h, (CombiEdit_Part:16)                               ; FBE079  c1 65 27 f6
	jr z, .LFBE086                                       ; FBE07D  66 07
	ld A,(XIX)                                           ; FBE07F  84 21
	and A,0x04                                           ; FBE081  c9 cc 04
	jr z, .LFBE0A1                                       ; FBE084  66 1b
.LFBE086:
	push 0x00                                            ; FBE086  09 00
	push H                                               ; FBE088  ce 04
	ld bc, (CombiEdit_Row:16)                                 ; FBE08A  d1 69 27 21
	extz BC                                              ; FBE08E  d9 12
	extz XBC                                             ; FBE090  e9 12
	add XBC,IndexMap_F1B031                              ; FBE092  e9 c8 31 b0 f1 00
	ld A,(XBC)                                           ; FBE098  81 21
	pushw wa                                             ; FBE09A  28
	calr PartParam_StepFieldById                                          ; FBE09B  1e 62 d7
	pop XIY                                              ; FBE09E  5d
	jr .LFBE0B4                                          ; FBE09F  68 13
.LFBE0A1:
	ld (UI_PartIndex:16), h                                   ; FBE0A1  f1 50 22 46
	ld (CombiEdit_Part:16), h                                   ; FBE0A5  f1 65 27 46
	call T_PartIndex_PostChangeEvent                                        ; FBE0A9  1d 9c 2c f4
	or	(xix), 0x08                                  ; FBE0AD  84 3e 08
	set	4, (UI_Request_Hi:16)                               ; FBE0B0  f1 71 20 bc
.LFBE0B4:
	pop XIX                                              ; FBE0B4  5c
	popw hl                                              ; FBE0B5  4b
	unlk XIZ                                             ; FBE0B6  ee 0d
	ret                                                  ; FBE0B8  0e
; CombiEditMixer_ResetRowForPage: PageKey_CombiEditMixer: CombiEdit_Row (and (0x276A)) = the page's first row -- 3 on page 0, 4 on page 1,
;   0x0A on page 2 (9 outside panel-mode group 0x16).  Basis: body + caller.
CombiEditMixer_ResetRowForPage:
	push XIX                                             ; FBE0B9  3c
	lda xix, (CombiEdit_Row:16)                                ; FBE0BA  f1 69 27 34
	ld bc, (CombiEdit_Page:16)                                 ; FBE0BE  d1 67 27 21
	extz BC                                              ; FBE0C2  d9 12
	cp bc, 0x00:i3                                         ; FBE0C4  d9 d8
	jr z, .LFBE0D2                                       ; FBE0C6  66 0a
	cp bc, 0x01:i3                                         ; FBE0C8  d9 d9
	jr z, .LFBE0D7                                       ; FBE0CA  66 0b
	cp bc, 0x02:i3                                         ; FBE0CC  d9 da
	jr z, .LFBE0DC                                       ; FBE0CE  66 0c
	jr .LFBE0E9                                          ; FBE0D0  68 17
.LFBE0D2:
	ld (XIX),0x03                                        ; FBE0D2  b4 00 03
	jr .LFBE0E9                                          ; FBE0D5  68 12
.LFBE0D7:
	ld (XIX),0x04                                        ; FBE0D7  b4 00 04
	jr .LFBE0E9                                          ; FBE0DA  68 0d
.LFBE0DC:
	ld (XIX),0x0a                                        ; FBE0DC  b4 00 0a
	cp	(PanelModeGroup:16), 0x16                            ; FBE0DF  c1 76 20 3f 16
	jr z, .LFBE0E9                                       ; FBE0E4  66 03
	ld (XIX),0x09                                        ; FBE0E6  b4 00 09
.LFBE0E9:
	ld (0x276a),(xix)                                    ; FBE0E9  84 19 6a 27   ld (0x276a),(XIX)
	pop XIX                                              ; FBE0ED  5c
	ret                                                  ; FBE0EE  0e
; CombiEditMixer_SetDialButtons: ScreenEnterBody_CombiEditMixer: PanelDial_UpButton = CombiEdit_Part & 7, PanelDial_DownButton = the same + 0x80.
;   Basis: body.
CombiEditMixer_SetDialButtons:
	pushw hl                                             ; FBE0EF  2b
	ld h, (CombiEdit_Part:16)                                   ; FBE0F0  c1 65 27 26
	and H,0x07                                           ; FBE0F4  ce cc 07
	ld C,H                                               ; FBE0F7  ce 8b
	add C,0x80                                           ; FBE0F9  cb c8 80
	ld (PanelDial_DownButton:16), c                                   ; FBE0FC  f1 9b 20 43
	ld (PanelDial_UpButton:16), h                                   ; FBE100  f1 9c 20 46
	popw hl                                              ; FBE104  4b
	ret                                                  ; FBE105  0e
; CombiEditMixer_ShowOtherParts: Outside panel-mode group 0x16, and once the mixer's posted paint callback has set
;   (0x277E) = 1: CombiEdit_Part := (CombiEdit_Part + 8) & 0x1F, copied to UI_PartIndex with
;   T_PartIndex_PostChangeEvent, and UI_Request_Hi bit 4 (repaint) -- the mixer shows the next group of 8 parts. The
;   un-paired arm of LcdKeyRow4_CombiEditMixer; the mixer draws its "OTHER PARTS" caption under the same group != 0x16
;   test. Basis: caller + body + caption. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
CombiEditMixer_ShowOtherParts:
	pushw hl                                             ; FBE106  2b
	push XIX                                             ; FBE107  3c
	cp	(PanelModeGroup:16), 0x16                            ; FBE108  c1 76 20 3f 16
	jr z, .LFBE131                                       ; FBE10D  66 22
	cp	(0x277e:16), 0x01                            ; FBE10F  c1 7e 27 3f 01
	jr nz, .LFBE131                                      ; FBE114  6e 1b
	lda xix, (CombiEdit_Part:16)                                ; FBE116  f1 65 27 34
	incm8 0x08, (xix)                                    ; FBE11A  84 60
	ld C,(XIX)                                           ; FBE11C  84 23
	ld H,C                                               ; FBE11E  cb 8e
	and H,0x1f                                           ; FBE120  ce cc 1f
	ld (XIX),H                                           ; FBE123  b4 46
	ld (UI_PartIndex:16), h                                   ; FBE125  f1 50 22 46
	call T_PartIndex_PostChangeEvent                                        ; FBE129  1d 9c 2c f4
	set	4, (UI_Request_Hi:16)                               ; FBE12D  f1 71 20 bc
.LFBE131:
	pop XIX                                              ; FBE131  5c
	popw hl                                              ; FBE132  4b
	ret                                                  ; FBE133  0e
	ret                                                  ; FBE134  0e
.LFBE135:
	push XIX                                             ; FBE135  3c
	lda xix, (T_DisplayList_Run_Stack:24)                ; FBE136  f2 00 2e f4 34
	ld	(0x2768:16), (CombiEdit_Page:16)             ; FBE13B  c1 67 27 19 68 27
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; FBE141  1d 10 2e f4
	call T_UiPaint_PageLabelBackdrop                                        ; FBE145  1d 18 2e f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE149  f1 40 25 00 00
	lda xbc, (CombiEditMixer_ShowOtherParts_DL1:24)                              ; FBE14E  f2 2e 7e f1 31
	push XBC                                             ; FBE153  39
	lda xwa, (DL_Mixer:24)                               ; FBE154  f2 8c 7c f1 30
	push XWA                                             ; FBE159  38
	lda xiy, (.LFBE162:24)                               ; FBE15A  f2 62 e1 fb 35
	push XIY                                             ; FBE15F  3d
	jp (xix)                                             ; FBE160  b4 d8
.LFBE162:
	ld bc, (CombiEdit_Page:16)                                 ; FBE162  d1 67 27 21
	extz BC                                              ; FBE166  d9 12
	inc 8,XSP                                            ; FBE168  ef 60
	cp bc, 0x00:i3                                         ; FBE16A  d9 d8
	jr z, .LFBE179                                       ; FBE16C  66 0b
	cp bc, 0x01:i3                                         ; FBE16E  d9 d9
	jr z, .LFBE1C0                                       ; FBE170  66 4e
	cp bc, 0x02:i3                                         ; FBE172  d9 da
	jr z, .LFBE1E6                                       ; FBE174  66 70
	jrl .LFBE23E                                         ; FBE176  78 c5 00
.LFBE179:
	cp	(PanelModeGroup:16), 0x16                            ; FBE179  c1 76 20 3f 16
	jr z, .LFBE199                                       ; FBE17E  66 19
	lda xbc, (CombiEditMixer_ShowOtherParts_DL2:24)                              ; FBE180  f2 9d 7e f1 31
	push XBC                                             ; FBE185  39
	lda xwa, (CombiEditMixer_ShowOtherParts_DL1:24)                              ; FBE186  f2 2e 7e f1 30
	push XWA                                             ; FBE18B  38
	lda xiy, (.LFBE194:24)                               ; FBE18C  f2 94 e1 fb 35
	push XIY                                             ; FBE191  3d
	jp (xix)                                             ; FBE192  b4 d8
.LFBE194:
	inc 8,XSP                                            ; FBE194  ef 60
	jrl .LFBE23E                                         ; FBE196  78 a5 00
.LFBE199:
	lda xbc, (DL_KeyShift:24)                            ; FBE199  f2 07 7f f1 31
	push XBC                                             ; FBE19E  39
	lda xwa, (DL_Sound:24)                               ; FBE19F  f2 42 7e f1 30
	push XWA                                             ; FBE1A4  38
	lda xiy, (.LFBE1AD:24)                               ; FBE1A5  f2 ad e1 fb 35
	push XIY                                             ; FBE1AA  3d
	jp (xix)                                             ; FBE1AB  b4 d8
.LFBE1AD:
	pushw 0x2e                                           ; FBE1AD  0b 2e 00
	calr CombiEditMixer_DrawPartBoxRow                                      ; FBE1B0  1e f1 00
	pushw 0x55                                           ; FBE1B3  0b 55 00
	calr CombiEditMixer_DrawPartIconRow                                      ; FBE1B6  1e b2 00
	inc 8,XSP                                            ; FBE1B9  ef 60
	inc 4,XSP                                            ; FBE1BB  ef 64
	jrl .LFBE23E                                         ; FBE1BD  78 7e 00
.LFBE1C0:
	lda xbc, (DL_Midiout:24)                             ; FBE1C0  f2 a4 7f f1 31
	push XBC                                             ; FBE1C5  39
	lda xwa, (DL_KeyShift:24)                            ; FBE1C6  f2 07 7f f1 30
	push XWA                                             ; FBE1CB  38
	lda xiy, (.LFBE1D4:24)                               ; FBE1CC  f2 d4 e1 fb 35
	push XIY                                             ; FBE1D1  3d
	jp (xix)                                             ; FBE1D2  b4 d8
.LFBE1D4:
	pushw 0x7c                                           ; FBE1D4  0b 7c 00
	calr CombiEditMixer_DrawPartIconRow                                      ; FBE1D7  1e 91 00
	pushw 0xa7                                           ; FBE1DA  0b a7 00
	calr CombiEditMixer_DrawPartIconRow                                      ; FBE1DD  1e 8b 00
	inc 8,XSP                                            ; FBE1E0  ef 60
	inc 4,XSP                                            ; FBE1E2  ef 64
	jr .LFBE237                                          ; FBE1E4  68 51
.LFBE1E6:
	cp	(PanelModeGroup:16), 0x16                            ; FBE1E6  c1 76 20 3f 16
	jr z, .LFBE20D                                       ; FBE1EB  66 20
	lda xbc, (DL_F18044:24)                              ; FBE1ED  f2 44 80 f1 31
	push XBC                                             ; FBE1F2  39
	lda xwa, (DL_Midiout:24)                             ; FBE1F3  f2 a4 7f f1 30
	push XWA                                             ; FBE1F8  38
	lda xiy, (.LFBE201:24)                               ; FBE1F9  f2 01 e2 fb 35
	push XIY                                             ; FBE1FE  3d
	jp (xix)                                             ; FBE1FF  b4 d8
.LFBE201:
	pushw 0x2d                                           ; FBE201  0b 2d 00
	calr CombiEditMixer_DrawPartIconRow                                      ; FBE204  1e 64 00
	inc 8,XSP                                            ; FBE207  ef 60
	inc 2,XSP                                            ; FBE209  ef 62
	jr .LFBE223                                          ; FBE20B  68 16
.LFBE20D:
	lda xbc, (CombiEditMixer_ShowOtherParts_DL3:24)                              ; FBE20D  f2 2a 80 f1 31
	push XBC                                             ; FBE212  39
	lda xwa, (DL_Midiout:24)                             ; FBE213  f2 a4 7f f1 30
	push XWA                                             ; FBE218  38
	lda xiy, (.LFBE221:24)                               ; FBE219  f2 21 e2 fb 35
	push XIY                                             ; FBE21E  3d
	jp (xix)                                             ; FBE21F  b4 d8
.LFBE221:
	inc 8,XSP                                            ; FBE221  ef 60
.LFBE223:
	pushw 0x55                                           ; FBE223  0b 55 00
	calr CombiEditMixer_DrawPartIconRow                                      ; FBE226  1e 42 00
	pushw 0x7c                                           ; FBE229  0b 7c 00
	calr CombiEditMixer_DrawPartIconRow                                      ; FBE22C  1e 3c 00
	pushw 0xa7                                           ; FBE22F  0b a7 00
	calr CombiEditMixer_DrawPartBoxRow                                      ; FBE232  1e 6f 00
	inc 6,XSP                                            ; FBE235  ef 66
.LFBE237:
	pushw 0xca                                           ; FBE237  0b ca 00
	calr CombiEditMixer_DrawPartBoxRow                                      ; FBE23A  1e 67 00
	popw bc                                              ; FBE23D  49
.LFBE23E:
	cp	(PanelModeGroup:16), 0x16                            ; FBE23E  c1 76 20 3f 16
	jr z, .LFBE253                                       ; FBE243  66 0e
	lda xbc, (DL_Solo_F17C2A:24)                         ; FBE245  f2 2a 7c f1 31
	push XBC                                             ; FBE24A  39
	lda xwa, (DL_OtherParts:24)                          ; FBE24B  f2 08 7c f1 30
	push XWA                                             ; FBE250  38
	jr .LFBE25F                                          ; FBE251  68 0c
.LFBE253:
	lda xbc, (DL_F17C45:24)                              ; FBE253  f2 45 7c f1 31
	push XBC                                             ; FBE258  39
	lda xwa, (DL_Solo_F17C2A:24)                         ; FBE259  f2 2a 7c f1 30
	push XWA                                             ; FBE25E  38
.LFBE25F:
	lda xiy, (.LFBE267:24)                               ; FBE25F  f2 67 e2 fb 35
	push XIY                                             ; FBE264  3d
	jp (xix)                                             ; FBE265  b4 d8
.LFBE267:
	inc 8,XSP                                            ; FBE267  ef 60
	pop XIX                                              ; FBE269  5c
	ret                                                  ; FBE26A  0e
; CombiEditMixer_DrawPartIconRow: (y): copies Record_F1AAA9 (an op-03 record blitting Bitmap_F17C59_24x17, BC = 3
;   bytes, HL = 17 rows) to its frame and blits it 8 times at byte offset 40*y + 1 + 5i -- one 24x17 frame per part
;   column (x = 8 + 40i). The MIXER page-frame painter at 0xFBE135 (posted by ScreenEnterBody_CombiEditMixer) draws
;   such rows at y 0x55 / 0x7C / 0xA7 / 0x2D by CombiEdit_Page. Basis: caller + body + record. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_a10.json)
CombiEditMixer_DrawPartIconRow:
	link XIZ,0xfff4                                      ; FBE26B  ee 0c f4 ff
	pushw hl                                             ; FBE26F  2b
	push XIX                                             ; FBE270  3c
	lda xix, (xiz-12)                                    ; FBE271  be f4 34
	push XIX                                             ; FBE274  3c
	ldw bc, 0x06                                         ; FBE275  31 06 00
	lda xiy, (Record_F1AAA9:24)                          ; FBE278  f2 a9 aa f1 35
	lda xix, (xiz-12)                                    ; FBE27D  be f4 34
	ldirw                                                ; FBE280  95 11
	pop XIX                                              ; FBE282  5c
	ldw bc, 0x28                                         ; FBE283  31 28 00
	mul	xbc, (xiz+8)                                 ; FBE286  9e 08 41
	inc 1,BC                                             ; FBE289  d9 61
	ld (XIX+0x06),BC                                     ; FBE28B  bc 06 51
	ld h, 0x08:opc                                          ; FBE28E  26 08
.LFBE290:
	push XIX                                             ; FBE290  3c
	call T_DisplayList_RunOne_Stack                      ; FBE291  1d 08 2e f4
	incw 0x05, (xix+0x06)                                ; FBE295  9c 06 65
	dec 1,H                                              ; FBE298  ce 69
	pop XIY                                              ; FBE29A  5d
	cp h, 0x00:i3                                          ; FBE29B  ce d8
	jr nz, .LFBE290                                      ; FBE29D  6e f1
	pop XIX                                              ; FBE29F  5c
	popw hl                                              ; FBE2A0  4b
	unlk XIZ                                             ; FBE2A1  ee 0d
	ret                                                  ; FBE2A3  0e
; CombiEditMixer_DrawPartBoxRow: (y): copies Record_F1AAB5 (an op-09 record, LCD_Svc_09_DrawBox) to its frame and
;   draws 8 boxes (4 + 40i, y)-(34 + 40i, y + 20), one per part column. The MIXER page-frame painter at 0xFBE135
;   (posted by ScreenEnterBody_CombiEditMixer) draws such rows at y 0x2E / 0xA7 / 0xCA by CombiEdit_Page. Basis:
;   caller + body + record. (notes/naming-pilot-2026-10-06/proposals_wave10_a10.json)
CombiEditMixer_DrawPartBoxRow:
	link XIZ,0xfff6                                      ; FBE2A4  ee 0c f6 ff
	pushw hl                                             ; FBE2A8  2b
	push XIX                                             ; FBE2A9  3c
	lda xix, (xiz-10)                                    ; FBE2AA  be f6 34
	push XIX                                             ; FBE2AD  3c
	ldw bc, 0x05                                         ; FBE2AE  31 05 00
	lda xiy, (Record_F1AAB5:24)                          ; FBE2B1  f2 b5 aa f1 35
	lda xix, (xiz-10)                                    ; FBE2B6  be f6 34
	ldirw                                                ; FBE2B9  95 11
	pop XIX                                              ; FBE2BB  5c
	ld BC,(XIZ+0x08)                                     ; FBE2BC  9e 08 21
	ld (XIX+0x04),BC                                     ; FBE2BF  bc 04 51
	ld BC,(XIZ+0x08)                                     ; FBE2C2  9e 08 21
	add BC,0x0014                                        ; FBE2C5  d9 c8 14 00
	ld (XIX+0x08),BC                                     ; FBE2C9  bc 08 51
	ld h, 0x08:opc                                          ; FBE2CC  26 08
.LFBE2CE:
	push XIX                                             ; FBE2CE  3c
	call T_DisplayList_RunOne_Stack                      ; FBE2CF  1d 08 2e f4
	addw	(xix+2), 0x0028                              ; FBE2D3  9c 02 38 28 00
	addw	(xix+6), 0x0028                              ; FBE2D8  9c 06 38 28 00
	dec 1,H                                              ; FBE2DD  ce 69
	pop XIY                                              ; FBE2DF  5d
	cp h, 0x00:i3                                          ; FBE2E0  ce d8
	jr nz, .LFBE2CE                                      ; FBE2E2  6e ea
	pop XIX                                              ; FBE2E4  5c
	popw hl                                              ; FBE2E5  4b
	unlk XIZ                                             ; FBE2E6  ee 0d
	ret                                                  ; FBE2E8  0e
.LFBE2E9:
	pushw hl                                             ; FBE2E9  2b
	pushw de                                             ; FBE2EA  2a
	push XIX                                             ; FBE2EB  3c
	lda xix, (T_DisplayListB_Run_Stack:24)               ; FBE2EC  f2 04 2e f4 34
	ld h, (CombiEdit_Part:16)                                   ; FBE2F1  c1 65 27 26
	ld l, (0x2766:16)                                   ; FBE2F5  c1 66 27 27
	ld (0x2766:16), h                                   ; FBE2F9  f1 66 27 46
	ld (UI_DrawScratch:16), h                                   ; FBE2FD  f1 40 26 46
	ld (UI_DrawScratch+1:16), l                                   ; FBE301  f1 41 26 47
	ld D,L                                               ; FBE305  cf 8c
	and D,0xf8                                           ; FBE307  cc cc f8
	ld C,H                                               ; FBE30A  ce 8b
	and C,0xf8                                           ; FBE30C  cb cc f8
	cp C,D                                               ; FBE30F  cc f3
	jr z, .LFBE352                                       ; FBE311  66 3f
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE313  f1 40 25 00 00
	lda xbc, (DL_Part1Part9Part17Part25Part2:24)         ; FBE318  f2 d6 81 f1 31
	push XBC                                             ; FBE31D  39
	lda xwa, (DL_Pt1Pt9Pt2Pt3Pt4Pt5Pt6Pt7:24)            ; FBE31E  f2 4e 81 f1 30
	push XWA                                             ; FBE323  38
	lda xiy, (.LFBE32C:24)                               ; FBE324  f2 2c e3 fb 35
	push XIY                                             ; FBE329  3d
	jp (xix)                                             ; FBE32A  b4 d8
.LFBE32C:
	inc 8,XSP                                            ; FBE32C  ef 60
	cp	(PanelModeGroup:16), 0x16                            ; FBE32E  c1 76 20 3f 16
	jr z, .LFBE352                                       ; FBE333  66 1d
	cp	(CombiEdit_Page:16), 0x00                            ; FBE335  c1 67 27 3f 00
	jr nz, .LFBE352                                      ; FBE33A  6e 16
	lda xbc, (CombiEditMixer_DrawPartBoxRow_DL1:24)                              ; FBE33C  f2 5e 82 f1 31
	push XBC                                             ; FBE341  39
	lda xwa, (DL_Part1Part9Part17Part25Part2:24)         ; FBE342  f2 d6 81 f1 30
	push XWA                                             ; FBE347  38
	lda xiy, (.LFBE350:24)                               ; FBE348  f2 50 e3 fb 35
	push XIY                                             ; FBE34D  3d
	jp (xix)                                             ; FBE34E  b4 d8
.LFBE350:
	inc 8,XSP                                            ; FBE350  ef 60
.LFBE352:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FBE352  f1 40 25 00 01
	lda xbc, (StringTable_F1828A:24)                     ; FBE357  f2 8a 82 f1 31
	push XBC                                             ; FBE35C  39
	lda xwa, (CombiEditMixer_DrawPartBoxRow_DL2:24)                              ; FBE35D  f2 74 82 f1 30
	push XWA                                             ; FBE362  38
	lda xiy, (.LFBE36B:24)                               ; FBE363  f2 6b e3 fb 35
	push XIY                                             ; FBE368  3d
	jp (xix)                                             ; FBE369  b4 d8
.LFBE36B:
	calr CombiEditMixer_DrawCurrentPartSound                                      ; FBE36B  1e 5c 02
	inc 8,XSP                                            ; FBE36E  ef 60
	pop XIX                                              ; FBE370  5c
	popw de                                              ; FBE371  4a
	popw hl                                              ; FBE372  4b
	ret                                                  ; FBE373  0e
.LFBE374:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FBE374  f1 40 25 00 01
	ld	(UI_DrawScratch+1:16), (0x276a:16)             ; FBE379  c1 6a 27 19 41 26
	lda xbc, (CombiEditMixer_DrawPartBoxRow_DL3:24)                              ; FBE37F  f2 69 82 f1 31
	push XBC                                             ; FBE384  39
	lda xwa, (CombiEditMixer_DrawPartBoxRow_DL1:24)                              ; FBE385  f2 5e 82 f1 30
	push XWA                                             ; FBE38A  38
	call T_DisplayListB_Run_Stack                        ; FBE38B  1d 04 2e f4
	ld	(UI_DrawScratch:16), (CombiEdit_Row:16)             ; FBE38F  c1 69 27 19 40 26
	lda xbc, (CombiEditMixer_DrawPartBoxRow_DL2:24)                              ; FBE395  f2 74 82 f1 31
	push XBC                                             ; FBE39A  39
	lda xwa, (CombiEditMixer_DrawPartBoxRow_DL3:24)                              ; FBE39B  f2 69 82 f1 30
	push XWA                                             ; FBE3A0  38
	call T_DisplayListB_Run_Stack                        ; FBE3A1  1d 04 2e f4
	ld	(0x276a:16), (CombiEdit_Row:16)             ; FBE3A5  c1 69 27 19 6a 27
	inc 8,XSP                                            ; FBE3AB  ef 60
	inc 8,XSP                                            ; FBE3AD  ef 60
	ret                                                  ; FBE3AF  0e
.LFBE3B0:
	ld (0x277e:16), 0x01                                 ; FBE3B0  f1 7e 27 00 01
	ld (LCD_CurrentLayer:16), 0x01                                 ; FBE3B5  f1 40 25 00 01
	cp	(0x276f:16), 0x00                            ; FBE3BA  c1 6f 27 3f 00
	jr nz, .LFBE3C9                                      ; FBE3BF  6e 08
	lda xbc, (DL_F17C45:24)                              ; FBE3C1  f2 45 7c f1 31
	push XBC                                             ; FBE3C6  39
	jr .LFBE3CF                                          ; FBE3C7  68 06
.LFBE3C9:
	lda xbc, (CombiEditMixer_DrawPartBoxRow_DL4:24)                              ; FBE3C9  f2 4f 7c f1 31
	push XBC                                             ; FBE3CE  39
.LFBE3CF:
	call T_DisplayList_RunOne_Stack                      ; FBE3CF  1d 08 2e f4
	ld c, 0x04:opc                                          ; FBE3D3  23 04
	mul	bc, (CombiEdit_Page:16)                              ; FBE3D5  c1 67 27 43
	extz XBC                                             ; FBE3D9  e9 12
	add XBC,PtrTable_F1B03F                              ; FBE3DB  e9 c8 3f b0 f1 00
	ld XBC,(XBC)                                         ; FBE3E1  a1 21
	lda xiy, (.LFBE3EB:24)                               ; FBE3E3  f2 eb e3 fb 35
	push XIY                                             ; FBE3E8  3d
	jp (xbc)                                             ; FBE3E9  b1 d8
.LFBE3EB:
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; FBE3EB  1d 14 2e f4
	pop XBC                                              ; FBE3EF  59
	ret                                                  ; FBE3F0  0e
; CombiEditMixer_PaintSoundPanVolumePage: PtrTable_F1B03F[0], MIXER page 0 ((0x2767) = 0): for the 8 parts of the edited group ((0x2765) & 0xF8 + 0..7)
;   CombiEditMixer_DrawSound, _DrawLocalControl (in panel-mode group 0x16 only), _DrawPanpot, _DrawVolume.
;   Basis: body (the cells it draws).
CombiEditMixer_PaintSoundPanVolumePage:
	pushw hl                                             ; FBE3F1  2b
	ld l, 0x00:opc                                          ; FBE3F2  27 00
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE3F4  f1 40 25 00 00
.LFBE3F9:
	ld h, (CombiEdit_Part:16)                                   ; FBE3F9  c1 65 27 26
	and H,0xf8                                           ; FBE3FD  ce cc f8
	ld C,L                                               ; FBE400  cf 8b
	add H,C                                              ; FBE402  cb 86
	push 0x00                                            ; FBE404  09 00
	push H                                               ; FBE406  ce 04
	calr CombiEditMixer_DrawSound                                      ; FBE408  1e e3 01
	popw bc                                              ; FBE40B  49
	cp	(PanelModeGroup:16), 0x16                            ; FBE40C  c1 76 20 3f 16
	jr nz, .LFBE41B                                      ; FBE411  6e 08
	push 0x00                                            ; FBE413  09 00
	push H                                               ; FBE415  ce 04
	calr CombiEditMixer_DrawLocalControl                                      ; FBE417  1e f5 02
	popw bc                                              ; FBE41A  49
.LFBE41B:
	push 0x00                                            ; FBE41B  09 00
	push H                                               ; FBE41D  ce 04
	calr CombiEditMixer_DrawPanpot                                      ; FBE41F  1e 66 03
	push 0x00                                            ; FBE422  09 00
	push H                                               ; FBE424  ce 04
	calr CombiEditMixer_DrawVolume                                      ; FBE426  1e f2 03
	inc 1,L                                              ; FBE429  cf 61
	pop XIY                                              ; FBE42B  5d
	cp L,0x08                                            ; FBE42C  cf cf 08
	jr c, .LFBE3F9                                       ; FBE42F  67 c8
	popw hl                                              ; FBE431  4b
	ret                                                  ; FBE432  0e
; CombiEditMixer_PaintSendsPage: PtrTable_F1B03F[1], MIXER page 1: for the 8 parts CombiEditMixer_DrawReverbSend, _DrawEffect1Send,
;   _DrawEffect2OnOff, _DrawMainOut, _DrawKeyShift.  Basis: body.
CombiEditMixer_PaintSendsPage:
	pushw hl                                             ; FBE433  2b
	ld h, 0x00:opc                                          ; FBE434  26 00
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE436  f1 40 25 00 00
.LFBE43B:
	ld c, (CombiEdit_Part:16)                                   ; FBE43B  c1 65 27 23
	and C,0xf8                                           ; FBE43F  cb cc f8
	ld L,C                                               ; FBE442  cb 8f
	add L,H                                              ; FBE444  ce 87
	pushw hl                                             ; FBE446  2b
	calr CombiEditMixer_DrawReverbSend                                      ; FBE447  1e 59 04
	pushw hl                                             ; FBE44A  2b
	calr CombiEditMixer_DrawEffect1Send                                      ; FBE44B  1e dd 04
	pushw hl                                             ; FBE44E  2b
	calr CombiEditMixer_DrawEffect2OnOff                                      ; FBE44F  1e 61 05
	pushw hl                                             ; FBE452  2b
	calr CombiEditMixer_DrawMainOut                                      ; FBE453  1e cc 05
	pushw hl                                             ; FBE456  2b
	calr CombiEditMixer_DrawKeyShift                                      ; FBE457  1e fd 07
	inc 1,H                                              ; FBE45A  ce 61
	inc 8,XSP                                            ; FBE45C  ef 60
	inc 2,XSP                                            ; FBE45E  ef 62
	cp H,0x08                                            ; FBE460  ce cf 08
	jr c, .LFBE43B                                       ; FBE463  67 d6
	popw hl                                              ; FBE465  4b
	ret                                                  ; FBE466  0e
; CombiEditMixer_PaintMidiPage: PtrTable_F1B03F[2], MIXER page 2: for the 8 parts CombiEditMixer_DrawLocalControl (outside panel-mode group
;   0x16), _DrawMidiOutSetting, _DrawMidiInSetting, _DrawBasicChannel, _DrawSubOut.  Basis: body.
CombiEditMixer_PaintMidiPage:
	pushw hl                                             ; FBE467  2b
	ld l, 0x00:opc                                          ; FBE468  27 00
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE46A  f1 40 25 00 00
.LFBE46F:
	ld h, (CombiEdit_Part:16)                                   ; FBE46F  c1 65 27 26
	and H,0xf8                                           ; FBE473  ce cc f8
	ld C,L                                               ; FBE476  cf 8b
	add H,C                                              ; FBE478  cb 86
	cp	(PanelModeGroup:16), 0x16                            ; FBE47A  c1 76 20 3f 16
	jr z, .LFBE489                                       ; FBE47F  66 08
	push 0x00                                            ; FBE481  09 00
	push H                                               ; FBE483  ce 04
	calr CombiEditMixer_DrawLocalControl                                      ; FBE485  1e 87 02
	popw bc                                              ; FBE488  49
.LFBE489:
	push 0x00                                            ; FBE489  09 00
	push H                                               ; FBE48B  ce 04
	calr CombiEditMixer_DrawMidiOutSetting                                      ; FBE48D  1e 06 06
	push 0x00                                            ; FBE490  09 00
	push H                                               ; FBE492  ce 04
	calr CombiEditMixer_DrawMidiInSetting                                      ; FBE494  1e 6c 06
	push 0x00                                            ; FBE497  09 00
	push H                                               ; FBE499  ce 04
	calr CombiEditMixer_DrawBasicChannel                                      ; FBE49B  1e d2 06
	push 0x00                                            ; FBE49E  09 00
	push H                                               ; FBE4A0  ce 04
	calr CombiEditMixer_DrawSubOut                                      ; FBE4A2  1e 3c 07
	inc 1,L                                              ; FBE4A5  cf 61
	inc 8,XSP                                            ; FBE4A7  ef 60
	cp L,0x08                                            ; FBE4A9  cf cf 08
	jr c, .LFBE46F                                       ; FBE4AC  67 c1
	popw hl                                              ; FBE4AE  4b
	ret                                                  ; FBE4AF  0e
; CombiEditMixer_DrawSwitchCell: (part, state, y): copies the 10-word display-list record Record_F1AABF, moves its x fields to the part's column
;   (part & 7) x 0x28, puts y + 1 / + 7 and y + 9 / + 0xF into the two halves in the order the state (1 or not)
;   selects, and runs it on layer 1 -- the two-position switch of an ON/OFF cell.  Callers: the LOCAL CONTROL,
;   EFFECT2, MAIN OUT, MIDI OUT and MIDI IN cells.  Basis: body + callers.
CombiEditMixer_DrawSwitchCell:
	link XIZ,0xffec                                      ; FBE4B0  ee 0c ec ff
	pushw hl                                             ; FBE4B4  2b
	pushw de                                             ; FBE4B5  2a
	push XIX                                             ; FBE4B6  3c
	lda xix, (xiz-20)                                    ; FBE4B7  be ec 34
	ld HL,(XIZ+0x0c)                                     ; FBE4BA  9e 0c 23
	push XIX                                             ; FBE4BD  3c
	ldw bc, 0x0a                                         ; FBE4BE  31 0a 00
	lda xiy, (Record_F1AABF:24)                          ; FBE4C1  f2 bf aa f1 35
	lda xix, (xiz-20)                                    ; FBE4C6  be ec 34
	ldirw                                                ; FBE4C9  95 11
	pop XIX                                              ; FBE4CB  5c
	ld A,(XIZ+0x08)                                      ; FBE4CC  8e 08 21
	and A,0x07                                           ; FBE4CF  c9 cc 07
	mul A,0x28                                           ; FBE4D2  c9 08 28
	ld DE,WA                                             ; FBE4D5  d8 8a
	add (XIX+0x02),WA                                    ; FBE4D7  9c 02 88
	add (XIX+0x06),DE                                    ; FBE4DA  9c 06 8a
	add (XIX+0x0c),DE                                    ; FBE4DD  9c 0c 8a
	add (XIX+0x10),DE                                    ; FBE4E0  9c 10 8a
	cp (XIZ+0x0a),0x01                                   ; FBE4E3  8e 0a 3f 01
	jr nz, .LFBE50B                                      ; FBE4E7  6e 22
	ld BC,HL                                             ; FBE4E9  db 89
	add BC,0x0009                                        ; FBE4EB  d9 c8 09 00
	ld (XIX+0x04),BC                                     ; FBE4EF  bc 04 51
	ld BC,HL                                             ; FBE4F2  db 89
	add BC,0x000f                                        ; FBE4F4  d9 c8 0f 00
	ld (XIX+0x08),BC                                     ; FBE4F8  bc 08 51
	ld BC,HL                                             ; FBE4FB  db 89
	inc 1,BC                                             ; FBE4FD  d9 61
	ld (XIX+0x0e),BC                                     ; FBE4FF  bc 0e 51
	ld BC,HL                                             ; FBE502  db 89
	inc 7,BC                                             ; FBE504  d9 67
	ld (XIX+0x12),BC                                     ; FBE506  bc 12 51
	jr CombiEditMixer_DrawSwitchCell_Join                                        ; FBE509  68 20
.LFBE50B:
	ld BC,HL                                             ; FBE50B  db 89
	inc 1,BC                                             ; FBE50D  d9 61
	ld (XIX+0x04),BC                                     ; FBE50F  bc 04 51
	ld BC,HL                                             ; FBE512  db 89
	inc 7,BC                                             ; FBE514  d9 67
	ld (XIX+0x08),BC                                     ; FBE516  bc 08 51
	ld BC,HL                                             ; FBE519  db 89
	add BC,0x0009                                        ; FBE51B  d9 c8 09 00
	ld (XIX+0x0e),BC                                     ; FBE51F  bc 0e 51
	ld BC,HL                                             ; FBE522  db 89
	add BC,0x000f                                        ; FBE524  d9 c8 0f 00
	ld (XIX+0x12),BC                                     ; FBE528  bc 12 51
CombiEditMixer_DrawSwitchCell_Join:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FBE52B  f1 40 25 00 01
	ld XBC,XIX                                           ; FBE530  ec 89
	add XBC,0x00000014                                   ; FBE532  e9 c8 14 00 00 00
	push XBC                                             ; FBE538  39
	push XIX                                             ; FBE539  3c
	call T_DisplayList_Run_Stack                         ; FBE53A  1d 00 2e f4
	inc 8,XSP                                            ; FBE53E  ef 60
	pop XIX                                              ; FBE540  5c
	popw de                                              ; FBE541  4a
	popw hl                                              ; FBE542  4b
	unlk XIZ                                             ; FBE543  ee 0d
	ret                                                  ; FBE545  0e
; CombiEditMixer_DrawValueCell: (part, value, y): the 6-word record Record_F1AAD3 with the value in UI_DrawScratch, x moved to the part's column
;   and y set, run on layer 0 (T_DisplayListB_RunOne_Stack).  Callers: the VOLUME, REVERB SEND and EFFECT1 SEND
;   cells.  Basis: body + callers.
CombiEditMixer_DrawValueCell:
	link XIZ,0xfff4                                      ; FBE546  ee 0c f4 ff
	push XIX                                             ; FBE54A  3c
	lda xix, (xiz-12)                                    ; FBE54B  be f4 34
	push XIX                                             ; FBE54E  3c
	ldw bc, 0x06                                         ; FBE54F  31 06 00
	lda xiy, (Record_F1AAD3:24)                          ; FBE552  f2 d3 aa f1 35
	lda xix, (xiz-12)                                    ; FBE557  be f4 34
	ldirw                                                ; FBE55A  95 11
	pop XIX                                              ; FBE55C  5c
	ld A,(XIZ+0x0a)                                      ; FBE55D  8e 0a 21
	ld (UI_DrawScratch:16), a                                   ; FBE560  f1 40 26 41
	ld C,(XIZ+0x08)                                      ; FBE564  8e 08 23
	and C,0x07                                           ; FBE567  cb cc 07
	mul C,0x28                                           ; FBE56A  cb 08 28
	add (XIX+0x07),BC                                    ; FBE56D  9c 07 89
	ld BC,(XIZ+0x0c)                                     ; FBE570  9e 0c 21
	ld (XIX+0x09),BC                                     ; FBE573  bc 09 51
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE576  f1 40 25 00 00
	push XIX                                             ; FBE57B  3c
	call T_DisplayListB_RunOne_Stack                     ; FBE57C  1d 0c 2e f4
	pop XBC                                              ; FBE580  59
	pop XIX                                              ; FBE581  5c
	unlk XIZ                                             ; FBE582  ee 0d
	ret                                                  ; FBE584  0e
; CombiEditMixer_DrawKeyShiftValue: (part, value, y, b): CombiEditMixer_DrawValueCell's shape with the 13-byte record Record_F1AADF and one more
;   byte at +0x0C; its one caller is CombiEditMixer_DrawKeyShift.  Basis: body + caller.
CombiEditMixer_DrawKeyShiftValue:
	link XIZ,0xfff3                                      ; FBE585  ee 0c f3 ff
	push XIX                                             ; FBE589  3c
	lda xix, (xiz-13)                                    ; FBE58A  be f3 34
	push XIX                                             ; FBE58D  3c
	ldw bc, 0x0d                                         ; FBE58E  31 0d 00
	lda xiy, (Record_F1AADF:24)                          ; FBE591  f2 df aa f1 35
	lda xix, (xiz-13)                                    ; FBE596  be f3 34
	ldir85                                               ; FBE599  85 11
	pop XIX                                              ; FBE59B  5c
	ld A,(XIZ+0x0a)                                      ; FBE59C  8e 0a 21
	ld (UI_DrawScratch:16), a                                   ; FBE59F  f1 40 26 41
	ld C,(XIZ+0x08)                                      ; FBE5A3  8e 08 23
	and C,0x07                                           ; FBE5A6  cb cc 07
	mul C,0x28                                           ; FBE5A9  cb 08 28
	add (XIX+0x07),BC                                    ; FBE5AC  9c 07 89
	ld BC,(XIZ+0x0c)                                     ; FBE5AF  9e 0c 21
	ld (XIX+0x09),BC                                     ; FBE5B2  bc 09 51
	ld C,(XIZ+0x0e)                                      ; FBE5B5  8e 0e 23
	ld (XIX+0x0c),C                                      ; FBE5B8  bc 0c 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE5BB  f1 40 25 00 00
	push XIX                                             ; FBE5C0  3c
	call T_DisplayListB_RunOne_Stack                     ; FBE5C1  1d 0c 2e f4
	pop XBC                                              ; FBE5C5  59
	pop XIX                                              ; FBE5C6  5c
	unlk XIZ                                             ; FBE5C7  ee 0d
	ret                                                  ; FBE5C9  0e
; CombiEditMixer_DrawCurrentPartSound: Layer 0: T_PartSound_CopyNameToDrawScratch(CombiEdit_Part), then interpreter B
;   on DL_F18044 -- "PART n" from StringTable_F1828A by CombiEdit_Part (0x2765 & 0x1F) and the sound name from
;   UI_DrawScratch (0x2640). The mixer's line for the current part: drawn after the part list is painted, and by
;   CombiEditMixer_RepaintMarkedSound when the marked part is CombiEdit_Part. Basis: callers + body + the display
;   list. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
CombiEditMixer_DrawCurrentPartSound:
	push 0x00                                            ; FBE5CA  09 00
	push	(CombiEdit_Part:16)                                  ; FBE5CC  c1 65 27 04
	call T_PartSound_CopyNameToDrawScratch                                        ; FBE5D0  1d a0 2c f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE5D4  f1 40 25 00 00
	lda xbc, (RecordArray_F18066:24)                     ; FBE5D9  f2 66 80 f1 31
	push XBC                                             ; FBE5DE  39
	lda xwa, (DL_F18044:24)                              ; FBE5DF  f2 44 80 f1 30
	push XWA                                             ; FBE5E4  38
	call T_DisplayListB_Run_Stack                        ; FBE5E5  1d 04 2e f4
	inc 8,XSP                                            ; FBE5E9  ef 60
	inc 2,XSP                                            ; FBE5EB  ef 62
	ret                                                  ; FBE5ED  0e
; CombiEditMixer_DrawSound: (part) the MIXER cell of one part -- the part's sound: in panel-mode group 0x16 the second record's +0x1D bank, +0x1B group, +0x1C member (number = group x 8 + member + 1), otherwise T_PartSound_CopyNameToDrawScratch's text.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawSound:
	link XIZ,0xfff4                                      ; FBE5EE  ee 0c f4 ff
	pushw hl                                             ; FBE5F2  2b
	pushw de                                             ; FBE5F3  2a
	push XIX                                             ; FBE5F4  3c
	lda xix, (T_IndexedTable_GetByte:24)                 ; FBE5F5  f2 90 2c f4 34
	ld H,(XIZ+0x08)                                      ; FBE5FA  8e 08 26
	cp	(PanelModeGroup:16), 0x16                            ; FBE5FD  c1 76 20 3f 16
	jr z, .LFBE628                                       ; FBE602  66 24
	push 0x00                                            ; FBE604  09 00
	push H                                               ; FBE606  ce 04
	call T_PartSound_CopyNameToDrawScratch                                        ; FBE608  1d a0 2c f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE60C  f1 40 25 00 00
	ld C,H                                               ; FBE611  ce 8b
	and C,0x07                                           ; FBE613  cb cc 07
	mul C,0x04                                           ; FBE616  cb 08 04
	extz XBC                                             ; FBE619  e9 12
	add XBC,PtrTable_F1B04B                              ; FBE61B  e9 c8 4b b0 f1 00
	ld XBC,(XBC)                                         ; FBE621  a1 21
	popw wa                                              ; FBE623  48
	push XBC                                             ; FBE624  39
	jrl .LFBE6B9                                         ; FBE625  78 91 00
.LFBE628:
	lda xbc, (UI_DrawScratch:16)                                ; FBE628  f1 40 26 31
	ld (xiz-4), xbc                                      ; FBE62C  be fc 61
	pushw 0x1d                                           ; FBE62F  0b 1d 00
	ld A,H                                               ; FBE632  ce 89
	extz WA                                              ; FBE634  d8 12
	add WA,0x0020                                        ; FBE636  d8 c8 20 00
	ld L,A                                               ; FBE63A  c9 8f
	pushw wa                                             ; FBE63C  28
	lda xiy, (.LFBE645:24)                               ; FBE63D  f2 45 e6 fb 35
	push XIY                                             ; FBE642  3d
	jp (xix)                                             ; FBE643  b4 d8
.LFBE645:
	ld xbc, (xiz-4)                                      ; FBE645  ae fc 21
	ld (XBC),A                                           ; FBE648  b1 41
	ld xbc, (xiz-4)                                      ; FBE64A  ae fc 21
	inc 1,XBC                                            ; FBE64D  e9 61
	ld (xiz-8), xbc                                      ; FBE64F  be f8 61
	pushw 0x1b                                           ; FBE652  0b 1b 00
	pushw hl                                             ; FBE655  2b
	lda xiy, (.LFBE65E:24)                               ; FBE656  f2 5e e6 fb 35
	push XIY                                             ; FBE65B  3d
	jp (xix)                                             ; FBE65C  b4 d8
.LFBE65E:
	ld D,A                                               ; FBE65E  c9 8c
	ld xbc, (xiz-8)                                      ; FBE660  ae f8 21
	ld (XBC),A                                           ; FBE663  b1 41
	ld C,D                                               ; FBE665  cc 8b
	sll c, 0x03                                          ; FBE667  cb ee 03
	ld D,C                                               ; FBE66A  cb 8c
	ld xbc, (xiz-8)                                      ; FBE66C  ae f8 21
	ld (XBC),D                                           ; FBE66F  b1 44
	pushw 0x1c                                           ; FBE671  0b 1c 00
	pushw hl                                             ; FBE674  2b
	lda xiy, (.LFBE67D:24)                               ; FBE675  f2 7d e6 fb 35
	push XIY                                             ; FBE67A  3d
	jp (xix)                                             ; FBE67B  b4 d8
.LFBE67D:
	ld xbc, (xiz-8)                                      ; FBE67D  ae f8 21
	add (XBC),A                                          ; FBE680  81 89
	ld xbc, (xiz-8)                                      ; FBE682  ae f8 21
	ld A,(XBC)                                           ; FBE685  81 21
	inc 1,A                                              ; FBE687  c9 61
	ld (XBC),A                                           ; FBE689  b1 41
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE68B  f1 40 25 00 00
	ld C,H                                               ; FBE690  ce 8b
	and C,0x07                                           ; FBE692  cb cc 07
	mul C,0x04                                           ; FBE695  cb 08 04
	extz XBC                                             ; FBE698  e9 12
	ld (xiz-12), xbc                                     ; FBE69A  be f4 61
	add XBC,PtrTable_F1B06B                              ; FBE69D  e9 c8 6b b0 f1 00
	ld XBC,(XBC)                                         ; FBE6A3  a1 21
	push XBC                                             ; FBE6A5  39
	call T_DisplayListB_RunOne_Stack                     ; FBE6A6  1d 0c 2e f4
	lda xbc, (PtrTable_F1B08B:24)                        ; FBE6AA  f2 8b b0 f1 31
	add	xbc, (xiz-12)                                ; FBE6AF  ae f4 81
	ld XWA,(XBC)                                         ; FBE6B2  a1 20
	inc 8,XSP                                            ; FBE6B4  ef 60
	inc 8,XSP                                            ; FBE6B6  ef 60
	push XWA                                             ; FBE6B8  38
.LFBE6B9:
	call T_DisplayListB_RunOne_Stack                     ; FBE6B9  1d 0c 2e f4
	pop XBC                                              ; FBE6BD  59
	pop XIX                                              ; FBE6BE  5c
	popw de                                              ; FBE6BF  4a
	popw hl                                              ; FBE6C0  4b
	unlk XIZ                                             ; FBE6C1  ee 0d
	ret                                                  ; FBE6C3  0e
; CombiEditMixer_RepaintMarkedSound: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEdit_DirtySound (0x2770) under ei 6, then CombiEditMixer_DrawSound for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedSound:
	pushw hl                                             ; FBE6C4  2b
	pushw de                                             ; FBE6C5  2a
	ei 0x06                                              ; FBE6C6  06 06
	ld e, (CombiEdit_DirtySound:16)                                   ; FBE6C8  c1 70 27 25
	ld (CombiEdit_DirtySound:16), 0x00                                 ; FBE6CC  f1 70 27 00 00
	ei 0x00                                              ; FBE6D1  06 00
	ld d, 0x01:opc                                          ; FBE6D3  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBE6D5  c1 65 27 27
	and L,0xf8                                           ; FBE6D9  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE6DC  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBE6E1  26 08
.LFBE6E3:
	ld C,D                                               ; FBE6E3  cc 8b
	and C,E                                              ; FBE6E5  cd c3
	jr z, .LFBE6FE                                       ; FBE6E7  66 15
	cp	(CombiEdit_Page:16), 0x00                            ; FBE6E9  c1 67 27 3f 00
	jr nz, .LFBE6F5                                      ; FBE6EE  6e 05
	pushw hl                                             ; FBE6F0  2b
	calr CombiEditMixer_DrawSound                                      ; FBE6F1  1e fa fe
	popw bc                                              ; FBE6F4  49
.LFBE6F5:
	cp	l, (CombiEdit_Part:16)                               ; FBE6F5  c1 65 27 f7
	jr nz, .LFBE6FE                                      ; FBE6F9  6e 03
	calr CombiEditMixer_DrawCurrentPartSound                                      ; FBE6FB  1e cc fe
.LFBE6FE:
	inc 1,L                                              ; FBE6FE  cf 61
	ld C,D                                               ; FBE700  cc 8b
	add C,D                                              ; FBE702  cc 83
	ld D,C                                               ; FBE704  cb 8c
	dec 1,H                                              ; FBE706  ce 69
	cp h, 0x00:i3                                          ; FBE708  ce d8
	jr nz, .LFBE6E3                                      ; FBE70A  6e d7
	popw de                                              ; FBE70C  4a
	popw hl                                              ; FBE70D  4b
	ret                                                  ; FBE70E  0e
; CombiEditMixer_DrawLocalControl: (part) the MIXER cell of one part -- reads the first record byte 13 & 0x20: LOCAL CONTROL.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawLocalControl:
	link XIZ,0x0000                                      ; FBE70F  ee 0c 00 00
	pushw hl                                             ; FBE713  2b
	pushw 0x0d                                           ; FBE714  0b 0d 00
	push 0x00                                            ; FBE717  09 00
	push	(xiz+8)                                      ; FBE719  8e 08 04
	call T_IndexedTable_GetByte                          ; FBE71C  1d 90 2c f4
	and A,0x20                                           ; FBE720  c9 cc 20
	pop XIY                                              ; FBE723  5d
	jr z, .LFBE72A                                       ; FBE724  66 04
	ld h, 0x00:opc                                          ; FBE726  26 00
	jr .LFBE72C                                          ; FBE728  68 02
.LFBE72A:
	ld h, 0x01:opc                                          ; FBE72A  26 01
.LFBE72C:
	cp	(CombiEdit_Page:16), 0x00                            ; FBE72C  c1 67 27 3f 00
	jr nz, .LFBE738                                      ; FBE731  6e 05
	pushw 0x55                                           ; FBE733  0b 55 00
	jr .LFBE73B                                          ; FBE736  68 03
.LFBE738:
	pushw 0x2d                                           ; FBE738  0b 2d 00
.LFBE73B:
	push 0x00                                            ; FBE73B  09 00
	push H                                               ; FBE73D  ce 04
	push 0x00                                            ; FBE73F  09 00
	push	(xiz+8)                                      ; FBE741  8e 08 04
	calr CombiEditMixer_DrawSwitchCell                                      ; FBE744  1e 69 fd
	inc 6,XSP                                            ; FBE747  ef 66
	popw hl                                              ; FBE749  4b
	unlk XIZ                                             ; FBE74A  ee 0d
	ret                                                  ; FBE74C  0e
; CombiEditMixer_RepaintMarkedLocalControl: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyLocalControl (0x2771) under ei 6, then CombiEditMixer_DrawLocalControl for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedLocalControl:
	pushw hl                                             ; FBE74D  2b
	pushw de                                             ; FBE74E  2a
	ei 0x06                                              ; FBE74F  06 06
	ld e, (CombiEditMixer_DirtyLocalControl:16)                                   ; FBE751  c1 71 27 25
	ld (CombiEditMixer_DirtyLocalControl:16), 0x00                                 ; FBE755  f1 71 27 00 00
	ei 0x00                                              ; FBE75A  06 00
	ld d, 0x01:opc                                          ; FBE75C  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBE75E  c1 65 27 27
	and L,0xf8                                           ; FBE762  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE765  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBE76A  26 08
.LFBE76C:
	ld C,D                                               ; FBE76C  cc 8b
	and C,E                                              ; FBE76E  cd c3
	jr z, .LFBE777                                       ; FBE770  66 05
	pushw hl                                             ; FBE772  2b
	calr CombiEditMixer_DrawLocalControl                                      ; FBE773  1e 99 ff
	popw bc                                              ; FBE776  49
.LFBE777:
	inc 1,L                                              ; FBE777  cf 61
	ld C,D                                               ; FBE779  cc 8b
	add C,D                                              ; FBE77B  cc 83
	ld D,C                                               ; FBE77D  cb 8c
	dec 1,H                                              ; FBE77F  ce 69
	cp h, 0x00:i3                                          ; FBE781  ce d8
	jr nz, .LFBE76C                                      ; FBE783  6e e7
	popw de                                              ; FBE785  4a
	popw hl                                              ; FBE786  4b
	ret                                                  ; FBE787  0e
; CombiEditMixer_DrawPanpot: (part) the MIXER cell of one part -- reads the first record byte 8: PANPOT.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawPanpot:
	link XIZ,0x0000                                      ; FBE788  ee 0c 00 00
	pushw hl                                             ; FBE78C  2b
	pushw 0x08                                           ; FBE78D  0b 08 00
	push 0x00                                            ; FBE790  09 00
	push	(xiz+8)                                      ; FBE792  8e 08 04
	call T_IndexedTable_GetByte                          ; FBE795  1d 90 2c f4
	ld (UI_DrawScratch:16), a                                   ; FBE799  f1 40 26 41
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE79D  f1 40 25 00 00
	ld H,(XIZ+0x08)                                      ; FBE7A2  8e 08 26
	and H,0x07                                           ; FBE7A5  ce cc 07
	ld c, 0x04:opc                                          ; FBE7A8  23 04
	mul bc, h                                          ; FBE7AA  ce 43
	extz XBC                                             ; FBE7AC  e9 12
	add XBC,PtrTable_F1B0AB                              ; FBE7AE  e9 c8 ab b0 f1 00
	ld XBC,(XBC)                                         ; FBE7B4  a1 21
	push XBC                                             ; FBE7B6  39
	call T_DisplayListB_RunOne_Stack                     ; FBE7B7  1d 0c 2e f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBE7BB  f1 40 25 00 02
	ld c, (UI_DrawScratch:16)                                   ; FBE7C0  c1 40 26 23
	pushw bc                                             ; FBE7C4  29
	ld c, 0x02:opc                                          ; FBE7C5  23 02
	mul bc, h                                          ; FBE7C7  ce 43
	extz XBC                                             ; FBE7C9  e9 12
	add XBC,IndexMap_F1B0CB                              ; FBE7CB  e9 c8 cb b0 f1 00
	ld BC,(XBC)                                          ; FBE7D1  91 21
	pushw bc                                             ; FBE7D3  29
	call DrawValueGlyph_Veneer                           ; FBE7D4  1d 17 f0 f4
	inc 8,XSP                                            ; FBE7D8  ef 60
	inc 4,XSP                                            ; FBE7DA  ef 64
	popw hl                                              ; FBE7DC  4b
	unlk XIZ                                             ; FBE7DD  ee 0d
	ret                                                  ; FBE7DF  0e
; CombiEditMixer_RepaintMarkedPanpot: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyPanpot (0x2772) under ei 6, then CombiEditMixer_DrawPanpot for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedPanpot:
	pushw hl                                             ; FBE7E0  2b
	pushw de                                             ; FBE7E1  2a
	ei 0x06                                              ; FBE7E2  06 06
	ld e, (CombiEditMixer_DirtyPanpot:16)                                   ; FBE7E4  c1 72 27 25
	ld (CombiEditMixer_DirtyPanpot:16), 0x00                                 ; FBE7E8  f1 72 27 00 00
	ei 0x00                                              ; FBE7ED  06 00
	ld d, 0x01:opc                                          ; FBE7EF  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBE7F1  c1 65 27 27
	and L,0xf8                                           ; FBE7F5  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE7F8  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBE7FD  26 08
.LFBE7FF:
	ld C,D                                               ; FBE7FF  cc 8b
	and C,E                                              ; FBE801  cd c3
	jr z, .LFBE80A                                       ; FBE803  66 05
	pushw hl                                             ; FBE805  2b
	calr CombiEditMixer_DrawPanpot                                      ; FBE806  1e 7f ff
	popw bc                                              ; FBE809  49
.LFBE80A:
	inc 1,L                                              ; FBE80A  cf 61
	ld C,D                                               ; FBE80C  cc 8b
	add C,D                                              ; FBE80E  cc 83
	ld D,C                                               ; FBE810  cb 8c
	dec 1,H                                              ; FBE812  ce 69
	cp h, 0x00:i3                                          ; FBE814  ce d8
	jr nz, .LFBE7FF                                      ; FBE816  6e e7
	popw de                                              ; FBE818  4a
	popw hl                                              ; FBE819  4b
	ret                                                  ; FBE81A  0e
; CombiEditMixer_DrawVolume: (part) the MIXER cell of one part -- reads the first record byte 3: VOLUME.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawVolume:
	link XIZ,0x0000                                      ; FBE81B  ee 0c 00 00
	pushw hl                                             ; FBE81F  2b
	ld H,(XIZ+0x08)                                      ; FBE820  8e 08 26
	pushw 0x03                                           ; FBE823  0b 03 00
	push 0x00                                            ; FBE826  09 00
	push H                                               ; FBE828  ce 04
	call T_IndexedTable_GetByte                          ; FBE82A  1d 90 2c f4
	ld L,A                                               ; FBE82E  c9 8f
	ld (UI_DrawScratch:16), a                                   ; FBE830  f1 40 26 41
	pushw 0xa7                                           ; FBE834  0b a7 00
	pushw hl                                             ; FBE837  2b
	push 0x00                                            ; FBE838  09 00
	push H                                               ; FBE83A  ce 04
	calr CombiEditMixer_DrawValueCell                                      ; FBE83C  1e 07 fd
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBE83F  f1 40 25 00 02
	ld c, (UI_DrawScratch:16)                                   ; FBE844  c1 40 26 23
	pushw bc                                             ; FBE848  29
	ld C,H                                               ; FBE849  ce 8b
	and C,0x07                                           ; FBE84B  cb cc 07
	mul C,0x02                                           ; FBE84E  cb 08 02
	extz XBC                                             ; FBE851  e9 12
	add XBC,IndexMap_F1B0DB                              ; FBE853  e9 c8 db b0 f1 00
	ld BC,(XBC)                                          ; FBE859  91 21
	pushw bc                                             ; FBE85B  29
	call LCD_BlitValueBar_StackArgs                                      ; FBE85C  1d 00 f0 f4
	inc 8,XSP                                            ; FBE860  ef 60
	inc 6,XSP                                            ; FBE862  ef 66
	popw hl                                              ; FBE864  4b
	unlk XIZ                                             ; FBE865  ee 0d
	ret                                                  ; FBE867  0e
; CombiEditMixer_RepaintMarkedVolume: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyVolume (0x2773) under ei 6, then CombiEditMixer_DrawVolume for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedVolume:
	pushw hl                                             ; FBE868  2b
	pushw de                                             ; FBE869  2a
	ei 0x06                                              ; FBE86A  06 06
	ld e, (CombiEditMixer_DirtyVolume:16)                                   ; FBE86C  c1 73 27 25
	ld (CombiEditMixer_DirtyVolume:16), 0x00                                 ; FBE870  f1 73 27 00 00
	ei 0x00                                              ; FBE875  06 00
	ld d, 0x01:opc                                          ; FBE877  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBE879  c1 65 27 27
	and L,0xf8                                           ; FBE87D  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE880  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBE885  26 08
.LFBE887:
	ld C,D                                               ; FBE887  cc 8b
	and C,E                                              ; FBE889  cd c3
	jr z, .LFBE892                                       ; FBE88B  66 05
	pushw hl                                             ; FBE88D  2b
	calr CombiEditMixer_DrawVolume                                      ; FBE88E  1e 8a ff
	popw bc                                              ; FBE891  49
.LFBE892:
	inc 1,L                                              ; FBE892  cf 61
	ld C,D                                               ; FBE894  cc 8b
	add C,D                                              ; FBE896  cc 83
	ld D,C                                               ; FBE898  cb 8c
	dec 1,H                                              ; FBE89A  ce 69
	cp h, 0x00:i3                                          ; FBE89C  ce d8
	jr nz, .LFBE887                                      ; FBE89E  6e e7
	popw de                                              ; FBE8A0  4a
	popw hl                                              ; FBE8A1  4b
	ret                                                  ; FBE8A2  0e
; CombiEditMixer_DrawReverbSend: (part) the MIXER cell of one part -- reads the first record byte 7: REVERB SEND.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawReverbSend:
	link XIZ,0x0000                                      ; FBE8A3  ee 0c 00 00
	pushw hl                                             ; FBE8A7  2b
	ld H,(XIZ+0x08)                                      ; FBE8A8  8e 08 26
	pushw 0x07                                           ; FBE8AB  0b 07 00
	push 0x00                                            ; FBE8AE  09 00
	push H                                               ; FBE8B0  ce 04
	call T_IndexedTable_GetByte                          ; FBE8B2  1d 90 2c f4
	ld L,A                                               ; FBE8B6  c9 8f
	ld (UI_DrawScratch:16), a                                   ; FBE8B8  f1 40 26 41
	pushw 0x2a                                           ; FBE8BC  0b 2a 00
	pushw hl                                             ; FBE8BF  2b
	push 0x00                                            ; FBE8C0  09 00
	push H                                               ; FBE8C2  ce 04
	calr CombiEditMixer_DrawValueCell                                      ; FBE8C4  1e 7f fc
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBE8C7  f1 40 25 00 02
	ld c, (UI_DrawScratch:16)                                   ; FBE8CC  c1 40 26 23
	pushw bc                                             ; FBE8D0  29
	ld C,H                                               ; FBE8D1  ce 8b
	and C,0x07                                           ; FBE8D3  cb cc 07
	mul C,0x02                                           ; FBE8D6  cb 08 02
	extz XBC                                             ; FBE8D9  e9 12
	add XBC,IndexMap_F1B0EB                              ; FBE8DB  e9 c8 eb b0 f1 00
	ld BC,(XBC)                                          ; FBE8E1  91 21
	pushw bc                                             ; FBE8E3  29
	call DrawValueGlyph_Veneer                           ; FBE8E4  1d 17 f0 f4
	inc 8,XSP                                            ; FBE8E8  ef 60
	inc 6,XSP                                            ; FBE8EA  ef 66
	popw hl                                              ; FBE8EC  4b
	unlk XIZ                                             ; FBE8ED  ee 0d
	ret                                                  ; FBE8EF  0e
; CombiEditMixer_RepaintMarkedReverbSend: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyReverbSend (0x2774) under ei 6, then CombiEditMixer_DrawReverbSend for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedReverbSend:
	pushw hl                                             ; FBE8F0  2b
	pushw de                                             ; FBE8F1  2a
	ei 0x06                                              ; FBE8F2  06 06
	ld e, (CombiEditMixer_DirtyReverbSend:16)                                   ; FBE8F4  c1 74 27 25
	ld (CombiEditMixer_DirtyReverbSend:16), 0x00                                 ; FBE8F8  f1 74 27 00 00
	ei 0x00                                              ; FBE8FD  06 00
	ld d, 0x01:opc                                          ; FBE8FF  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBE901  c1 65 27 27
	and L,0xf8                                           ; FBE905  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE908  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBE90D  26 08
.LFBE90F:
	ld C,D                                               ; FBE90F  cc 8b
	and C,E                                              ; FBE911  cd c3
	jr z, .LFBE91A                                       ; FBE913  66 05
	pushw hl                                             ; FBE915  2b
	calr CombiEditMixer_DrawReverbSend                                      ; FBE916  1e 8a ff
	popw bc                                              ; FBE919  49
.LFBE91A:
	inc 1,L                                              ; FBE91A  cf 61
	ld C,D                                               ; FBE91C  cc 8b
	add C,D                                              ; FBE91E  cc 83
	ld D,C                                               ; FBE920  cb 8c
	dec 1,H                                              ; FBE922  ce 69
	cp h, 0x00:i3                                          ; FBE924  ce d8
	jr nz, .LFBE90F                                      ; FBE926  6e e7
	popw de                                              ; FBE928  4a
	popw hl                                              ; FBE929  4b
	ret                                                  ; FBE92A  0e
; CombiEditMixer_DrawEffect1Send: (part) the MIXER cell of one part -- reads the first record byte 5: EFFECT1 SEND.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawEffect1Send:
	link XIZ,0x0000                                      ; FBE92B  ee 0c 00 00
	pushw hl                                             ; FBE92F  2b
	ld H,(XIZ+0x08)                                      ; FBE930  8e 08 26
	pushw 0x05                                           ; FBE933  0b 05 00
	push 0x00                                            ; FBE936  09 00
	push H                                               ; FBE938  ce 04
	call T_IndexedTable_GetByte                          ; FBE93A  1d 90 2c f4
	ld L,A                                               ; FBE93E  c9 8f
	ld (UI_DrawScratch:16), a                                   ; FBE940  f1 40 26 41
	pushw 0x53                                           ; FBE944  0b 53 00
	pushw hl                                             ; FBE947  2b
	push 0x00                                            ; FBE948  09 00
	push H                                               ; FBE94A  ce 04
	calr CombiEditMixer_DrawValueCell                                      ; FBE94C  1e f7 fb
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBE94F  f1 40 25 00 02
	ld c, (UI_DrawScratch:16)                                   ; FBE954  c1 40 26 23
	pushw bc                                             ; FBE958  29
	ld C,H                                               ; FBE959  ce 8b
	and C,0x07                                           ; FBE95B  cb cc 07
	mul C,0x02                                           ; FBE95E  cb 08 02
	extz XBC                                             ; FBE961  e9 12
	add XBC,IndexMap_F1B0FB                              ; FBE963  e9 c8 fb b0 f1 00
	ld BC,(XBC)                                          ; FBE969  91 21
	pushw bc                                             ; FBE96B  29
	call DrawValueGlyph_Veneer                           ; FBE96C  1d 17 f0 f4
	inc 8,XSP                                            ; FBE970  ef 60
	inc 6,XSP                                            ; FBE972  ef 66
	popw hl                                              ; FBE974  4b
	unlk XIZ                                             ; FBE975  ee 0d
	ret                                                  ; FBE977  0e
; CombiEditMixer_RepaintMarkedEffect1Send: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyEffect1Send (0x2775) under ei 6, then CombiEditMixer_DrawEffect1Send for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedEffect1Send:
	pushw hl                                             ; FBE978  2b
	pushw de                                             ; FBE979  2a
	ei 0x06                                              ; FBE97A  06 06
	ld e, (CombiEditMixer_DirtyEffect1Send:16)                                   ; FBE97C  c1 75 27 25
	ld (CombiEditMixer_DirtyEffect1Send:16), 0x00                                 ; FBE980  f1 75 27 00 00
; (sub_FBE985 removed 2026-10-04: no code names it and the line above falls through into it -- part of CombiEditMixer_DrawEffect1Send;
;  notes/prom_a_stray_label_removal.py)
	ei 0x00                                              ; FBE985  06 00
	ld d, 0x01:opc                                          ; FBE987  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBE989  c1 65 27 27
	and L,0xf8                                           ; FBE98D  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE990  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBE995  26 08
.LFBE997:
	ld C,D                                               ; FBE997  cc 8b
	and C,E                                              ; FBE999  cd c3
	jr z, .LFBE9A2                                       ; FBE99B  66 05
	pushw hl                                             ; FBE99D  2b
	calr CombiEditMixer_DrawEffect1Send                                      ; FBE99E  1e 8a ff
	popw bc                                              ; FBE9A1  49
.LFBE9A2:
	inc 1,L                                              ; FBE9A2  cf 61
	ld C,D                                               ; FBE9A4  cc 8b
	add C,D                                              ; FBE9A6  cc 83
	ld D,C                                               ; FBE9A8  cb 8c
	dec 1,H                                              ; FBE9AA  ce 69
	cp h, 0x00:i3                                          ; FBE9AC  ce d8
	jr nz, .LFBE997                                      ; FBE9AE  6e e7
	popw de                                              ; FBE9B0  4a
	popw hl                                              ; FBE9B1  4b
	ret                                                  ; FBE9B2  0e
; CombiEditMixer_DrawEffect2OnOff: (part) the MIXER cell of one part -- reads the first record byte 6 & 0x7F: EFFECT2 ON/OFF.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawEffect2OnOff:
	link XIZ,0x0000                                      ; FBE9B3  ee 0c 00 00
	pushw hl                                             ; FBE9B7  2b
	pushw 0x06                                           ; FBE9B8  0b 06 00
	push 0x00                                            ; FBE9BB  09 00
	push	(xiz+8)                                      ; FBE9BD  8e 08 04
	call T_IndexedTable_GetByte                          ; FBE9C0  1d 90 2c f4
	res 0x07,A                                           ; FBE9C4  c9 30 07
	pop XIY                                              ; FBE9C7  5d
	cp a, 0x00:i3                                          ; FBE9C8  c9 d8
	jr z, .LFBE9D0                                       ; FBE9CA  66 04
	ld h, 0x01:opc                                          ; FBE9CC  26 01
	jr .LFBE9D2                                          ; FBE9CE  68 02
.LFBE9D0:
	ld h, 0x00:opc                                          ; FBE9D0  26 00
.LFBE9D2:
	pushw 0x7c                                           ; FBE9D2  0b 7c 00
	push 0x00                                            ; FBE9D5  09 00
	push H                                               ; FBE9D7  ce 04
	push 0x00                                            ; FBE9D9  09 00
	push	(xiz+8)                                      ; FBE9DB  8e 08 04
	calr CombiEditMixer_DrawSwitchCell                                      ; FBE9DE  1e cf fa
	inc 6,XSP                                            ; FBE9E1  ef 66
	popw hl                                              ; FBE9E3  4b
	unlk XIZ                                             ; FBE9E4  ee 0d
	ret                                                  ; FBE9E6  0e
; CombiEditMixer_RepaintMarkedEffect2OnOff: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyEffect2OnOff (0x2776) under ei 6, then CombiEditMixer_DrawEffect2OnOff for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedEffect2OnOff:
	pushw hl                                             ; FBE9E7  2b
	pushw de                                             ; FBE9E8  2a
	ei 0x06                                              ; FBE9E9  06 06
	ld e, (CombiEditMixer_DirtyEffect2OnOff:16)                                   ; FBE9EB  c1 76 27 25
	ld (CombiEditMixer_DirtyEffect2OnOff:16), 0x00                                 ; FBE9EF  f1 76 27 00 00
	ei 0x00                                              ; FBE9F4  06 00
	ld d, 0x01:opc                                          ; FBE9F6  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBE9F8  c1 65 27 27
	and L,0xf8                                           ; FBE9FC  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBE9FF  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBEA04  26 08
.LFBEA06:
	ld C,D                                               ; FBEA06  cc 8b
	and C,E                                              ; FBEA08  cd c3
	jr z, .LFBEA11                                       ; FBEA0A  66 05
	pushw hl                                             ; FBEA0C  2b
	calr CombiEditMixer_DrawEffect2OnOff                                      ; FBEA0D  1e a3 ff
	popw bc                                              ; FBEA10  49
.LFBEA11:
	inc 1,L                                              ; FBEA11  cf 61
	ld C,D                                               ; FBEA13  cc 8b
	add C,D                                              ; FBEA15  cc 83
	ld D,C                                               ; FBEA17  cb 8c
	dec 1,H                                              ; FBEA19  ce 69
	cp h, 0x00:i3                                          ; FBEA1B  ce d8
	jr nz, .LFBEA06                                      ; FBEA1D  6e e7
	popw de                                              ; FBEA1F  4a
	popw hl                                              ; FBEA20  4b
	ret                                                  ; FBEA21  0e
; CombiEditMixer_DrawMainOut: (part) the MIXER cell of one part -- reads the second record byte 3 & 0xFF: MAIN OUT.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawMainOut:
	link XIZ,0x0000                                      ; FBEA22  ee 0c 00 00
	pushw hl                                             ; FBEA26  2b
	pushw 0x03                                           ; FBEA27  0b 03 00
	ld BC,(XIZ+0x08)                                     ; FBEA2A  9e 08 21
	extz BC                                              ; FBEA2D  d9 12
	add BC,0x0020                                        ; FBEA2F  d9 c8 20 00
	pushw bc                                             ; FBEA33  29
	call T_IndexedTable_GetByte                          ; FBEA34  1d 90 2c f4
	and A,0xff                                           ; FBEA38  c9 cc ff
	pop XIY                                              ; FBEA3B  5d
	cp a, 0x01:i3                                          ; FBEA3C  c9 d9
	jr nz, .LFBEA44                                      ; FBEA3E  6e 04
	ld h, 0x01:opc                                          ; FBEA40  26 01
	jr .LFBEA46                                          ; FBEA42  68 02
.LFBEA44:
	ld h, 0x00:opc                                          ; FBEA44  26 00
.LFBEA46:
	pushw 0xa7                                           ; FBEA46  0b a7 00
	push 0x00                                            ; FBEA49  09 00
	push H                                               ; FBEA4B  ce 04
	push 0x00                                            ; FBEA4D  09 00
	push	(xiz+8)                                      ; FBEA4F  8e 08 04
	calr CombiEditMixer_DrawSwitchCell                                      ; FBEA52  1e 5b fa
	inc 6,XSP                                            ; FBEA55  ef 66
	popw hl                                              ; FBEA57  4b
	unlk XIZ                                             ; FBEA58  ee 0d
	ret                                                  ; FBEA5A  0e
; CombiEditMixer_RepaintMarkedMainOut: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyMainOut (0x2778) under ei 6, then CombiEditMixer_DrawMainOut for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedMainOut:
	pushw hl                                             ; FBEA5B  2b
	pushw de                                             ; FBEA5C  2a
	ei 0x06                                              ; FBEA5D  06 06
	ld e, (CombiEditMixer_DirtyMainOut:16)                                   ; FBEA5F  c1 78 27 25
	ld (CombiEditMixer_DirtyMainOut:16), 0x00                                 ; FBEA63  f1 78 27 00 00
	ei 0x00                                              ; FBEA68  06 00
	ld d, 0x01:opc                                          ; FBEA6A  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBEA6C  c1 65 27 27
	and L,0xf8                                           ; FBEA70  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBEA73  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBEA78  26 08
.LFBEA7A:
	ld C,D                                               ; FBEA7A  cc 8b
	and C,E                                              ; FBEA7C  cd c3
	jr z, .LFBEA85                                       ; FBEA7E  66 05
	pushw hl                                             ; FBEA80  2b
	calr CombiEditMixer_DrawMainOut                                      ; FBEA81  1e 9e ff
	popw bc                                              ; FBEA84  49
.LFBEA85:
	inc 1,L                                              ; FBEA85  cf 61
	ld C,D                                               ; FBEA87  cc 8b
	add C,D                                              ; FBEA89  cc 83
	ld D,C                                               ; FBEA8B  cb 8c
	dec 1,H                                              ; FBEA8D  ce 69
	cp h, 0x00:i3                                          ; FBEA8F  ce d8
	jr nz, .LFBEA7A                                      ; FBEA91  6e e7
	popw de                                              ; FBEA93  4a
	popw hl                                              ; FBEA94  4b
	ret                                                  ; FBEA95  0e
; CombiEditMixer_DrawMidiOutSetting: (part) the MIXER cell of one part -- reads the first record byte 13 & 0x40: MIDI OUT SETTING.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawMidiOutSetting:
	link XIZ,0x0000                                      ; FBEA96  ee 0c 00 00
	pushw hl                                             ; FBEA9A  2b
	pushw 0x0d                                           ; FBEA9B  0b 0d 00
	push 0x00                                            ; FBEA9E  09 00
	push	(xiz+8)                                      ; FBEAA0  8e 08 04
	call T_IndexedTable_GetByte                          ; FBEAA3  1d 90 2c f4
	and A,0x40                                           ; FBEAA7  c9 cc 40
	pop XIY                                              ; FBEAAA  5d
	jr z, .LFBEAB1                                       ; FBEAAB  66 04
	ld h, 0x00:opc                                          ; FBEAAD  26 00
	jr .LFBEAB3                                          ; FBEAAF  68 02
.LFBEAB1:
	ld h, 0x01:opc                                          ; FBEAB1  26 01
.LFBEAB3:
	pushw 0x55                                           ; FBEAB3  0b 55 00
	push 0x00                                            ; FBEAB6  09 00
	push H                                               ; FBEAB8  ce 04
	push 0x00                                            ; FBEABA  09 00
	push	(xiz+8)                                      ; FBEABC  8e 08 04
	calr CombiEditMixer_DrawSwitchCell                                      ; FBEABF  1e ee f9
	inc 6,XSP                                            ; FBEAC2  ef 66
	popw hl                                              ; FBEAC4  4b
	unlk XIZ                                             ; FBEAC5  ee 0d
	ret                                                  ; FBEAC7  0e
; CombiEditMixer_RepaintMarkedMidiOutSetting: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyMidiOutSetting (0x2779) under ei 6, then CombiEditMixer_DrawMidiOutSetting for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedMidiOutSetting:
	pushw hl                                             ; FBEAC8  2b
	pushw de                                             ; FBEAC9  2a
	ei 0x06                                              ; FBEACA  06 06
	ld e, (CombiEditMixer_DirtyMidiOutSetting:16)                                   ; FBEACC  c1 79 27 25
	ld (CombiEditMixer_DirtyMidiOutSetting:16), 0x00                                 ; FBEAD0  f1 79 27 00 00
	ei 0x00                                              ; FBEAD5  06 00
	ld d, 0x01:opc                                          ; FBEAD7  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBEAD9  c1 65 27 27
	and L,0xf8                                           ; FBEADD  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBEAE0  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBEAE5  26 08
.LFBEAE7:
	ld C,D                                               ; FBEAE7  cc 8b
	and C,E                                              ; FBEAE9  cd c3
	jr z, .LFBEAF2                                       ; FBEAEB  66 05
	pushw hl                                             ; FBEAED  2b
	calr CombiEditMixer_DrawMidiOutSetting                                      ; FBEAEE  1e a5 ff
	popw bc                                              ; FBEAF1  49
.LFBEAF2:
	inc 1,L                                              ; FBEAF2  cf 61
	ld C,D                                               ; FBEAF4  cc 8b
	add C,D                                              ; FBEAF6  cc 83
	ld D,C                                               ; FBEAF8  cb 8c
	dec 1,H                                              ; FBEAFA  ce 69
	cp h, 0x00:i3                                          ; FBEAFC  ce d8
	jr NZ,.LFBEAE7                                       ; FBEAFE  6e e7
	popw de                                              ; FBEB00  4a
	popw hl                                              ; FBEB01  4b
	ret                                                  ; FBEB02  0e
; CombiEditMixer_DrawMidiInSetting: (part) the MIXER cell of one part -- reads the first record byte 13 & 0x80: MIDI IN SETTING.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawMidiInSetting:
	link XIZ,0x0000                                      ; FBEB03  ee 0c 00 00
	pushw hl                                             ; FBEB07  2b
	pushw 0x0d                                           ; FBEB08  0b 0d 00
	push 0x00                                            ; FBEB0B  09 00
	push	(xiz+8)                                      ; FBEB0D  8e 08 04
	call T_IndexedTable_GetByte                          ; FBEB10  1d 90 2c f4
	and A,0x80                                           ; FBEB14  c9 cc 80
	pop XIY                                              ; FBEB17  5d
	jr z, .LFBEB1E                                       ; FBEB18  66 04
	ld h, 0x00:opc                                          ; FBEB1A  26 00
	jr .LFBEB20                                          ; FBEB1C  68 02
.LFBEB1E:
	ld h, 0x01:opc                                          ; FBEB1E  26 01
.LFBEB20:
	pushw 0x7c                                           ; FBEB20  0b 7c 00
	push 0x00                                            ; FBEB23  09 00
	push H                                               ; FBEB25  ce 04
	push 0x00                                            ; FBEB27  09 00
	push	(xiz+8)                                      ; FBEB29  8e 08 04
	calr CombiEditMixer_DrawSwitchCell                                      ; FBEB2C  1e 81 f9
	inc 6,XSP                                            ; FBEB2F  ef 66
	popw hl                                              ; FBEB31  4b
	unlk XIZ                                             ; FBEB32  ee 0d
	ret                                                  ; FBEB34  0e
; CombiEditMixer_RepaintMarkedMidiInSetting: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyMidiInSetting (0x277A) under ei 6, then CombiEditMixer_DrawMidiInSetting for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedMidiInSetting:
	pushw hl                                             ; FBEB35  2b
	pushw de                                             ; FBEB36  2a
	ei 0x06                                              ; FBEB37  06 06
	ld e, (CombiEditMixer_DirtyMidiInSetting:16)                                   ; FBEB39  c1 7a 27 25
	ld (CombiEditMixer_DirtyMidiInSetting:16), 0x00                                 ; FBEB3D  f1 7a 27 00 00
	ei 0x00                                              ; FBEB42  06 00
	ld d, 0x01:opc                                          ; FBEB44  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBEB46  c1 65 27 27
	and L,0xf8                                           ; FBEB4A  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBEB4D  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBEB52  26 08
.LFBEB54:
	ld C,D                                               ; FBEB54  cc 8b
	and C,E                                              ; FBEB56  cd c3
	jr z, .LFBEB5F                                       ; FBEB58  66 05
	pushw hl                                             ; FBEB5A  2b
	calr CombiEditMixer_DrawMidiInSetting                                      ; FBEB5B  1e a5 ff
	popw bc                                              ; FBEB5E  49
.LFBEB5F:
	inc 1,L                                              ; FBEB5F  cf 61
	ld C,D                                               ; FBEB61  cc 8b
	add C,D                                              ; FBEB63  cc 83
	ld D,C                                               ; FBEB65  cb 8c
	dec 1,H                                              ; FBEB67  ce 69
	cp h, 0x00:i3                                          ; FBEB69  ce d8
	jr nz, .LFBEB54                                      ; FBEB6B  6e e7
	popw de                                              ; FBEB6D  4a
	popw hl                                              ; FBEB6E  4b
	ret                                                  ; FBEB6F  0e
; CombiEditMixer_DrawBasicChannel: (part) the MIXER cell of one part -- reads the first record byte 13: BASIC CHANNEL; no mask; offset 13's bits 5-7 have cells of their own, so BASIC CHANNEL (bits 0-4) by elimination.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawBasicChannel:
	link XIZ,0x0000                                      ; FBEB70  ee 0c 00 00
	pushw 0x0d                                           ; FBEB74  0b 0d 00
	push 0x00                                            ; FBEB77  09 00
	push	(xiz+8)                                      ; FBEB79  8e 08 04
	call T_IndexedTable_GetByte                          ; FBEB7C  1d 90 2c f4
	ld (UI_DrawScratch:16), a                                   ; FBEB80  f1 40 26 41
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBEB84  f1 40 25 00 00
	ld C,(XIZ+0x08)                                      ; FBEB89  8e 08 23
	and C,0x07                                           ; FBEB8C  cb cc 07
	mul C,0x04                                           ; FBEB8F  cb 08 04
	extz XBC                                             ; FBEB92  e9 12
	add XBC,PtrTable_F1B10B                              ; FBEB94  e9 c8 0b b1 f1 00
	ld XBC,(XBC)                                         ; FBEB9A  a1 21
	push XBC                                             ; FBEB9C  39
	call T_DisplayListB_RunOne_Stack                     ; FBEB9D  1d 0c 2e f4
	inc 8,XSP                                            ; FBEBA1  ef 60
	unlk XIZ                                             ; FBEBA3  ee 0d
	ret                                                  ; FBEBA5  0e
; CombiEditMixer_RepaintMarkedBasicChannel: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyBasicChannel (0x277B) under ei 6, then CombiEditMixer_DrawBasicChannel for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedBasicChannel:
	pushw hl                                             ; FBEBA6  2b
	pushw de                                             ; FBEBA7  2a
	ei 0x06                                              ; FBEBA8  06 06
	ld e, (CombiEditMixer_DirtyBasicChannel:16)                                   ; FBEBAA  c1 7b 27 25
	ld (CombiEditMixer_DirtyBasicChannel:16), 0x00                                 ; FBEBAE  f1 7b 27 00 00
	ei 0x00                                              ; FBEBB3  06 00
	ld d, 0x01:opc                                          ; FBEBB5  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBEBB7  c1 65 27 27
	and L,0xf8                                           ; FBEBBB  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBEBBE  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBEBC3  26 08
.LFBEBC5:
	ld C,D                                               ; FBEBC5  cc 8b
	and C,E                                              ; FBEBC7  cd c3
	jr z, .LFBEBD0                                       ; FBEBC9  66 05
	pushw hl                                             ; FBEBCB  2b
	calr CombiEditMixer_DrawBasicChannel                                      ; FBEBCC  1e a1 ff
	popw bc                                              ; FBEBCF  49
.LFBEBD0:
	inc 1,L                                              ; FBEBD0  cf 61
	ld C,D                                               ; FBEBD2  cc 8b
	add C,D                                              ; FBEBD4  cc 83
	ld D,C                                               ; FBEBD6  cb 8c
	dec 1,H                                              ; FBEBD8  ce 69
	cp h, 0x00:i3                                          ; FBEBDA  ce d8
	jr nz, .LFBEBC5                                      ; FBEBDC  6e e7
	popw de                                              ; FBEBDE  4a
	popw hl                                              ; FBEBDF  4b
	ret                                                  ; FBEBE0  0e
; CombiEditMixer_DrawSubOut: (part) the MIXER cell of one part -- reads the second record byte 4: SUB OUT.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawSubOut:
	link XIZ,0x0000                                      ; FBEBE1  ee 0c 00 00
	pushw 0x04                                           ; FBEBE5  0b 04 00
	ld BC,(XIZ+0x08)                                     ; FBEBE8  9e 08 21
	extz BC                                              ; FBEBEB  d9 12
	add BC,0x0020                                        ; FBEBED  d9 c8 20 00
	pushw bc                                             ; FBEBF1  29
	call T_IndexedTable_GetByte                          ; FBEBF2  1d 90 2c f4
	ld (UI_DrawScratch:16), a                                   ; FBEBF6  f1 40 26 41
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBEBFA  f1 40 25 00 00
	ld C,(XIZ+0x08)                                      ; FBEBFF  8e 08 23
	and C,0x07                                           ; FBEC02  cb cc 07
	mul C,0x04                                           ; FBEC05  cb 08 04
	extz XBC                                             ; FBEC08  e9 12
	add XBC,PtrTable_F1B12B                              ; FBEC0A  e9 c8 2b b1 f1 00
	ld XBC,(XBC)                                         ; FBEC10  a1 21
	push XBC                                             ; FBEC12  39
	call T_DisplayListB_RunOne_Stack                     ; FBEC13  1d 0c 2e f4
	inc 8,XSP                                            ; FBEC17  ef 60
	unlk XIZ                                             ; FBEC19  ee 0d
	ret                                                  ; FBEC1B  0e
; CombiEditMixer_RepaintMarkedSubOut: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtySubOut (0x2777) under ei 6, then CombiEditMixer_DrawSubOut for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedSubOut:
	pushw hl                                             ; FBEC1C  2b
	pushw de                                             ; FBEC1D  2a
	ei 0x06                                              ; FBEC1E  06 06
	ld e, (CombiEditMixer_DirtySubOut:16)                                   ; FBEC20  c1 77 27 25
	ld (CombiEditMixer_DirtySubOut:16), 0x00                                 ; FBEC24  f1 77 27 00 00
	ei 0x00                                              ; FBEC29  06 00
	ld d, 0x01:opc                                          ; FBEC2B  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBEC2D  c1 65 27 27
	and L,0xf8                                           ; FBEC31  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBEC34  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBEC39  26 08
.LFBEC3B:
	ld C,D                                               ; FBEC3B  cc 8b
	and C,E                                              ; FBEC3D  cd c3
	jr z, .LFBEC46                                       ; FBEC3F  66 05
	pushw hl                                             ; FBEC41  2b
	calr CombiEditMixer_DrawSubOut                                      ; FBEC42  1e 9c ff
	popw bc                                              ; FBEC45  49
.LFBEC46:
	inc 1,L                                              ; FBEC46  cf 61
	ld C,D                                               ; FBEC48  cc 8b
	add C,D                                              ; FBEC4A  cc 83
	ld D,C                                               ; FBEC4C  cb 8c
	dec 1,H                                              ; FBEC4E  ce 69
	cp h, 0x00:i3                                          ; FBEC50  ce d8
	jr nz, .LFBEC3B                                      ; FBEC52  6e e7
	popw de                                              ; FBEC54  4a
	popw hl                                              ; FBEC55  4b
	ret                                                  ; FBEC56  0e
; CombiEditMixer_DrawKeyShift: (part) the MIXER cell of one part -- reads the first record byte 9: KEY SHIFT.  Basis: table (descriptor match) (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_DrawKeyShift:
	link XIZ,0x0000                                      ; FBEC57  ee 0c 00 00
	pushw hl                                             ; FBEC5B  2b
	pushw 0x09                                           ; FBEC5C  0b 09 00
	push 0x00                                            ; FBEC5F  09 00
	push	(xiz+8)                                      ; FBEC61  8e 08 04
	call T_IndexedTable_GetByte                          ; FBEC64  1d 90 2c f4
	ld H,A                                               ; FBEC68  c9 8e
	ld (UI_DrawScratch:16), a                                   ; FBEC6A  f1 40 26 41
	pushw 0x40                                           ; FBEC6E  0b 40 00
	pushw 0xd1                                           ; FBEC71  0b d1 00
	push 0x00                                            ; FBEC74  09 00
	push H                                               ; FBEC76  ce 04
	push 0x00                                            ; FBEC78  09 00
	push	(xiz+8)                                      ; FBEC7A  8e 08 04
	calr CombiEditMixer_DrawKeyShiftValue                                      ; FBEC7D  1e 05 f9
	inc 8,XSP                                            ; FBEC80  ef 60
	inc 4,XSP                                            ; FBEC82  ef 64
	popw hl                                              ; FBEC84  4b
	unlk XIZ                                             ; FBEC85  ee 0d
	ret                                                  ; FBEC87  0e
; CombiEditMixer_RepaintMarkedKeyShift: the callback CombiEditMixer_OnPartParamEvent posts: takes and clears CombiEditMixer_DirtyKeyShift (0x277C) under ei 6, then CombiEditMixer_DrawKeyShift for each part of the edited group whose bit is set.  Basis: body (notes/prom_a_combi_mixer_cells.py)
CombiEditMixer_RepaintMarkedKeyShift:
	pushw hl                                             ; FBEC88  2b
	pushw de                                             ; FBEC89  2a
	ei 0x06                                              ; FBEC8A  06 06
	ld e, (CombiEditMixer_DirtyKeyShift:16)                                   ; FBEC8C  c1 7c 27 25
	ld (CombiEditMixer_DirtyKeyShift:16), 0x00                                 ; FBEC90  f1 7c 27 00 00
	ei 0x00                                              ; FBEC95  06 00
	ld d, 0x01:opc                                          ; FBEC97  24 01
	ld l, (CombiEdit_Part:16)                                   ; FBEC99  c1 65 27 27
	and L,0xf8                                           ; FBEC9D  cf cc f8
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBECA0  f1 40 25 00 00
	ld h, 0x08:opc                                          ; FBECA5  26 08
.LFBECA7:
	ld C,D                                               ; FBECA7  cc 8b
	and C,E                                              ; FBECA9  cd c3
	jr z, .LFBECB2                                       ; FBECAB  66 05
	pushw hl                                             ; FBECAD  2b
	calr CombiEditMixer_DrawKeyShift                                      ; FBECAE  1e a6 ff
	popw bc                                              ; FBECB1  49
.LFBECB2:
	inc 1,L                                              ; FBECB2  cf 61
	ld C,D                                               ; FBECB4  cc 8b
	add C,D                                              ; FBECB6  cc 83
	ld D,C                                               ; FBECB8  cb 8c
	dec 1,H                                              ; FBECBA  ce 69
	cp h, 0x00:i3                                          ; FBECBC  ce d8
	jr nz, .LFBECA7                                      ; FBECBE  6e e7
	popw de                                              ; FBECC0  4a
	popw hl                                              ; FBECC1  4b
	ret                                                  ; FBECC2  0e
; CombiEdit_Begin: T_CombiEdit_Begin: T_Mode_SwitchToCombination, T_SoundGroup_ReloadSelection, (0x2134) bit 1; the current part (UI_PartIndex)
;   becomes CombiEdit_Part and is kept in CombiEdit_EntryPart (0x276D); T_NoteRouting_SetSoloAndRebuild(0),
;   (0x276F) = 0, then CombiEdit_SaveOriginalForCompare.  Basis: body.
CombiEdit_Begin:
	pushw hl                                             ; FBECC3  2b
	push XDE                                             ; FBECC4  3a
	push XHL                                             ; FBECC5  3b
	push XIX                                             ; FBECC6  3c
	push XIZ                                             ; FBECC7  3e
	call T_Mode_SwitchToCombination                                        ; FBECC8  1d c0 15 f4
	call T_SoundGroup_ReloadSelection                                        ; FBECCC  1d c8 15 f4
	pop XIZ                                              ; FBECD0  5e
	pop XIX                                              ; FBECD1  5c
	pop XHL                                              ; FBECD2  5b
	pop XDE                                              ; FBECD3  5a
	set	1, (0x2134:16)                               ; FBECD4  f1 34 21 b9
	ld h, (UI_PartIndex:16)                                   ; FBECD8  c1 50 22 26
	ld (CombiEdit_EntryPart:16), h                                   ; FBECDC  f1 6d 27 46
	ld (0x2766:16), h                                   ; FBECE0  f1 66 27 46
	ld (CombiEdit_Part:16), h                                   ; FBECE4  f1 65 27 46
	ld C,H                                               ; FBECE8  ce 8b
	inc 1,C                                              ; FBECEA  cb 61
	ld (0x2766:16), c                                   ; FBECEC  f1 66 27 43
	pushw 0x00                                           ; FBECF0  0b 00 00
	call T_NoteRouting_SetSoloAndRebuild                                        ; FBECF3  1d ec 11 f4
	ld (0x276f:16), 0x00                                 ; FBECF7  f1 6f 27 00 00
	calr CombiEdit_SaveOriginalForCompare                                      ; FBECFC  1e 22 00
	popw bc                                              ; FBECFF  49
	popw hl                                              ; FBED00  4b
	ret                                                  ; FBED01  0e
; CombiEdit_End: T_CombiEdit_End: (0x2134) bit 1, UI_PartIndex = CombiEdit_EntryPart, T_PartIndex_PostChangeEvent, T_NoteRouting_SetSoloAndRebuild(0),
;   (0x276F) = 0, CombiEdit_CompareOff.  Basis: body.
CombiEdit_End:
	set	1, (0x2134:16)                               ; FBED02  f1 34 21 b9
	ld	(UI_PartIndex:16), (CombiEdit_EntryPart:16)             ; FBED06  c1 6d 27 19 50 22
	call T_PartIndex_PostChangeEvent                                        ; FBED0C  1d 9c 2c f4
	pushw 0x00                                           ; FBED10  0b 00 00
	call T_NoteRouting_SetSoloAndRebuild                                        ; FBED13  1d ec 11 f4
	ld (0x276f:16), 0x00                                 ; FBED17  f1 6f 27 00 00
	calr CombiEdit_CompareOff                                      ; FBED1C  1e 58 00
	popw bc                                              ; FBED1F  49
	ret                                                  ; FBED20  0e
; CombiEdit_SaveOriginalForCompare: CombiEdit_Comparing = 0, (0x216E) = 0, (0x213B) bit 2, and the 0x2C0-byte current combination
;   (Combination_Current, 0x7620..0x78DF) copied word by word to CombiEdit_CompareOriginal (0x1400) -- what COMPARE
;   shows.  Basis: body + caller (CombiEdit_Begin).
CombiEdit_SaveOriginalForCompare:
	link XIZ,0xfffa                                      ; FBED21  ee 0c fa ff
	pushw hl                                             ; FBED25  2b
	pushw de                                             ; FBED26  2a
	push XIX                                             ; FBED27  3c
	ld (CombiEdit_Comparing:16), 0x00                                 ; FBED28  f1 7f 27 00 00
	ld (0x216e:16), 0x00                                 ; FBED2D  f1 6e 21 00 00
	set	2, (0x213b:16)                               ; FBED32  f1 3b 21 ba
	lda xbc, (Combination_Current:16)                                ; FBED36  f1 20 76 31
	ld (xiz-4), xbc                                      ; FBED3A  be fc 61
	lda xix, (CombiEdit_CompareOriginal:16)                                ; FBED3D  f1 00 14 34
	ldw hl, 0x00                                         ; FBED41  33 00 00
	ldw wa, Combination_Current                                       ; FBED44  30 20 76
	ld (xiz-6), wa                                       ; FBED47  be fa 50
	ldw bc, 0x78de                                       ; FBED4A  31 de 78
	sub BC,WA                                            ; FBED4D  d8 a1
	inc 2,BC                                             ; FBED4F  d9 62
	exts XBC                                             ; FBED51  e9 13
	divs BC,0x0002                                       ; FBED53  d9 0b 02 00
	ld DE,BC                                             ; FBED57  d9 8a
.LFBED59:
	cp HL,DE                                             ; FBED59  da f3
	jr nc, .LFBED71                                      ; FBED5B  6f 14
	ld xbc, (xiz-4)                                      ; FBED5D  ae fc 21
	ld WA,(XBC)                                          ; FBED60  91 20
	ld (XIX),WA                                          ; FBED62  b4 50
	sub XBC,XBC                                          ; FBED64  e9 a1
	inc 2,XBC                                            ; FBED66  e9 62
	add (xiz-4), xbc                                     ; FBED68  ae fc 89
	add XIX,XBC                                          ; FBED6B  e9 84
	inc 1,HL                                             ; FBED6D  db 61
	jr .LFBED59                                          ; FBED6F  68 e8
.LFBED71:
	pop XIX                                              ; FBED71  5c
	popw de                                              ; FBED72  4a
	popw hl                                              ; FBED73  4b
	unlk XIZ                                             ; FBED74  ee 0d
	ret                                                  ; FBED76  0e
; CombiEdit_CompareOff: when (0x277F) is 1: (0x277F) = 0, (0x216E) = 0, (0x213B) bit 2, CombiEdit_SwapForCompare, a repaint.  CompareKey_CombiEdit
;   calls it in COMBINATION EDIT (PanelModeGroup 0x16) while comparing.
CombiEdit_CompareOff:
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBED77  c1 7f 27 3f 01
	jr nz, .LFBED93                                      ; FBED7C  6e 15
	ld (CombiEdit_Comparing:16), 0x00                                 ; FBED7E  f1 7f 27 00 00
	ld (0x216e:16), 0x00                                 ; FBED83  f1 6e 21 00 00
	set	2, (0x213b:16)                               ; FBED88  f1 3b 21 ba
	calr CombiEdit_SwapForCompare                                      ; FBED8C  1e 46 00
	set	4, (UI_ScreenFlags:16)                               ; FBED8F  f1 95 20 bc
.LFBED93:
	ret                                                  ; FBED93  0e
; CombiEdit_CompareOn: when (0x277F) is 0: (0x277F) = 1, (0x216E) = 1, (0x213B) bit 2, CombiEdit_SwapForCompare, T_NoteRouting_SetSoloAndRebuild(0), (0x276F) = 0, a repaint.
CombiEdit_CompareOn:
	cp	(CombiEdit_Comparing:16), 0x00                            ; FBED94  c1 7f 27 3f 00
	jr nz, .LFBEDBD                                      ; FBED99  6e 22
	ld (CombiEdit_Comparing:16), 0x01                                 ; FBED9B  f1 7f 27 00 01
	ld (0x216e:16), 0x01                                 ; FBEDA0  f1 6e 21 00 01
	set	2, (0x213b:16)                               ; FBEDA5  f1 3b 21 ba
	calr CombiEdit_SwapForCompare                                      ; FBEDA9  1e 29 00
	pushw 0x00                                           ; FBEDAC  0b 00 00
	call T_NoteRouting_SetSoloAndRebuild                                        ; FBEDAF  1d ec 11 f4
	ld (0x276f:16), 0x00                                 ; FBEDB3  f1 6f 27 00 00
	set	4, (UI_ScreenFlags:16)                               ; FBEDB8  f1 95 20 bc
	popw bc                                              ; FBEDBC  49
.LFBEDBD:
	ret                                                  ; FBEDBD  0e
; CompareKey_CombiEdit: slot 21 (code 0x1E, COMPARE -- Dispatch_FF4049's code map) of the 23-slot button tables of
;   CombiEditInternalSound (ScreenButtons_CombiEditInternalSound), CombiEditMixer (_F1AFD5), CombinationNaming (_F1B14B), CombiEditConfigure
;   (_F1B239) and CombiEditMenu (_F1B295); ScreenButton_CombiEditDspEffect also calls it for code 0x1E.
CompareKey_CombiEdit:
	cp	(PanelModeGroup:16), 0x16                            ; FBEDBE  c1 76 20 3f 16
	jr nz, .LFBEDD4                                      ; FBEDC3  6e 0f
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBEDC5  c1 7f 27 3f 01
	jr nz, .LFBEDD1                                      ; FBEDCA  6e 05
	calr CombiEdit_CompareOff                                      ; FBEDCC  1e a8 ff
	jr .LFBEDD4                                          ; FBEDCF  68 03
.LFBEDD1:
	calr CombiEdit_CompareOn                                      ; FBEDD1  1e c0 ff
.LFBEDD4:
	ret                                                  ; FBEDD4  0e
; CombiEdit_SwapForCompare: T_ParamImage_SnapshotCombination_Entry, then: COMPARE turned on (CombiEdit_Comparing 1) -> the edited combination
;   is saved to CombiEdit_CompareEdited (0x1D00) and CombiEdit_CompareOriginal loaded into Combination_Current; turned
;   off -> CombiEdit_CompareEdited restored; then T_ParamImage_QueueDiffCombination sends what changed.  Callers:
;   CombiEdit_CompareOn / _CompareOff.  Basis: body + callers.
CombiEdit_SwapForCompare:
	link XIZ,0xfff6                                      ; FBEDD5  ee 0c f6 ff
	pushw hl                                             ; FBEDD9  2b
	pushw de                                             ; FBEDDA  2a
	push XIX                                             ; FBEDDB  3c
	push XDE                                             ; FBEDDC  3a
	push XHL                                             ; FBEDDD  3b
	push XIX                                             ; FBEDDE  3c
	push XIZ                                             ; FBEDDF  3e
	call T_ParamImage_SnapshotCombination_Entry                                        ; FBEDE0  1d 4c 02 f4
	pop XIZ                                              ; FBEDE4  5e
	pop XIX                                              ; FBEDE5  5c
	pop XHL                                              ; FBEDE6  5b
	pop XDE                                              ; FBEDE7  5a
	lda xbc, (Combination_Current:16)                                ; FBEDE8  f1 20 76 31
	ld (xiz-4), xbc                                      ; FBEDEC  be fc 61
	lda xix, (CombiEdit_CompareOriginal:16)                                ; FBEDEF  f1 00 14 34
	lda xwa, (CombiEdit_CompareEdited:16)                                ; FBEDF3  f1 00 1d 30
	ld (xiz-8), xwa                                      ; FBEDF7  be f8 60
	ldw de, 0x00                                         ; FBEDFA  32 00 00
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBEDFD  c1 7f 27 3f 01
	jr nz, .LFBEE43                                      ; FBEE02  6e 3f
	ldw bc, Combination_Current                                       ; FBEE04  31 20 76
	ld (xiz-10), bc                                      ; FBEE07  be f6 51
	ldw bc, 0x78de                                       ; FBEE0A  31 de 78
	sub	bc, (xiz-10)                                 ; FBEE0D  9e f6 a1
	inc 2,BC                                             ; FBEE10  d9 62
	exts XBC                                             ; FBEE12  e9 13
	divs BC,0x0002                                       ; FBEE14  d9 0b 02 00
	ld HL,BC                                             ; FBEE18  d9 8b
.LFBEE1A:
	cp DE,HL                                             ; FBEE1A  db f2
	jr nc, .LFBEE71                                      ; FBEE1C  6f 53
	ld xbc, (xiz-4)                                      ; FBEE1E  ae fc 21
	ld WA,(XBC)                                          ; FBEE21  91 20
	ld xiy, (xiz-8)                                      ; FBEE23  ae f8 25
	ld (XIY),WA                                          ; FBEE26  b5 50
	sub XBC,XBC                                          ; FBEE28  e9 a1
	inc 2,XBC                                            ; FBEE2A  e9 62
	add (xiz-8), xbc                                     ; FBEE2C  ae f8 89
	ld WA,(XIX)                                          ; FBEE2F  94 20
	ld xiy, (xiz-4)                                      ; FBEE31  ae fc 25
	ld (XIY),WA                                          ; FBEE34  b5 50
	inc 2,XIX                                            ; FBEE36  ec 62
	sub XBC,XBC                                          ; FBEE38  e9 a1
	inc 2,XBC                                            ; FBEE3A  e9 62
	add (xiz-4), xbc                                     ; FBEE3C  ae fc 89
	inc 1,DE                                             ; FBEE3F  da 61
	jr .LFBEE1A                                          ; FBEE41  68 d7
.LFBEE43:
	ldw ix, Combination_Current                                       ; FBEE43  34 20 76
	ldw bc, 0x78de                                       ; FBEE46  31 de 78
	sub BC,IX                                            ; FBEE49  dc a1
	inc 2,BC                                             ; FBEE4B  d9 62
	exts XBC                                             ; FBEE4D  e9 13
	divs BC,0x0002                                       ; FBEE4F  d9 0b 02 00
	ld HL,BC                                             ; FBEE53  d9 8b
.LFBEE55:
	cp DE,HL                                             ; FBEE55  db f2
	jr nc, .LFBEE71                                      ; FBEE57  6f 18
	ld xbc, (xiz-8)                                      ; FBEE59  ae f8 21
	ld WA,(XBC)                                          ; FBEE5C  91 20
	ld xiy, (xiz-4)                                      ; FBEE5E  ae fc 25
	ld (XIY),WA                                          ; FBEE61  b5 50
	sub XBC,XBC                                          ; FBEE63  e9 a1
	inc 2,XBC                                            ; FBEE65  e9 62
	add (xiz-8), xbc                                     ; FBEE67  ae f8 89
	add (xiz-4), xbc                                     ; FBEE6A  ae fc 89
	inc 1,DE                                             ; FBEE6D  da 61
	jr .LFBEE55                                          ; FBEE6F  68 e4
.LFBEE71:
	push XDE                                             ; FBEE71  3a
	push XHL                                             ; FBEE72  3b
	push XIX                                             ; FBEE73  3c
	push XIZ                                             ; FBEE74  3e
	call T_ParamImage_QueueDiffCombination                                        ; FBEE75  1d 48 02 f4
	pop XIZ                                              ; FBEE79  5e
	pop XIX                                              ; FBEE7A  5c
	pop XHL                                              ; FBEE7B  5b
	pop XDE                                              ; FBEE7C  5a
	pop XIX                                              ; FBEE7D  5c
	popw de                                              ; FBEE7E  4a
	popw hl                                              ; FBEE7F  4b
	unlk XIZ                                             ; FBEE80  ee 0d
	ret                                                  ; FBEE82  0e
; CombiEdit_RestoreEditedIfComparing: T_CombiEdit_RestoreEditedIfComparing: in COMBINATION EDIT (PanelModeGroup 0x16) while CombiEdit_Comparing is 1, CombiEdit_CompareEdited
;   copied back into Combination_Current (the flag is left as it is).  Basis: body.
CombiEdit_RestoreEditedIfComparing:
	link XIZ,0xfffa                                      ; FBEE83  ee 0c fa ff
	pushw hl                                             ; FBEE87  2b
	pushw de                                             ; FBEE88  2a
	push XIX                                             ; FBEE89  3c
	cp	(PanelModeGroup:16), 0x16                            ; FBEE8A  c1 76 20 3f 16
	jr nz, .LFBEED3                                      ; FBEE8F  6e 42
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBEE91  c1 7f 27 3f 01
	jr nz, .LFBEED3                                      ; FBEE96  6e 3b
	lda xbc, (Combination_Current:16)                                ; FBEE98  f1 20 76 31
	ld (xiz-4), xbc                                      ; FBEE9C  be fc 61
	lda xix, (CombiEdit_CompareEdited:16)                                ; FBEE9F  f1 00 1d 34
	ldw hl, 0x00                                         ; FBEEA3  33 00 00
	ldw wa, Combination_Current                                       ; FBEEA6  30 20 76
	ld (xiz-6), wa                                       ; FBEEA9  be fa 50
	ldw bc, 0x78de                                       ; FBEEAC  31 de 78
	sub BC,WA                                            ; FBEEAF  d8 a1
	inc 2,BC                                             ; FBEEB1  d9 62
	exts XBC                                             ; FBEEB3  e9 13
	divs BC,0x0002                                       ; FBEEB5  d9 0b 02 00
	ld DE,BC                                             ; FBEEB9  d9 8a
.LFBEEBB:
	cp HL,DE                                             ; FBEEBB  da f3
	jr nc, .LFBEED3                                      ; FBEEBD  6f 14
	ld BC,(XIX)                                          ; FBEEBF  94 21
	ld xwa, (xiz-4)                                      ; FBEEC1  ae fc 20
	ld (XWA),BC                                          ; FBEEC4  b0 51
	inc 2,XIX                                            ; FBEEC6  ec 62
	sub XBC,XBC                                          ; FBEEC8  e9 a1
	inc 2,XBC                                            ; FBEECA  e9 62
	add (xiz-4), xbc                                     ; FBEECC  ae fc 89
	inc 1,HL                                             ; FBEECF  db 61
	jr .LFBEEBB                                          ; FBEED1  68 e8
.LFBEED3:
	pop XIX                                              ; FBEED3  5c
	popw de                                              ; FBEED4  4a
	popw hl                                              ; FBEED5  4b
	unlk XIZ                                             ; FBEED6  ee 0d
	ret                                                  ; FBEED8  0e
; ScreenEnter_CombiEditMenuRedirect: the +0 ENTER method of the screen object for screen id 0x33 -- PanelScreen_VtableTable entry 0x53
;   (ViewB entry 0x33) points at the thunk triple starting at T_ScreenEnter_CombiEditMenuRedirect, and slot T_ScreenEnter_CombiEditMenuRedirect jumps here.
; ScreenEnter_CombiEditMenuRedirect: screen 0x33's +0 ENTER -- requests screen 0x34, ScreenEnter_CombiEditMenu
;   (UI_Request = 0x34 with UI_Request_Hi bit 7).
ScreenEnter_CombiEditMenuRedirect:
	set	7, (UI_Request_Hi:16)                               ; FBEED9  f1 71 20 bf
	ld (UI_Request:16), 0x34                                 ; FBEEDD  f1 70 20 00 34
	ret                                                  ; FBEEE2  0e
T_F41A0C_Nop:
	ret                                                  ; FBEEE3  0e
T_F41A10_Nop:
	ret                                                  ; FBEEE4  0e
T_F41A14_Nop:
	ret                                                  ; FBEEE5  0e
; ScreenEnter_CombiEditDspEffect: the +0 ENTER method of the screen object for screen id 0x39 -- PanelScreen_VtableTable entry 0x59
;   (ViewB entry 0x39) points at the thunk triple starting at T_ScreenEnter_CombiEditDspEffect, and slot T_ScreenEnter_CombiEditDspEffect jumps here.
; ScreenEnter_CombiEditDspEffect: screen 0x39's +0 ENTER.  0x39 is the DSP EFFECT page of the COMBINATION EDIT group
;   (0x34-0x3A): it calls T_ScreenEnterBody_DspEffect, the enter code of DSP EFFECT (screen 0x66, Screen_DspEffect_Enter), and its button
;   method calls T_ScreenButtonBody_DspEffect as Screen_DspEffect_Button does (2026-10-04).
ScreenEnter_CombiEditDspEffect:
	call T_ScreenEnterBody_DspEffect                                        ; FBEEE6  1d 4c 2f f4
	ret                                                  ; FBEEEA  0e
T_F41A6C_Nop:
	ret                                                  ; FBEEEB  0e
; ScreenButton_CombiEditDspEffect: the +8 BUTTON method of the screen object for screen id 0x39 -- PanelScreen_VtableTable entry 0x59
;   (ViewB entry 0x39) points at the thunk triple starting at T_ScreenEnter_CombiEditDspEffect, and slot T_ScreenButton_CombiEditDspEffect jumps here.
ScreenButton_CombiEditDspEffect:
	link XIZ,0x0000                                      ; FBEEEC  ee 0c 00 00
	pushw hl                                             ; FBEEF0  2b
	ld HL,(XIZ+0x08)                                     ; FBEEF1  9e 08 23
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBEEF4  c1 7f 27 3f 01
	jr nz, .LFBEF03                                      ; FBEEF9  6e 08
	cp HL,0x001e                                         ; FBEEFB  db cf 1e 00
	jr nz, .LFBEF17                                      ; FBEEFF  6e 16
	jr .LFBEF09                                          ; FBEF01  68 06
.LFBEF03:
	cp HL,0x001e                                         ; FBEF03  db cf 1e 00
	jr nz, .LFBEF0E                                      ; FBEF07  6e 05
.LFBEF09:
	calr CompareKey_CombiEdit                                      ; FBEF09  1e b2 fe
	jr .LFBEF17                                          ; FBEF0C  68 09
.LFBEF0E:
	pushw	(xiz+10)                                     ; FBEF0E  9e 0a 04
	pushw hl                                             ; FBEF11  2b
	call T_ScreenButtonBody_DspEffect                                        ; FBEF12  1d 50 2f f4
	pop XIY                                              ; FBEF16  5d
.LFBEF17:
	popw hl                                              ; FBEF17  4b
	unlk XIZ                                             ; FBEF18  ee 0d
	ret                                                  ; FBEF1A  0e
T_F41A74_Nop:
	ret                                                  ; FBEF1B  0e
; ---------------------------------------------------------------------
; Screen_CombinationNaming_Enter -- the Enter method of the COMBINATION NAMING screen: sets
;                                   the screen's paint state and calls its painter
;
; Evidence: PanelScreen_VtableTable's entry for screen 92 -- the .long
;           at 0xF87031, which this listing annotates `[60]` because the
;           index comment restarts at PanelScreen_VtableTable_ViewB, 32
;           entries in -- holds 0xF41A98, and prom_b's three consecutive
;           `jp` at 0xF41A98, 0xF41A9C and 0xF41AA0 reach 0xFBEF1C,
;           0xFBEF75 and 0xFBEF76. The +0 Enter / +4 Leave / +8 Button
;           reading is that table's own documented one, established in
;           this listing from three different call sites (checks V1-V6).
;           The SCREEN's name is not invented here: its Enter method
;           calls 0xFBEF6E `calr Paint_CombinationNaming`, and round 7
;           named that painter from the screen's own display-list text,
;           "COMBINATION NAMING". This is the +0 slot.
; Unknown:  what the state bytes it writes before painting mean.
;           (0x2075), (0x209B), (0x209C) and the (0x2095) & 0x10 test
;           guarding the painter call are shared by all five Enter
;           methods and named by nothing in this tree
; Was `sub_FBEF1C`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
Screen_CombinationNaming_Enter:
	cp	(UI_ScreenStage:16), 0x01                            ; FBEF1C  c1 7e 20 3f 01
	jr nz, .LFBEF2E                                      ; FBEF21  6e 0b
	set	1, (UI_Request_Hi:16)                               ; FBEF23  f1 71 20 b9
	ld (UI_Request:16), 0x02                                 ; FBEF27  f1 70 20 00 02
	jr .LFBEF74                                          ; FBEF2C  68 46
.LFBEF2E:
	ld c, (UI_ScreenLatch:16)                                   ; FBEF2E  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FBEF32  c1 7b 20 f3
	jr z, .LFBEF4E                                       ; FBEF36  66 16
	cp	(UI_ScreenId_Previous:16), 0x36                            ; FBEF38  c1 7d 20 3f 36
	jr z, .LFBEF4E                                       ; FBEF3D  66 0f
	pushw 0x01                                           ; FBEF3F  0b 01 00
	pushw 0x98                                           ; FBEF42  0b 98 00
	call T_IndexedTable_GetByte                          ; FBEF45  1d 90 2c f4
	ld (0x276e:16), a                                   ; FBEF49  f1 6e 27 41
	pop XIY                                              ; FBEF4D  5d
.LFBEF4E:
	ld (UI_ScreenStage:16), 0x00                                 ; FBEF4E  f1 7e 20 00 00
	set	0, (UI_RequestBits:16)                               ; FBEF53  f1 75 20 b8
	ld (PanelDial_UpButton:16), 0x0a                                 ; FBEF57  f1 9c 20 00 0a
	ld (PanelDial_DownButton:16), 0x0b                                 ; FBEF5C  f1 9b 20 00 0b
	ld c, (UI_ScreenFlags:16)                                   ; FBEF61  c1 95 20 23
	and C,0x10                                           ; FBEF65  cb cc 10
	jr nz, .LFBEF71                                      ; FBEF68  6e 07
	call T_CallbackQueue_ResetAndRestartTask2            ; FBEF6A  1d 80 2e f4
	calr Paint_CombinationNaming                                      ; FBEF6E  1e 7d 01
.LFBEF71:
	calr CombinationNaming_DrawNamesAndNumber                                      ; FBEF71  1e 96 01
.LFBEF74:
	ret                                                  ; FBEF74  0e
; ---------------------------------------------------------------------
; Screen_CombinationNaming_Leave -- the Leave method of the COMBINATION NAMING screen
;
; Evidence: PanelScreen_VtableTable's entry for screen 92 -- the .long
;           at 0xF87031, which this listing annotates `[60]` because the
;           index comment restarts at PanelScreen_VtableTable_ViewB, 32
;           entries in -- holds 0xF41A98, and prom_b's three consecutive
;           `jp` at 0xF41A98, 0xF41A9C and 0xF41AA0 reach 0xFBEF1C,
;           0xFBEF75 and 0xFBEF76. The +0 Enter / +4 Leave / +8 Button
;           reading is that table's own documented one, established in
;           this listing from three different call sites (checks V1-V6).
;           The SCREEN's name is not invented here: its Enter method
;           calls 0xFBEF6E `calr Paint_CombinationNaming`, and round 7
;           named that painter from the screen's own display-list text,
;           "COMBINATION NAMING". This is the +4 slot, and its body is a
;           bare `ret`.
; Unknown:  nothing here says why this screen needs no teardown
; Was `sub_FBEF75`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
Screen_CombinationNaming_Leave:
	ret                                                  ; FBEF75  0e
; ---------------------------------------------------------------------
; Screen_CombinationNaming_Button -- the Button method of the COMBINATION NAMING screen:
;                                    dispatches through a 23-entry table of handlers (NOT 32 -- see the note below)
;
; Evidence: PanelScreen_VtableTable's entry for screen 92 -- the .long
;           at 0xF87031, which this listing annotates `[60]` because the
;           index comment restarts at PanelScreen_VtableTable_ViewB, 32
;           entries in -- holds 0xF41A98, and prom_b's three consecutive
;           `jp` at 0xF41A98, 0xF41A9C and 0xF41AA0 reach 0xFBEF1C,
;           0xFBEF75 and 0xFBEF76. The +0 Enter / +4 Leave / +8 Button
;           reading is that table's own documented one, established in
;           this listing from three different call sites (checks V1-V6).
;           The SCREEN's name is not invented here: its Enter method
;           calls 0xFBEF6E `calr Paint_CombinationNaming`, and round 7
;           named that painter from the screen's own display-list text,
;           "COMBINATION NAMING". This is the +8 slot; 0xFBEF9C `add
;           XWA,0x00F1B14B` indexes its own handler table after `mul
;           A,0x04`, which is the four-byte stride of a 32-entry button
;           table -- the shape notes/prom_b_entrypoints_round7.py
;           establishes for every +8 method.
; Unknown:  which button is which. The index arrives from prom_b
;           0xF42C74 and no reader in prom_a bounds it; round 7's two
;           independent five-bit masks are what make it 32
; Was `sub_FBEF76`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
Screen_CombinationNaming_Button:
	link XIZ,0x0000                                      ; FBEF76  ee 0c 00 00
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBEF7A  c1 7f 27 3f 01
	jr nz, .LFBEF8D                                      ; FBEF7F  6e 0c
	cpw	(xiz+8), 0x001e                              ; FBEF81  9e 08 3f 1e 00
	jr nz, .LFBEFAD                                      ; FBEF86  6e 25
	calr CompareKey_CombiEdit                                      ; FBEF88  1e 33 fe
	jr .LFBEFAD                                          ; FBEF8B  68 20
.LFBEF8D:
	pushw	(xiz+10)                                     ; FBEF8D  9e 0a 04
	pushw	(xiz+8)                                      ; FBEF90  9e 08 04
	call T_PanelCode_ToSlotAndFlags                                        ; FBEF93  1d 74 2c f4
	mul A,0x04                                           ; FBEF97  c9 08 04
	extz XWA                                             ; FBEF9A  e8 12
	add XWA,ScreenButtons_CombinationNaming                              ; FBEF9C  e8 c8 4b b1 f1 00
	ld XBC,(XWA)                                         ; FBEFA2  a0 21
	lda xiy, (.LFBEFAC:24)                               ; FBEFA4  f2 ac ef fb 35
	push XIY                                             ; FBEFA9  3d
	jp (xbc)                                             ; FBEFAA  b1 d8
.LFBEFAC:
	pop XIY                                              ; FBEFAC  5d
.LFBEFAD:
	unlk XIZ                                             ; FBEFAD  ee 0d
	ret                                                  ; FBEFAF  0e
T_F41AA4_Nop:
	ret                                                  ; FBEFB0  0e
; LcdKeyRow1_CombinationNaming: ScreenButtons_CombinationNaming[8], the 23-slot button table Screen_CombinationNaming_Button reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow1 handler of CombinationNaming (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow1_CombinationNaming:
	ld c, (PanelEvent_Flags:16)                                   ; FBEFB1  c1 b0 28 23
	and C,0x01                                           ; FBEFB5  cb cc 01
	jr z, .LFBEFD1                                       ; FBEFB8  66 17
	ld c, (0x7fd6:16)                                   ; FBEFBA  c1 d6 7f 23
	and C,0x02                                           ; FBEFBE  cb cc 02
	jr z, .LFBEFCE                                       ; FBEFC1  66 0b
	set	6, (UI_Request_Hi:16)                               ; FBEFC3  f1 71 20 be
	ld (UI_Request:16), 0xb3                                 ; FBEFC7  f1 70 20 00 b3
	jr .LFBEFD1                                          ; FBEFCC  68 03
.LFBEFCE:
	calr CombinationNaming_WriteToUserMemory                                      ; FBEFCE  1e 69 00
.LFBEFD1:
	ret                                                  ; FBEFD1  0e
; LcdKeyRow3_CombinationNaming: ScreenButtons_CombinationNaming[10], the 23-slot button table Screen_CombinationNaming_Button reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow3 handler of CombinationNaming (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow3_CombinationNaming:
	push XIX                                             ; FBEFD2  3c
	lda xix, (PanelEvent_Flags:16)                                ; FBEFD3  f1 b0 28 34
	ld C,(XIX)                                           ; FBEFD7  84 23
	and C,0x01                                           ; FBEFD9  cb cc 01
	jr nz, .LFBEFE4                                      ; FBEFDC  6e 06
	and (XIX),0xfe                                       ; FBEFDE  84 3c fe
	calr CombinationNaming_StepWriteNumber                                      ; FBEFE1  1e 3c 00
.LFBEFE4:
	pop XIX                                              ; FBEFE4  5c
	ret                                                  ; FBEFE5  0e
; LcdKeyRow4_CombinationNaming: ScreenButtons_CombinationNaming[11], the 23-slot button table Screen_CombinationNaming_Button reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow4 handler of CombinationNaming (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow4_CombinationNaming:
	push XIX                                             ; FBEFE6  3c
	lda xix, (PanelEvent_Flags:16)                                ; FBEFE7  f1 b0 28 34
	ld C,(XIX)                                           ; FBEFEB  84 23
	and C,0x01                                           ; FBEFED  cb cc 01
	jr nz, .LFBEFF8                                      ; FBEFF0  6e 06
	or	(xix), 0x01                                  ; FBEFF2  84 3e 01
	calr CombinationNaming_StepWriteNumber                                      ; FBEFF5  1e 28 00
.LFBEFF8:
	pop XIX                                              ; FBEFF8  5c
	ret                                                  ; FBEFF9  0e
; LcdKeyRow5_CombinationNaming: ScreenButtons_CombinationNaming[12], the 23-slot button table Screen_CombinationNaming_Button reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow5 handler of CombinationNaming (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow5_CombinationNaming:
	ld c, (PanelEvent_Flags:16)                                   ; FBEFFA  c1 b0 28 23
	and C,0x01                                           ; FBEFFE  cb cc 01
	jr nz, .LFBF00C                                      ; FBF001  6e 09
	set	7, (UI_Request_Hi:16)                               ; FBF003  f1 71 20 bf
	ld (UI_Request:16), 0x36                                 ; FBF007  f1 70 20 00 36
.LFBF00C:
	ret                                                  ; FBF00C  0e
; ExitKey_CombinationNaming: ScreenButtons_CombinationNaming[15], the 23-slot button table Screen_CombinationNaming_Button reads through T_PanelCode_ToSlotAndFlags -- the
;   ExitKey handler of CombinationNaming (notes/prom_ab_promb_slot23_targets.py).
ExitKey_CombinationNaming:
	ld c, (PanelEvent_Flags:16)                                   ; FBF00D  c1 b0 28 23
	and C,0x01                                           ; FBF011  cb cc 01
	jr nz, .LFBF01F                                      ; FBF014  6e 09
	set	7, (UI_Request_Hi:16)                               ; FBF016  f1 71 20 bf
	ld (UI_Request:16), 0x33                                 ; FBF01A  f1 70 20 00 33
.LFBF01F:
	ret                                                  ; FBF01F  0e
; CombinationNaming_StepWriteNumber: EditValue_StepBitField((0x276E), Record_F1B1A7: mask 0x7F, 0..127): steps the
;   USER combination number the screen writes to, up or down by PanelEvent_Flags bit 0; if it moved, UI_ScreenFlags
;   bit 4 (repaint). LcdKeyRow3 (bit 0 cleared) and LcdKeyRow4 (bit 0 set) of COMBINATION NAMING; CombinationNaming_WriteToUserMemory writes
;   Combination_Current to 0xEC0300 + n*0x2C0. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_g.json)
CombinationNaming_StepWriteNumber:
	lda xbc, (Record_F1B1A7:24)                          ; FBF020  f2 a7 b1 f1 31
	push XBC                                             ; FBF025  39
	lda xwa, (0x276e:16)                                ; FBF026  f1 6e 27 30
	push XWA                                             ; FBF02A  38
	call T_EditValue_StepBitField                                        ; FBF02B  1d 78 2c f4
	inc 8,XSP                                            ; FBF02F  ef 60
	cp a, 0x01:i3                                          ; FBF031  c9 d9
	jr nz, .LFBF039                                      ; FBF033  6e 04
	set	4, (UI_ScreenFlags:16)                               ; FBF035  f1 95 20 bc
.LFBF039:
	ret                                                  ; FBF039  0e
; CombinationNaming_WriteToUserMemory: COMBINATION NAMING's WRITE: status 0x25 painted, then Combination_Current
;   (0x2C0 bytes) sent to CPU 2 at USER combination n = (0x276E), 0xEC0300 + n x 0x2C0 (Link_SendCommand3 / E4 / 5);
;   USER n selected ((0x60F189) = n, bank 8, CombiSel_GroupMemberFromNumberAndBank, two 0x98 events to List2030);
;   status 0x23, UI_Request 0xAB. LcdKeyRow1 when (0x7FD6) bit 1 is clear; panel twin of
;   SysExParam_SetCombinationWriteRequest. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
CombinationNaming_WriteToUserMemory:
	link XIZ,0xfff8                                      ; FBF03A  ee 0c f8 ff
	push XIX                                             ; FBF03E  3c
	lda xix, (0x60f18d:24)                               ; FBF03F  f2 8d f1 60 34
	ld (UI_StatusCode:16), 0x25                                 ; FBF044  f1 80 28 00 25
	push XDE                                             ; FBF049  3a
	push XHL                                             ; FBF04A  3b
	push XIX                                             ; FBF04B  3c
	push XIZ                                             ; FBF04C  3e
	call T_MessageScreen_Paint                                        ; FBF04D  1d 00 16 f4
	pop XIZ                                              ; FBF051  5e
	pop XIX                                              ; FBF052  5c
	pop XHL                                              ; FBF053  5b
	pop XDE                                              ; FBF054  5a
	ld (0x7659:16), 0x00                                 ; FBF055  f1 59 76 00 00
	ld (0x7679:16), 0x00                                 ; FBF05A  f1 79 76 00 00
	ld (0x7699:16), 0x00                                 ; FBF05F  f1 99 76 00 00
	ld XBC,0x00ec0300                                    ; FBF064  41 00 03 ec 00
	ld (xiz-4), xbc                                      ; FBF069  be fc 61
	ld wa, (0x276e:16)                                 ; FBF06C  d1 6e 27 20
	extz WA                                              ; FBF070  d8 12
	mul WA,0x02c0                                        ; FBF072  d8 08 c0 02
	add XBC,XWA                                          ; FBF076  e8 81
	ld (xiz-8), xbc                                      ; FBF078  be f8 61
	push XBC                                             ; FBF07B  39
	call T_Link_SendCommand3_WaitTicks                                        ; FBF07C  1d 34 12 f4
	ld xbc, (xiz-8)                                      ; FBF080  ae f8 21
	push XBC                                             ; FBF083  39
	pushw 0x02c0                                         ; FBF084  0b c0 02
	lda xwa, (Combination_Current:16)                                ; FBF087  f1 20 76 30
	push XWA                                             ; FBF08B  38
	call T_Link_SendCommandE4                            ; FBF08C  1d 30 12 f4
	ld xbc, (xiz-8)                                      ; FBF090  ae f8 21
	push XBC                                             ; FBF093  39
	call T_Link_SendCommand5_WaitDone                    ; FBF094  1d 38 12 f4
	ld	(0x60f189:24), (0x276e)                      ; FBF098  f2 89 f1 60 14 6e 27
	ld (0x60f18a:24), 0x08                             ; FBF09F  f2 8a f1 60 00 08
	ld (0x60f180:24), 0x98                             ; FBF0A5  f2 80 f1 60 00 98
	call T_CombiSel_GroupMemberFromNumberAndBank                                        ; FBF0AB  1d 08 08 f4
	pushw 0x7f                                           ; FBF0AF  0b 7f 00
	ld C,(XIX+0x02)                                      ; FBF0B2  8c 02 23
	pushw bc                                             ; FBF0B5  29
	pushw 0x01                                           ; FBF0B6  0b 01 00
	pushw 0x98                                           ; FBF0B9  0b 98 00
	call T_List2030_Append4                              ; FBF0BC  1d 88 2c f4
	ld C,(XIX+0x01)                                      ; FBF0C0  8c 01 23
	pushw bc                                             ; FBF0C3  29
	ld C,(XIX)                                           ; FBF0C4  84 23
	pushw bc                                             ; FBF0C6  29
	pushw 0x01                                           ; FBF0C7  0b 01 00
	pushw 0x98                                           ; FBF0CA  0b 98 00
	call T_List2030_Append4                              ; FBF0CD  1d 88 2c f4
	ld (UI_StatusCode:16), 0x23                                 ; FBF0D1  f1 80 28 00 23
	set	6, (UI_Request_Hi:16)                               ; FBF0D6  f1 71 20 be
	ld (UI_Request:16), 0xab                                 ; FBF0DA  f1 70 20 00 ab
	ld (UI_ScreenStage:16), 0x01                                 ; FBF0DF  f1 7e 20 00 01
	add XSP,0x00000022                                   ; FBF0E4  ef c8 22 00 00 00
	pop XIX                                              ; FBF0EA  5c
	unlk XIZ                                             ; FBF0EB  ee 0d
	ret                                                  ; FBF0ED  0e
; ---------------------------------------------------------------------
; Paint_CombinationNaming -- paints the screen whose own text reads "COMBINATION NAMING" / "MEM0RY WRITE"
;
; Called from: prom_a Screen_CombinationNaming_Enter (`calr`) at 0xFBEF6E
;
; It hands 1 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xFBF0F7  list 0xF19ABF-0xF19BBD (254 B, leaves by call)
;        text: "MEM0RY WRITE"; "COMBI.EDIT"; "NAME:"; "MEMORY BANK:U1-"; ...
; From the captions: "COMBINATION NAMING"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_CombinationNaming:
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; FBF0EE  1d 10 2e f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBF0F2  f1 40 25 00 02
	lda xbc, (DL_F19BBD:24)                              ; FBF0F7  f2 bd 9b f1 31
	push XBC                                             ; FBF0FC  39
	lda xwa, (DL_CombinationNaming_F19ABF:24)            ; FBF0FD  f2 bf 9a f1 30
	push XWA                                             ; FBF102  38
	call T_DisplayList_Run_Stack                         ; FBF103  1d 00 2e f4
	inc 8,XSP                                            ; FBF107  ef 60
	ret                                                  ; FBF109  0e
; CombinationNaming_DrawNamesAndNumber: Reads USER combination n's 16-character name (T_CombiName_Lookup, bank 8, n =
;   (0x276E)) into UI_DrawScratch, n + 1 into UI_DrawScratch+16, and runs DL_F19BBD: the current combination's text at
;   Combination_Current+2, the destination number and the destination name, then shows all layers. Last step of
;   Screen_CombinationNaming_Enter. Basis: caller + body + the display list. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
CombinationNaming_DrawNamesAndNumber:
	link XIZ,0xfffc                                      ; FBF10A  ee 0c fc ff
	pushw hl                                             ; FBF10E  2b
	push XIX                                             ; FBF10F  3c
	ld (UI_DrawScratch:16), 0x08                                 ; FBF110  f1 40 26 00 08
	ld	(UI_DrawScratch+1:16), (0x276e:16)             ; FBF115  c1 6e 27 19 41 26
	ld (UI_DrawScratch+2:16), 0x98                                 ; FBF11B  f1 42 26 00 98
	push XDE                                             ; FBF120  3a
	push XHL                                             ; FBF121  3b
	push XIX                                             ; FBF122  3c
	push XIZ                                             ; FBF123  3e
	ld w, (UI_DrawScratch:16)                                   ; FBF124  c1 40 26 20
	ld a, (UI_DrawScratch+1:16)                                   ; FBF128  c1 41 26 21
	ld b, (UI_DrawScratch+2:16)                                   ; FBF12C  c1 42 26 22
	call T_CombiName_Lookup                                        ; FBF130  1d 2c 10 f4
	ld (UI_DrawScratch:16), xiy                                 ; FBF134  f1 40 26 65
	pop XIZ                                              ; FBF138  5e
	pop XIX                                              ; FBF139  5c
	pop XHL                                              ; FBF13A  5b
	pop XDE                                              ; FBF13B  5a
	lda xbc, (UI_DrawScratch:16)                                ; FBF13C  f1 40 26 31
	ld (xiz-4), xbc                                      ; FBF140  be fc 61
	ld xwa, (UI_DrawScratch:16)                                 ; FBF143  e1 40 26 20
	ld XIX,XWA                                           ; FBF147  e8 8c
	ld h, 0x04:opc                                          ; FBF149  26 04
.LFBF14B:
	ld XBC,(XIX)                                         ; FBF14B  a4 21
	ld xwa, (xiz-4)                                      ; FBF14D  ae fc 20
	ld (XWA),XBC                                         ; FBF150  b0 61
	inc 4,XIX                                            ; FBF152  ec 64
	sub XBC,XBC                                          ; FBF154  e9 a1
	inc 4,XBC                                            ; FBF156  e9 64
	add (xiz-4), xbc                                     ; FBF158  ae fc 89
	dec 1,H                                              ; FBF15B  ce 69
	cp h, 0x00:i3                                          ; FBF15D  ce d8
	jr nz, .LFBF14B                                      ; FBF15F  6e ea
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBF161  f1 40 25 00 00
	ld a, (0x276e:16)                                   ; FBF166  c1 6e 27 21
	inc 1,A                                              ; FBF16A  c9 61
	ld (UI_DrawScratch+16:16), a                                   ; FBF16C  f1 50 26 41
	lda xwa, (DL_CombinationNaming_F19BE5:24)            ; FBF170  f2 e5 9b f1 30
	push XWA                                             ; FBF175  38
	lda xiy, (DL_F19BBD:24)                              ; FBF176  f2 bd 9b f1 35
	push XIY                                             ; FBF17B  3d
	call T_DisplayListB_Run_Stack                        ; FBF17C  1d 04 2e f4
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; FBF180  1d 14 2e f4
	inc 8,XSP                                            ; FBF184  ef 60
	pop XIX                                              ; FBF186  5c
	popw hl                                              ; FBF187  4b
	unlk XIZ                                             ; FBF188  ee 0d
	ret                                                  ; FBF18A  0e
ScreenEnterBody_CombinationNaming:
	link XIZ,0xfffc                                      ; FBF18B  ee 0c fc ff
	pushw hl                                             ; FBF18F  2b
	push XIX                                             ; FBF190  3c
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBF191  c1 7f 27 3f 01
	jr nz, .LFBF1BE                                      ; FBF196  6e 26
	lda xbc, (DiskSave_PasswordEntry:16)                                ; FBF198  f1 f0 22 31
	ld (xiz-4), xbc                                      ; FBF19C  be fc 61
	ldw wa, CombiEdit_CompareEdited                                       ; FBF19F  30 00 1d
	inc 2,WA                                             ; FBF1A2  d8 62
	extz XWA                                             ; FBF1A4  e8 12
	ld XIX,XWA                                           ; FBF1A6  e8 8c
	ld h, 0x10:opc                                          ; FBF1A8  26 10
.LFBF1AA:
	ld xbc, (xiz-4)                                      ; FBF1AA  ae fc 21
	ld A,(XBC)                                           ; FBF1AD  81 21
	ld (XIX),A                                           ; FBF1AF  b4 41
	sub XBC,XBC                                          ; FBF1B1  e9 a1
	inc 1,XBC                                            ; FBF1B3  e9 61
	add (xiz-4), xbc                                     ; FBF1B5  ae fc 89
	add XIX,XBC                                          ; FBF1B8  e9 84
	sub H,C                                              ; FBF1BA  cb a6
	jr nz, .LFBF1AA                                      ; FBF1BC  6e ec
.LFBF1BE:
	lda xbc, (DiskSave_PasswordEntry:16)                                ; FBF1BE  f1 f0 22 31
	ld (xiz-4), xbc                                      ; FBF1C2  be fc 61
	lda xix, (0x7622:16)                                ; FBF1C5  f1 22 76 34
	ld h, 0x10:opc                                          ; FBF1C9  26 10
.LFBF1CB:
	ld C,(XIX)                                           ; FBF1CB  84 23
	ld L,C                                               ; FBF1CD  cb 8f
	ld xbc, (xiz-4)                                      ; FBF1CF  ae fc 21
	ld (XBC),L                                           ; FBF1D2  b1 47
	sub XBC,XBC                                          ; FBF1D4  e9 a1
	inc 1,XBC                                            ; FBF1D6  e9 61
	add (xiz-4), xbc                                     ; FBF1D8  ae fc 89
	add XIX,XBC                                          ; FBF1DB  e9 84
	sub H,C                                              ; FBF1DD  cb a6
	jr nz, .LFBF1CB                                      ; FBF1DF  6e ea
	ld a, (UI_ScreenId:16)                                   ; FBF1E1  c1 7c 20 21
	cp	a, (UI_ScreenId_Previous:16)                               ; FBF1E5  c1 7d 20 f1
	jr z, .LFBF1EF                                       ; FBF1E9  66 04
	call T_CallbackQueue_ResetAndRestartTask2            ; FBF1EB  1d 80 2e f4
.LFBF1EF:
	pushw 0x10                                           ; FBF1EF  0b 10 00
	call T_NameEntry_Begin                                        ; FBF1F2  1d 80 2f f4
	calr Paint_CombinationNamingWrite                                      ; FBF1F6  1e c9 00
	popw bc                                              ; FBF1F9  49
	pop XIX                                              ; FBF1FA  5c
	popw hl                                              ; FBF1FB  4b
	unlk XIZ                                             ; FBF1FC  ee 0d
	ret                                                  ; FBF1FE  0e
ScreenLeaveBody_CombinationNaming:
	link XIZ,0xfffc                                      ; FBF1FF  ee 0c fc ff
	pushw hl                                             ; FBF203  2b
	push XIX                                             ; FBF204  3c
	ld c, (UI_ScreenLatch:16)                                   ; FBF205  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FBF209  c1 7b 20 f3
	jr z, .LFBF230                                       ; FBF20D  66 21
	lda xbc, (DiskSave_PasswordEntry:16)                                ; FBF20F  f1 f0 22 31
	ld (xiz-4), xbc                                      ; FBF213  be fc 61
	lda xix, (0x7622:16)                                ; FBF216  f1 22 76 34
	ld h, 0x10:opc                                          ; FBF21A  26 10
.LFBF21C:
	ld xbc, (xiz-4)                                      ; FBF21C  ae fc 21
	ld A,(XBC)                                           ; FBF21F  81 21
	ld (XIX),A                                           ; FBF221  b4 41
	sub XBC,XBC                                          ; FBF223  e9 a1
	inc 1,XBC                                            ; FBF225  e9 61
	add (xiz-4), xbc                                     ; FBF227  ae fc 89
	add XIX,XBC                                          ; FBF22A  e9 84
	sub H,C                                              ; FBF22C  cb a6
	jr nz, .LFBF21C                                      ; FBF22E  6e ec
.LFBF230:
	pop XIX                                              ; FBF230  5c
	popw hl                                              ; FBF231  4b
	unlk XIZ                                             ; FBF232  ee 0d
	ret                                                  ; FBF234  0e
; CombinationNamingWrite_NoAction: the bare `ret` that 12 of ScreenButtons_CombinationNamingWrite's 32 slots name -- a control with nothing
;   to do on screen 0x36.
CombinationNamingWrite_NoAction:
	ret                                                  ; FBF235  0e
ScreenButtonBody_CombinationNaming:
	link XIZ,0x0000                                      ; FBF236  ee 0c 00 00
	pushw hl                                             ; FBF23A  2b
	ld HL,(XIZ+0x08)                                     ; FBF23B  9e 08 23
	cp HL,0x001f                                         ; FBF23E  db cf 1f 00
	jr ugt, .LFBF26F                                     ; FBF242  6b 2b
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBF244  c1 7f 27 3f 01
	jr nz, .LFBF256                                      ; FBF249  6e 0b
	cp HL,0x001e                                         ; FBF24B  db cf 1e 00
	jr nz, .LFBF26F                                      ; FBF24F  6e 1e
	calr CompareKey_CombiEdit                                      ; FBF251  1e 6a fb
	jr .LFBF26F                                          ; FBF254  68 19
.LFBF256:
	pushw	(xiz+10)                                     ; FBF256  9e 0a 04
	ldw bc, 0x04                                         ; FBF259  31 04 00
	mul xbc, hl                                         ; FBF25C  db 41
	add XBC,ScreenButtons_CombinationNamingWrite                              ; FBF25E  e9 c8 b0 b1 f1 00
	ld XBC,(XBC)                                         ; FBF264  a1 21
	lda xiy, (.LFBF26E:24)                               ; FBF266  f2 6e f2 fb 35
	push XIY                                             ; FBF26B  3d
	jp (xbc)                                             ; FBF26C  b1 d8
.LFBF26E:
	popw bc                                              ; FBF26E  49
.LFBF26F:
	popw hl                                              ; FBF26F  4b
	unlk XIZ                                             ; FBF270  ee 0d
	ret                                                  ; FBF272  0e
	ret                                                  ; FBF273  0e
; LcdKeyRow1_CombinationNamingWrite: ScreenButtons_CombinationNamingWrite[8] -- the LcdKeyRow1 handler of screen 0x36, the COMBINATION NAMING page
;   reached from COMBI.EDIT WRITE (Paint_CombinationNamingWrite).  The table is indexed by the raw button code
;   (ScreenButtonBody_CombinationNaming: `cp HL,0x1F`, then `mul XBC,HL` by 4).  Screen 0x3C, the other COMBINATION
;   NAMING, has its own <Control>_CombinationNaming handlers.
LcdKeyRow1_CombinationNamingWrite:
	link XIZ,0x0000                                      ; FBF274  ee 0c 00 00
	cpw	(xiz+8), 0x0000                              ; FBF278  9e 08 3f 00 00
	jr z, .LFBF28A                                       ; FBF27D  66 0b
	set	7, (UI_Request_Hi:16)                               ; FBF27F  f1 71 20 bf
	ld (UI_Request:16), 0x3c                                 ; FBF283  f1 70 20 00 3c
	jr .LFBF292                                          ; FBF288  68 08
.LFBF28A:
	pushw	(xiz+8)                                      ; FBF28A  9e 08 04
	call T_SoundEditNaming_LcdKeyRow1                                        ; FBF28D  1d a4 2f f4
	popw bc                                              ; FBF291  49
.LFBF292:
	unlk XIZ                                             ; FBF292  ee 0d
	ret                                                  ; FBF294  0e
; LcdKeyRow2_CombinationNamingWrite: ScreenButtons_CombinationNamingWrite[9] -- the LcdKeyRow2 handler of screen 0x36 (see LcdKeyRow1_CombinationNamingWrite).
LcdKeyRow2_CombinationNamingWrite:
	link XIZ,0x0000                                      ; FBF295  ee 0c 00 00
	cpw	(xiz+8), 0x0000                              ; FBF299  9e 08 3f 00 00
	jr nz, .LFBF2A8                                      ; FBF29E  6e 08
	pushw	(xiz+8)                                      ; FBF2A0  9e 08 04
	call T_SoundEditNaming_LcdKeyRow2                                        ; FBF2A3  1d a8 2f f4
	popw bc                                              ; FBF2A7  49
.LFBF2A8:
	unlk XIZ                                             ; FBF2A8  ee 0d
	ret                                                  ; FBF2AA  0e
; ExitKey_CombinationNamingWrite: ScreenButtons_CombinationNamingWrite[15] -- the EXIT handler of screen 0x36 (see LcdKeyRow1_CombinationNamingWrite).
ExitKey_CombinationNamingWrite:
	link XIZ,0x0000                                      ; FBF2AB  ee 0c 00 00
	cpw	(xiz+8), 0x0000                              ; FBF2AF  9e 08 3f 00 00
	jr nz, .LFBF2BF                                      ; FBF2B4  6e 09
	set	7, (UI_Request_Hi:16)                               ; FBF2B6  f1 71 20 bf
	ld (UI_Request:16), 0x3c                                 ; FBF2BA  f1 70 20 00 3c
.LFBF2BF:
	unlk XIZ                                             ; FBF2BF  ee 0d
	ret                                                  ; FBF2C1  0e
; ---------------------------------------------------------------------
; Paint_CombinationNamingWrite -- paints the "COMBINATION NAMING" screen's "WRITE" state
;
; Called from: prom_a ScreenEnterBody_CombinationNaming (`calr`) at 0xFBF1F6
;
; It hands 1 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xFBF2C7  list 0xF19BE5-0xF19C39 (84 B, leaves by call)
;        text: "COMBI.EDIT"; "COMBINATION NAMING"; "WRITE"
; From the captions: "COMBINATION NAMING"; "WRITE"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_CombinationNamingWrite:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBF2C2  f1 40 25 00 02
	lda xbc, (DL_Configure_F19C39:24)                    ; FBF2C7  f2 39 9c f1 31
	push XBC                                             ; FBF2CC  39
	lda xwa, (DL_CombinationNaming_F19BE5:24)            ; FBF2CD  f2 e5 9b f1 30
	push XWA                                             ; FBF2D2  38
	call T_DisplayList_Run_Stack                         ; FBF2D3  1d 00 2e f4
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; FBF2D7  1d 14 2e f4
	inc 8,XSP                                            ; FBF2DB  ef 60
	ret                                                  ; FBF2DD  0e
ScreenEnterBody_CombiEditConfigure_Call:
	calr ScreenEnterBody_CombiEditConfigure                                      ; FBF2DE  1e 01 00
	ret                                                  ; FBF2E1  0e
; ScreenEnterBody_CombiEditConfigure: the shared enter body of screens 0x35 and 0xB2.  The painters it posts draw
;   DL_Configure_F19C39 / _F19D5C ("CONFIGURE", "COMBI.EDIT", "SOLO:", "PART", "ASIGN:", "KEY:") and DL_KeyLayer ("KEY LAYER",
;   "LOW", "HIGH") -- the COMBINATION EDIT CONFIGURE page (2026-10-04).
ScreenEnterBody_CombiEditConfigure:
	pushw hl                                             ; FBF2E2  2b
	push XIX                                             ; FBF2E3  3c
	lda xix, (0x2768:16)                                ; FBF2E4  f1 68 27 34
	cp	(PanelModeGroup:16), 0x16                            ; FBF2E8  c1 76 20 3f 16
	jr nz, .LFBF305                                      ; FBF2ED  6e 16
	ld h, (UI_PartIndex:16)                                   ; FBF2EF  c1 50 22 26
	cp H,0x08                                            ; FBF2F3  ce cf 08
	jr c, .LFBF305                                       ; FBF2F6  67 0d
	ld C,H                                               ; FBF2F8  ce 8b
	and C,0x07                                           ; FBF2FA  cb cc 07
	ld (UI_PartIndex:16), c                                   ; FBF2FD  f1 50 22 43
	call T_PartIndex_PostChangeEvent                                        ; FBF301  1d 9c 2c f4
.LFBF305:
	calr CombiEdit_TakePartIndex                                          ; FBF305  1e a9 d9
	ld c, (UI_ScreenLatch:16)                                   ; FBF308  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FBF30C  c1 7b 20 f3
	jr z, .LFBF350                                       ; FBF310  66 3e
	cp	(PanelModeGroup:16), 0x12                            ; FBF312  c1 76 20 3f 12
	jr nz, .LFBF329                                      ; FBF317  6e 10
	ld h, (UI_PartIndex:16)                                   ; FBF319  c1 50 22 26
	ld (CombiEdit_EntryPart:16), h                                   ; FBF31D  f1 6d 27 46
	ld (0x2766:16), h                                   ; FBF321  f1 66 27 46
	ld (CombiEdit_Part:16), h                                   ; FBF325  f1 65 27 46
.LFBF329:
	ld h, (CombiEdit_Part:16)                                   ; FBF329  c1 65 27 26
	and H,0xf8                                           ; FBF32D  ce cc f8
	ld (0x276c:16), h                                   ; FBF330  f1 6c 27 46
	ld (0x276b:16), h                                   ; FBF334  f1 6b 27 46
	ld (XIX),0x00                                        ; FBF338  b4 00 00
	ld (CombiEdit_Page:16), 0x00                                 ; FBF33B  f1 67 27 00 00
	ld (0x276a:16), 0x00                                 ; FBF340  f1 6a 27 00 00
	ld (CombiEdit_Row:16), 0x00                                 ; FBF345  f1 69 27 00 00
	ld	(0x2766:16), (CombiEdit_Part:16)             ; FBF34A  c1 65 27 19 66 27
.LFBF350:
	ld c, (UI_ScreenId:16)                                   ; FBF350  c1 7c 20 23
	cp	c, (UI_ScreenId_Previous:16)                               ; FBF354  c1 7d 20 f3
	jr z, .LFBF372                                       ; FBF358  66 18
	inc 0x01, (0x276c:16)                                ; FBF35A  c1 6c 27 61
	incm8 0x01, (xix)                                    ; FBF35E  84 61
	inc 0x01, (0x276a:16)                                ; FBF360  c1 6a 27 61
	inc 0x01, (0x2766:16)                                ; FBF364  c1 66 27 61
	ld (CombiEdit_DirtySound:16), 0xff                                 ; FBF368  f1 70 27 00 ff
	ld (0x277e:16), 0x00                                 ; FBF36D  f1 7e 27 00 00
.LFBF372:
	set	0, (UI_RequestBits:16)                               ; FBF372  f1 75 20 b8
	ld bc, (CombiEdit_Row:16)                                 ; FBF376  d1 69 27 21
	extz BC                                              ; FBF37A  d9 12
	extz XBC                                             ; FBF37C  e9 12
	add XBC,IndexMap_F1B230                              ; FBF37E  e9 c8 30 b2 f1 00
	ld H,(XBC)                                           ; FBF384  81 26
	ld A,H                                               ; FBF386  ce 89
	xor A,0x80                                           ; FBF388  c9 cd 80
	ld (PanelDial_DownButton:16), a                                   ; FBF38B  f1 9b 20 41
	ld (PanelDial_UpButton:16), h                                   ; FBF38F  f1 9c 20 46
	ld B,(XIX)                                           ; FBF393  84 22
	cp (CombiEdit_Page:16), b                                    ; FBF395  c1 67 27 fa
	jr z, .LFBF3AB                                       ; FBF399  66 10
	cp	(0x277e:16), 0x01                            ; FBF39B  c1 7e 27 3f 01
	jr nz, .LFBF3AB                                      ; FBF3A0  6e 09
	call T_CallbackQueue_ResetAndRestartTask2            ; FBF3A2  1d 80 2e f4
	ld (0x277e:16), 0x00                                 ; FBF3A6  f1 7e 27 00 00
.LFBF3AB:
	ld c, (UI_ScreenFlags:16)                                   ; FBF3AB  c1 95 20 23
	and C,0x10                                           ; FBF3AF  cb cc 10
	jr nz, .LFBF40C                                      ; FBF3B2  6e 58
	ld c, (UI_ScreenId:16)                                   ; FBF3B4  c1 7c 20 23
	cp	c, (UI_ScreenId_Previous:16)                               ; FBF3B8  c1 7d 20 f3
	jr z, .LFBF3DA                                       ; FBF3BC  66 1c
	call T_CallbackQueue_ResetAndRestartTask2            ; FBF3BE  1d 80 2e f4
	ld (0x277e:16), 0x00                                 ; FBF3C2  f1 7e 27 00 00
	lda xbc, (.LFBF6C1:24)                               ; FBF3C7  f2 c1 f6 fb 31
	push XBC                                             ; FBF3CC  39
	call T_CallbackQueue_Post                            ; FBF3CD  1d 84 2e f4
	pushw 0x01                                           ; FBF3D1  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBF3D4  1d c0 2d f4
	inc 6,XSP                                            ; FBF3D8  ef 66
.LFBF3DA:
	ld C,(XIX)                                           ; FBF3DA  84 23
	cp (CombiEdit_Page:16), c                                    ; FBF3DC  c1 67 27 fb
	jr z, .LFBF3F9                                       ; FBF3E0  66 17
	lda xbc, (.LFBF704:24)                               ; FBF3E2  f2 04 f7 fb 31
	push XBC                                             ; FBF3E7  39
	call T_CallbackQueue_Post                            ; FBF3E8  1d 84 2e f4
	pushw 0x01                                           ; FBF3EC  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBF3EF  1d c0 2d f4
	ld	(xix), (CombiEdit_Page)                              ; FBF3F3  b4 14 67 27
	inc 6,XSP                                            ; FBF3F7  ef 66
.LFBF3F9:
	lda xbc, (.LFBF807:24)                               ; FBF3F9  f2 07 f8 fb 31
	push XBC                                             ; FBF3FE  39
	call T_CallbackQueue_Post                            ; FBF3FF  1d 84 2e f4
	pushw 0x01                                           ; FBF403  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBF406  1d c0 2d f4
	inc 6,XSP                                            ; FBF40A  ef 66
.LFBF40C:
	lda xbc, (.LFBF8DE:24)                               ; FBF40C  f2 de f8 fb 31
	push XBC                                             ; FBF411  39
	call T_CallbackQueue_Post                            ; FBF412  1d 84 2e f4
	pushw 0x01                                           ; FBF416  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBF419  1d c0 2d f4
	inc 6,XSP                                            ; FBF41D  ef 66
	pop XIX                                              ; FBF41F  5c
	popw hl                                              ; FBF420  4b
	ret                                                  ; FBF421  0e
ScreenLeaveBody_CombiEditConfigure_Call:
	calr ScreenLeaveBody_CombiEditConfigure                                      ; FBF422  1e 01 00
	ret                                                  ; FBF425  0e
ScreenLeaveBody_CombiEditConfigure:
	ld c, (UI_ScreenLatch:16)                                   ; FBF426  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FBF42A  c1 7b 20 f3
	jr z, .LFBF441                                       ; FBF42E  66 11
	cp	(PanelModeGroup_Previous:16), 0x12                            ; FBF430  c1 77 20 3f 12
	jr nz, .LFBF441                                      ; FBF435  6e 0a
	ld	(UI_PartIndex:16), (CombiEdit_EntryPart:16)             ; FBF437  c1 6d 27 19 50 22
	call T_PartIndex_PostChangeEvent                                        ; FBF43D  1d 9c 2c f4
.LFBF441:
	ret                                                  ; FBF441  0e
ScreenButtonBody_CombiEditConfigure_Call:
	link XIZ,0x0000                                      ; FBF442  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBF446  9e 0a 04
	pushw	(xiz+8)                                      ; FBF449  9e 08 04
	calr ScreenButtonBody_CombiEditConfigure                                      ; FBF44C  1e 04 00
	pop XBC                                              ; FBF44F  59
	unlk XIZ                                             ; FBF450  ee 0d
	ret                                                  ; FBF452  0e
ScreenButtonBody_CombiEditConfigure:
	link XIZ,0x0000                                      ; FBF453  ee 0c 00 00
	cp	(PanelModeGroup:16), 0x16                            ; FBF457  c1 76 20 3f 16
	jr nz, .LFBF471                                      ; FBF45C  6e 13
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBF45E  c1 7f 27 3f 01
	jr nz, .LFBF471                                      ; FBF463  6e 0c
	cpw	(xiz+8), 0x001e                              ; FBF465  9e 08 3f 1e 00
	jr nz, .LFBF491                                      ; FBF46A  6e 25
	calr CompareKey_CombiEdit                                      ; FBF46C  1e 4f f9
	jr .LFBF491                                          ; FBF46F  68 20
.LFBF471:
	pushw	(xiz+10)                                     ; FBF471  9e 0a 04
	pushw	(xiz+8)                                      ; FBF474  9e 08 04
	call T_PanelCode_ToSlotAndFlags                                        ; FBF477  1d 74 2c f4
	mul A,0x04                                           ; FBF47B  c9 08 04
	extz XWA                                             ; FBF47E  e8 12
	add XWA,ScreenButtons_CombiEditConfigure                              ; FBF480  e8 c8 39 b2 f1 00
	ld XBC,(XWA)                                         ; FBF486  a0 21
	lda xiy, (.LFBF490:24)                               ; FBF488  f2 90 f4 fb 35
	push XIY                                             ; FBF48D  3d
	jp (xbc)                                             ; FBF48E  b1 d8
.LFBF490:
	pop XIY                                              ; FBF490  5d
.LFBF491:
	unlk XIZ                                             ; FBF491  ee 0d
	ret                                                  ; FBF493  0e
	calr ScreenButtonBody_CombiEditConfigure_Nop                                      ; FBF494  1e 01 00
	ret                                                  ; FBF497  0e
ScreenButtonBody_CombiEditConfigure_Nop:
	ret                                                  ; FBF498  0e
; SoftKeyCol2_CombiEditConfigure: ScreenButtons_CombiEditConfigure[1], the 23-slot button table ScreenButtonBody_CombiEditConfigure reads through T_PanelCode_ToSlotAndFlags -- the
;   SoftKeyCol2 handler of CombiEditConfigure (notes/prom_ab_promb_slot23_targets.py).
SoftKeyCol2_CombiEditConfigure:
	pushw hl                                             ; FBF499  2b
	pushw de                                             ; FBF49A  2a
	push XIX                                             ; FBF49B  3c
	lda xix, (UI_Request_Hi:16)                                ; FBF49C  f1 71 20 34
	cp	(CombiEdit_Row:16), 0x00                            ; FBF4A0  c1 69 27 3f 00
	jr z, .LFBF4B5                                       ; FBF4A5  66 0e
	ld (CombiEdit_Row:16), 0x00                                 ; FBF4A7  f1 69 27 00 00
	or	(xix), 0x10                                  ; FBF4AC  84 3e 10
	set	3, (UI_RequestBits:16)                               ; FBF4AF  f1 75 20 bb
	jr .LFBF50B                                          ; FBF4B3  68 56
.LFBF4B5:
	xor	(PanelEvent_Flags:16), 0x01                            ; FBF4B5  c1 b0 28 3d 01
	cp	(PanelModeGroup:16), 0x16                            ; FBF4BA  c1 76 20 3f 16
	jr nz, .LFBF4C9                                      ; FBF4BF  6e 08
	lda xbc, (Record_F1AE24:24)                          ; FBF4C1  f2 24 ae f1 31
	push XBC                                             ; FBF4C6  39
	jr .LFBF4CF                                          ; FBF4C7  68 06
.LFBF4C9:
	lda xbc, (Record_F1AE1B:24)                          ; FBF4C9  f2 1b ae f1 31
	push XBC                                             ; FBF4CE  39
.LFBF4CF:
	lda xbc, (UI_PartIndex:16)                                ; FBF4CF  f1 50 22 31
	push XBC                                             ; FBF4D3  39
	call T_EditValue_StepBitField                                        ; FBF4D4  1d 78 2c f4
	ld H,A                                               ; FBF4D8  c9 8e
	inc 8,XSP                                            ; FBF4DA  ef 60
	cp a, 0x01:i3                                          ; FBF4DC  c9 d9
	jr nz, .LFBF50B                                      ; FBF4DE  6e 2b
	ld h, (0x276b:16)                                   ; FBF4E0  c1 6b 27 26
	ld l, (UI_PartIndex:16)                                   ; FBF4E4  c1 50 22 27
	ld (0x276b:16), l                                   ; FBF4E8  f1 6b 27 47
	ld D,L                                               ; FBF4EC  cf 8c
	and D,0xf8                                           ; FBF4EE  cc cc f8
	ld (0x276b:16), d                                   ; FBF4F1  f1 6b 27 44
	cp H,D                                               ; FBF4F5  cc f6
	jr z, .LFBF4FE                                       ; FBF4F7  66 05
	ld (CombiEdit_DirtySound:16), 0xff                                 ; FBF4F9  f1 70 27 00 ff
.LFBF4FE:
	call T_PartIndex_PostChangeEvent                                        ; FBF4FE  1d 9c 2c f4
	ld	(CombiEdit_Part:16), (UI_PartIndex:16)             ; FBF502  c1 50 22 19 65 27
	or	(xix), 0x10                                  ; FBF508  84 3e 10
.LFBF50B:
	pop XIX                                              ; FBF50B  5c
	popw de                                              ; FBF50C  4a
	popw hl                                              ; FBF50D  4b
	ret                                                  ; FBF50E  0e
; SoftKeyCol4_CombiEditConfigure: ScreenButtons_CombiEditConfigure[3], the 23-slot button table ScreenButtonBody_CombiEditConfigure reads through T_PanelCode_ToSlotAndFlags -- the
;   SoftKeyCol4 handler of CombiEditConfigure (notes/prom_ab_promb_slot23_targets.py).
SoftKeyCol4_CombiEditConfigure:
	cp	(CombiEdit_Page:16), 0x00                            ; FBF50F  c1 67 27 3f 00
	jr nz, .LFBF539                                      ; FBF514  6e 23
	cp	(CombiEdit_Row:16), 0x01                            ; FBF516  c1 69 27 3f 01
	jr z, .LFBF52C                                       ; FBF51B  66 0f
	ld (CombiEdit_Row:16), 0x01                                 ; FBF51D  f1 69 27 00 01
	set	4, (UI_Request_Hi:16)                               ; FBF522  f1 71 20 bc
	set	3, (UI_RequestBits:16)                               ; FBF526  f1 75 20 bb
	jr .LFBF539                                          ; FBF52A  68 0d
.LFBF52C:
	push 0x00                                            ; FBF52C  09 00
	push	(CombiEdit_Part:16)                                  ; FBF52E  c1 65 27 04
	pushw 0x09                                           ; FBF532  0b 09 00
	calr PartParam_StepFieldById                                          ; FBF535  1e c8 c2
	pop XIY                                              ; FBF538  5d
.LFBF539:
	ret                                                  ; FBF539  0e
; SoftKeyCol5_CombiEditConfigure: ScreenButtons_CombiEditConfigure[4], the 23-slot button table ScreenButtonBody_CombiEditConfigure reads through T_PanelCode_ToSlotAndFlags -- the
;   SoftKeyCol5 handler of CombiEditConfigure (notes/prom_ab_promb_slot23_targets.py).
SoftKeyCol5_CombiEditConfigure:
	pushw hl                                             ; FBF53A  2b
	ld bc, (CombiEdit_Page:16)                                 ; FBF53B  d1 67 27 21
	extz BC                                              ; FBF53F  d9 12
	cp bc, 0x00:i3                                         ; FBF541  d9 d8
	jr z, .LFBF54F                                       ; FBF543  66 0a
	cp bc, 0x01:i3                                         ; FBF545  d9 d9
	jr z, .LFBF555                                       ; FBF547  66 0c
	cp bc, 0x02:i3                                         ; FBF549  d9 da
	jr z, .LFBF55B                                       ; FBF54B  66 0e
	jr .LFBF55F                                          ; FBF54D  68 10
.LFBF54F:
	ld h, 0x02:opc                                          ; FBF54F  26 02
	ld l, 0x0a:opc                                          ; FBF551  27 0a
	jr .LFBF55F                                          ; FBF553  68 0a
.LFBF555:
	ld h, 0x05:opc                                          ; FBF555  26 05
	ld l, 0x25:opc                                          ; FBF557  27 25
	jr .LFBF55F                                          ; FBF559  68 04
.LFBF55B:
	ld h, 0x07:opc                                          ; FBF55B  26 07
	ld l, 0x27:opc                                          ; FBF55D  27 27
.LFBF55F:
	ld c, (CombiEdit_Row:16)                                   ; FBF55F  c1 69 27 23
	cp C,H                                               ; FBF563  ce f3
	jr z, .LFBF575                                       ; FBF565  66 0e
	ld (CombiEdit_Row:16), h                                   ; FBF567  f1 69 27 46
	set	4, (UI_Request_Hi:16)                               ; FBF56B  f1 71 20 bc
	set	3, (UI_RequestBits:16)                               ; FBF56F  f1 75 20 bb
	jr .LFBF580                                          ; FBF573  68 0b
.LFBF575:
	push 0x00                                            ; FBF575  09 00
	push	(CombiEdit_Part:16)                                  ; FBF577  c1 65 27 04
	pushw hl                                             ; FBF57B  2b
	calr PartParam_StepFieldById                                          ; FBF57C  1e 81 c2
	pop XIY                                              ; FBF57F  5d
.LFBF580:
	popw hl                                              ; FBF580  4b
	ret                                                  ; FBF581  0e
; SoftKeyCol6_CombiEditConfigure: ScreenButtons_CombiEditConfigure[5], the 23-slot button table ScreenButtonBody_CombiEditConfigure reads through T_PanelCode_ToSlotAndFlags -- the
;   SoftKeyCol6 handler of CombiEditConfigure (notes/prom_ab_promb_slot23_targets.py).
SoftKeyCol6_CombiEditConfigure:
	pushw hl                                             ; FBF582  2b
	ld bc, (CombiEdit_Page:16)                                 ; FBF583  d1 67 27 21
	extz BC                                              ; FBF587  d9 12
	cp bc, 0x00:i3                                         ; FBF589  d9 d8
	jr z, .LFBF597                                       ; FBF58B  66 0a
	cp bc, 0x01:i3                                         ; FBF58D  d9 d9
	jr z, .LFBF59D                                       ; FBF58F  66 0c
	cp bc, 0x02:i3                                         ; FBF591  d9 da
	jr z, .LFBF5A3                                       ; FBF593  66 0e
	jr .LFBF5A7                                          ; FBF595  68 10
.LFBF597:
	ld h, 0x03:opc                                          ; FBF597  26 03
	ld l, 0x0b:opc                                          ; FBF599  27 0b
	jr .LFBF5A7                                          ; FBF59B  68 0a
.LFBF59D:
	ld h, 0x06:opc                                          ; FBF59D  26 06
	ld l, 0x26:opc                                          ; FBF59F  27 26
	jr .LFBF5A7                                          ; FBF5A1  68 04
.LFBF5A3:
	ld h, 0x08:opc                                          ; FBF5A3  26 08
	ld l, 0x28:opc                                          ; FBF5A5  27 28
.LFBF5A7:
	ld c, (CombiEdit_Row:16)                                   ; FBF5A7  c1 69 27 23
	cp C,H                                               ; FBF5AB  ce f3
	jr z, .LFBF5BD                                       ; FBF5AD  66 0e
	ld (CombiEdit_Row:16), h                                   ; FBF5AF  f1 69 27 46
	set	4, (UI_Request_Hi:16)                               ; FBF5B3  f1 71 20 bc
	set	3, (UI_RequestBits:16)                               ; FBF5B7  f1 75 20 bb
	jr .LFBF5C8                                          ; FBF5BB  68 0b
.LFBF5BD:
	push 0x00                                            ; FBF5BD  09 00
	push	(CombiEdit_Part:16)                                  ; FBF5BF  c1 65 27 04
	pushw hl                                             ; FBF5C3  2b
	calr PartParam_StepFieldById                                          ; FBF5C4  1e 39 c2
	pop XIY                                              ; FBF5C7  5d
.LFBF5C8:
	popw hl                                              ; FBF5C8  4b
	ret                                                  ; FBF5C9  0e
; SoftKeyCol7_CombiEditConfigure: ScreenButtons_CombiEditConfigure[6], the 23-slot button table ScreenButtonBody_CombiEditConfigure reads through T_PanelCode_ToSlotAndFlags -- the
;   SoftKeyCol7 handler of CombiEditConfigure (notes/prom_ab_promb_slot23_targets.py).
SoftKeyCol7_CombiEditConfigure:
	cp	(CombiEdit_Page:16), 0x00                            ; FBF5CA  c1 67 27 3f 00
	jr nz, .LFBF5F4                                      ; FBF5CF  6e 23
	cp	(CombiEdit_Row:16), 0x04                            ; FBF5D1  c1 69 27 3f 04
	jr z, .LFBF5E7                                       ; FBF5D6  66 0f
	ld (CombiEdit_Row:16), 0x04                                 ; FBF5D8  f1 69 27 00 04
	set	4, (UI_Request_Hi:16)                               ; FBF5DD  f1 71 20 bc
	set	3, (UI_RequestBits:16)                               ; FBF5E1  f1 75 20 bb
	jr .LFBF5F4                                          ; FBF5E5  68 0d
.LFBF5E7:
	push 0x00                                            ; FBF5E7  09 00
	push	(CombiEdit_Part:16)                                  ; FBF5E9  c1 65 27 04
	pushw 0x24                                           ; FBF5ED  0b 24 00
	calr PartParam_StepFieldById                                          ; FBF5F0  1e 0d c2
	pop XIY                                              ; FBF5F3  5d
.LFBF5F4:
	ret                                                  ; FBF5F4  0e
; LcdKeyRow1_CombiEditConfigure: ScreenButtons_CombiEditConfigure[8], the 23-slot button table ScreenButtonBody_CombiEditConfigure reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow1 handler of CombiEditConfigure (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow1_CombiEditConfigure:
	cp	(PanelModeGroup:16), 0x16                            ; FBF5F5  c1 76 20 3f 16
	jr nz, .LFBF608                                      ; FBF5FA  6e 0c
	ld c, (PanelEvent_Flags:16)                                   ; FBF5FC  c1 b0 28 23
	and C,0x01                                           ; FBF600  cb cc 01
	jr nz, .LFBF608                                      ; FBF603  6e 03
	calr CombiEdit_ToggleSolo                                      ; FBF605  1e 2a 06
.LFBF608:
	ret                                                  ; FBF608  0e
; LcdKeyRow2_CombiEditConfigure: ScreenButtons_CombiEditConfigure[9], the 23-slot button table ScreenButtonBody_CombiEditConfigure reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow2 handler of CombiEditConfigure (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow2_CombiEditConfigure:
	cp	(PanelModeGroup:16), 0x16                            ; FBF609  c1 76 20 3f 16
	jr nz, .LFBF62E                                      ; FBF60E  6e 1e
	ld c, (PanelEvent_Flags:16)                                   ; FBF610  c1 b0 28 23
	and C,0x01                                           ; FBF614  cb cc 01
	jr nz, .LFBF62E                                      ; FBF617  6e 15
	cp	(CombiEdit_Page:16), 0x00                            ; FBF619  c1 67 27 3f 00
	jr z, .LFBF62E                                       ; FBF61E  66 0e
	ld (CombiEdit_Page:16), 0x00                                 ; FBF620  f1 67 27 00 00
	ld (CombiEdit_Row:16), 0x00                                 ; FBF625  f1 69 27 00 00
	set	4, (UI_Request_Hi:16)                               ; FBF62A  f1 71 20 bc
.LFBF62E:
	ret                                                  ; FBF62E  0e
; LcdKeyRow3_CombiEditConfigure: ScreenButtons_CombiEditConfigure[10], the 23-slot button table ScreenButtonBody_CombiEditConfigure reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow3 handler of CombiEditConfigure (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow3_CombiEditConfigure:
	cp	(PanelModeGroup:16), 0x16                            ; FBF62F  c1 76 20 3f 16
	jr nz, .LFBF654                                      ; FBF634  6e 1e
	ld c, (PanelEvent_Flags:16)                                   ; FBF636  c1 b0 28 23
	and C,0x01                                           ; FBF63A  cb cc 01
	jr nz, .LFBF654                                      ; FBF63D  6e 15
	cp	(CombiEdit_Page:16), 0x01                            ; FBF63F  c1 67 27 3f 01
	jr z, .LFBF654                                       ; FBF644  66 0e
	ld (CombiEdit_Page:16), 0x01                                 ; FBF646  f1 67 27 00 01
	ld (CombiEdit_Row:16), 0x00                                 ; FBF64B  f1 69 27 00 00
	set	4, (UI_Request_Hi:16)                               ; FBF650  f1 71 20 bc
.LFBF654:
	ret                                                  ; FBF654  0e
; LcdKeyRow4_CombiEditConfigure: ScreenButtons_CombiEditConfigure[11], the 23-slot button table ScreenButtonBody_CombiEditConfigure reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow4 handler of CombiEditConfigure (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow4_CombiEditConfigure:
	cp	(PanelModeGroup:16), 0x16                            ; FBF655  c1 76 20 3f 16
	jr nz, .LFBF67A                                      ; FBF65A  6e 1e
	ld c, (PanelEvent_Flags:16)                                   ; FBF65C  c1 b0 28 23
	and C,0x01                                           ; FBF660  cb cc 01
	jr nz, .LFBF67A                                      ; FBF663  6e 15
	cp	(CombiEdit_Page:16), 0x02                            ; FBF665  c1 67 27 3f 02
	jr z, .LFBF67A                                       ; FBF66A  66 0e
	ld (CombiEdit_Page:16), 0x02                                 ; FBF66C  f1 67 27 00 02
	ld (CombiEdit_Row:16), 0x00                                 ; FBF671  f1 69 27 00 00
	set	4, (UI_Request_Hi:16)                               ; FBF676  f1 71 20 bc
.LFBF67A:
	ret                                                  ; FBF67A  0e
; ExitKey_CombiEditConfigure: ScreenButtons_CombiEditConfigure[15], the 23-slot button table ScreenButtonBody_CombiEditConfigure reads through T_PanelCode_ToSlotAndFlags -- the
;   ExitKey handler of CombiEditConfigure (notes/prom_ab_promb_slot23_targets.py).
ExitKey_CombiEditConfigure:
	push XIX                                             ; FBF67B  3c
	lda xix, (UI_Request_Hi:16)                                ; FBF67C  f1 71 20 34
	ld c, (PanelEvent_Flags:16)                                   ; FBF680  c1 b0 28 23
	and C,0x01                                           ; FBF684  cb cc 01
	jr nz, .LFBF6BF                                      ; FBF687  6e 36
	ld bc, (PanelModeGroup:16)                                 ; FBF689  d1 76 20 21
	extz BC                                              ; FBF68D  d9 12
	cp BC,0x0009                                         ; FBF68F  d9 cf 09 00
	jr z, .LFBF6A3                                       ; FBF693  66 0e
	cp BC,0x0012                                         ; FBF695  d9 cf 12 00
	jr z, .LFBF6B7                                       ; FBF699  66 1c
	cp BC,0x0016                                         ; FBF69B  d9 cf 16 00
	jr z, .LFBF6AD                                       ; FBF69F  66 0c
	jr .LFBF6BF                                          ; FBF6A1  68 1c
.LFBF6A3:
	or	(xix), 0x80                                  ; FBF6A3  84 3e 80
	ld (UI_Request:16), 0xb0                                 ; FBF6A6  f1 70 20 00 b0
	jr .LFBF6BF                                          ; FBF6AB  68 12
.LFBF6AD:
	or	(xix), 0x80                                  ; FBF6AD  84 3e 80
	ld (UI_Request:16), 0x34                                 ; FBF6B0  f1 70 20 00 34
	jr .LFBF6BF                                          ; FBF6B5  68 08
.LFBF6B7:
	or	(xix), 0x80                                  ; FBF6B7  84 3e 80
	ld (UI_Request:16), 0x70                                 ; FBF6BA  f1 70 20 00 70
.LFBF6BF:
	pop XIX                                              ; FBF6BF  5c
	ret                                                  ; FBF6C0  0e
.LFBF6C1:
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; FBF6C1  1d 10 2e f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBF6C5  f1 40 25 00 00
	cp	(PanelModeGroup:16), 0x16                            ; FBF6CA  c1 76 20 3f 16
	jr nz, .LFBF6DF                                      ; FBF6CF  6e 0e
	lda xbc, (DL_Configure_F19D5C:24)                    ; FBF6D1  f2 5c 9d f1 31
	push XBC                                             ; FBF6D6  39
	lda xwa, (DL_Configure_F19C39:24)                    ; FBF6D7  f2 39 9c f1 30
	push XWA                                             ; FBF6DC  38
	jr .LFBF6EB                                          ; FBF6DD  68 0c
.LFBF6DF:
	lda xbc, (DL_Midi:24)                                ; FBF6DF  f2 d0 9d f1 31
	push XBC                                             ; FBF6E4  39
	lda xwa, (DL_Configure_F19D5C:24)                    ; FBF6E5  f2 5c 9d f1 30
	push XWA                                             ; FBF6EA  38
.LFBF6EB:
	call T_DisplayList_Run_Stack                         ; FBF6EB  1d 00 2e f4
	inc 8,XSP                                            ; FBF6EF  ef 60
	cp	(PanelModeGroup:16), 0x12                            ; FBF6F1  c1 76 20 3f 12
	jr nz, .LFBF703                                      ; FBF6F6  6e 0b
	lda xbc, (DL_Midi:24)                                ; FBF6F8  f2 d0 9d f1 31
	push XBC                                             ; FBF6FD  39
	call T_DisplayList_RunOne_Stack                      ; FBF6FE  1d 08 2e f4
	pop XIY                                              ; FBF702  5d
.LFBF703:
	ret                                                  ; FBF703  0e
.LFBF704:
	push XIX                                             ; FBF704  3c
	lda xix, (LCD_CurrentLayer:16)                                ; FBF705  f1 40 25 34
	ld	(0x2768:16), (CombiEdit_Page:16)             ; FBF709  c1 67 27 19 68 27
	cp	(PanelModeGroup:16), 0x16                            ; FBF70F  c1 76 20 3f 16
	jr nz, .LFBF740                                      ; FBF714  6e 2a
	ld (XIX),0x00                                        ; FBF716  b4 00 00
	lda xbc, (ExitKey_CombiEditConfigure_DL1:24)                              ; FBF719  f2 2d a0 f1 31
	push XBC                                             ; FBF71E  39
	lda xwa, (ExitKey_CombiEditConfigure_DL2:24)                              ; FBF71F  f2 19 a0 f1 30
	push XWA                                             ; FBF724  38
	call T_DisplayList_Run_Stack                         ; FBF725  1d 00 2e f4
	ld (XIX),0x01                                        ; FBF729  b4 00 01
	lda xbc, (RecordArray_F1A037:24)                     ; FBF72C  f2 37 a0 f1 31
	push XBC                                             ; FBF731  39
	lda xwa, (ExitKey_CombiEditConfigure_DL1:24)                              ; FBF732  f2 2d a0 f1 30
	push XWA                                             ; FBF737  38
	call T_DisplayList_Run_Stack                         ; FBF738  1d 00 2e f4
	inc 8,XSP                                            ; FBF73C  ef 60
	inc 8,XSP                                            ; FBF73E  ef 60
.LFBF740:
	ld (XIX),0x00                                        ; FBF740  b4 00 00
	ld bc, (CombiEdit_Page:16)                                 ; FBF743  d1 67 27 21
	extz BC                                              ; FBF747  d9 12
	cp bc, 0x00:i3                                         ; FBF749  d9 d8
	jr z, .LFBF757                                       ; FBF74B  66 0a
	cp bc, 0x01:i3                                         ; FBF74D  d9 d9
	jr z, .LFBF765                                       ; FBF74F  66 14
	cp bc, 0x02:i3                                         ; FBF751  d9 da
	jr z, .LFBF773                                       ; FBF753  66 1e
	jr .LFBF785                                          ; FBF755  68 2e
.LFBF757:
	lda xbc, (DL_KeyLayer:24)                            ; FBF757  f2 d6 9e f1 31
	push XBC                                             ; FBF75C  39
	lda xwa, (DL_Inter:24)                               ; FBF75D  f2 da 9d f1 30
	push XWA                                             ; FBF762  38
	jr .LFBF77F                                          ; FBF763  68 1a
.LFBF765:
	lda xbc, (DL_VelocityLayer:24)                       ; FBF765  f2 89 9f f1 31
	push XBC                                             ; FBF76A  39
	lda xwa, (DL_KeyLayer:24)                            ; FBF76B  f2 d6 9e f1 30
	push XWA                                             ; FBF770  38
	jr .LFBF77F                                          ; FBF771  68 0c
.LFBF773:
	lda xbc, (ExitKey_CombiEditConfigure_DL2:24)                              ; FBF773  f2 19 a0 f1 31
	push XBC                                             ; FBF778  39
	lda xwa, (DL_VelocityLayer:24)                       ; FBF779  f2 89 9f f1 30
	push XWA                                             ; FBF77E  38
.LFBF77F:
	call T_DisplayList_Run_Stack                         ; FBF77F  1d 00 2e f4
	inc 8,XSP                                            ; FBF783  ef 60
.LFBF785:
	cp	(PanelModeGroup:16), 0x16                            ; FBF785  c1 76 20 3f 16
	jr nz, .LFBF79A                                      ; FBF78A  6e 0e
	ld (XIX),0x01                                        ; FBF78C  b4 00 01
	lda xbc, (ExitKey_CombiEditConfigure_DL3:24)                              ; FBF78F  f2 58 a1 f1 31
	push XBC                                             ; FBF794  39
	call T_DisplayListB_RunOne_Stack                     ; FBF795  1d 0c 2e f4
	pop XIY                                              ; FBF799  5d
.LFBF79A:
	pop XIX                                              ; FBF79A  5c
	ret                                                  ; FBF79B  0e
; CombiEditConfigure_RepaintMarkedSounds: posted by CombiEdit_RunPendingRepaint, and called by the CONFIGURE page repaint: takes and clears
;   CombiEdit_DirtySound, then for the 8 parts shown from (0x276B) whose bit is set, T_PartSound_CopyNameToDrawScratch and the part's
;   record of RecordArray_F1A037 (one record per part, stride from the array).  Basis: body.
CombiEditConfigure_RepaintMarkedSounds:
	link XIZ,0xfff8                                      ; FBF79C  ee 0c f8 ff
	pushw hl                                             ; FBF7A0  2b
	pushw de                                             ; FBF7A1  2a
	push XIX                                             ; FBF7A2  3c
	ld e, (CombiEdit_DirtySound:16)                                   ; FBF7A3  c1 70 27 25
	ld (CombiEdit_DirtySound:16), 0x00                                 ; FBF7A7  f1 70 27 00 00
	ld l, 0x01:opc                                          ; FBF7AC  27 01
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBF7AE  f1 40 25 00 00
	lda xbc, (RecordArray_F1A037:24)                     ; FBF7B3  f2 37 a0 f1 31
	ld (xiz-4), xbc                                      ; FBF7B8  be fc 61
	ld h, (0x276b:16)                                   ; FBF7BB  c1 6b 27 26
	ld d, (0x276b:16)                                   ; FBF7BF  c1 6b 27 24
	inc 7,D                                              ; FBF7C3  cc 67
	cp H,D                                               ; FBF7C5  cc f6
	jr ugt, .LFBF801                                     ; FBF7C7  6b 38
	lda xwa, (RecordArray_F1A037:24)                     ; FBF7C9  f2 37 a0 f1 30
	ld (xiz-8), xwa                                      ; FBF7CE  be f8 60
	lda xix, (0xf1a048:24)                               ; FBF7D1  f2 48 a0 f1 34
	sub XIX,XWA                                          ; FBF7D6  e8 a4
.LFBF7D8:
	ld C,L                                               ; FBF7D8  cf 8b
	and C,E                                              ; FBF7DA  cd c3
	jr z, .LFBF7F0                                       ; FBF7DC  66 12
	push 0x00                                            ; FBF7DE  09 00
	push H                                               ; FBF7E0  ce 04
	call T_PartSound_CopyNameToDrawScratch                                        ; FBF7E2  1d a0 2c f4
	ld xbc, (xiz-4)                                      ; FBF7E6  ae fc 21
	push XBC                                             ; FBF7E9  39
	call T_DisplayListB_RunOne_Stack                     ; FBF7EA  1d 0c 2e f4
	inc 6,XSP                                            ; FBF7EE  ef 66
.LFBF7F0:
	ld XBC,XIX                                           ; FBF7F0  ec 89
	add (xiz-4), xbc                                     ; FBF7F2  ae fc 89
	ld A,L                                               ; FBF7F5  cf 89
	add A,L                                              ; FBF7F7  cf 81
	ld L,A                                               ; FBF7F9  c9 8f
	inc 1,H                                              ; FBF7FB  ce 61
	cp H,D                                               ; FBF7FD  cc f6
	jr ule, .LFBF7D8                                     ; FBF7FF  63 d7
.LFBF801:
	pop XIX                                              ; FBF801  5c
	popw de                                              ; FBF802  4a
	popw hl                                              ; FBF803  4b
	unlk XIZ                                             ; FBF804  ee 0d
	ret                                                  ; FBF806  0e
.LFBF807:
	link XIZ,0xfff4                                      ; FBF807  ee 0c f4 ff
	pushw hl                                             ; FBF80B  2b
	push XIX                                             ; FBF80C  3c
	lda xix, (UI_DrawScratch:16)                                ; FBF80D  f1 40 26 34
	ld (xiz-4), xix                                      ; FBF811  be fc 64
	ld xbc, (xiz-4)                                      ; FBF814  ae fc 21
	ld	(xbc), (CombiEdit_Part)                              ; FBF817  b1 14 65 27
	ld h, (CombiEdit_Part:16)                                   ; FBF81B  c1 65 27 26
	ld xbc, (xiz-4)                                      ; FBF81F  ae fc 21
	ld	(xbc+1), (0x2766)                            ; FBF822  b9 01 14 66 27
	ld xbc, (xiz-4)                                      ; FBF827  ae fc 21
	inc 2,XBC                                            ; FBF82A  e9 62
	ld (xiz-8), xbc                                      ; FBF82C  be f8 61
	ld (0x2766:16), h                                   ; FBF82F  f1 66 27 46
	ld	(xbc), (CombiEdit_Row)                              ; FBF833  b1 14 69 27
	ld l, (CombiEdit_Row:16)                                   ; FBF837  c1 69 27 27
	ld xbc, (xiz-4)                                      ; FBF83B  ae fc 21
	ld	(xbc+3), (0x276a)                            ; FBF83E  b9 03 14 6a 27
	ld xbc, (xiz-4)                                      ; FBF843  ae fc 21
	inc 4,XBC                                            ; FBF846  e9 64
	ld (xiz-12), xbc                                     ; FBF848  be f4 61
	ld (0x276a:16), l                                   ; FBF84B  f1 6a 27 47
	ld	(xbc), (0x276b)                              ; FBF84F  b1 14 6b 27
	ld l, (0x276b:16)                                   ; FBF853  c1 6b 27 27
	ld xbc, (xiz-4)                                      ; FBF857  ae fc 21
	ld	(xbc+5), (0x276c)                            ; FBF85A  b9 05 14 6c 27
	ld (0x276c:16), l                                   ; FBF85F  f1 6c 27 47
	set	0, (0xc6:8)                                   ; FBF863  f0 c6 b8
	ld (LCD_CurrentLayer:16), 0x01                                 ; FBF866  f1 40 25 00 01
	ld BC,IX                                             ; FBF86B  dc 89
	inc 1,BC                                             ; FBF86D  d9 61
	extz XBC                                             ; FBF86F  e9 12
	ld A,(XBC)                                           ; FBF871  81 21
	cp H,A                                               ; FBF873  c9 f6
	jr z, .LFBF889                                       ; FBF875  66 12
	lda xbc, (CombiEditConfigure_RepaintMarkedSounds_DL1:24)                              ; FBF877  f2 79 a1 f1 31
	push XBC                                             ; FBF87C  39
	lda xwa, (CombiEditConfigure_RepaintMarkedSounds_DL2:24)                              ; FBF87D  f2 63 a1 f1 30
	push XWA                                             ; FBF882  38
	call T_DisplayListB_Run_Stack                        ; FBF883  1d 04 2e f4
	inc 8,XSP                                            ; FBF887  ef 60
.LFBF889:
	extz XIX                                             ; FBF889  ec 12
	ld H,(XIX+0x03)                                      ; FBF88B  8c 03 26
	ld C,(XIX+0x02)                                      ; FBF88E  8c 02 23
	cp C,H                                               ; FBF891  ce f3
	jr z, .LFBF8A7                                       ; FBF893  66 12
	lda xbc, (CombiEditConfigure_RepaintMarkedSounds_DL3:24)                              ; FBF895  f2 4d a1 f1 31
	push XBC                                             ; FBF89A  39
	lda xwa, (CombiEditConfigure_RepaintMarkedSounds_DL4:24)                              ; FBF89B  f2 37 a1 f1 30
	push XWA                                             ; FBF8A0  38
	call T_DisplayListB_Run_Stack                        ; FBF8A1  1d 04 2e f4
	inc 8,XSP                                            ; FBF8A5  ef 60
.LFBF8A7:
	ld (xiz-4), xix                                      ; FBF8A7  be fc 64
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBF8AA  f1 40 25 00 00
	ld xbc, (xiz-4)                                      ; FBF8AF  ae fc 21
	ld	(xbc), (0x276b)                              ; FBF8B2  b1 14 6b 27
	ld h, (0x276b:16)                                   ; FBF8B6  c1 6b 27 26
	ld C,(XIX+0x05)                                      ; FBF8BA  8c 05 23
	cp H,C                                               ; FBF8BD  cb f6
	jr z, .LFBF8D3                                       ; FBF8BF  66 12
	lda xbc, (CombiEditConfigure_RepaintMarkedSounds_DL4:24)                              ; FBF8C1  f2 37 a1 f1 31
	push XBC                                             ; FBF8C6  39
	lda xwa, (DL_Pt1Pt2Pt3Pt4Pt5Pt6Pt7Pt8:24)            ; FBF8C7  f2 bf a0 f1 30
	push XWA                                             ; FBF8CC  38
	call T_DisplayListB_Run_Stack                        ; FBF8CD  1d 04 2e f4
	inc 8,XSP                                            ; FBF8D1  ef 60
.LFBF8D3:
	calr CombiEditConfigure_RepaintMarkedSounds                                      ; FBF8D3  1e c6 fe
	res	0, (0xc6:8)                                   ; FBF8D6  f0 c6 b0
	pop XIX                                              ; FBF8D9  5c
	popw hl                                              ; FBF8DA  4b
	unlk XIZ                                             ; FBF8DB  ee 0d
	ret                                                  ; FBF8DD  0e
.LFBF8DE:
	cp	(PanelModeGroup:16), 0x16                            ; FBF8DE  c1 76 20 3f 16
	jr nz, .LFBF904                                      ; FBF8E3  6e 1f
	ld (LCD_CurrentLayer:16), 0x01                                 ; FBF8E5  f1 40 25 00 01
	cp	(0x276f:16), 0x00                            ; FBF8EA  c1 6f 27 3f 00
	jr nz, .LFBF8F9                                      ; FBF8EF  6e 08
	lda xbc, (CombiEditConfigure_RepaintMarkedSounds_DL1:24)                              ; FBF8F1  f2 79 a1 f1 31
	push XBC                                             ; FBF8F6  39
	jr .LFBF8FF                                          ; FBF8F7  68 06
.LFBF8F9:
	lda xbc, (CombiEditConfigure_RepaintMarkedSounds_DL5:24)                              ; FBF8F9  f2 83 a1 f1 31
	push XBC                                             ; FBF8FE  39
.LFBF8FF:
	call T_DisplayList_RunOne_Stack                      ; FBF8FF  1d 08 2e f4
	pop XIY                                              ; FBF903  5d
.LFBF904:
	ld bc, (CombiEdit_Page:16)                                 ; FBF904  d1 67 27 21
	extz BC                                              ; FBF908  d9 12
	cp bc, 0x00:i3                                         ; FBF90A  d9 d8
	jr z, .LFBF918                                       ; FBF90C  66 0a
	cp bc, 0x01:i3                                         ; FBF90E  d9 d9
	jr z, .LFBF91D                                       ; FBF910  66 0b
	cp bc, 0x02:i3                                         ; FBF912  d9 da
	jr z, .LFBF922                                       ; FBF914  66 0c
	jr .LFBF925                                          ; FBF916  68 0d
.LFBF918:
	calr CombiEditConfigure_DrawMidiSettings                                      ; FBF918  1e 14 00
	jr .LFBF925                                          ; FBF91B  68 08
.LFBF91D:
	calr CombiEditConfigure_DrawKeyLayers                                      ; FBF91D  1e 51 00
	jr .LFBF925                                          ; FBF920  68 03
.LFBF922:
	calr CombiEditConfigure_DrawVelocityLayers                                      ; FBF922  1e 28 01
.LFBF925:
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; FBF925  1d 14 2e f4
	ld (0x277e:16), 0x01                                 ; FBF929  f1 7e 27 00 01
	ret                                                  ; FBF92E  0e
; CombiEditConfigure_DrawMidiSettings: CONFIGURE page 0 (CombiEdit_Page): byte 13 of the 8 parts from (0x276B) -- BASIC CHANNEL, LOCAL CONTROL, MIDI
;   OUT / IN SETTING (SysEx PART descriptors, offset 13) -- into UI_DrawScratch, drawn by CombiEditConfigure_DrawMidiSettings_DL with
;   StringTable_F1A515.  Basis: table (descriptor match) + the page switch at 0xFBF904.
CombiEditConfigure_DrawMidiSettings:
	pushw hl                                             ; FBF92F  2b
	push XIX                                             ; FBF930  3c
	ld l, (0x276b:16)                                   ; FBF931  c1 6b 27 27
	inc 7,L                                              ; FBF935  cf 67
	lda xix, (UI_DrawScratch:16)                                ; FBF937  f1 40 26 34
	ld h, (0x276b:16)                                   ; FBF93B  c1 6b 27 26
	jr .LFBF953                                          ; FBF93F  68 12
.LFBF941:
	pushw 0x0d                                           ; FBF941  0b 0d 00
	push 0x00                                            ; FBF944  09 00
	push H                                               ; FBF946  ce 04
	call T_IndexedTable_GetByte                          ; FBF948  1d 90 2c f4
	ld (XIX),A                                           ; FBF94C  b4 41
	inc 1,XIX                                            ; FBF94E  ec 61
	inc 1,H                                              ; FBF950  ce 61
	pop XIY                                              ; FBF952  5d
.LFBF953:
	cp H,L                                               ; FBF953  cf f6
	jr ule, .LFBF941                                     ; FBF955  63 ea
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBF957  f1 40 25 00 00
	lda xbc, (StringTable_F1A515:24)                     ; FBF95C  f2 15 a5 f1 31
	push XBC                                             ; FBF961  39
	lda xwa, (CombiEditConfigure_DrawMidiSettings_DL:24)                              ; FBF962  f2 ad a2 f1 30
	push XWA                                             ; FBF967  38
	call T_DisplayListB_Run_Stack                        ; FBF968  1d 04 2e f4
	inc 8,XSP                                            ; FBF96C  ef 60
	pop XIX                                              ; FBF96E  5c
	popw hl                                              ; FBF96F  4b
	ret                                                  ; FBF970  0e
; CombiEditConfigure_DrawKeyLayers: CONFIGURE page 1: the second records of parts 0..7 (0x20..0x27), bytes 7 / 8 -- KEY LAYER LOW / HIGH -- each
;   divided by 3 into an x position of the keyboard bar (Record_F1AAEC).  Basis: table (descriptor match).
CombiEditConfigure_DrawKeyLayers:
	link XIZ,0xffda                                      ; FBF971  ee 0c da ff
	pushw hl                                             ; FBF975  2b
	pushw de                                             ; FBF976  2a
	push XIX                                             ; FBF977  3c
	ldw bc, 0x0f                                         ; FBF978  31 0f 00
	lda xiy, (Record_F1AAEC:24)                          ; FBF97B  f2 ec aa f1 35
	lda xix, (xiz-38)                                    ; FBF980  be da 34
	ldirw                                                ; FBF983  95 11
	lda xbc, (UI_DrawScratch:16)                                ; FBF985  f1 40 26 31
	ld (xiz-4), xbc                                      ; FBF989  be fc 61
	ldw wa, UI_DrawScratch                                       ; FBF98C  30 40 26
	inc 8,WA                                             ; FBF98F  d8 60
	extz XWA                                             ; FBF991  e8 12
	ld (xiz-8), xwa                                      ; FBF993  be f8 60
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBF996  f1 40 25 00 00
	ld h, 0x20:opc                                          ; FBF99B  26 20
	lda xix, (xiz-8)                                     ; FBF99D  be f8 34
.LFBF9A0:
	pushw 0x07                                           ; FBF9A0  0b 07 00
	push 0x00                                            ; FBF9A3  09 00
	push H                                               ; FBF9A5  ce 04
	call T_IndexedTable_GetByte                          ; FBF9A7  1d 90 2c f4
	ld xbc, (xiz-4)                                      ; FBF9AB  ae fc 21
	ld (XBC),A                                           ; FBF9AE  b1 41
	pushw 0x08                                           ; FBF9B0  0b 08 00
	push 0x00                                            ; FBF9B3  09 00
	push H                                               ; FBF9B5  ce 04
	call T_IndexedTable_GetByte                          ; FBF9B7  1d 90 2c f4
	ld xbc, (xiz-8)                                      ; FBF9BB  ae f8 21
	ld (XBC),A                                           ; FBF9BE  b1 41
	ld xbc, (xiz-4)                                      ; FBF9C0  ae fc 21
	ld A,(XBC)                                           ; FBF9C3  81 21
	extz WA                                              ; FBF9C5  d8 12
	div A,0x03                                           ; FBF9C7  c9 0a 03
	extz WA                                              ; FBF9CA  d8 12
	ld DE,WA                                             ; FBF9CC  d8 8a
	add WA,0x00db                                        ; FBF9CE  d8 c8 db 00
	ld (xiz-32), wa                                      ; FBF9D2  be e0 50
	ld BC,DE                                             ; FBF9D5  da 89
	add BC,0x00dc                                        ; FBF9D7  d9 c8 dc 00
	ld (xiz-26), bc                                      ; FBF9DB  be e6 51
	ld xbc, (xiz-8)                                      ; FBF9DE  ae f8 21
	ld A,(XBC)                                           ; FBF9E1  81 21
	extz WA                                              ; FBF9E3  d8 12
	div A,0x03                                           ; FBF9E5  c9 0a 03
	extz WA                                              ; FBF9E8  d8 12
	ld DE,WA                                             ; FBF9EA  d8 8a
	add WA,0x00db                                        ; FBF9EC  d8 c8 db 00
	ld (xiz-22), wa                                      ; FBF9F0  be ea 50
	ld BC,DE                                             ; FBF9F3  da 89
	add BC,0x00dc                                        ; FBF9F5  d9 c8 dc 00
	ld (xiz-16), bc                                      ; FBF9F9  be f0 51
	push XIX                                             ; FBF9FC  3c
	lda xbc, (xiz-38)                                    ; FBF9FD  be da 31
	push XBC                                             ; FBFA00  39
	call T_DisplayList_Run_Stack                         ; FBFA01  1d 00 2e f4
	ldw de, 0x10                                         ; FBFA05  32 10 00
	add (xiz-34), de                                     ; FBFA08  9e de 8a
	add (xiz-30), de                                     ; FBFA0B  9e e2 8a
	add (xiz-24), de                                     ; FBFA0E  9e e8 8a
	add (xiz-20), de                                     ; FBFA11  9e ec 8a
	add (xiz-14), de                                     ; FBFA14  9e f2 8a
	add (xiz-10), de                                     ; FBFA17  9e f6 8a
	sub XBC,XBC                                          ; FBFA1A  e9 a1
	inc 1,XBC                                            ; FBFA1C  e9 61
	add (xiz-4), xbc                                     ; FBFA1E  ae fc 89
	add (xiz-8), xbc                                     ; FBFA21  ae f8 89
	add H,C                                              ; FBFA24  cb 86
	inc 8,XSP                                            ; FBFA26  ef 60
	inc 8,XSP                                            ; FBFA28  ef 60
	cp H,0x27                                            ; FBFA2A  ce cf 27
	jrl ule, .LFBF9A0                                    ; FBFA2D  73 70 ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBFA30  f1 40 25 00 00
	lda xwa, (MidiNoteNames:24)                          ; FBFA35  f2 2f a6 f1 30
	push XWA                                             ; FBFA3A  38
	lda xiy, (CombiEditConfigure_DrawKeyLayers_DL:24)                              ; FBFA3B  f2 3f a5 f1 35
	push XIY                                             ; FBFA40  3d
	call T_DisplayListB_Run_Stack                        ; FBFA41  1d 04 2e f4
	inc 8,XSP                                            ; FBFA45  ef 60
	pop XIX                                              ; FBFA47  5c
	popw de                                              ; FBFA48  4a
	popw hl                                              ; FBFA49  4b
	unlk XIZ                                             ; FBFA4A  ee 0d
	ret                                                  ; FBFA4C  0e
; CombiEditConfigure_DrawVelocityLayers: CONFIGURE page 2: the second records of parts 0..7, bytes 9 / 10 -- VELOCITY LAYER LOW / HIGH -- into
;   UI_DrawScratch, drawn by CombiEditConfigure_DrawVelocityLayers_DL.  Basis: table (descriptor match).
CombiEditConfigure_DrawVelocityLayers:
	link XIZ,0xfffc                                      ; FBFA4D  ee 0c fc ff
	pushw hl                                             ; FBFA51  2b
	push XIX                                             ; FBFA52  3c
	lda xbc, (UI_DrawScratch:16)                                ; FBFA53  f1 40 26 31
	ld (xiz-4), xbc                                      ; FBFA57  be fc 61
	ldw wa, UI_DrawScratch                                       ; FBFA5A  30 40 26
	inc 8,WA                                             ; FBFA5D  d8 60
	extz XWA                                             ; FBFA5F  e8 12
	ld XIX,XWA                                           ; FBFA61  e8 8c
	ld h, 0x20:opc                                          ; FBFA63  26 20
.LFBFA65:
	pushw 0x09                                           ; FBFA65  0b 09 00
	push 0x00                                            ; FBFA68  09 00
	push H                                               ; FBFA6A  ce 04
	call T_IndexedTable_GetByte                          ; FBFA6C  1d 90 2c f4
	ld xbc, (xiz-4)                                      ; FBFA70  ae fc 21
	ld (XBC),A                                           ; FBFA73  b1 41
	pushw 0x0a                                           ; FBFA75  0b 0a 00
	push 0x00                                            ; FBFA78  09 00
	push H                                               ; FBFA7A  ce 04
	call T_IndexedTable_GetByte                          ; FBFA7C  1d 90 2c f4
	ld (XIX),A                                           ; FBFA80  b4 41
	sub XBC,XBC                                          ; FBFA82  e9 a1
	inc 1,XBC                                            ; FBFA84  e9 61
	add (xiz-4), xbc                                     ; FBFA86  ae fc 89
	add XIX,XBC                                          ; FBFA89  e9 84
	add H,C                                              ; FBFA8B  cb 86
	inc 8,XSP                                            ; FBFA8D  ef 60
	cp H,0x27                                            ; FBFA8F  ce cf 27
	jr ule, .LFBFA65                                     ; FBFA92  63 d1
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBFA94  f1 40 25 00 00
	lda xwa, (DL_F1A84F:24)                              ; FBFA99  f2 4f a8 f1 30
	push XWA                                             ; FBFA9E  38
	lda xiy, (CombiEditConfigure_DrawVelocityLayers_DL:24)                              ; FBFA9F  f2 af a7 f1 35
	push XIY                                             ; FBFAA4  3d
	call T_DisplayListB_Run_Stack                        ; FBFAA5  1d 04 2e f4
	inc 8,XSP                                            ; FBFAA9  ef 60
	pop XIX                                              ; FBFAAB  5c
	popw hl                                              ; FBFAAC  4b
	unlk XIZ                                             ; FBFAAD  ee 0d
	ret                                                  ; FBFAAF  0e
; ScreenEnter_CombiEditMenu: the +0 ENTER method of the screen object for screen id 0x34 -- PanelScreen_VtableTable entry 0x54
;   (ViewB entry 0x34) points at the thunk triple starting at T_ScreenEnter_CombiEditMenu, and slot T_ScreenEnter_CombiEditMenu jumps here.
; ScreenEnter_CombiEditMenu: screen 0x34's +0 ENTER.  Its painter runs DL_CopyFromSoundPlay .. DL_Part_F18BBA: "C0MBINATI0N EDIT",
;   "INTERNAL", "CONFIGURE", "MIDI", "MIXER", "DSP EFFECT", "SOUND WRITE", "COPY FROM SOUND PLAY" -- the COMBINATION EDIT menu.
ScreenEnter_CombiEditMenu:
	calr CombiEdit_TakePartIndex                                          ; FBFAB0  1e fe d1
	ld c, (UI_ScreenFlags:16)                                   ; FBFAB3  c1 95 20 23
	and C,0x10                                           ; FBFAB7  cb cc 10
	jr nz, .LFBFADD                                      ; FBFABA  6e 21
	ld c, (UI_ScreenId:16)                                   ; FBFABC  c1 7c 20 23
	cp	c, (UI_ScreenId_Previous:16)                               ; FBFAC0  c1 7d 20 f3
	jr z, .LFBFADD                                       ; FBFAC4  66 17
	call T_CallbackQueue_ResetAndRestartTask2            ; FBFAC6  1d 80 2e f4
	lda xbc, (.LFBFCF1:24)                               ; FBFACA  f2 f1 fc fb 31
	push XBC                                             ; FBFACF  39
	call T_CallbackQueue_Post                            ; FBFAD0  1d 84 2e f4
	pushw 0x01                                           ; FBFAD4  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBFAD7  1d c0 2d f4
	inc 6,XSP                                            ; FBFADB  ef 66
.LFBFADD:
	lda xbc, (.LFBFD49:24)                               ; FBFADD  f2 49 fd fb 31
	push XBC                                             ; FBFAE2  39
	call T_CallbackQueue_Post                            ; FBFAE3  1d 84 2e f4
	pushw 0x01                                           ; FBFAE7  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBFAEA  1d c0 2d f4
	inc 6,XSP                                            ; FBFAEE  ef 66
	ret                                                  ; FBFAF0  0e
T_F41A1C_Nop:
	ret                                                  ; FBFAF1  0e
; ScreenButton_CombiEditMenu: the +8 BUTTON method of the screen object for screen id 0x34 -- PanelScreen_VtableTable entry 0x54
;   (ViewB entry 0x34) points at the thunk triple starting at T_ScreenEnter_CombiEditMenu, and slot T_ScreenButton_CombiEditMenu jumps here.
ScreenButton_CombiEditMenu:
	link XIZ,0x0000                                      ; FBFAF2  ee 0c 00 00
	cp	(PanelModeGroup:16), 0x16                            ; FBFAF6  c1 76 20 3f 16
	jr nz, .LFBFB10                                      ; FBFAFB  6e 13
	cp	(CombiEdit_Comparing:16), 0x01                            ; FBFAFD  c1 7f 27 3f 01
	jr nz, .LFBFB10                                      ; FBFB02  6e 0c
	cpw	(xiz+8), 0x001e                              ; FBFB04  9e 08 3f 1e 00
	jr nz, .LFBFB30                                      ; FBFB09  6e 25
	calr CompareKey_CombiEdit                                      ; FBFB0B  1e b0 f2
	jr .LFBFB30                                          ; FBFB0E  68 20
.LFBFB10:
	pushw	(xiz+10)                                     ; FBFB10  9e 0a 04
	pushw	(xiz+8)                                      ; FBFB13  9e 08 04
	call T_PanelCode_ToSlotAndFlags                                        ; FBFB16  1d 74 2c f4
	mul A,0x04                                           ; FBFB1A  c9 08 04
	extz XWA                                             ; FBFB1D  e8 12
	add XWA,ScreenButtons_CombiEditMenu                              ; FBFB1F  e8 c8 95 b2 f1 00
	ld XBC,(XWA)                                         ; FBFB25  a0 21
	lda xiy, (.LFBFB2F:24)                               ; FBFB27  f2 2f fb fb 35
	push XIY                                             ; FBFB2C  3d
	jp (xbc)                                             ; FBFB2D  b1 d8
.LFBFB2F:
	pop XIY                                              ; FBFB2F  5d
.LFBFB30:
	unlk XIZ                                             ; FBFB30  ee 0d
	ret                                                  ; FBFB32  0e
T_F41A24_Nop:
	ret                                                  ; FBFB33  0e
; LcdKeyRow1_CombiEditMenu: ScreenButtons_CombiEditMenu[8], the 23-slot button table ScreenButton_CombiEditMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow1 handler of CombiEditMenu (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow1_CombiEditMenu:
	push XIX                                             ; FBFB34  3c
	lda xix, (PanelEvent_Flags:16)                                ; FBFB35  f1 b0 28 34
	ld C,(XIX)                                           ; FBFB39  84 23
	and C,0x01                                           ; FBFB3B  cb cc 01
	jr z, .LFBFB66                                       ; FBFB3E  66 26
	and (XIX),0xfe                                       ; FBFB40  84 3c fe
	lda xbc, (Record_F1AE24:24)                          ; FBFB43  f2 24 ae f1 31
	push XBC                                             ; FBFB48  39
	lda xwa, (UI_PartIndex:16)                                ; FBFB49  f1 50 22 30
	push XWA                                             ; FBFB4D  38
	call T_EditValue_StepBitField                                        ; FBFB4E  1d 78 2c f4
	inc 8,XSP                                            ; FBFB52  ef 60
	cp a, 0x01:i3                                          ; FBFB54  c9 d9
	jr nz, .LFBFB66                                      ; FBFB56  6e 0e
	call T_PartIndex_PostChangeEvent                                        ; FBFB58  1d 9c 2c f4
	ld	(CombiEdit_Part:16), (UI_PartIndex:16)             ; FBFB5C  c1 50 22 19 65 27
	set	4, (UI_ScreenFlags:16)                               ; FBFB62  f1 95 20 bc
.LFBFB66:
	pop XIX                                              ; FBFB66  5c
	ret                                                  ; FBFB67  0e
; LcdKeyRow2_CombiEditMenu: ScreenButtons_CombiEditMenu[9], the 23-slot button table ScreenButton_CombiEditMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow2 handler of CombiEditMenu (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow2_CombiEditMenu:
	ld c, (PanelEvent_Flags:16)                                   ; FBFB68  c1 b0 28 23
	and C,0x01                                           ; FBFB6C  cb cc 01
	jr z, .LFBFB96                                       ; FBFB6F  66 25
	lda xbc, (Record_F1AE24:24)                          ; FBFB71  f2 24 ae f1 31
	push XBC                                             ; FBFB76  39
	lda xwa, (UI_PartIndex:16)                                ; FBFB77  f1 50 22 30
	push XWA                                             ; FBFB7B  38
	call T_EditValue_StepBitField                                        ; FBFB7C  1d 78 2c f4
	inc 8,XSP                                            ; FBFB80  ef 60
	cp a, 0x01:i3                                          ; FBFB82  c9 d9
	jr nz, .LFBFB99                                      ; FBFB84  6e 13
	call T_PartIndex_PostChangeEvent                                        ; FBFB86  1d 9c 2c f4
; (sub_FBFB8A removed 2026-10-04: no code names it and the line above falls through into it -- part of ScreenButton_CombiEditMenu;
;  notes/prom_a_stray_label_removal.py)
	ld	(CombiEdit_Part:16), (UI_PartIndex:16)             ; FBFB8A  c1 50 22 19 65 27
	set	4, (UI_ScreenFlags:16)                               ; FBFB90  f1 95 20 bc
	jr .LFBFB99                                          ; FBFB94  68 03
.LFBFB96:
	calr CombiEdit_ToggleSolo                                      ; FBFB96  1e 99 00
.LFBFB99:
	ret                                                  ; FBFB99  0e
; LcdKeyRow3_CombiEditMenu: ScreenButtons_CombiEditMenu[10], the 23-slot button table ScreenButton_CombiEditMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow3 handler of CombiEditMenu (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow3_CombiEditMenu:
	pushw hl                                             ; FBFB9A  2b
	push XIX                                             ; FBFB9B  3c
	lda xix, (UI_Request_Hi:16)                                ; FBFB9C  f1 71 20 34
	ld H,(XIX)                                           ; FBFBA0  84 26
	set 0x07,H                                           ; FBFBA2  ce 31 07
	ld c, (PanelEvent_Flags:16)                                   ; FBFBA5  c1 b0 28 23
	and C,0x01                                           ; FBFBA9  cb cc 01
	jr z, LcdKeyRow3_CombiEditMenu_Skip                                     ; FBFBAC  66 09
	ld (XIX),H                                           ; FBFBAE  b4 46
	ld (UI_Request:16), 0x37                                 ; FBFBB0  f1 70 20 00 37
	jr .LFBFBBE                                          ; FBFBB5  68 07
LcdKeyRow3_CombiEditMenu_Skip:
	ld (XIX),H                                           ; FBFBB7  b4 46
	ld (UI_Request:16), 0x35                                 ; FBFBB9  f1 70 20 00 35
.LFBFBBE:
	pop XIX                                              ; FBFBBE  5c
	popw hl                                              ; FBFBBF  4b
	ret                                                  ; FBFBC0  0e
; LcdKeyRow4_CombiEditMenu: ScreenButtons_CombiEditMenu[11], the 23-slot button table ScreenButton_CombiEditMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow4 handler of CombiEditMenu (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow4_CombiEditMenu:
	pushw hl                                             ; FBFBC1  2b
	push XIX                                             ; FBFBC2  3c
	lda xix, (UI_Request_Hi:16)                                ; FBFBC3  f1 71 20 34
	ld H,(XIX)                                           ; FBFBC7  84 26
	set 0x07,H                                           ; FBFBC9  ce 31 07
	ld c, (PanelEvent_Flags:16)                                   ; FBFBCC  c1 b0 28 23
	and C,0x01                                           ; FBFBD0  cb cc 01
	jr z, .LFBFBDE                                       ; FBFBD3  66 09
	ld (XIX),H                                           ; FBFBD5  b4 46
	ld (UI_Request:16), 0x38                                 ; FBFBD7  f1 70 20 00 38
	jr .LFBFBE5                                          ; FBFBDC  68 07
.LFBFBDE:
	ld (XIX),H                                           ; FBFBDE  b4 46
	ld (UI_Request:16), 0x3a                                 ; FBFBE0  f1 70 20 00 3a
.LFBFBE5:
	pop XIX                                              ; FBFBE5  5c
	popw hl                                              ; FBFBE6  4b
	ret                                                  ; FBFBE7  0e
; LcdKeyRow5_CombiEditMenu: ScreenButtons_CombiEditMenu[12], the 23-slot button table ScreenButton_CombiEditMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow5 handler of CombiEditMenu (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow5_CombiEditMenu:
	pushw hl                                             ; FBFBE8  2b
	push XIX                                             ; FBFBE9  3c
	lda xix, (UI_Request_Hi:16)                                ; FBFBEA  f1 71 20 34
	ld H,(XIX)                                           ; FBFBEE  84 26
	set 0x07,H                                           ; FBFBF0  ce 31 07
	ld c, (PanelEvent_Flags:16)                                   ; FBFBF3  c1 b0 28 23
	and C,0x01                                           ; FBFBF7  cb cc 01
	jr z, .LFBFC05                                       ; FBFBFA  66 09
	ld (XIX),H                                           ; FBFBFC  b4 46
	ld (UI_Request:16), 0x3c                                 ; FBFBFE  f1 70 20 00 3c
	jr .LFBFC0C                                          ; FBFC03  68 07
.LFBFC05:
	ld (XIX),H                                           ; FBFC05  b4 46
	ld (UI_Request:16), 0x39                                 ; FBFC07  f1 70 20 00 39
.LFBFC0C:
	pop XIX                                              ; FBFC0C  5c
	popw hl                                              ; FBFC0D  4b
	ret                                                  ; FBFC0E  0e
; ExitKey_CombiEditMenu: ScreenButtons_CombiEditMenu[15], the 23-slot button table ScreenButton_CombiEditMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   ExitKey handler of CombiEditMenu (notes/prom_ab_promb_slot23_targets.py).
ExitKey_CombiEditMenu:
	ld c, (PanelEvent_Flags:16)                                   ; FBFC0F  c1 b0 28 23
	and C,0x01                                           ; FBFC13  cb cc 01
	jr nz, .LFBFC31                                      ; FBFC16  6e 19
	ld c, (UI_ScreenHoldState:16)                                   ; FBFC18  c1 92 20 23
	and C,0x01                                           ; FBFC1C  cb cc 01
	jr z, .LFBFC28                                       ; FBFC1F  66 07
	ld (UI_ScreenHoldPending:16), 0x01                                 ; FBFC21  f1 9a 20 00 01
	jr .LFBFC31                                          ; FBFC26  68 09
.LFBFC28:
	set	1, (UI_Request_Hi:16)                               ; FBFC28  f1 71 20 b9
	ld (UI_Request:16), 0x01                                 ; FBFC2C  f1 70 20 00 01
.LFBFC31:
	ret                                                  ; FBFC31  0e
; CombiEdit_ToggleSolo: (0x276F) toggled between 0 and 1 and passed to T_NoteRouting_SetSoloAndRebuild, then UI_ScreenFlags bit 4; called
;   from LcdKeyRow1_CombiEditConfigure, LcdKeyRow1_CombiEditMixer and LcdKeyRow2_CombiEditMenu.  (0x276F) is cleared on
;   COMBINATION EDIT entry.  Basis: body + callers.
CombiEdit_ToggleSolo:
	push XIX                                             ; FBFC32  3c
	lda xix, (0x276f:16)                                ; FBFC33  f1 6f 27 34
	ld C,(XIX)                                           ; FBFC37  84 23
	cp c, 0x00:i3                                          ; FBFC39  cb d8
	jr nz, .LFBFC42                                      ; FBFC3B  6e 05
	ld (XIX),0x01                                        ; FBFC3D  b4 00 01
	jr .LFBFC45                                          ; FBFC40  68 03
.LFBFC42:
	ld (XIX),0x00                                        ; FBFC42  b4 00 00
.LFBFC45:
	ld C,(XIX)                                           ; FBFC45  84 23
	pushw bc                                             ; FBFC47  29
	call T_NoteRouting_SetSoloAndRebuild                                        ; FBFC48  1d ec 11 f4
	set	4, (UI_ScreenFlags:16)                               ; FBFC4C  f1 95 20 bc
	popw bc                                              ; FBFC50  49
	pop XIX                                              ; FBFC51  5c
	ret                                                  ; FBFC52  0e
; SoftKeyCol1_CombiEditMenu: ScreenButtons_CombiEditMenu[0], the 23-slot button table ScreenButton_CombiEditMenu reads through T_PanelCode_ToSlotAndFlags -- the
;   SoftKeyCol1 handler of CombiEditMenu (notes/prom_ab_promb_slot23_targets.py).
SoftKeyCol1_CombiEditMenu:
	link XIZ,0xfffa                                      ; FBFC53  ee 0c fa ff
	pushw hl                                             ; FBFC57  2b
	pushw de                                             ; FBFC58  2a
	push XIX                                             ; FBFC59  3c
	push XDE                                             ; FBFC5A  3a
	push XHL                                             ; FBFC5B  3b
	push XIX                                             ; FBFC5C  3c
	push XIZ                                             ; FBFC5D  3e
	call T_ParamImage_SnapshotCombination_Entry                                        ; FBFC5E  1d 4c 02 f4
	pop XIZ                                              ; FBFC62  5e
	pop XIX                                              ; FBFC63  5c
	pop XHL                                              ; FBFC64  5b
	pop XDE                                              ; FBFC65  5a
	lda xix, (Combination_Current:16)                                ; FBFC66  f1 20 76 34
	lda xbc, (0x7000:16)                                ; FBFC6A  f1 00 70 31
	ld (xiz-4), xbc                                      ; FBFC6E  be fc 61
	ldw hl, 0x00                                         ; FBFC71  33 00 00
	ldw wa, Combination_Current                                       ; FBFC74  30 20 76
	ld (xiz-6), wa                                       ; FBFC77  be fa 50
	ldw bc, 0x78de                                       ; FBFC7A  31 de 78
	sub BC,WA                                            ; FBFC7D  d8 a1
	inc 2,BC                                             ; FBFC7F  d9 62
	exts XBC                                             ; FBFC81  e9 13
	divs BC,0x0002                                       ; FBFC83  d9 0b 02 00
	ld DE,BC                                             ; FBFC87  d9 8a
.LFBFC89:
	cp HL,DE                                             ; FBFC89  da f3
	jr nc, .LFBFCA1                                      ; FBFC8B  6f 14
	ld xbc, (xiz-4)                                      ; FBFC8D  ae fc 21
	ld WA,(XBC)                                          ; FBFC90  91 20
	ld (XIX),WA                                          ; FBFC92  b4 50
	sub XBC,XBC                                          ; FBFC94  e9 a1
	inc 2,XBC                                            ; FBFC96  e9 62
	add (xiz-4), xbc                                     ; FBFC98  ae fc 89
	add XIX,XBC                                          ; FBFC9B  e9 84
	inc 1,HL                                             ; FBFC9D  db 61
	jr .LFBFC89                                          ; FBFC9F  68 e8
.LFBFCA1:
	pushw 0x00                                           ; FBFCA1  0b 00 00
	call T_IndexedTable_GetPtr                           ; FBFCA4  1d 8c 2c f4
	ld XIX,XIY                                           ; FBFCA8  ed 8c
	add XIY,0x0000000d                                   ; FBFCAA  ed c8 0d 00 00 00
	ld XIX,XIY                                           ; FBFCB0  ed 8c
	and (XIY),0xdf                                       ; FBFCB2  85 3c df
	ldw de, 0x76a2                                       ; FBFCB5  32 a2 76
	ldw bc, 0x76e2                                       ; FBFCB8  31 e2 76
	sub BC,DE                                            ; FBFCBB  da a1
	exts XBC                                             ; FBFCBD  e9 13
	ld (xiz-4), xbc                                      ; FBFCBF  be fc 61
	ld h, 0x07:opc                                          ; FBFCC2  26 07
	popw bc                                              ; FBFCC4  49
.LFBFCC5:
	add	xix, (xiz-4)                                 ; FBFCC5  ae fc 84
	or	(xix), 0x20                                  ; FBFCC8  84 3e 20
	dec 1,H                                              ; FBFCCB  ce 69
	cp h, 0x00:i3                                          ; FBFCCD  ce d8
	jr nz, .LFBFCC5                                      ; FBFCCF  6e f4
	push XDE                                             ; FBFCD1  3a
	push XHL                                             ; FBFCD2  3b
	push XIX                                             ; FBFCD3  3c
	push XIZ                                             ; FBFCD4  3e
	call T_ParamImage_QueueDiffCombination                                        ; FBFCD5  1d 48 02 f4
	pop XIZ                                              ; FBFCD9  5e
	pop XIX                                              ; FBFCDA  5c
	pop XHL                                              ; FBFCDB  5b
	pop XDE                                              ; FBFCDC  5a
	ld (UI_StatusCode:16), 0x23                                 ; FBFCDD  f1 80 28 00 23
	set	6, (UI_Request_Hi:16)                               ; FBFCE2  f1 71 20 be
	ld (UI_Request:16), 0xab                                 ; FBFCE6  f1 70 20 00 ab
	pop XIX                                              ; FBFCEB  5c
	popw de                                              ; FBFCEC  4a
	popw hl                                              ; FBFCED  4b
	unlk XIZ                                             ; FBFCEE  ee 0d
	ret                                                  ; FBFCF0  0e
.LFBFCF1:
	push XIX                                             ; FBFCF1  3c
	lda xix, (T_DisplayList_Run_Stack:24)                ; FBFCF2  f2 00 2e f4 34
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; FBFCF7  1d 10 2e f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBFCFB  f1 40 25 00 02
	lda xbc, (DL_Part_F18BBA:24)                         ; FBFD00  f2 ba 8b f1 31
	push XBC                                             ; FBFD05  39
	lda xwa, (DL_CopyFromSoundPlay:24)                   ; FBFD06  f2 b7 8a f1 30
	push XWA                                             ; FBFD0B  38
	lda xiy, (.LFBFD14:24)                               ; FBFD0C  f2 14 fd fb 35
	push XIY                                             ; FBFD11  3d
	jp (xix)                                             ; FBFD12  b4 d8
.LFBFD14:
	lda xbc, (DL_F18CD5:24)                              ; FBFD14  f2 d5 8c f1 31
	push XBC                                             ; FBFD19  39
	lda xwa, (DL_Part_F18C69:24)                         ; FBFD1A  f2 69 8c f1 30
	push XWA                                             ; FBFD1F  38
	lda xiy, (.LFBFD28:24)                               ; FBFD20  f2 28 fd fb 35
	push XIY                                             ; FBFD25  3d
	jp (xix)                                             ; FBFD26  b4 d8
.LFBFD28:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBFD28  f1 40 25 00 00
	lda xbc, (DL_F18C08:24)                              ; FBFD2D  f2 08 8c f1 31
	push XBC                                             ; FBFD32  39
	lda xwa, (DL_Solo_F18BE8:24)                         ; FBFD33  f2 e8 8b f1 30
	push XWA                                             ; FBFD38  38
	lda xiy, (.LFBFD41:24)                               ; FBFD39  f2 41 fd fb 35
	push XIY                                             ; FBFD3E  3d
	jp (xix)                                             ; FBFD3F  b4 d8
.LFBFD41:
	add XSP,0x00000018                                   ; FBFD41  ef c8 18 00 00 00
	pop XIX                                              ; FBFD47  5c
	ret                                                  ; FBFD48  0e
.LFBFD49:
	push XIX                                             ; FBFD49  3c
	ld (LCD_CurrentLayer:16), 0x01                                 ; FBFD4A  f1 40 25 00 01
	cp	(0x276f:16), 0x00                            ; FBFD4F  c1 6f 27 3f 00
	jr nz, .LFBFD5E                                      ; FBFD54  6e 08
	lda xbc, (DL_F18C08:24)                              ; FBFD56  f2 08 8c f1 31
	push XBC                                             ; FBFD5B  39
	jr .LFBFD64                                          ; FBFD5C  68 06
.LFBFD5E:
	lda xbc, (DL_F18C12:24)                              ; FBFD5E  f2 12 8c f1 31
	push XBC                                             ; FBFD63  39
.LFBFD64:
	call T_DisplayList_RunOne_Stack                      ; FBFD64  1d 08 2e f4
	lda xix, (CombiEdit_Part:16)                                ; FBFD68  f1 65 27 34
	pushw 0x1d                                           ; FBFD6C  0b 1d 00
	ld C,(XIX)                                           ; FBFD6F  84 23
	extz BC                                              ; FBFD71  d9 12
	add BC,0x0020                                        ; FBFD73  d9 c8 20 00
	pushw bc                                             ; FBFD77  29
	call T_IndexedTable_GetByte                          ; FBFD78  1d 90 2c f4
	ld (UI_DrawScratch:16), a                                   ; FBFD7C  f1 40 26 41
	pushw 0x0d                                           ; FBFD80  0b 0d 00
	ld C,(XIX)                                           ; FBFD83  84 23
	pushw bc                                             ; FBFD85  29
	call T_IndexedTable_GetByte                          ; FBFD86  1d 90 2c f4
	ld (UI_DrawScratch+1:16), a                                   ; FBFD8A  f1 41 26 41
	ld (LCD_CurrentLayer:16), 0x02                                 ; FBFD8E  f1 40 25 00 02
	lda xbc, (StringTable_F19238:24)                     ; FBFD93  f2 38 92 f1 31
	push XBC                                             ; FBFD98  39
	lda xwa, (DL_F19207:24)                              ; FBFD99  f2 07 92 f1 30
	push XWA                                             ; FBFD9E  38
	call T_DisplayListB_Run_Stack                        ; FBFD9F  1d 04 2e f4
	ld C,(XIX)                                           ; FBFDA3  84 23
	pushw bc                                             ; FBFDA5  29
	call T_PartSound_CopyNameToDrawScratch                                        ; FBFDA6  1d a0 2c f4
	lda xbc, (DL_F191F8:24)                              ; FBFDAA  f2 f8 91 f1 31
	push XBC                                             ; FBFDAF  39
	call T_DisplayListB_RunOne_Stack                     ; FBFDB0  1d 0c 2e f4
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; FBFDB4  1d 14 2e f4
	add XSP,0x0000001a                                   ; FBFDB8  ef c8 1a 00 00 00
	pop XIX                                              ; FBFDBE  5c
	ret                                                  ; FBFDBF  0e
ScreenEnterBody_Effect2OutputConflict:
	lda xbc, (.LFBFE42:24)                               ; FBFDC0  f2 42 fe fb 31
	push XBC                                             ; FBFDC5  39
	call T_CallbackQueue_Post                            ; FBFDC6  1d 84 2e f4
	pushw 0x01                                           ; FBFDCA  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBFDCD  1d c0 2d f4
	inc 6,XSP                                            ; FBFDD1  ef 66
	ret                                                  ; FBFDD3  0e
ScreenLeaveBody_Effect2OutputConflict:
	pushw hl                                             ; FBFDD4  2b
	ld h, (PanelModeGroup:16)                                   ; FBFDD5  c1 76 20 26
	cp H,0x08                                            ; FBFDD9  ce cf 08
	jr z, .LFBFDE7                                       ; FBFDDC  66 09
	cp h, 0x03:i3                                          ; FBFDDE  ce db
	jr z, .LFBFDE7                                       ; FBFDE0  66 05
	cp H,0x15                                            ; FBFDE2  ce cf 15
	jr nz, .LFBFDF5                                      ; FBFDE5  6e 0e
.LFBFDE7:
	set	6, (UI_Request_Hi:16)                               ; FBFDE7  f1 71 20 be
	ld (UI_Request:16), 0xb7                                 ; FBFDEB  f1 70 20 00 b7
; Var277E_Set02: ld (0x277e:16), 0x02; popw hl (single-cell template; the cell's meaning is not established unless it is named)
Var277E_Set02:
	ld (0x277e:16), 0x02                                 ; FBFDF0  f1 7e 27 00 02
.LFBFDF5:
	popw hl                                              ; FBFDF5  4b
	ret                                                  ; FBFDF6  0e
ScreenButtonBody_Effect2OutputConflict:
	link XIZ,0x0000                                      ; FBFDF7  ee 0c 00 00
; (sub_FBFDFB removed 2026-10-04: no code names it and the line above falls through into it -- part of ScreenButtonBody_Effect2OutputConflict;
;  notes/prom_a_stray_label_removal.py)
	pushw	(xiz+10)                                     ; FBFDFB  9e 0a 04
	pushw	(xiz+8)                                      ; FBFDFE  9e 08 04
	call T_PanelCode_ToSlotAndFlags                                        ; FBFE01  1d 74 2c f4
	mul A,0x04                                           ; FBFE05  c9 08 04
	extz XWA                                             ; FBFE08  e8 12
	add XWA,ScreenButtons_Effect2OutputConflict                              ; FBFE0A  e8 c8 f1 b2 f1 00
	ld XBC,(XWA)                                         ; FBFE10  a0 21
	lda xiy, (.LFBFE1A:24)                               ; FBFE12  f2 1a fe fb 35
	push XIY                                             ; FBFE17  3d
	jp (xbc)                                             ; FBFE18  b1 d8
.LFBFE1A:
	pop XBC                                              ; FBFE1A  59
	unlk XIZ                                             ; FBFE1B  ee 0d
	ret                                                  ; FBFE1D  0e
	ret                                                  ; FBFE1E  0e
; ExitKey_Effect2OutputConflict: ScreenButtons_Effect2OutputConflict[15], the 23-slot button table ScreenButtonBody_Effect2OutputConflict reads through T_PanelCode_ToSlotAndFlags -- the
;   ExitKey handler of Effect2OutputConflict (notes/prom_ab_promb_slot23_targets.py).
ExitKey_Effect2OutputConflict:
	ld c, (PanelEvent_Flags:16)                                   ; FBFE1F  c1 b0 28 23
	and C,0x01                                           ; FBFE23  cb cc 01
	jr nz, .LFBFE41                                      ; FBFE26  6e 19
	ld c, (UI_ScreenHoldState:16)                                   ; FBFE28  c1 92 20 23
; (sub_FBFE2C removed 2026-10-04: no code names it and the line above falls through into it -- part of ScreenButtonBody_Effect2OutputConflict;
;  notes/prom_a_stray_label_removal.py)
	and C,0x01                                           ; FBFE2C  cb cc 01
	jr z, .LFBFE38                                       ; FBFE2F  66 07
	ld (UI_ScreenHoldPending:16), 0x01                                 ; FBFE31  f1 9a 20 00 01
	jr .LFBFE41                                          ; FBFE36  68 09
.LFBFE38:
	set	1, (UI_Request_Hi:16)                               ; FBFE38  f1 71 20 b9
	ld (UI_Request:16), 0x01                                 ; FBFE3C  f1 70 20 00 01
.LFBFE41:
	ret                                                  ; FBFE41  0e
.LFBFE42:
	push XIX                                             ; FBFE42  3c
	lda xix, (LCD_CurrentLayer:16)                                ; FBFE43  f1 40 25 34
	cp	(PanelModeGroup:16), 0x01                            ; FBFE47  c1 76 20 3f 01
	jr z, .LFBFE55                                       ; FBFE4C  66 07
	cp	(PanelModeGroup:16), 0x02                            ; FBFE4E  c1 76 20 3f 02
	jr nz, .LFBFE82                                      ; FBFE53  6e 2d
.LFBFE55:
	ld (XIX),0x02                                        ; FBFE55  b4 00 02
	lda xbc, (DL_F1A84F:24)                              ; FBFE58  f2 4f a8 f1 31
	push XBC                                             ; FBFE5D  39
	call T_DisplayList_RunOne_Stack                      ; FBFE5E  1d 08 2e f4
	ld (XIX),0x01                                        ; FBFE62  b4 00 01
	lda xbc, (DL_F1A84F:24)                              ; FBFE65  f2 4f a8 f1 31
	push XBC                                             ; FBFE6A  39
	call T_DisplayList_RunOne_Stack                      ; FBFE6B  1d 08 2e f4
	ld (XIX),0x00                                        ; FBFE6F  b4 00 00
	inc 8,XSP                                            ; FBFE72  ef 60
	lda xbc, (ExitKey_Effect2OutputConflict_DL:24)                              ; FBFE74  f2 ef a8 f1 31
	push XBC                                             ; FBFE79  39
	lda xwa, (DL_F1A84F:24)                              ; FBFE7A  f2 4f a8 f1 30
	push XWA                                             ; FBFE7F  38
	jr .LFBFEAD                                          ; FBFE80  68 2b
.LFBFE82:
	ld (XIX),0x02                                        ; FBFE82  b4 00 02
	lda xbc, (ExitKey_Effect2OutputConflict_DL:24)                              ; FBFE85  f2 ef a8 f1 31
	push XBC                                             ; FBFE8A  39
	call T_DisplayList_RunOne_Stack                      ; FBFE8B  1d 08 2e f4
	ld (XIX),0x01                                        ; FBFE8F  b4 00 01
	lda xbc, (ExitKey_Effect2OutputConflict_DL:24)                              ; FBFE92  f2 ef a8 f1 31
	push XBC                                             ; FBFE97  39
	call T_DisplayList_RunOne_Stack                      ; FBFE98  1d 08 2e f4
	ld (XIX),0x00                                        ; FBFE9C  b4 00 00
	inc 8,XSP                                            ; FBFE9F  ef 60
	lda xbc, (DL_Err0rTheS0undOrC0mbinati0n:24)          ; FBFEA1  f2 99 a9 f1 31
	push XBC                                             ; FBFEA6  39
	lda xwa, (ExitKey_Effect2OutputConflict_DL:24)                              ; FBFEA7  f2 ef a8 f1 30
	push XWA                                             ; FBFEAC  38
.LFBFEAD:
	call T_DisplayList_Run_Stack                         ; FBFEAD  1d 00 2e f4
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; FBFEB1  1d 14 2e f4
	inc 8,XSP                                            ; FBFEB5  ef 60
	pop XIX                                              ; FBFEB7  5c
	ret                                                  ; FBFEB8  0e
ScreenEnterBody_WriteProtectError:
	set	7, (UI_RequestBits:16)                               ; FBFEB9  f1 75 20 bf
	call T_CallbackQueue_ResetAndRestartTask2            ; FBFEBD  1d 80 2e f4
	lda xbc, (.LFBFF40:24)                               ; FBFEC1  f2 40 ff fb 31
	push XBC                                             ; FBFEC6  39
	call T_CallbackQueue_Post                            ; FBFEC7  1d 84 2e f4
	pushw 0x01                                           ; FBFECB  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; FBFECE  1d c0 2d f4
	inc 6,XSP                                            ; FBFED2  ef 66
	ret                                                  ; FBFED4  0e
; ---------------------------------------------------------------------
; Var2075_ClrBit7 -- clear bit 7 of (0x2075)
;
; A single-cell accessor of the C-compiled half of prom_a: 2
; instructions, 0xFBFED5 to 0xFBFED9, with no branch.
; Called from: 1 proven call sites, first a 0xFBC5C1.
; Evidence: the body decoded from the ROM matches one of the 15
;          templates in notes/prom_a_naming_round3.py EXACTLY,
;          instruction for instruction, and touches exactly ONE
;          absolute address, 0x2075.  The name states the cell and the
;          direction and claims nothing about meaning.
; Note:     (0x2075) is the panel mode-flag byte PanelButton_Route and PanelButton_Accept test bit by bit (prom_a 0xF861B6 onward).
; ---------------------------------------------------------------------
Var2075_ClrBit7:
	res	7, (UI_RequestBits:16)                               ; FBFED5  f1 75 20 b7
	ret                                                  ; FBFED9  0e
ScreenButtonBody_WriteProtectError:
	link XIZ,0x0000                                      ; FBFEDA  ee 0c 00 00
	pushw	(xiz+10)                                     ; FBFEDE  9e 0a 04
	pushw	(xiz+8)                                      ; FBFEE1  9e 08 04
	call T_PanelCode_ToSlotAndFlags                                        ; FBFEE4  1d 74 2c f4
	mul A,0x04                                           ; FBFEE8  c9 08 04
	extz XWA                                             ; FBFEEB  e8 12
	add XWA,ScreenButtons_WriteProtectError                              ; FBFEED  e8 c8 4d b3 f1 00
	ld XBC,(XWA)                                         ; FBFEF3  a0 21
	lda xiy, (.LFBFEFD:24)                               ; FBFEF5  f2 fd fe fb 35
	push XIY                                             ; FBFEFA  3d
	jp (xbc)                                             ; FBFEFB  b1 d8
.LFBFEFD:
	pop XBC                                              ; FBFEFD  59
	unlk XIZ                                             ; FBFEFE  ee 0d
	ret                                                  ; FBFF00  0e
	ret                                                  ; FBFF01  0e
; LcdKeyRow3_WriteProtectError: ScreenButtons_WriteProtectError[10], the 23-slot button table ScreenButtonBody_WriteProtectError reads through T_PanelCode_ToSlotAndFlags -- the
;   LcdKeyRow3 handler of WriteProtectError (notes/prom_ab_promb_slot23_targets.py).
LcdKeyRow3_WriteProtectError:
	ld c, (PanelEvent_Flags:16)                                   ; FBFF02  c1 b0 28 23
	and C,0x01                                           ; FBFF06  cb cc 01
	jr nz, .LFBFF18                                      ; FBFF09  6e 0d
	res	7, (UI_RequestBits:16)                               ; FBFF0B  f1 75 20 b7
	set	6, (UI_Request_Hi:16)                               ; FBFF0F  f1 71 20 be
	ld (UI_Request:16), 0x6e                                 ; FBFF13  f1 70 20 00 6e
.LFBFF18:
	ret                                                  ; FBFF18  0e
; WriteProtectError_Dismiss: slots 11 (LCD key row 4) and 15 (EXIT) of ScreenButtons_WriteProtectError: on the release, either UI_ScreenHoldPending
;   = 1 (while UI_ScreenHoldState bit 0, with UI_RequestBits bit 7 cleared) or UI_Request = 1 with UI_Request_Hi bit 1.
;   Basis: table (button code) + body.
WriteProtectError_Dismiss:
	ld c, (PanelEvent_Flags:16)                                   ; FBFF19  c1 b0 28 23
	and C,0x01                                           ; FBFF1D  cb cc 01
	jr nz, .LFBFF3F                                      ; FBFF20  6e 1d
	ld c, (UI_ScreenHoldState:16)                                   ; FBFF22  c1 92 20 23
	and C,0x01                                           ; FBFF26  cb cc 01
	jr z, .LFBFF36                                       ; FBFF29  66 0b
	res	7, (UI_RequestBits:16)                               ; FBFF2B  f1 75 20 b7
	ld (UI_ScreenHoldPending:16), 0x01                                 ; FBFF2F  f1 9a 20 00 01
	jr .LFBFF3F                                          ; FBFF34  68 09
.LFBFF36:
	set	1, (UI_Request_Hi:16)                               ; FBFF36  f1 71 20 b9
	ld (UI_Request:16), 0x01                                 ; FBFF3A  f1 70 20 00 01
.LFBFF3F:
	ret                                                  ; FBFF3F  0e
.LFBFF40:
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; FBFF40  1d 10 2e f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FBFF44  f1 40 25 00 00
	lda xbc, (PartParamField_KeyLayerLow:24)                          ; FBFF49  f2 7c aa f1 31
	push XBC                                             ; FBFF4E  39
	lda xwa, (DL_Err0rTheS0undOrC0mbinati0n:24)          ; FBFF4F  f2 99 a9 f1 30
	push XWA                                             ; FBFF54  38
	call T_DisplayList_Run_Stack                         ; FBFF55  1d 00 2e f4
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; FBFF59  1d 14 2e f4
	inc 8,XSP                                            ; FBFF5D  ef 60
	ret                                                  ; FBFF5F  0e
	xor (XDE),B                                          ; FBFF60  82 da
	ldw hl, 0x660f                                       ; FBFF62  33 0f 66
	reti                                                 ; FBFF65  07
	bit 0x0f,HL                                          ; FBFF66  db 33 0f
	jr z, .LFBFF73                                       ; FBFF69  66 08
	xor DE,DE                                            ; FBFF6B  da d2
	cp DE,IY                                             ; FBFF6D  dd f2
	jr nc, .LFBFF73                                      ; FBFF6F  6f 02
	ld DE,IY                                             ; FBFF71  dd 8a
.LFBFF73:
	cp DE,IX                                             ; FBFF73  dc f2
	jr ule, .LFBFF79                                     ; FBFF75  63 02
	ld DE,IX                                             ; FBFF77  dc 8a
.LFBFF79:
	ret                                                  ; FBFF79  0e
	nop                                                  ; FBFF7A  00
	normal                                               ; FBFF7B  01
	push SR                                              ; FBFF7C  02
	pop SR                                               ; FBFF7D  03
	max                                                  ; FBFF7E  04
	halt                                                 ; FBFF7F  05
	ei 0x07                                              ; FBFF80  06 07
	nop                                                  ; FBFF82  00
	swi 7                                                ; FBFF83  ff
	swi 6                                                ; FBFF84  fe
	swi 5                                                ; FBFF85  fd
	swi 4                                                ; FBFF86  fc
	swi 3                                                ; FBFF87  fb
	swi 2                                                ; FBFF88  fa
	swi 1                                                ; FBFF89  f9
	jp WriteProtectError_Dismiss_Join                                        ; FBFF8A  1b a2 ff fb
	ret                                                  ; FBFF8E  0e
	nop                                                  ; FBFF8F  00
	nop                                                  ; FBFF90  00
	nop                                                  ; FBFF91  00
	ret                                                  ; FBFF92  0e
	nop                                                  ; FBFF93  00
	nop                                                  ; FBFF94  00
	nop                                                  ; FBFF95  00
	ret                                                  ; FBFF96  0e
	nop                                                  ; FBFF97  00
	nop                                                  ; FBFF98  00
	nop                                                  ; FBFF99  00
	ret                                                  ; FBFF9A  0e
	nop                                                  ; FBFF9B  00
	nop                                                  ; FBFF9C  00
	nop                                                  ; FBFF9D  00
	ret                                                  ; FBFF9E  0e
	nop                                                  ; FBFF9F  00
	nop                                                  ; FBFFA0  00
	nop                                                  ; FBFFA1  00
WriteProtectError_Dismiss_Join:
	calr sub_FBFFA6                                      ; FBFFA2  1e 01 00
	ret                                                  ; FBFFA5  0e
sub_FBFFA6:
	ld XBC,0x00000000                                    ; FBFFA6  41 00 00 00 00
	and XBC,XBC                                          ; FBFFAB  e9 c1
	jr z, .LFBFFBB                                       ; FBFFAD  66 0c
	lda xiy, (sub_FBFFA6_Data:24)                               ; FBFFAF  f2 d5 ff fb 35
	lda xix, (0x00:24)                                   ; FBFFB4  f2 00 00 00 34
	ldir85                                               ; FBFFB9  85 11
.LFBFFBB:
	ld XBC,0x0000001f                                    ; FBFFBB  41 1f 00 00 00
	and XBC,XBC                                          ; FBFFC0  e9 c1
	jr z, .LFBFFD4                                       ; FBFFC2  66 10
	lda xix, (0x2760:24)                                 ; FBFFC4  f2 60 27 00 34
	xor WA,WA                                            ; FBFFC9  d8 d0
.LFBFFCB:
	ld (xix+), a                                    ; FBFFCB  f5 f0 41
	sub BC,0x0001                                        ; FBFFCE  d9 ca 01 00
	jr nz, .LFBFFCB                                      ; FBFFD2  6e f7
.LFBFFD4:
	ret                                                  ; FBFFD4  0e

; 0xFBFFD5-0xFBFFFF -- 43 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
sub_FBFFA6_Data:
	.fill 43, 1, 0x0E
