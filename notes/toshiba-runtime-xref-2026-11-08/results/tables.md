#### maincpu v10: exact hits (28)

| address  | Toshiba name           | bytes | our label                | library builds                                 | check            |
|----------|------------------------|-------|--------------------------|------------------------------------------------|------------------|
| 0xeed778 | `___ctype` / `__ctype` | 256   | `CType_ClassTable`       | IDE ml, IDE pic, V4.23 ml, v1.10 ml            | ambiguous        |
| 0xeed8a4 | `__doform_c data`      | 35    | `Sprintf_HexDigitsLower` | IDE pic                                        | no matched refs  |
| 0xff091d | `_strstr`              | 96    | `TmFlash_CompareStrings` | IDE ml, V4.23 ml                               | refs confirmed 2 |
| 0xff097d | `_strcspn`             | 35    | `StrSearch_Init`         | IDE ml, V4.23 ml                               | no matched refs  |
| 0xff09a0 | `_atoi`                | 86    | `ParseInt16`             | IDE ml, V4.23 ml                               | no matched refs  |
| 0xff09f6 | `_atol`                | 102   | `ParseInt32`             | IDE ml, V4.23 ml                               | no matched refs  |
| 0xff0a5c | `C9H_mullu`            | 22    | `Math_Multiply32`        | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | no matched refs  |
| 0xff0bc3 | `SDivMod`              | 71    | `Math_DivModSigned32`    | IDE ml, V4.23 ml                               | no matched refs  |
| 0xff0c18 | `C9H_divlu`            | 122   | `Math_DivideU32`         | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs  |
| 0xff0c92 | `_strncat`             | 47    | `Strncat`                | IDE ml, V4.23 ml                               | no matched refs  |
| 0xff0cc1 | `_strncmp`             | 50    | `String_Compare`         | IDE ml, V4.23 ml                               | no matched refs  |
| 0xff0cf3 | `_strncpy`             | 43    | `Strncpy`                | IDE ml, V4.23 ml                               | no matched refs  |
| 0xff0d1e | `_memcmp`              | 123   | `Mem_Compare`            | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs  |
| 0xff0d99 | `_memcpy`              | 40    | `Mem_Copy`               | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs  |
| 0xff0dc1 | `_strcat`              | 34    | `Strcat`                 | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs  |
| 0xff0de3 | `_itoa`                | 138   | `Itoa_Safe`              | IDE ml, V4.23 ml                               | refs confirmed 1 |
| 0xff0e6d | `_strchr`              | 19    | `Strchr`                 | IDE ml, V4.23 ml                               | no matched refs  |
| 0xff0f4d | `_strcpy`              | 44    | `Strcpy`                 | IDE ml, V4.23 ml                               | refs confirmed 1 |
| 0xff0f79 | `.sbrk`                | 39    | `Heap_Alloc`             | IDE ml, V4.23 ml                               | no matched refs  |
| 0xff0fa0 | `_strlen`              | 30    | `Strlen`                 | IDE ml, V4.23 ml                               | refs confirmed 1 |
| 0xff0fbe | `_ltoa`                | 60    | `Strlen_LoadParam`       | IDE ml, V4.23 ml                               | refs confirmed 1 |
| 0xff0ffa | `_memset`              | 68    | `Memset`                 | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs  |
| 0xff27f7 | `_ultoa`               | 136   | `Sprintf_ItoaBaseN`      | IDE ml                                         | refs confirmed 2 |
| 0xff2880 | `._fld_xx`             | 17    | `Sprintf_CopyBytes10`    | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | no matched refs  |
| 0xff2891 | `_memccpy`             | 64    | `Sprintf_StringNSearch`  | V4.23 ml                                       | refs confirmed 2 |
| 0xff28d1 | `_memchr`              | 24    | `Sprintf_MemChr`         | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs  |
| 0xff28e9 | `_strnset`             | 32    | `Sprintf_StrNSet`        | IDE ml, V4.23 ml                               | no matched refs  |
| 0xff2909 | `_strrchr`             | 39    | `Sprintf_StringLength`   | V4.23 ml                                       | refs confirmed 1 |

#### maincpu v10: names read from those routines' calls and pointers (4)

