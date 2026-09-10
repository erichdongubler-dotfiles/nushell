export def init-os-env [] {
	use std

	let paths = match $nu.os-info.name {
		"macos" => [
			'~/.local/bin'
			'/opt/homebrew/opt/rustup/bin'
			'~/.cargo/bin'
			'~/.volta/bin'
			'~/Library/pnpm/bin'
			'~/.rvm/bin'
			'/opt/homebrew/bin'
		]
		"linux" => [
			'~/.local/bin'
			'/home/linuxbrew/.linuxbrew/opt/rustup/bin'
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
			'~/AppData/Local/pnpm/bin'
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
