export def init-os-env [] {
	use std

	match $nu.os-info.name {
		"macos" => {
			with-env { PATH: $env.PATH } {
				std path add '/opt/homebrew/bin'
				std path add '~/.local/bin'
				std path add '~/.cargo/bin'
				std path add '~/.volta/bin'
				{
					PATH: $env.PATH
				}
			}
		}
		"linux" => {
			with-env { PATH: $env.PATH } {
				std path add --append '~/.local/bin'
				std path add --append '~/.cargo/bin'
				std path add --append '~/.volta/bin'
				{
					PATH: $env.PATH
				}
			}
		}
		"android" => {
			with-env { PATH: $env.PATH } {
				std path add '~/.cargo/bin/'
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
