export def init-starship [] {
	mkdir ~/.cache/starship
	starship init nu | save -f ~/.cache/starship/init.nu
}
