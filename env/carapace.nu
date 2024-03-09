export def init-carapace [] {
	mkdir ~/.cache/carapace
	carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
	{
		CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'
	}
}
