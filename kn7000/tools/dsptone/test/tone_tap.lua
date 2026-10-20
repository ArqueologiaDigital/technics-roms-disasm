-- tone_tap.lua -- DSPTONE in MAME: what the DSP and the firmware do while it runs (test/run_mame.sh).
-- Installed after the boot (the remote rig's `lua dofile(...)`). Every 0.25 s of emulated time it writes one line to
-- $TT_OUT/tap.txt:
--   t        emulated seconds
--   st       DSPTONE's state (V_STATE, 0x502DC000; dsptone.inc ST_*: 5 RUN, 6 UPLOAD, 8 DONE, 10 END)
--   dead     the firmware's "DSP dead" flag (893: 0x500066D8; 941: 0x500066CC) -- must stay 0
--   slot     PM 0x8080, the kernel's unit-0 CALL slot (06BE04008400 = the firmware's reverb, 06BE04008200 = ours)
--   m4..m7   MSGR4-MSGR7 (IOP 0x0C-0x0F): copy request, destination, mode, heartbeat
--   c003     DM 0xC003: the reverb program (rec51) stores I6 there every frame; it moves while the firmware's
--            effect runs in unit 0 and stands still while ours does
--   out      DM 0xC342: unit 0's return, left (what the bridge hands to the tone generator's mix)
--   rate, pcm, rest   DSPTONE's V_RATE, V_PCMDONE, V_RESTORED
--   calls    DSPTONE's converter calls so far (V_CALLS)
--   lcd_fw, lcd_ours  stores into the LCD frame (0x9CE00000-0x9CE257FF) so far, by the firmware's code and by
--            DSPTONE's (PC in 0x502BA000-0x502E7FFF); the firmware's full repaint of its STYLE CONVERT screen is
--            76,160 stores (893 0x48414F92)
local mac = manager.machine
local sp = mac.devices[":maincpu"].spaces["program"]
local dsp = mac.devices[":dsp"]
local dm, pm = dsp.spaces["data"], dsp.spaces["program"]
local OUT = assert(os.getenv("TT_OUT"), "set TT_OUT")
local DEAD = tonumber(os.getenv("TT_DEAD") or "0x500066D8")
local VARS = 0x502DC000
local f = assert(io.open(OUT .. "/tap.txt", "w"))
f:write("t st dead slot m4 m5 m6 m7 c003 out rate pcm rest calls lcd_fw lcd_ours\n")
local function now() return mac.time.seconds + mac.time.attoseconds / 1e18 end
_G.TT = { next = 0, deadmax = 0, n = 0, fw = 0, ours = 0 }
local cpu = mac.devices[":maincpu"]
_G.TT.tap = sp:install_write_tap(0x9CE00000, 0x9CE257FF, "tone_lcd", function(o, d, m)
  local pc = cpu.state["PC"].value
  if pc >= 0x502BA000 and pc < 0x502E8000 then _G.TT.ours = _G.TT.ours + 1 else _G.TT.fw = _G.TT.fw + 1 end
end)
_G.TT.h = emu.register_periodic(function()
  local t = now()
  local dead = sp:read_u8(DEAD)
  if dead > _G.TT.deadmax then _G.TT.deadmax = dead end
  if t < _G.TT.next then return end
  _G.TT.next = t + 0.25
  _G.TT.n = _G.TT.n + 1
  f:write(string.format("%.2f %d %d %012X %X %X %X %d %08X %08X %d %d %d %d %d %d\n", t, sp:read_u32(VARS), dead,
    pm:read_u64(0x8080) & 0xFFFFFFFFFFFF, dm:read_u32(0x0C), dm:read_u32(0x0D), dm:read_u32(0x0E), dm:read_u32(0x0F),
    dm:read_u32(0xC003), dm:read_u32(0xC342), sp:read_u32(VARS + 0xBC), sp:read_u32(VARS + 0xC0),
    sp:read_u32(VARS + 0xD4), sp:read_u32(VARS + 4), _G.TT.fw, _G.TT.ours))
  f:flush()
end)
emu.print_error("tone_tap: installed, dead flag at " .. string.format("0x%08X", DEAD))
