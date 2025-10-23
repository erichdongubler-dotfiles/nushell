export def "disks list" [] {
	match $nu.os-info.name {
		"macos" => {
			diskutil list
				| split row "\n\n"
				| parse --regex '^(?P<path>/dev/\S+) \((?P<types>[^\)]+?)\):\n(?P<partitions>.*)'
				| update types { split row ', ' }
				| update partitions { from ssv  }
			# TODO: `partitions` parsing is busted
		}
		_ => {
			error make {
				msg: (["unable to determine how to list disks; unrecognized platform " ($nu.os-info | debug)] | str join)
			}
		}
	}
}

export def suspend [] {
	match $nu.os-info.name {
		"windows" => {
			^([$env.windir System32 rundll32.exe] | path join) powrprof.dll,SetSuspendState 0,1,0
		}
		"macos" => {
			osascript -e 'tell app "System Events" to sleep'
		}
		_ => {
			error make {
				msg: (["unable to determine how to sleep; unrecognized platform " ($nu.os-info | debug)] | str join)
			}
		}
	}
}
