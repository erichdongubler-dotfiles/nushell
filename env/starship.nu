export const STARSHIP_INIT_PATH = ($nu.cache-dir | path join starship init.nu)

# Creates an `init.nu` file via `starship init …` at `STARSHIP_INIT_PATH`.
export def init-starship [] {
	mkdir ($STARSHIP_INIT_PATH | path dirname)

	if (which starship | is-empty) {
		echo '# Starship not detected, so this stub was created.' | save --force $STARSHIP_INIT_PATH
		return
	}

	starship init nu | save -f $STARSHIP_INIT_PATH
}

export def gen-completions-starship [] {
	let completions_path = [
		$nu.default-config-dir
		'autoload'
		'starship-completions.nu'
	] | path join

	# NOTE: Autoload tolerates a missing file, so no stub is needed here.
	if (which starship | is-empty) {
		rm --force $completions_path
		return
	}

	starship completions nushell o> $completions_path
}
