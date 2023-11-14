export def suspend [] {
	if $nu.os-info.name == "windows" {
		^([$env.windir System32 rundll32.exe] | path join) powrprof.dll,SetSuspendState 0,1,0
	} else {
		error make {
msg: (["unable to determine how to sleep; unrecognized platform " ($nu.os-info | debug)] | str join)
		}
	}
}
