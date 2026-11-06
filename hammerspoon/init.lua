hs = hs
require("hs.ipc")
local async = require("async")

local function runAppleScript(script, callback)
	return async.run("/usr/bin/osascript", { "-e", script }, 10, callback)
end

function reloadConfig(files)
	doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end

-- Config lives in ~/dotfiles/hammerspoon (symlinked as ~/.config/hammerspoon, MJConfigFile).
-- Watch the resolved path: FSEvents reports changes at the real location, not via the symlink.
myWatcher = hs.pathwatcher.new(hs.fs.pathToAbsolute(hs.configdir) .. "/", reloadConfig):start()
hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "D", function()
	async.run("/usr/bin/open", { os.getenv("HOME") .. "/Downloads" }, 5)
end)

-- Activation belongs to the shortcut press. Delayed work must never reactivate
-- a browser or move the user's current workspace after they have switched away.
local pendingBrowserAction

local function cancelBrowserAction()
	local action = pendingBrowserAction
	pendingBrowserAction = nil
	if not action then return end
	if action.timer then action.timer:stop() end
	if action.task and action.task:isRunning() then action.task:terminate() end
end

local function browserActionHasFocus(action)
	local app = hs.application.frontmostApplication()
	local window = hs.window.focusedWindow()
	return app and app:name() == action.browserName and app:pid() == action.pid
		and (window and window:id() or nil) == action.windowID
end

local function cancelBrowserActionIfUnfocused()
	if pendingBrowserAction and pendingBrowserAction.started
		and not browserActionHasFocus(pendingBrowserAction) then
		cancelBrowserAction()
	end
end

local function runBrowserAction(browserName, script, launch)
	cancelBrowserAction()
	if launch and not hs.application.launchOrFocus(browserName) then return end
	local action = { browserName = browserName, attempts = 0 }
	pendingBrowserAction = action
	local function start()
		if pendingBrowserAction ~= action then return end
		local app = hs.application.frontmostApplication()
		if not app or app:name() ~= browserName then
			action.attempts = action.attempts + 1
			if launch and action.attempts < 100 then
				action.timer = hs.timer.doAfter(0.05, start)
			else
				cancelBrowserAction()
			end
			return
		end
		local window = hs.window.focusedWindow()
		action.pid = app:pid()
		action.windowID = window and window:id() or nil
		action.started = true
		action.task = runAppleScript(script, function()
			if pendingBrowserAction == action then pendingBrowserAction = nil end
		end)
	end
	start()
end

local function typeTextSlowly(text, interval, callback)
	local i = 1
	local timer = nil
	timer = hs.timer.doEvery(interval or 0.05, function()
		if i > #text then
			timer:stop()
			if callback then
				callback()
			end
			return
		end
		hs.eventtap.keyStrokes(text:sub(i, i))
		i = i + 1
	end)
end

local function openSafariShortcut(targetURL, matchText)
	local script = string.format([[
    tell application "Safari"
      if not frontmost then return
      set targetURL to "%s"
      set matchText to "%s"
      set foundTab to missing value
      set foundWindow to missing value
      repeat with w in windows
        repeat with t in tabs of w
          if (URL of t contains matchText) then
            set foundTab to t
            set foundWindow to w
            exit repeat
          end if
        end repeat
        if foundTab is not missing value then exit repeat
      end repeat
      if foundTab is missing value then
        if (count of windows) > 0 then
          set foundWindow to front window
          set foundTab to make new tab at end of tabs of foundWindow with properties {URL:targetURL}
        else
          make new document with properties {URL:targetURL}
        end if
      else
        set current tab of foundWindow to foundTab
      end if
    end tell
  ]], targetURL, matchText)

	-- AeroSpace's existing Safari rule handles workspace placement.
	runBrowserAction("Safari", script, true)
end

hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "E", function()
	openSafariShortcut("https://excalidraw.com", "excalidraw.com")
end)

-- Private hosts live in private.lua (git-ignored); see private.example.lua.
local privateOk, private = pcall(require, "private")
if not privateOk or type(private) ~= "table" then private = {} end

for key, site in pairs(private.hyperSafari or {}) do
	hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, key, function()
		openSafariShortcut(site.url, site.match)
	end)
end

local supportedBrowsers = {
	Safari = true,
	Orion = true,
	Ardia = true,
}

local function frontmostSupportedBrowser()
	local app = hs.application.frontmostApplication()
	local appName = app and app:name()
	if appName and supportedBrowsers[appName] then
		return appName
	end
	return nil
end

