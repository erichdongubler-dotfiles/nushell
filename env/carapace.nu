export const CARAPACE_INIT_PATH = ($nu.cache-dir | path join carapace init.nu)

export def init-carapace [] {
	mkdir ($CARAPACE_INIT_PATH | path dirname)

	try {
		which carapace
	} catch {
		return
	}

	carapace _carapace nushell | save --force $CARAPACE_INIT_PATH
	{
		CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'
	}
}