| address  | Toshiba name  | referenced from | our label           |
|----------|---------------|-----------------|---------------------|
| 0xeed778 | `__ctype`     | `_atoi`         | `CType_ClassTable`  |
| 0x03d528 | `_SBRK_size`  | `.sbrk`         | (no label)          |
| 0x03d524 | `_SBRK_break` | `.sbrk`         | (no label)          |
| 0xff0c12 | `C9H_remlu`   | `_ultoa`        | `Math_RemainderU32` |

#### subcpu v142: exact hits (54)

| address  | Toshiba name                                  | bytes | our label                     | library builds                                 | check                                      |
|----------|-----------------------------------------------|-------|-------------------------------|------------------------------------------------|--------------------------------------------|
| 0x00f34e | `__trig_c data`                               | 96    | `FPConst_InvFact3`            | IDE ml, IDE pic, V4.23 ml                      | no matched refs                            |
| 0x00f3ba | `_g_dbltbl`                                   | 72    | `FPConst_Pi`                  | IDE ml, IDE pic, V4.23 ml                      | no matched refs                            |
| 0x00f402 | `_g_ldbltbl`                                  | 30    | `FPConst_NegZero`             | IDE ml, IDE pic, V4.23 ml, v1.10 ml            | no matched refs                            |
| 0x01f646 | `_pow_c data`                                 | 72    | `FPConst_Int32_Min_As_Double` | V4.23 ml                                       | no matched refs                            |
| 0x01f6b6 | `_exp_c data`                                 | 40    | `FPConst_exp_One`             | V4.23 ml                                       | no matched refs                            |
| 0x03d2ac | `._fcmp_d`                                    | 90    | `FP_dcmp`                     | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03d306 | `._fcmp_f`                                    | 71    | `FP_fcmp`                     | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03d34d | `_cos`                                        | 87    | `FP_cos`                      | V4.23 ml                                       | refs confirmed 3                           |
| 0x03d3a4 | `._fdiv_d`                                    | 48    | `FP_ddiv`                     | IDE ml, V4.23 ml                               | callee score ._fdiv_d 0.49, ._fmul_d 0.08  |
| 0x03d3d4 | `._fdiv_f`                                    | 48    | `FP_fdiv`                     | IDE ml, V4.23 ml                               | callee score ._fdiv_f 0.88, ._fmul_f 0.21  |
| 0x03d404 | `._fneg_d`                                    | 24    | `FP_DP_CopyOrNegate8`         | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03d41c | `._fneg_f`                                    | 18    | `FP_SP_CopyOrNegate4`         | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03d42e | `_fabs`                                       | 29    | `FP_fabs`                     | IDE ml, V4.23 ml                               | refs confirmed 2                           |
| 0x03d44c | `._fld_ulf`                                   | 25    | `FP_ftoi`                     | IDE ml, V4.23 ml                               | refs confirmed 1                           |
| 0x03d466 | `._fcmp_zd`                                   | 52    | `FP_DP_CmpZero64`             | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03d49a | `._fcmp_zf`                                   | 47    | `FP_SP_CmpZero32`             | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03d4c9 | `_tan`                                        | 106   | `FP_tan`                      | V4.23 ml                                       | refs confirmed 3                           |
| 0x03d533 | `_pow`                                        | 796   | `FP_pow`                      | V4.23 ml                                       | refs confirmed 9                           |
| 0x03d84f | `_sin`                                        | 123   | `FP_sin`                      | V4.23 ml                                       | refs confirmed 3                           |
| 0x03d8ca | `C9H_mullu`                                   | 22    | `Math_Multiply32`             | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | no matched refs                            |
| 0x03d8e0 | `._fsub_d`                                    | 75    | `FP_dsub`                     | IDE ml, V4.23 ml                               | refs confirmed 2                           |
| 0x03d92c | `._fsub_f`                                    | 75    | `FP_fsub`                     | IDE ml, V4.23 ml                               | refs confirmed 5                           |
| 0x03d98a | `__trig`                                      | 650   | `FP_SinCos_Kernel`            | V4.23 ml                                       | refs confirmed 7                           |
| 0x03dc14 | `SDivMod`                                     | 71    | `Int_SignedDiv`               | IDE ml, V4.23 ml                               | no matched refs                            |
| 0x03dd36 | `._fld_dl`                                    | 27    | `FP_ScalarToDP`               | IDE ml, V4.23 ml                               | callee score ._fld_dl 1.00, ._fld_dul 0.01 |
| 0x03dd51 | `._fld_dul`                                   | 27    | `FP_DP_CallWithBuf12`         | IDE ml, V4.23 ml                               | callee score ._fld_dl 0.00, ._fld_dul 0.50 |
| 0x03ddca | `._fld_fl`                                    | 27    | `FP_SP_CallWithBuf8`          | IDE ml, V4.23 ml                               | refs confirmed 1                           |
| 0x03dde5 | `._fld_fl_tail`                               | 27    | `FP_SP_CallWithBuf8b`         | IDE ml, V4.23 ml                               | refs confirmed 2                           |
| 0x03de00 | `._fld_uld`                                   | 25    | `FP_DP_DecodeToInt`           | IDE ml, V4.23 ml                               | refs confirmed 1                           |
| 0x03de1a | `._fcvt_dacl` / `._fcvt_facl` / `._fcvt_xacl` | 25    | `FP_DP_Normalize`             | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | ambiguous                                  |
| 0x03de33 | `._fcvt_facul`                                | 90    | `FP_DP_NormCore`              | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03de8e | `._fcvt_lfac`                                 | 92    | `FP_DP_ShiftDecode`           | IDE ml, V4.23 ml                               | no matched refs                            |
| 0x03df38 | `._fadd_acf`                                  | 39    | `FP_SP_AddMantissa`           | IDE ml, V4.23 ml                               | no matched refs                            |
| 0x03df60 | `._fset_acd`                                  | 60    | `FP_DP_Decode`                | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03df9c | `._fset_acf`                                  | 57    | `FP_SP_Decode`                | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03dfd6 | `._fcvt_dacl` / `._fcvt_facl` / `._fcvt_xacl` | 25    | `FP_SP_Normalize`             | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | ambiguous                                  |
| 0x03e046 | `._fset_dac`                                  | 105   | `FP_DP_Encode`                | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                            |
| 0x03e0b0 | `._fset_fac`                                  | 94    | `FP_SP_Encode`                | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                            |
| 0x03e10e | `._fadd_d`                                    | 75    | `FP_dadd`                     | IDE ml, V4.23 ml                               | refs confirmed 2                           |
| 0x03e15a | `._fadd_f`                                    | 75    | `FP_fadd`                     | IDE ml, V4.23 ml                               | refs confirmed 5                           |
| 0x03e1a5 | `_modf`                                       | 76    | `FP_modf`                     | V4.23 ml                                       | refs confirmed 2                           |
| 0x03e1f1 | `_frexp`                                      | 158   | `FP_frexp`                    | IDE ml, V4.23 ml, v1.10 ml                     | refs confirmed 1                           |
| 0x03e290 | `._fmul_d`                                    | 48    | `FP_dmul`                     | IDE ml, V4.23 ml                               | callee score ._fdiv_d 0.10, ._fmul_d 0.63  |
| 0x03e2c0 | `._fmul_f`                                    | 48    | `FP_fmul`                     | IDE ml, V4.23 ml                               | callee score ._fdiv_f 0.14, ._fmul_f 0.71  |
| 0x03e3a0 | `._fadj_acf`                                  | 86    | `FP_SP_AlignMantissa`         | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03e5f6 | `._fsub_acf`                                  | 85    | `FP_SP_SubMantissa`           | IDE ml, V4.23 ml                               | no matched refs                            |
| 0x03e64b | `_exp`                                        | 230   | `FP_exp`                      | V4.23 ml                                       | refs confirmed 6                           |
| 0x03e731 | `_log`                                        | 338   | `FP_log`                      | V4.23 ml                                       | refs confirmed 9                           |
| 0x03e884 | `SPECIAL_DIV`                                 | 16    | `FP_NaN_Handler`              | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | no matched refs                            |
| 0x03e894 | `__fint`                                      | 365   | `FP_trunc`                    | IDE ml, V4.23 ml                               | refs confirmed 2                           |
| 0x03ea0a | `SPECIAL_ADD_LD`                              | 41    | `FP_CopyWithSign_D2`          | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |
| 0x03ea9c | `_ldexp`                                      | 305   | `FP_ldexp`                    | IDE ml                                         | refs confirmed 2                           |
| 0x03ed0e | `MUL_XHL_XIY`                                 | 46    | `FP_MulMantissa64x64`         | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | no matched refs                            |
| 0x03ee3e | `SPECIAL_SUB_LD`                              | 49    | `FP_NegWithSign_D2`           | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                            |

