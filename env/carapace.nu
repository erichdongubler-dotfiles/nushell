export def init-carapace [] {
	let init_path = $nu.user-autoload-dirs.0 | path join carapace-init.nu

	# NOTE: Autoload tolerates a missing file, so no stub is needed here.
	if (which carapace | is-empty) {
		rm --force $init_path
		return
	}

	mut output = carapace _carapace nushell
	# NOTE: Necessary until `carapace`'s output catches up with the Nushel 0.105.0's change in
	# closure handling for `default`.
	$output = $output | str replace 'default $carapace_completer' 'default { $carapace_completer }' --all
	$output | save --force $init_path

	{
		CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'
	}
}
