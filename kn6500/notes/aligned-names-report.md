# kn6500: KN7000 941 names carried along aligned call sites and RAM operands

- routine names carried: 114, 32 of them by mapped operands (rounds: 92, 16, 3, 1, 2, 0, 0, 0, 0)
- routine pairs both images leave unnamed, accepted by the same rule as anchors: 1907
- accepted pairs that a later round gave a rival: 0
- audit, callees both images name: 504 right, 2 wrong (of them paired by operand pointers alone: 13 right, 0 wrong; pairs by table words alone are audited below)
- paired data tables: {'audit: named word, table passes without it, right': 4, 'tables refused (named words disagree, or too few agree)': 1883, 'tables used': 4}
- routine names carried on pointer supports alone (an operand or a table word): 2
- audit, same-body routines B names already, picked by mapped operands: 130 right, 0 wrong
- RAM address pairs: 2124: 1643 by aligned operands (of 1656 B addresses seen in them), 481 between two of one delta (runs; the premise on the voted pairs: 1152 right, 2 wrong); named from A: 8; RAM audit 15 right, 0 wrong
- not carried (last reason per call-site pair):
  -   1907 A's callee is unnamed too (the pair anchors the next round)
  -    216 A's callee is unnamed too
  -     24 body skeleton similarity below 0.6
  -     14 one aligned call site only
  -      2 the bodies' callees or strings disagree
  -      2 the name is taken in B

Audit, wrong pairs (B name, B address, A name, A address, call sites):

- `Draw2BpFile_Impl` 0x4C01792B / `DrawBitmapFile_Impl` 0x48424B05 (1)
- `M3HookDispatch` 0x4C03CDDE / `M3SetSpecialDispatch` 0x4C0216A3 (3)