#### subcpu v142: names read from those routines' calls and pointers (20)

| address  | Toshiba name         | referenced from | our label              |
|----------|----------------------|-----------------|------------------------|
| 0x03d978 | `TAB_EQ`             | `._fcmp_d`      | `FP_CmpResult_Equal`   |
| 0x03d97e | `TAB_LT`             | `._fcmp_d`      | `FP_CmpResult_Less`    |
| 0x03d984 | `TAB_GT`             | `._fcmp_d`      | `FP_CmpResult_Greater` |
| 0x03dce6 | `._fld_dd`           | `_cos`          | `FP_DP_Raw8Copy`       |
| 0x03e3f6 | `._fdiv_acd`         | `._fdiv_d`      | `FP_DP_DivCore`        |
| 0x03e4b4 | `._fdiv_acf`         | `._fdiv_f`      | `FP_SP_DivCore`        |
| 0x040c22 | `_errno`             | `_tan`          | `FP_Errno`             |
| 0x00f420 | `_g_mathtbl`         | `_pow`          | `FPConst_MaxNorm`      |
| 0x03e2f0 | `._fadj_acd`         | `._fsub_d`      | `FP_DP_AlignMantissa`  |
| 0x03deea | `._fadd_acd`         | `._fsub_d`      | `FP_DP_AddMantissa`    |
| 0x03e54c | `._fsub_acd`         | `._fsub_d`      | `FP_DP_SubMantissa`    |
| 0x03dfd6 | `._fcvt_dacl`        | `._fld_dl`      | `FP_SP_Normalize`      |
| 0x03dfef | `._fcvt_dacul`       | `._fld_dul`     | `FP_SP_NormCore`       |
| 0x03de1a | `._fcvt_facl`        | `._fld_fl`      | `FP_DP_Normalize`      |
| 0x03ea34 | `._fcvt_uldac`       | `._fld_uld`     | `FP_SP_DecodeToInt`    |
| 0x03ea02 | `SPECIAL_ADD_F`      | `._fadd_acf`    | `FP_DP_CopyNoSign`     |
| 0x00f428 | `__FloatErrorHandle` | `._fset_dac`    | `FPConst_Zero`         |
| 0x03ebce | `._fmul_acd`         | `._fmul_d`      | `FP_DP_MulAdd`         |
| 0x03ec9e | `._fmul_acf`         | `._fmul_f`      | `FP_SP_MulAdd`         |
| 0x03ee36 | `SPECIAL_SUB_F`      | `._fsub_acf`    | `FP_DP_NegNoSign`      |

