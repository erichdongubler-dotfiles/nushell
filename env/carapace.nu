export const CARAPACE_INIT_PATH = ($nu.cache-dir | path join carapace init.nu)

export def init-carapace [] {
	mkdir ($CARAPACE_INIT_PATH | path dirname)
	touch $CARAPACE_INIT_PATH

	if (which carapace | is-empty) {
		echo '# Carapace not detected, so this stub was created.' | save --force $CARAPACE_INIT_PATH
		return
	}

	mut output = carapace _carapace nushell
	# NOTE: Necessary until `carapace`'s output catches up with the Nushel 0.105.0's change in
	# closure handling for `default`.
	$output = $output | str replace 'default $carapace_completer' 'default { $carapace_completer }' --all
	$output | save --force $CARAPACE_INIT_PATH

	{
		CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'
	}
}
