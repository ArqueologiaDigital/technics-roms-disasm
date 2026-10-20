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
-- the boot protocol's answer 0x0020 there (every overlay build so far).
-- With DSP_FAKE_FS=1, reads of DMAC0's low half (register 0x1C) while a readback is armed (the last DMAC0 low
-- half written had DEN and TRAN set) carry FS = 11, "EPB0 full": the chip sets those bits when its DMA has put
-- data in EPB0 (TRM Table E-16); an emulator that does not model them would leave phase 2 waiting.
-- PREFILL_END also saves, for the verifier, the IOP registers as the port answers them after the run
-- (OUT/ref_iop.bin) and what the DSP itself holds: OUT/ref_pm.bin (PM 0x8000-0x8DFF, 6 bytes per word, low first,
-- as DSPPM.BIN) and OUT/ref_dm.bin (DM 0x9800-0x9FFF and 0xC000-0xC4FF, 4 bytes each).
local sp = manager.machine.devices[":maincpu"].spaces["program"]
local T = { idx = 0, half = 0, armed = false, I = {}, R = {}, RF = {}, W = {}, taps = {} }
_G.DSPT = T
local fake = os.getenv("DSP_FAKE_SYSCON") == "1"
local fakefs = os.getenv("DSP_FAKE_FS") == "1"
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
T.tick = emu.register_periodic(function()
  if not T.armed and sp:read_u32(0x502E0000) >= 1 then
    T.armed = true
    emu.print_error(string.format("PREFILL dsp tap armed at t=%.1f%s", manager.machine.time:as_double(),
      fake and " (SYSCON faked as 0x410)" or ""))
  end
end)
emu.print_error("PREFILL dsp tap installed on 0x98000000 and 0x9C000000" .. (fake and ", SYSCON faked" or "") ..
  (fakefs and ", DMAC0 FS faked while armed" or ""))

function _G.PREFILL_END(out)
  local f = io.open(out .. "/dsp_traffic.txt", "w")
  local n = 0
  for i, c in pairs(T.I) do f:write(string.format("I %x %d\n", i, c)); n = n + c end
  for i, c in pairs(T.R) do f:write(string.format("R %x %d %x\n", i, c, T.RF[i])) end
  for k, c in pairs(T.W) do f:write(string.format("W %s %d\n", k, c)) end
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
  emu.print_error(string.format("PREFILL dsp tap end: %d index writes logged%s", n,
    dsp and "; ref_pm.bin, ref_dm.bin saved" or "; no :dsp device"))
end
