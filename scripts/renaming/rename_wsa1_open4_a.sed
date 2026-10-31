# lane open4/wsa1-a (2026-10-31): Voice_ApplyParamChange_Dispatch's arms for controller
# DESTINATION codes 29, 30 and 37, named from prom_b's ControllerDestinationNames (0xF33022),
# whose 64 x 13-byte entries are indexed by the same 6-bit code (mask 0x3F) CPU 2 dispatches on:
# [29] "POSITION", [30] "POS.DEPTH", [37] "SUB GAIN".  wsa1/notes/open4-a-probes/ctrl_dest_names.py
s/\bsub_FAEAF9\b/CtrlDest29_Position_Apply/g
s/\bsub_FAEB65\b/CtrlDest30_PosDepth_Apply/g
s/\bsub_FAECC7\b/CtrlDest37_SubGain_Apply/g
