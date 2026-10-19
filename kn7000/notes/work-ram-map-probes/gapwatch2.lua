-- Build 941 (kn7000_program.rom sha1 cc1c364c...): write-watch the work-RAM spans that no
-- instruction or pointer table addresses, IGNORING the reset-time clear loops (PCs
-- 0x48410038/39 and 0x4841004F/50), and log the extent written by everything else plus the
-- first distinct writer PCs. Output: $GW_LOG. Duration: $GW_T emulated seconds (default 40).
local M = manager.machine
local cpu = M.devices[":maincpu"]
local sp = cpu.spaces["program"]
local out = io.open(os.getenv("GW_LOG") or ((os.getenv("TMPDIR") or ".") .. "/gapwatch2.log"), "w")
local function L(s) out:write(s .. "\n"); out:flush() end
local CLEAR = {[0x48410038]=true, [0x48410039]=true, [0x4841004F]=true, [0x48410050]=true}
local spans = {
  {0x5000000C, 0x5000000F, "after trampolines"},
  {0x500214F8, 0x50021CF7, "boot stack (0x800 below INITIAL_SP)"},
  {0x5011F080, 0x5011F87F, "after picture plane 2"},
  {0x501749E8, 0x5017FFFF, "bss tail after JPEG MCU blocks"},
  {0x50297FFC, 0x50297FFF, "after slideshow pool"},
  {0x50298000, 0x502B7FFF, "0x50298000..INSTALL_SCRATCH"},
}
gw2_taps = {}
local st = {}
for i, s in ipairs(spans) do
  st[i] = {n = 0, lo = nil, hi = nil, pcs = {}, npcs = 0}
  gw2_taps[i] = sp:install_write_tap(s[1], s[2], "gw2_" .. i, function(offset, data, mask)
    local pc = cpu.state["PC"].value
    if CLEAR[pc] then return data end
    local r = st[i]
    r.n = r.n + 1
    if (not r.lo) or offset < r.lo then r.lo = offset end
    if (not r.hi) or offset > r.hi then r.hi = offset end
    if not r.pcs[pc] and r.npcs < 8 then r.pcs[pc] = M.time:as_double(); r.npcs = r.npcs + 1 end
    return data
  end)
end
local T = tonumber(os.getenv("GW_T") or "40")
local done = false
emu.register_periodic(function()
  if done or not gw2_taps then return end
  if M.time:as_double() > T then
    done = true
    for i, s in ipairs(spans) do
      local r = st[i]
      L(string.format("%-40s %08X..%08X non-clear writes=%d extent=%s..%s", s[3], s[1], s[2], r.n,
        r.lo and string.format("%08X", r.lo) or "-", r.hi and string.format("%08X", r.hi) or "-"))
      for pc, t in pairs(r.pcs) do L(string.format("    writer PC %08X first at t=%.3f", pc, t)) end
    end
    M:exit()
  end
end)
