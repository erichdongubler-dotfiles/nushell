export def init-os-env []: nothing -> record {
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

	let paths = with-env { PATH: $env.PATH } {
		if ($paths | is-not-empty) {
			std path add --ret ...$paths
		} else {
			$env.PATH
		}
	}

	let env_vars = {
		MOZ_SKIP_PATH_PERFORMANCE_CHECK: 1
		SHELL: $nu.current-exe
		PATH: $paths
	}

	systemctl-session-env-diff | update set { reject --optional PWD | merge $env_vars }
}

def systemctl-session-env-diff []: nothing -> record<set: record, remove: list<string>> {
	if $nu.os-info.name != "linux" or (which systemctl | is-empty) {
		return { set: {} remove: [] }
	}

	let manager_env = systemctl --user show-environment | complete
	if $manager_env.exit_code != 0 {
		return { set: {} remove: [] }
	}

	let env_vars = $manager_env.stdout
		| lines
		| parse --regex "^(?<key>[A-Za-z_][A-Za-z0-9_]*)=(?<value>.*)$"
		| update value {
			let original = $in
			let replaced = $original | str replace --regex "^\\$'(.*)'$" '$1'
			if $replaced == $original {
				$original
			} else {
				$replaced | str replace --regex --all '\\(.)' {|c|
					match $c {
						'\' => '\'
						"'" => "'"
						'n' => "\n"
						'r' => "\r"
						't' => "\t"
						'0' => "\0"
						$other => {
							use std assert
							assert false $"unrecognized escape sequence replace '\\($other)'"
						}
					}
				}
			}
		}
		| reduce --fold {} {|it, acc| $acc | insert $it.key $it.value }

	const MUST_BE_REMOVED_IF_NOT_REPLACED = [
		DISPLAY
		SSH_AUTH_SOCK
		WAYLAND_DISPLAY
		XAUTHORITY
		XDG_CURRENT_DESKTOP
		XDG_SESSION_DESKTOP
		XDG_SESSION_TYPE
	]

	{
		set: $env_vars
		remove: ($MUST_BE_REMOVED_IF_NOT_REPLACED | where { $in not-in $env_vars })
	}
}
