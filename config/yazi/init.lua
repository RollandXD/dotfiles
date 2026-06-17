require("full-border"):setup {
	type = ui.Border.ROUNDED,
}

require("git"):setup {
	order = 1500,
}

require("yamb"):setup {
	bookmarks = {},  -- 留空：主打运行时 g a 打书签，不在此写死预设
	jump_notify = true,
	cli = "fzf",
	keys = "1234567890qwertyuiopasdfghjklzxcvbnm",
	path = os.getenv("HOME") .. "/.config/yazi/bookmark",
}
