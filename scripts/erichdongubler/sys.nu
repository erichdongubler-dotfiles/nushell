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
