const SYS = path self ../erichdongubler/sys.nu
use $SYS

export def "main" []: nothing -> nothing {
  let bound_user_ports = sys bound-ports | take until { $in >= 1024 }
  let first_unbound_user_port = 1024..49151 | each {} | where { $in not-in $bound_user_ports } | first
  print $"First unbound user port: ($first_unbound_user_port)"
  let bind_to = $'localhost:($first_unbound_user_port)'
  start $'http://localhost:9998/?server=($bind_to)'
  nvim --headless --listen $bind_to
}
