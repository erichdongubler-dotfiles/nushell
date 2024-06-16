export def init-os-env [] {
	use std

	match $nu.os-info.name {
		"macos" => {
			with-env { PATH: $env.PATH } {
				std path add '~/.local/bin'
				std path add '/opt/homebrew/bin'
				std path add '/Users/mozilla/.cargo/bin'
				std path add '/Users/mozilla/Library/Python/3.9/bin'
				std path add '/Users/mozilla/Library/Python/3.10/bin'
				{
					PATH: $env.PATH
				}
			}
		}
		"linux" => {
			with-env { PATH: $env.PATH } {
				std path add --append '~/.cargo/bin'
				{
					PATH: $env.PATH
				}
			}
		}
		_ => {
			{
				PATH: $env.PATH
			}
		}
	}
}
