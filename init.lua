--Sessions control--
require("sessions_control")

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
	sessionsSave(sessions)
	hs.reload()
	hs.notify.new({title="Hammerspoon", informativeText='Config loaded'}):send():release()
end)


