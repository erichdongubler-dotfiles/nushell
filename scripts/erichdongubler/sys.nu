# Return a list of ports currently bound on all adapters.
#
# Note determining ports to bind based off of this is subject to TOCTOU bugs.
export def "bound-ports" []: nothing -> list<int> {
  let platform = $nu.os-info.name
  match $platform {
    "macos" => {
      netstat -a -n -p tcp
        | lines
        | skip 1
        | str join "\n"
        | from ssv
        | get '(state)'
        | each { parse --regex '^.*\.(\d+)$' }
        | flatten
        | rename port
        | get port
        | each { into int }
    }
    "windows" => {
      netstat -aon
        | lines
        | skip 2
        | str join "\n"
        | from ssv
        | each {
          if PID not-in ($in | columns) {
            merge { State: null PID: $in.State }
          } else {}
        }
        | where State == LISTENING
        | update PID { into int }
        | get 'Local Address'
        | each { parse --regex '^.*\:(\d+)$' }
        | flatten
        | rename port
        | get port
        | each { into int }
    }
    _ => {
      error make --unspanned {
        msg: $"platform support not present for querying bound ports from `($platform)`"
      }
    }
  }
  | uniq
  | sort
}
