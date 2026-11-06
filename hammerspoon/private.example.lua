-- Copy to private.lua (git-ignored) and fill in your own hosts.
return {
	-- hyper + key: find or open the tab in Safari
	hyperSafari = {
		O = { url = "https://erp.example.com", match = "erp.example.com" },
		G = { url = "https://dashboard.example", match = "dashboard.example" },
	},
	-- cmd + key inside Safari, Orion or Ardia
	browserTabs = {
		["7"] = "http://192.0.2.10:8080",
		["8"] = "http://192.0.2.20",
	},
}
