| image       | address  | Toshiba name      | bytes | matches    | build | difference                   | library/image bytes                                             |
|-------------|----------|-------------------|-------|------------|-------|------------------------------|-----------------------------------------------------------------|
| maincpu v10 | 0xeed8a4 | `__doform_c data` | 35    | 2003       | 1997  | +44 bytes                    | first difference at +0                                          |
| maincpu v10 | 0xeed8a4 | `__doform_c data` | 35    | 2003       | 2008  | +44 bytes                    | first difference at +0                                          |
| maincpu v10 | 0xff091d | `_strstr`         | 96    | 1997, 2003 | 2008  | -37 bytes                    | first difference at +0                                          |
| maincpu v10 | 0xff097d | `_strcspn`        | 35    | 1997, 2003 | 2008  | same length, 14 bytes differ | +3 e9/db +4 8b/a8 +6 14/16 +14 83/81 +16 66/b0 +17 0e/f6 ...    |
| maincpu v10 | 0xff09a0 | `_atoi`           | 86    | 1997, 2003 | 2008  | +6 bytes                     | first difference at +7                                          |
| maincpu v10 | 0xff09f6 | `_atol`           | 102   | 1997, 2003 | 2008  | +6 bytes                     | first difference at +7                                          |
| maincpu v10 | 0xff0bc3 | `SDivMod`         | 71    | 1997, 2003 | 2008  | same length, 1 bytes differ  | +35 32/30                                                       |
| maincpu v10 | 0xff0c92 | `_strncat`        | 47    | 1997, 2003 | 2008  | same length, 5 bytes differ  | +17 af/9f +35 e9/d9 +37 e9/d9 +39 e8/d8 +40 e0/d8               |
| maincpu v10 | 0xff0cc1 | `_strncmp`        | 50    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +0                                          |
| maincpu v10 | 0xff0cf3 | `_strncpy`        | 43    | 1997, 2003 | 2008  | same length, 10 bytes differ | +0 af/9f +8 23/24 +9 eb/ec +10 8c/8b +19 e9/d9 +21 e9/d9 ...    |
| maincpu v10 | 0xff0de3 | `_itoa`           | 138   | 1997, 2003 | 2008  | same length, 2 bytes differ  | +123 38/28 +131 0c/0a                                           |
| maincpu v10 | 0xff0e6d | `_strchr`         | 19    | 1997, 2003 | 2008  | same length, 1 bytes differ  | +7 f9/f1                                                        |
| maincpu v10 | 0xff0f4d | `_strcpy`         | 44    | 1997, 2003 | 2008  | +74 bytes                    | first difference at +1                                          |
| maincpu v10 | 0xff0f79 | `.sbrk`           | 39    | 1997, 2003 | 2008  | absent                       |                                                                 |
| maincpu v10 | 0xff0fa0 | `_strlen`         | 30    | 1997, 2003 | 2008  | +7 bytes                     | first difference at +1                                          |
| maincpu v10 | 0xff0fbe | `_ltoa`           | 60    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +14                                         |
| maincpu v10 | 0xff27f7 | `_ultoa`          | 136   | 2003       | 1997  | same length, 7 bytes differ  | +32 af/b8 +33 08/20 +34 20/00 +35 b8/00 +36 20/af +37 00/08 ... |
| maincpu v10 | 0xff27f7 | `_ultoa`          | 136   | 2003       | 2008  | +89 bytes                    |                                                                 |
| maincpu v10 | 0xff2891 | `_memccpy`        | 64    | 1997       | 2003  | -1 bytes                     | first difference at +2                                          |
| maincpu v10 | 0xff2891 | `_memccpy`        | 64    | 1997       | 2008  | +8 bytes                     | first difference at +2                                          |
| maincpu v10 | 0xff28e9 | `_strnset`        | 32    | 1997, 2003 | 2008  | same length, 5 bytes differ  | +0 af/9f +18 ea/da +20 ea/da +22 e8/d8 +23 e0/d8                |
| maincpu v10 | 0xff2909 | `_strrchr`        | 39    | 1997       | 2003  | +3 bytes                     | first difference at +12                                         |
| maincpu v10 | 0xff2909 | `_strrchr`        | 39    | 1997       | 2008  | -16 bytes                    | first difference at +0                                          |
| subcpu v142 | 0x00f34e | `__trig_c data`   | 96    | 1997, 2003 | 2008  | -40 bytes                    | first difference at +0                                          |
| subcpu v142 | 0x00f3ba | `_g_dbltbl`       | 72    | 1997, 2003 | 2008  | absent                       |                                                                 |
| subcpu v142 | 0x01f646 | `_pow_c data`     | 72    | 1997       | 2003  | same length, 2 bytes differ  | +0 00/01 +8 00/01                                               |
| subcpu v142 | 0x01f646 | `_pow_c data`     | 72    | 1997       | 2008  | +64 bytes                    | first difference at +0                                          |
| subcpu v142 | 0x01f6b6 | `_exp_c data`     | 40    | 1997       | 2003  | +32 bytes                    | first difference at +8                                          |
| subcpu v142 | 0x01f6b6 | `_exp_c data`     | 40    | 1997       | 2008  | +56 bytes                    | first difference at +8                                          |
| subcpu v142 | 0x03d34d | `_cos`            | 87    | 1997       | 2003  | -13 bytes                    | first difference at +1                                          |
| subcpu v142 | 0x03d34d | `_cos`            | 87    | 1997       | 2008  | -29 bytes                    | first difference at +1                                          |
| subcpu v142 | 0x03d3a4 | `._fdiv_d`        | 48    | 1997, 2003 | 2008  | -4 bytes                     | first difference at +11                                         |
| subcpu v142 | 0x03d3d4 | `._fdiv_f`        | 48    | 1997, 2003 | 2008  | -4 bytes                     | first difference at +11                                         |
| subcpu v142 | 0x03d42e | `_fabs`           | 29    | 1997, 2003 | 2008  | +19 bytes                    | first difference at +0                                          |
| subcpu v142 | 0x03d44c | `._fld_ulf`       | 25    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +8                                          |
| subcpu v142 | 0x03d4c9 | `_tan`            | 106   | 1997       | 2003  | same length, 12 bytes differ | +1 e8/d8 +5 20/30 +8 2a/3a +41 24/34 +51 14/24 +59 30/40 ...    |
| subcpu v142 | 0x03d4c9 | `_tan`            | 106   | 1997       | 2008  | -3 bytes                     | first difference at +1                                          |
| subcpu v142 | 0x03d533 | `_pow`            | 796   | 1997       | 2003  | +10 bytes                    | first difference at +4                                          |
| subcpu v142 | 0x03d533 | `_pow`            | 796   | 1997       | 2008  | +54 bytes                    | first difference at +1                                          |
| subcpu v142 | 0x03d84f | `_sin`            | 123   | 1997       | 2003  | -33 bytes                    | first difference at +0                                          |
| subcpu v142 | 0x03d84f | `_sin`            | 123   | 1997       | 2008  | +24 bytes                    | first difference at +1                                          |
| subcpu v142 | 0x03d8e0 | `._fsub_d`        | 75    | 1997, 2003 | 2008  | -6 bytes                     | first difference at +11                                         |
| subcpu v142 | 0x03d92c | `._fsub_f`        | 75    | 1997, 2003 | 2008  | -6 bytes                     | first difference at +11                                         |
| subcpu v142 | 0x03d98a | `__trig`          | 650   | 1997       | 2003  | -34 bytes                    | first difference at +1                                          |
| subcpu v142 | 0x03d98a | `__trig`          | 650   | 1997       | 2008  | -360 bytes                   | first difference at +1                                          |
| subcpu v142 | 0x03dc14 | `SDivMod`         | 71    | 1997, 2003 | 2008  | same length, 1 bytes differ  | +35 32/30                                                       |
| subcpu v142 | 0x03dd36 | `._fld_dl`        | 27    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +10                                         |
| subcpu v142 | 0x03dd51 | `._fld_dul`       | 27    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +10                                         |
| subcpu v142 | 0x03ddca | `._fld_fl`        | 27    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +10                                         |
| subcpu v142 | 0x03dde5 | `._fld_fl_tail`   | 27    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +10                                         |
| subcpu v142 | 0x03de00 | `._fld_uld`       | 25    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +8                                          |
| subcpu v142 | 0x03de8e | `._fcvt_lfac`     | 92    | 1997, 2003 | 2008  | -1 bytes                     | first difference at +6                                          |
| subcpu v142 | 0x03df38 | `._fadd_acf`      | 39    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +6                                          |
| subcpu v142 | 0x03e10e | `._fadd_d`        | 75    | 1997, 2003 | 2008  | -6 bytes                     | first difference at +11                                         |
| subcpu v142 | 0x03e15a | `._fadd_f`        | 75    | 1997, 2003 | 2008  | -6 bytes                     | first difference at +11                                         |
| subcpu v142 | 0x03e1a5 | `_modf`           | 76    | 1997       | 2003  | -14 bytes                    | first difference at +0                                          |
| subcpu v142 | 0x03e1a5 | `_modf`           | 76    | 1997       | 2008  | -14 bytes                    | first difference at +0                                          |
| subcpu v142 | 0x03e290 | `._fmul_d`        | 48    | 1997, 2003 | 2008  | -4 bytes                     | first difference at +11                                         |
| subcpu v142 | 0x03e2c0 | `._fmul_f`        | 48    | 1997, 2003 | 2008  | -4 bytes                     | first difference at +11                                         |
| subcpu v142 | 0x03e5f6 | `._fsub_acf`      | 85    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +6                                          |
| subcpu v142 | 0x03e64b | `_exp`            | 230   | 1997       | 2003  | +175 bytes                   | first difference at +1                                          |
| subcpu v142 | 0x03e64b | `_exp`            | 230   | 1997       | 2008  | +178 bytes                   | first difference at +1                                          |
| subcpu v142 | 0x03e731 | `_log`            | 338   | 1997       | 2003  | same length, 48 bytes differ | +1 be/9a +5 4e/72 +25 4a/6e +40 44/68 +49 52/76 +52 10/34 ...   |
| subcpu v142 | 0x03e731 | `_log`            | 338   | 1997       | 2008  | +63 bytes                    | first difference at +1                                          |
| subcpu v142 | 0x03e894 | `__fint`          | 365   | 1997, 2003 | 2008  | +315 bytes                   | first difference at +1                                          |
| subcpu v142 | 0x03ea9c | `_ldexp`          | 305   | 2003       | 1997  | +3 bytes                     | first difference at +42                                         |
| subcpu v142 | 0x03ea9c | `_ldexp`          | 305   | 2003       | 2008  | +25 bytes                    | first difference at +1                                          |
| table data  | 0x9ffb2f | `.sbrk`           | 39    | 1997, 2003 | 2008  | absent                       |                                                                 |
| table data  | 0x9ffb56 | `_malloc`         | 134   | 1997, 2003 | 2008  | -2 bytes                     | first difference at +0                                          |
| table data  | 0x9ffbdc | `_strncmp`        | 50    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +0                                          |
| table data  | 0x9ffc0e | `SDivMod`         | 71    | 1997, 2003 | 2008  | same length, 1 bytes differ  | +35 32/30                                                       |
| hdae v2.06i | 0x29ac3b | `_itoa`           | 138   | 1997, 2003 | 2008  | same length, 2 bytes differ  | +123 38/28 +131 0c/0a                                           |
| hdae v2.06i | 0x29acc5 | `_ldiv`           | 67    | 2003, 2008 | 1997  | +3 bytes                     | first difference at +10                                         |
| hdae v2.06i | 0x29ad08 | `_ltoa`           | 60    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +14                                         |
| hdae v2.06i | 0x29ad44 | `_ultoa`          | 136   | 2003       | 1997  | same length, 7 bytes differ  | +32 af/b8 +33 08/20 +34 20/00 +35 b8/00 +36 20/af +37 00/08 ... |
| hdae v2.06i | 0x29ad44 | `_ultoa`          | 136   | 2003       | 2008  | +89 bytes                    |                                                                 |
| hdae v2.06i | 0x29adcc | `_memccpy`        | 64    | 1997       | 2003  | -1 bytes                     | first difference at +2                                          |
| hdae v2.06i | 0x29adcc | `_memccpy`        | 64    | 1997       | 2008  | +8 bytes                     | first difference at +2                                          |
| hdae v2.06i | 0x29af45 | `_strcpy`         | 44    | 1997, 2003 | 2008  | +74 bytes                    | first difference at +1                                          |
| hdae v2.06i | 0x29af71 | `_strlen`         | 30    | 1997, 2003 | 2008  | +7 bytes                     | first difference at +1                                          |
| hdae v2.06i | 0x29af8f | `_strncat`        | 47    | 1997, 2003 | 2008  | same length, 5 bytes differ  | +17 af/9f +35 e9/d9 +37 e9/d9 +39 e8/d8 +40 e0/d8               |
| hdae v2.06i | 0x29afbe | `_strncmp`        | 50    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +0                                          |
| hdae v2.06i | 0x29aff0 | `_strncpy`        | 43    | 1997, 2003 | 2008  | same length, 10 bytes differ | +0 af/9f +8 23/24 +9 eb/ec +10 8c/8b +19 e9/d9 +21 e9/d9 ...    |
| hdae v2.06i | 0x29b01b | `_strrev`         | 51    | 1997       | 2003  | -1 bytes                     | first difference at +13                                         |
| hdae v2.06i | 0x29b01b | `_strrev`         | 51    | 1997       | 2008  | -3 bytes                     | first difference at +11                                         |
| hdae v2.06i | 0x29b04e | `_strupr`         | 44    | 1997, 2003 | 2008  | -7 bytes                     | first difference at +0                                          |
| hdae v2.06i | 0x29b7fa | `._fld_fl`        | 27    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +10                                         |
| hdae v2.06i | 0x29b815 | `._fld_fl_tail`   | 27    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +10                                         |
| hdae v2.06i | 0x29b840 | `._fdiv_f`        | 48    | 1997, 2003 | 2008  | -4 bytes                     | first difference at +11                                         |
| hdae v2.06i | 0x29b870 | `SDivMod`         | 71    | 1997, 2003 | 2008  | same length, 1 bytes differ  | +35 32/30                                                       |
| hdae v2.06i | 0x2f948e | `__doform_c data` | 35    | 2003       | 1997  | +44 bytes                    | first difference at +0                                          |
| hdae v2.06i | 0x2f948e | `__doform_c data` | 35    | 2003       | 2008  | +44 bytes                    | first difference at +0                                          |
| hdae v1.10i | 0x296b16 | `_itoa`           | 138   | 1997, 2003 | 2008  | same length, 2 bytes differ  | +123 38/28 +131 0c/0a                                           |
| hdae v1.10i | 0x296ba0 | `_ldiv`           | 67    | 2003, 2008 | 1997  | +3 bytes                     | first difference at +10                                         |
| hdae v1.10i | 0x296be3 | `_ltoa`           | 60    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +14                                         |
| hdae v1.10i | 0x296c1f | `_ultoa`          | 136   | 2003       | 1997  | same length, 7 bytes differ  | +32 af/b8 +33 08/20 +34 20/00 +35 b8/00 +36 20/af +37 00/08 ... |
| hdae v1.10i | 0x296c1f | `_ultoa`          | 136   | 2003       | 2008  | +89 bytes                    |                                                                 |
| hdae v1.10i | 0x296ca7 | `_memccpy`        | 64    | 1997       | 2003  | -1 bytes                     | first difference at +2                                          |
| hdae v1.10i | 0x296ca7 | `_memccpy`        | 64    | 1997       | 2008  | +8 bytes                     | first difference at +2                                          |
| hdae v1.10i | 0x296e20 | `_strcpy`         | 44    | 1997, 2003 | 2008  | +74 bytes                    | first difference at +1                                          |
| hdae v1.10i | 0x296e4c | `_strlen`         | 30    | 1997, 2003 | 2008  | +7 bytes                     | first difference at +1                                          |
| hdae v1.10i | 0x296e6a | `_strncat`        | 47    | 1997, 2003 | 2008  | same length, 5 bytes differ  | +17 af/9f +35 e9/d9 +37 e9/d9 +39 e8/d8 +40 e0/d8               |
| hdae v1.10i | 0x296e99 | `_strncmp`        | 50    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +0                                          |
| hdae v1.10i | 0x296ecb | `_strncpy`        | 43    | 1997, 2003 | 2008  | same length, 10 bytes differ | +0 af/9f +8 23/24 +9 eb/ec +10 8c/8b +19 e9/d9 +21 e9/d9 ...    |
| hdae v1.10i | 0x297676 | `._fld_fl`        | 27    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +10                                         |
| hdae v1.10i | 0x297691 | `._fld_fl_tail`   | 27    | 1997, 2003 | 2008  | -2 bytes                     | first difference at +10                                         |
| hdae v1.10i | 0x2976bc | `._fdiv_f`        | 48    | 1997, 2003 | 2008  | -4 bytes                     | first difference at +11                                         |
| hdae v1.10i | 0x2976ec | `SDivMod`         | 71    | 1997, 2003 | 2008  | same length, 1 bytes differ  | +35 32/30                                                       |
| hdae v1.10i | 0x2e0e02 | `__doform_c data` | 35    | 2003       | 1997  | +44 bytes                    | first difference at +0                                          |
| hdae v1.10i | 0x2e0e02 | `__doform_c data` | 35    | 2003       | 2008  | +44 bytes                    | first difference at +0                                          |
| wsa1 prom_a | 0xfe68f3 | `SDivMod`         | 71    | 1997, 2003 | 2008  | same length, 1 bytes differ  | +35 32/30                                                       |
