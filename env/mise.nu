# Creates a `mise-init.nu` autoload file via `mise activate nu`.
export def init-mise [] {
	let init_path = $nu.user-autoload-dirs.0 | path join mise-init.nu

	# NOTE: Autoload tolerates a missing file, so no stub is needed here.
	if (which mise | is-empty) {
		rm --force $init_path
		return
	}

	mise activate nu | save --force $init_path
}

export def gen-completions-mise [] {
	let completions_path = $nu.user-autoload-dirs.0 | path join mise-completions.nu

	# NOTE: Autoload tolerates a missing file, so no stub is needed here.
	if (which mise | is-empty) {
		rm --force $completions_path
		return
	}

	mise completions nu o> $completions_path
}