local function browserOpenOrSwitch(browserName, url)
	-- Ardia (Chromium-based) has its own dictionary: "active tab" and "focus"
	-- instead of Safari's "current tab".
	if browserName == "Ardia" then
		local script = string.format(
			[[
    tell application "Ardia"
      if not frontmost then return
      if (count of windows) = 0 then make new window
      set theWin to front window
      set foundTab to missing value
      repeat with t in tabs of theWin
        if (URL of t starts with "%s") then
          set foundTab to t
          exit repeat
        end if
      end repeat
      if foundTab is missing value then
        set foundTab to make new tab at end of tabs of theWin with properties {URL:"%s"}
      end if
      focus foundTab
    end tell
  ]],
			url,
			url
		)
		runBrowserAction(browserName, script)
		return
	end

	if browserName == "Orion" then
		local script = string.format(
			[[
    tell application "Orion"
      if not frontmost then return
      if (count of windows) = 0 then make new document
      set theWin to front window
      set foundTab to missing value
      repeat with t in tabs of theWin
        if (URL of t starts with "%s") then
          set foundTab to t
          exit repeat
        end if
      end repeat
      if foundTab is missing value then
        set foundTab to make new tab at theWin with properties {URL:"%s"}
      end if
      set current tab of theWin to foundTab
    end tell
  ]],
			url,
			url
		)
		runBrowserAction(browserName, script)
		return
	end

	local script = string.format(
		[[
    tell application "%s"
      if not frontmost then return
      if (count of windows) = 0 then make new document
      set theWin to front window
      set foundTab to missing value
      repeat with t in tabs of theWin
        if (URL of t starts with "%s") then
          set foundTab to t
          exit repeat
        end if
      end repeat
      if foundTab is missing value then
        set foundTab to make new tab at end of tabs of theWin with properties {URL:"%s"}
      end if
      set current tab of theWin to foundTab
    end tell
  ]],
		browserName,
		url,
		url
	)
	runBrowserAction(browserName, script)
end

local browserNavigationHotkeys = {}
local function bindBrowserShortcut(key, url)
	local hotkey = hs.hotkey.new({ "cmd" }, key, function()
		local browserName = frontmostSupportedBrowser()
		if not browserName then
			return
		end
		browserOpenOrSwitch(browserName, url)
	end)
	table.insert(browserNavigationHotkeys, hotkey)
	if frontmostSupportedBrowser() then hotkey:enable() end
end

local browserWHotkey = hs.hotkey.new({ "cmd" }, "W", function()
	local browserName = frontmostSupportedBrowser()
	if not browserName then
		return
	end
	local script = string.format(
		[[
    tell application "%s"
      if not frontmost then return
      if (count of windows) < 1 then return
      set numTabs to count of tabs of window 1
      if numTabs > 1 then
        close %s of front window
      else
      end if
    end tell
  ]],
		browserName,
		browserName == "Ardia" and "active tab" or "current tab"
	)
		runBrowserAction(browserName, script)
end)

local function updateBrowserHotkeys()
	local enabled = frontmostSupportedBrowser() ~= nil
	if enabled then browserWHotkey:enable() else browserWHotkey:disable() end
	for _, hotkey in ipairs(browserNavigationHotkeys) do
		if enabled then hotkey:enable() else hotkey:disable() end
	end
end

-- Retain the watcher: an unreferenced watcher is stopped by Lua garbage collection.
browserShortcutWatcher = hs.application.watcher
	.new(function(name, event)
		if event == hs.application.watcher.activated or event == hs.application.watcher.deactivated then
			updateBrowserHotkeys()
			cancelBrowserActionIfUnfocused()
			if pendingBrowserAction and not pendingBrowserAction.started
				and event == hs.application.watcher.activated and name ~= pendingBrowserAction.browserName then
				cancelBrowserAction()
			end
		end
	end)
	:start()

browserActionWindowWatcher = hs.window.filter.new(false)
	:setAppFilter("Safari", {})
	:setAppFilter("Orion", {})
	:setAppFilter("Ardia", {})
browserActionWindowWatcher:subscribe({ hs.window.filter.windowFocused, hs.window.filter.windowUnfocused,
	hs.window.filter.windowDestroyed }, cancelBrowserActionIfUnfocused)

bindBrowserShortcut("1", "https://www.instagram.com")
bindBrowserShortcut("2", "https://discord.com/channels/@me")
bindBrowserShortcut("3", "https://mail.google.com")
bindBrowserShortcut("4", "https://www.netflix.com")
bindBrowserShortcut("5", "https://chatgpt.com")
bindBrowserShortcut("6", "https://www.youtube.com")
for key, url in pairs(private.browserTabs or {}) do
	bindBrowserShortcut(key, url)
end
updateBrowserHotkeys()

-- NetBird / ZeroTier daemons are loaded idle at boot (KeepAlive/RunAtLoad false).
-- Start the daemon when its app opens, stop it when the app quits. sudo rule: /etc/sudoers.d/vpn-on-demand
-- ponytail: both are menu-bar-only apps, which never fire hs.application.watcher events, so poll every 5 s.
local vpnDaemons = { ["io.netbird.client"] = "netbird", ["com.zerotier.ZeroTier-UI"] = "com.zerotier.one" }
local vpnAppUp = {}
vpnDaemonTimer = hs.timer.doEvery(5, function()
	for bundleID, label in pairs(vpnDaemons) do
		local up = hs.application.get(bundleID) ~= nil
		if up ~= (vpnAppUp[bundleID] or false) then
			vpnAppUp[bundleID] = up
			local args = { "-n", "/bin/launchctl" }
			if up then
				table.insert(args, "kickstart")
			else
				table.insert(args, "kill")
				table.insert(args, "TERM")
			end
			table.insert(args, "system/" .. label)
			async.run("/usr/bin/sudo", args, 5)
		end
	end
end)
