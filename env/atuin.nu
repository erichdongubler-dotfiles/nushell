export def init-atuin [] {
	let atuin_path = "~/.local/share/atuin/init.nu"

	mkdir ($atuin_path | path dirname)
	atuin init nu --disable-up-arrow | save --force $atuin_path
}