#### table data: exact hits (5)

| address  | Toshiba name | bytes | our label        | library builds                        | check           |
|----------|--------------|-------|------------------|---------------------------------------|-----------------|
| 0x9ffb2f | `.sbrk`      | 39    | `Boot_sbrk`      | IDE ml, V4.23 ml                      | no matched refs |
| 0x9ffb56 | `_malloc`    | 134   | `Boot_malloc`    | IDE ml, V4.23 ml                      | no matched refs |
| 0x9ffbdc | `_strncmp`   | 50    | `Boot_memcmp`    | IDE ml, V4.23 ml                      | no matched refs |
| 0x9ffc0e | `SDivMod`    | 71    | `Boot_SDivMod32` | IDE ml, V4.23 ml                      | no matched refs |
| 0x9ffc63 | `C9H_divlu`  | 122   | `Boot_UDivMod32` | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic | no matched refs |

#### table data: names read from those routines' calls and pointers (3)

| address  | Toshiba name  | referenced from | our label  |
|----------|---------------|-----------------|------------|
| 0x00999c | `_SBRK_size`  | `.sbrk`         | (no label) |
| 0x009998 | `_SBRK_break` | `.sbrk`         | (no label) |
| 0x0099a0 | `__allocb`    | `_malloc`       | (no label) |

#### hdae v2.06i: exact hits (33)

