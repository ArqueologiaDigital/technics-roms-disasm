| function      | firmware sides with | rule leaves V4.23 unchanged | rule gives 2003 | V4.23 = 2003 |
|---------------|---------------------|-----------------------------|-----------------|--------------|
| `_acos`       | -                   | yes                         | no              | no           |
| `_asin`       | -                   | yes                         | no              | no           |
| `_atan`       | -                   | yes                         | no              | no           |
| `_atan2`      | -                   | yes                         | no              | no           |
| `_cos`        | v423                | yes                         | no              | no           |
| `_cosh`       | -                   | yes                         | no              | no           |
| `_exp`        | v423                | yes                         | no              | no           |
| `___fmemccpy` | -                   | yes                         | no              | no           |
| `_fmod`       | -                   | no                          | yes             | no           |
| `_fwrite`     | -                   | yes                         | no              | no           |
| `_ldexp`      | ide2003, v110       | no                          | yes             | no           |
| `_ldiv`       | ide2003, v110       | no                          | yes             | no           |
| `_log`        | v423                | yes                         | no              | no           |
| `_log10`      | -                   | yes                         | no              | no           |
| `_memccpy`    | v423                | yes                         | no              | no           |
| `_modf`       | v423                | yes                         | no              | no           |
| `_qsort`      | -                   | yes                         | no              | no           |
| `_realloc`    | -                   | yes                         | no              | no           |
| `_sin`        | v423                | yes                         | no              | no           |
| `_sinh`       | -                   | yes                         | no              | no           |
| `_sqrt`       | -                   | yes                         | no              | no           |
| `_strrchr`    | v423                | yes                         | no              | no           |
| `_strrev`     | v423                | yes                         | no              | no           |
| `_strtol`     | -                   | no                          | yes             | no           |
| `_tan`        | v423                | yes                         | no              | no           |
| `_tanh`       | -                   | yes                         | no              | no           |
| `_ultoa`      | ide2003, v110       | no                          | no              | no           |
| `__afcnv`     | -                   | no                          | no              | no           |
| `_mltint`     | -                   | yes                         | no              | no           |
| `_round`      | -                   | yes                         | no              | no           |
| `_sgl_set`    | -                   | yes                         | no              | no           |
| `__doprnt`    | (none)              | no                          | yes             | no           |
| `__dofloat`   | -                   | yes                         | no              | no           |
| `__dofloat_f` | -                   | yes                         | no              | no           |
| `__dofloat_e` | -                   | yes                         | no              | no           |
| `__doscan`    | -                   | yes                         | no              | no           |
| `_mul10`      | -                   | yes                         | no              | no           |
| `_sftlog`     | -                   | yes                         | no              | no           |
| `__trig`      | v423                | yes                         | no              | no           |

248 functions; 209 identical in V4.23 and 2003; the rule maps V4.23 to 2003 exactly for 214 of 248.
