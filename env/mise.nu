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
