-- ports_list.lua: which input ports and fields does the KN7000 driver expose (names, masks)?
-- At t = T_LIST (default 20 s) writes every port tag / field name / mask to $OUT and a snapshot, then exits.
local mac = manager.machine
local T = tonumber(os.getenv("T_LIST") or "20")
local out = os.getenv("OUT") or "ports.txt"
_G.PL = {}
_G.PL.h = emu.add_machine_frame_notifier(function()
  if PL.done or mac.time.seconds < T then return end
  PL.done = true
  local f = io.open(out, "w")
  local tags = {}
  for tag in pairs(mac.ioport.ports) do tags[#tags+1] = tag end
  table.sort(tags)
  for _, tag in ipairs(tags) do
    for name, fld in pairs(mac.ioport.ports[tag].fields) do
      f:write(("%s\t0x%08X\t%s\n"):format(tag, fld.mask, name))
    end
  end
  f:close()
  mac.video:snapshot()
  mac:exit()
end)
