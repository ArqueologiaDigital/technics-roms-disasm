-- (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
--
-- dsp_tap.lua -- what does the DSP probe (romdump_dsp.s) do on the effects DSP's host port? Run from dump.cmd.in's
-- @PREFILL_LATE@ line (run_test.sh --dsp, --dspmem). Taps the index port 0x98000000 (writes) and the data port
-- 0x9C000000 (reads and writes) and, once the dumper runs (the application's state word 0x502E0000 >= 1),
-- counts every access by index: index writes, 16-bit data reads and the values of every 16-bit data write.
-- PREFILL_END(out) writes the counts to OUT/dsp_traffic.txt (verify_dump.py --dsp/--dspmem reads them):
--   I <index> <count>              the index port was written with <index>
--   R <index> <count> <first>      data-port reads while <index> was latched, and the first value read
--   W <index> <value> <count>      data-port writes of <value> while <index> was latched
-- With DSP_FAKE_SYSCON=1 in the environment, reads of register 0 (SYSCON) answer 0x0410 for the first half and 0
-- for the second, as the firmware sets it up, so phase 2's pre-check passes on an emulator whose host port keeps
-- the boot protocol's answer 0x0020 there (overlay builds before kn7000_mame 70aa725; from it on the emulator
-- answers 0x410 itself, and neither stand-in is needed).
-- With DSP_FAKE_FS=1, reads of DMAC0's low half (register 0x1C) while a readback is armed (the last DMAC0 low
-- half written had DEN and TRAN set) carry FS = 11, "EPB0 full": the chip sets those bits when its DMA has put
-- data in EPB0 (TRM Table E-16); an emulator that does not model them would leave phase 2 waiting (overlay
-- builds before kn7000_mame 70aa725).
-- With DSP_FAKE_TM4=1 (run_test.sh --dsprate --fake-tm4), the MN10300's timer 4, which the overlay does not model
-- (its TM4 registers read 0, and a driver timer raises the 1 kHz tick at every whole millisecond of emulated time),
-- reads as the firmware set it up: TM4BR 0x7D0, TM4MD 0x81, and TM4BC counting down from 0x7D0 at 2 MHz from each
-- whole millisecond, when the driver's tick fires; so the pass-8 probe's stamps carry time below 1 ms in MAME too.
-- The emulated time of every data-port read while armed goes to OUT/dsp_times.txt ("<seconds> <index>"), and the
-- writes of the kernel's millisecond counter (the loader's SV_MSCOUNT, 0x502B9E60) to OUT/dsp_ticks.txt
-- ("<seconds> <value>"), for the pass-8 check of the stamps (test/check_dsprate_mame.py).
-- PREFILL_END also saves, for the verifier, the IOP registers as the port answers them after the run
-- (OUT/ref_iop.bin) and what the DSP itself holds: OUT/ref_pm.bin (PM 0x8000-0x8DFF, 6 bytes per word, low first,
-- as DSPPM.BIN) and OUT/ref_dm.bin (DM 0x9800-0x9FFF and 0xC000-0xC4FF, 4 bytes each).
local sp = manager.machine.devices[":maincpu"].spaces["program"]
local T = { idx = 0, half = 0, armed = false, I = {}, R = {}, RF = {}, W = {}, taps = {} }
_G.DSPT = T
local fake = os.getenv("DSP_FAKE_SYSCON") == "1"
local fakefs = os.getenv("DSP_FAKE_FS") == "1"
local faketm4 = os.getenv("DSP_FAKE_TM4") == "1"
T.times, T.ticks, T.tm4reads = {}, {}, 0
T.whalf = 0
T.armed_rb = false
T.taps[#T.taps + 1] = sp:install_write_tap(0x98000000, 0x98000003, "dsp_index", function(offset, data, mask)
  if offset == 0x98000000 and (mask & 0xffff) ~= 0 then
    T.idx = data & 0xffff
    T.half = 0
    T.whalf = 0
    if T.armed then T.I[T.idx] = (T.I[T.idx] or 0) + 1 end
  end
end)
T.taps[#T.taps + 1] = sp:install_read_tap(0x9c000000, 0x9c000003, "dsp_data_r", function(offset, data, mask)
  if offset ~= 0x9c000000 or (mask & 0xffff) == 0 then return end
  local v = data & 0xffff
  if fake and T.idx == 0 then
    v = (T.half == 0) and 0x0410 or 0x0000
    data = (data & ~0xffff) | v
  end
  if fakefs and T.idx == 0x1c and T.half == 0 and T.armed_rb then
    v = v | 0xc000
    data = (data & ~0xffff) | v
  end
  T.half = T.half ~ 1
  if T.armed then
    if #T.times < 40000 then T.times[#T.times + 1] = string.format("%.9f %x", manager.machine.time:as_double(), T.idx) end
    T.R[T.idx] = (T.R[T.idx] or 0) + 1
    if T.RF[T.idx] == nil then T.RF[T.idx] = v end
  end
  return data
end)
T.taps[#T.taps + 1] = sp:install_write_tap(0x9c000000, 0x9c000003, "dsp_data_w", function(offset, data, mask)
  if offset ~= 0x9c000000 or (mask & 0xffff) == 0 then return end
  if T.idx == 0x1c and T.whalf == 0 then T.armed_rb = (data & 5) == 5 end
  T.whalf = T.whalf ~ 1
  if T.armed then
    local k = string.format("%x %x", T.idx, data & 0xffff)
    T.W[k] = (T.W[k] or 0) + 1
  end
end)
if faketm4 then
  -- TM4MD (byte, 0x34001080), TM4BR (0x34001090), TM4BC (0x340010A0): the low half of each 32-bit word
  T.taps[#T.taps + 1] = sp:install_read_tap(0x34001080, 0x340010a3, "tm4_fake", function(offset, data, mask)
    local a = offset & ~3
    if a == 0x34001080 and (mask & 0xff) ~= 0 then
      data = (data & ~0xff) | 0x81
    elseif a == 0x34001090 and (mask & 0xffff) ~= 0 then
      data = (data & ~0xffff) | 0x07d0
    elseif a == 0x340010a0 and (mask & 0xffff) ~= 0 then
      local bc = 0x7d0 - math.floor((manager.machine.time:as_double() % 0.001) * 2e6)
      if bc < 0 then bc = 0 end
      data = (data & ~0xffff) | bc
      T.tm4reads = T.tm4reads + 1
    else
      return
    end
    return data
  end)
