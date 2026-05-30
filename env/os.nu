export def init-os-env [] {
	use std

	let paths = match $nu.os-info.name {
		"macos" => [
			'/opt/homebrew/bin'
			'~/.local/bin'
			'~/.cargo/bin'
			'~/.volta/bin'
		]
		"linux" => [
			'/home/linuxbrew/.linuxbrew/bin'
			'~/.local/bin'
			'~/.cargo/bin'
			'~/.volta/bin'
		]
		"android" => [
			'~/.local/bin'
			'~/.cargo/bin'
		]
		"windows" => [
			'~/.local/bin'
			'~/.cargo/bin'
			'~/.volta/bin'
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
		PATH: $env_vars
	}
}
