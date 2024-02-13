export def init-os-env [] {
	match $nu.os-info.name {
		"macos" => {
			{
				PATH: ($env.PATH | split row (char esep) | append [
					('~/.local/bin' | path expand)
					'/opt/homebrew/bin'
					'/Users/mozilla/.cargo/bin'
					'/Users/mozilla/Library/Python/3.9/bin'
					'/Users/mozilla/Library/Python/3.10/bin'
				])
			}
		}
		"linux" => {
			{
				PATH: ($env.PATH | append ('~/.cargo/bin' | path expand))
			}
		}
		_ => {
			{}
		}
	}
}
