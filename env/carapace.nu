# Provides the environment that `carapace` reads when `config.nu`'s external completer invokes it.
#
# NOTE: `carapace _carapace nushell`'s init. script is deliberately not used. Its completer only
# fills in when none is set, so `config.nu`'s always wins, and nothing else it defines is used.
export def init-carapace [] {
	# NOTE: Cleans up output from when this generated an init. script.
	rm --force ($nu.user-autoload-dirs.0 | path join carapace-init.nu)

	if (which carapace | is-empty) {
		return
	}

	{
		CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'
	}
}