| address  | Toshiba name                                  | bytes | our label                    | library builds                                 | check                                     |
|----------|-----------------------------------------------|-------|------------------------------|------------------------------------------------|-------------------------------------------|
| 0x29abd8 | `_sprintf`                                    | 40    | `HDAE5000_SPrintf`           | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                           |
| 0x29ac00 | `_vsprintf`                                   | 59    | `HDAE5000_VSPrintf`          | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                           |
| 0x29ac3b | `_itoa`                                       | 138   | `HDAE5000_IToA`              | IDE ml, V4.23 ml                               | refs confirmed 1                          |
| 0x29acc5 | `_ldiv`                                       | 67    | `HDAE5000_LDiv`              | IDE ml, v1.10 ml                               | no matched refs                           |
| 0x29ad08 | `_ltoa`                                       | 60    | `HDAE5000_LToA`              | IDE ml, V4.23 ml                               | refs confirmed 1                          |
| 0x29ad44 | `_ultoa`                                      | 136   | `HDAE5000_ULToA`             | IDE ml                                         | refs confirmed 1                          |
| 0x29adcc | `_memccpy`                                    | 64    | `HDAE5000_MemCCpy`           | V4.23 ml                                       | refs confirmed 2                          |
| 0x29ae0c | `_memchr`                                     | 24    | `HDAE5000_MemChr`            | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                           |
| 0x29ae24 | `_memcmp`                                     | 123   | `HDAE5000_MemCmp`            | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                           |
| 0x29ae9f | `_memcpy`                                     | 40    | `HDAE5000_MemCopy`           | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                           |
| 0x29aec7 | `_memset`                                     | 68    | `HDAE5000_MemFill`           | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                           |
| 0x29af0b | `_strcat`                                     | 34    | `HDAE5000_StrCat`            | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                           |
| 0x29af45 | `_strcpy`                                     | 44    | `HDAE5000_StrCpy`            | IDE ml, V4.23 ml                               | refs confirmed 1                          |
| 0x29af71 | `_strlen`                                     | 30    | `HDAE5000_StrLen`            | IDE ml, V4.23 ml                               | refs confirmed 1                          |
| 0x29af8f | `_strncat`                                    | 47    | `HDAE5000_StrNCat`           | IDE ml, V4.23 ml                               | no matched refs                           |
| 0x29afbe | `_strncmp`                                    | 50    | `HDAE5000_StrNCmp`           | IDE ml, V4.23 ml                               | no matched refs                           |
| 0x29aff0 | `_strncpy`                                    | 43    | `HDAE5000_StrNCpy`           | IDE ml, V4.23 ml                               | no matched refs                           |
| 0x29b01b | `_strrev`                                     | 51    | `HDAE5000_StrRev`            | V4.23 ml                                       | refs confirmed 1                          |
| 0x29b04e | `_strupr`                                     | 44    | `HDAE5000_StrUpr`            | IDE ml, V4.23 ml                               | no matched refs                           |
| 0x29b72d | `C9H_mullu`                                   | 22    | `HDAE5000_Multiply`          | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | no matched refs                           |
| 0x29b744 | `._fset_acf`                                  | 57    | `HDAE5000_Float_Unpack`      | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                           |
| 0x29b77e | `._fset_fac`                                  | 94    | `HDAE5000_Float_Pack`        | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                           |
| 0x29b7e8 | `._fld_xx`                                    | 17    | `HDAE5000_Copy10`            | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | no matched refs                           |
| 0x29b7fa | `._fld_fl`                                    | 27    | `HDAE5000_LongToFloat`       | IDE ml, V4.23 ml                               | refs confirmed 1                          |
| 0x29b815 | `._fld_fl_tail`                               | 27    | `HDAE5000_ULongToFloat`      | IDE ml, V4.23 ml                               | refs confirmed 2                          |
| 0x29b830 | `SPECIAL_DIV`                                 | 16    | `HDAE5000_FloatDiv_Special`  | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | no matched refs                           |
| 0x29b840 | `._fdiv_f`                                    | 48    | `HDAE5000_FloatDiv`          | IDE ml, V4.23 ml                               | callee score ._fdiv_f 0.88, ._fmul_f 0.21 |
| 0x29b870 | `SDivMod`                                     | 71    | `HDAE5000_SDivMod32_Common`  | IDE ml, V4.23 ml                               | no matched refs                           |
| 0x29b942 | `._fset_dac`                                  | 105   | `HDAE5000_Double_Pack`       | IDE ml, V4.23 ml, v1.10 ml                     | no matched refs                           |
| 0x29b9ac | `._fcvt_dacl` / `._fcvt_facl` / `._fcvt_xacl` | 25    | `HDAE5000_Long_To_Unpacked`  | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | ambiguous                                 |
| 0x29b9c5 | `._fcvt_facul`                                | 90    | `HDAE5000_ULong_To_Unpacked` | IDE ml, V4.23 ml, v1.10 ml, v1.10 pic          | no matched refs                           |
| 0x2f9362 | `___ctype` / `__ctype`                        | 256   | `HDAE5000_CType_Table`       | IDE ml, IDE pic, V4.23 ml, v1.10 ml            | ambiguous                                 |
| 0x2f948e | `__doform_c data`                             | 35    | `HDAE5000_HexDigits_Lower`   | IDE pic                                        | no matched refs                           |

