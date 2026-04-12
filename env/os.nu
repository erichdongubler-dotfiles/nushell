export def init-os-env [] {
	use std

	match $nu.os-info.name {
		"macos" => {
			with-env { PATH: $env.PATH } {
				(
					std path add
						'/opt/homebrew/bin'
						'~/.local/bin'
						'~/.cargo/bin'
						'~/.volta/bin'
				)
				{
					PATH: $env.PATH
				}
			}
		}
		"linux" => {
			with-env { PATH: $env.PATH } {
				# NOTE: Bazzite is an immutable distribution, so we should assume that a conflict
				# between system and user binaries should use user binaries first.
				let add = if (uname).nodename == "bazzite" {
					{|dirs| std path add ...$dirs }
				} else {
					{|dirs| std path add --append ...$dirs }
				}
				do --env $add [
					'/home/linuxbrew/.linuxbrew/bin/'
					'~/.local/bin'
					'~/.cargo/bin'
					'~/.volta/bin'
				]
				{
					PATH: $env.PATH
				}
			}
		}
		"android" => {
			with-env { PATH: $env.PATH } {
				(
					std path add --append
						'~/.local/bin'
						'~/.cargo/bin/'
				)
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
