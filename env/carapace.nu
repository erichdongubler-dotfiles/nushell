export const CARAPACE_INIT_PATH = ($nu.cache-dir | path join carapace init.nu)

export def init-carapace [] {
	mkdir ($CARAPACE_INIT_PATH | path dirname)
	touch $CARAPACE_INIT_PATH

	if (which carapace | is-empty) {
		return
	}

	carapace _carapace nushell | save --force $CARAPACE_INIT_PATH
	{
		CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'
	}
}
