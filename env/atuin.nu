export def init-atuin [] {
	mkdir ~/.local/share/atuin/
	atuin init nu --disable-up-arrow | save --force ~/.local/share/atuin/init.nu
}
