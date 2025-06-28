export def init-os-env [] {
	use std

	let paths = match $nu.os-info.name {
		"macos" => [
			'~/.local/bin'
			'~/.cargo/bin'
			'~/.volta/bin'
			'~/Library/pnpm/bin'
			'/opt/homebrew/bin'
		]
		"linux" => [
			'~/.local/bin'
			'~/.cargo/bin'
			'~/.volta/bin'
			'~/.local/share/pnpm/bin'
			'/home/linuxbrew/.linuxbrew/bin'
		]
		"android" => [
			'~/.local/bin'
			'~/.cargo/bin'
			'~/.volta/bin'
			'~/.local/share/pnpm/bin'
		]
		"windows" => [
			'~/.local/bin'
			'~/.cargo/bin'
			'~/.volta/bin'
			'~/.local/share/pnpm/bin'
		]
		_ => []
	}

	let env_vars = with-env { PATH: $env.PATH } {
		if ($paths | is-not-empty) {
			std path add --ret ...$paths
		} else {
			$env.PATH
		}
	}

	{
		SHELL: $nu.current-exe
		MOZ_AVOID_JJ_VCS: 0
		PATH: $env_vars
	}
}
