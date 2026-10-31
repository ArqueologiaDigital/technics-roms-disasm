# Probes of the hdae sub-lane (2026-10-31)

Run from the repository root.  The vendor files they read are already in the repository
(`hdae5000/hd-techmanager5000/`); what they unpack goes to a scratch directory and is never committed.

| Script                      | Question it answers                                                                                                     | Command                                                                                                                                             |
|-----------------------------|-------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| `pport_packet_map.py`       | Per PC-link command handler (Cmd01-Cmd20): which services it runs, which packet bytes it reads/writes, which info-block ranges it copies into its reply, which transfers it makes | `python3 notes/open4-kn5000-b/hdae/probes/pport_packet_map.py hdae5000/hdae5000_ui_display.s`                                                       |
| `ppkn50_command_map.py`     | Which PC-link command bytes each ppkn50.dll export sends, and whether it reads the reply's failure byte 255             | `python3 -I notes/open4-kn5000-b/hdae/probes/ppkn50_command_map.py hdae5000/hd-techmanager5000/ppkn50.dll` (needs binutils objdump with pei-i386)  |
| `wise_scan.py`              | What files the Wise installers of HD-TechManager5000 hold (raw-deflate members followed by their CRC-32)                | `python3 -I notes/open4-kn5000-b/hdae/probes/wise_scan.py ~/compartilhado/tmp/<dir> hdae5000/hd-techmanager5000/setup.EXE hdae5000/hd-techmanager5000/setup.W02` (about 2 minutes; 71 members; the HDTMD120 pair gives 80) |
| `apply_hdae_fls_names.py`   | (edit script, not a probe) applies the FLS AS/AL, AL-chain RAM, RCM-stream and service 29/30 names to the four HD-AE5000 trees; idempotent | `python3 notes/open4-kn5000-b/hdae/probes/apply_hdae_fls_names.py`                                                                                 |

Signals read:

- `pport_packet_map.py`: a packet offset counts only while XIX / XIY were last loaded with
  `HDAE5000_RAM_PportPacket` (service 1 returns XIX = the info block, so it resets XIX); `WA = n` before
  `call HDAE5000_PPORT_CallService` is service *n* (26 = status record).
- `ppkn50_command_map.py`: the second-to-last `push` before `call 0x10002810` is the command; functions are bounded
  by the next export or call target; reading DLL address 0x100121BF (reply byte 255) is the failure test.
- `wise_scan.py`: a member is kept only when the raw inflate ends cleanly and the following 4 bytes equal the
  CRC-32 of its output.  The `ppkn50.dll` member (offset 0x1CB33B of setup.EXE+W02) is byte-identical to
  `hdae5000/hd-techmanager5000/ppkn50.dll`.