#### hdae v2.06i: names read from those routines' calls and pointers (10)

| address  | Toshiba name         | referenced from | our label                   |
|----------|----------------------|-----------------|-----------------------------|
| 0x299ae7 | `__doprnt`           | `_sprintf`      | `HDAE5000_DoPrintf`         |
| 0x29b8bb | `C9H_divls`          | `_ldiv`         | `HDAE5000_SDiv32`           |
| 0x29b8b7 | `C9H_remls`          | `_ldiv`         | `HDAE5000_SMod32`           |
| 0x29b8bf | `C9H_remlu`          | `_ultoa`        | `HDAE5000_UMod32`           |
| 0x29b8c5 | `C9H_divlu`          | `_ultoa`        | `HDAE5000_UDivMod32`        |
| 0x2f9362 | `__ctype`            | `_strupr`       | `HDAE5000_CType_Table`      |
| 0x230eca | `_errno`             | `._fset_fac`    | (no label)                  |
| 0x23a1a8 | `__FloatErrorHandle` | `._fset_fac`    | (no label)                  |
| 0x29b9ac | `._fcvt_facl`        | `._fld_fl`      | `HDAE5000_Long_To_Unpacked` |
| 0x29ba64 | `._fdiv_acf`         | `._fdiv_f`      | `HDAE5000_Unpacked_Div`     |

#### wsa1 prom_a: exact hits (2)

| address  | Toshiba name | bytes | our label       | library builds                                 | check           |
|----------|--------------|-------|-----------------|------------------------------------------------|-----------------|
| 0xfe68dd | `C9H_mullu`  | 22    | `Int_Mul32`     | IDE ml, IDE pic, V4.23 ml, v1.10 ml, v1.10 pic | no matched refs |
| 0xfe68f3 | `SDivMod`    | 71    | `Int_SignedDiv` | IDE ml, V4.23 ml                               | no matched refs |

| image       | exact hits | 1997 + 2003 + 2008 | 1997 + 2003 | 2003 + 2008 | 1997 + 2008 | 1997 | 2003 | 2008 |
|-------------|------------|--------------------|-------------|-------------|-------------|------|------|------|
| maincpu v10 | 28         | 9                  | 15          | 0           | 0           | 2    | 2    | 0    |
| maincpu v9  | 28         | 9                  | 15          | 0           | 0           | 2    | 2    | 0    |
| maincpu v7  | 28         | 9                  | 15          | 0           | 0           | 2    | 2    | 0    |
| maincpu v6  | 28         | 9                  | 15          | 0           | 0           | 2    | 2    | 0    |
| maincpu v5  | 28         | 9                  | 15          | 0           | 0           | 2    | 2    | 0    |
| subcpu v142 | 54         | 21                 | 22          | 0           | 0           | 10   | 1    | 0    |
| subcpu v141 | 54         | 21                 | 22          | 0           | 0           | 10   | 1    | 0    |
| subcpu v140 | 54         | 21                 | 22          | 0           | 0           | 10   | 1    | 0    |
| table data  | 5          | 1                  | 4           | 0           | 0           | 0    | 0    | 0    |
| hdae v2.06i | 33         | 16                 | 12          | 1           | 0           | 2    | 2    | 0    |
| hdae v2.01i | 33         | 16                 | 12          | 1           | 0           | 2    | 2    | 0    |
| hdae v1.15i | 31         | 16                 | 11          | 1           | 0           | 1    | 2    | 0    |
| hdae v1.10i | 31         | 16                 | 11          | 1           | 0           | 1    | 2    | 0    |
| wsa1 prom_a | 2          | 1                  | 1           | 0           | 0           | 0    | 0    | 0    |
