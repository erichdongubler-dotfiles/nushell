export def init-atuin [] {
	mkdir ~/.local/share/atuin/
	atuin init nu | save --force ~/.local/share/atuin/init.nu
}