end
local function arm()
  if T.armed then return end
  T.armed = true
  emu.print_error(string.format("PREFILL dsp tap armed at t=%.4f%s", manager.machine.time:as_double(),
    fake and " (SYSCON faked as 0x410)" or ""))
end
-- armed the moment the application's state word (0x502E0000) is first written non-zero, i.e. in its first call,
-- before any DSP access (a periodic check alone could be a frame late)
T.taps[#T.taps + 1] = sp:install_write_tap(0x502E0000, 0x502E0003, "app_state", function(offset, data, mask)
  if offset == 0x502E0000 and data ~= 0 then arm() end
end)
T.tick = emu.register_periodic(function()
  if not T.armed and sp:read_u32(0x502E0000) >= 1 then arm() end
  local msc = sp:read_u32(0x502B9E60)       -- the loader has found the millisecond counter: log its writes
  if not T.mstap and msc ~= 0 then
    T.mstap = msc
    T.taps[#T.taps + 1] = sp:install_write_tap(msc, msc + 3, "ms_tick", function(offset, data, mask)
      if T.armed and #T.ticks < 20000 then T.ticks[#T.ticks + 1] = string.format("%.9f %d", manager.machine.time:as_double(), data) end
    end)
    emu.print_error(string.format("PREFILL ms counter %08X tapped at t=%.4f", msc, manager.machine.time:as_double()))
  end
end)
emu.print_error("PREFILL dsp tap installed on 0x98000000 and 0x9C000000" .. (fake and ", SYSCON faked" or "") ..
  (fakefs and ", DMAC0 FS faked while armed" or "") .. (faketm4 and ", TM4 faked (0x7D0, 0x81, 2 MHz)" or ""))

function _G.PREFILL_END(out)
  local f = io.open(out .. "/dsp_traffic.txt", "w")
  local n = 0
  for i, c in pairs(T.I) do f:write(string.format("I %x %d\n", i, c)); n = n + c end
  for i, c in pairs(T.R) do f:write(string.format("R %x %d %x\n", i, c, T.RF[i])) end
  for k, c in pairs(T.W) do f:write(string.format("W %s %d\n", k, c)) end
  f:close()
  f = io.open(out .. "/dsp_times.txt", "w")
  f:write(table.concat(T.times, "\n"), "\n")
  f:close()
  f = io.open(out .. "/dsp_ticks.txt", "w")
  f:write(table.concat(T.ticks, "\n"), "\n")
  f:close()
  -- the IOP registers as the emulator answers them now, through the port (the probe has finished; reads only,
  -- and not the ten whose read has a side effect): OUT/ref_iop.bin, 256 u32, 0 where not read
  local skip = { [0x04] = 1, [0x05] = 1, [0xe2] = 1, [0xe3] = 1, [0xee] = 1, [0xef] = 1, [0xf2] = 1, [0xf3] = 1,
                 [0xfe] = 1, [0xff] = 1 }
  T.armed = false
  local g = io.open(out .. "/ref_iop.bin", "wb")
  for r = 0, 255 do
    local v = 0
    if not skip[r] then
      sp:write_u16(0x98000000, r)
      local lo = sp:read_u16(0x9c000000)
      local hi = sp:read_u16(0x9c000000)
      v = (hi << 16) | lo
    end
    g:write(string.pack("<I4", v))
  end
  g:close()
  local dsp = manager.machine.devices[":dsp"]
  if dsp then
    local pm, dm = dsp.spaces["program"], dsp.spaces["data"]
    local g = io.open(out .. "/ref_pm.bin", "wb")
    for a = 0x8000, 0x8dff do
      local w = pm:read_u64(a)
      g:write(string.pack("<I2I2I2", w & 0xffff, (w >> 16) & 0xffff, (w >> 32) & 0xffff))
    end
    g:close()
    g = io.open(out .. "/ref_dm.bin", "wb")
    for _, r in ipairs({ { 0x9800, 0x9fff }, { 0xc000, 0xc4ff } }) do
      for a = r[1], r[2] do g:write(string.pack("<I4", dm:read_u32(a))) end
    end
    g:close()
  end
  emu.print_error(string.format("PREFILL dsp tap end: %d index writes logged%s; %d data reads timed, %d ticks, %d TM4BC "
    .. "reads faked", n, dsp and "; ref_pm.bin, ref_dm.bin saved" or "; no :dsp device", #T.times, #T.ticks, T.tm4reads))
end
