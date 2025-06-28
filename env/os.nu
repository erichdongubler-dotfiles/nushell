export def init-os-env [] {
	use std

	{
		MOZ_AVOID_JJ_VCS: 0
	} | merge (match $nu.os-info.name {
		"macos" => {
			with-env { PATH: $env.PATH } {
				std path add '~/.local/bin'
				std path add '/opt/homebrew/bin'
				std path add '~/.cargo/bin'
				std path add '~/.volta/bin'
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
	})
}
