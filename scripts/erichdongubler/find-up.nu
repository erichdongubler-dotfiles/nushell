use std/log

# Finds a filesystem entry in `names` in the CWD or its ancestors.
#
# This is implemented by:
#
# - Starting at the CWD, canonicalizing it,, and checking each
#   ancestor directory until the root of the file system has been
#   checked.
# - Ties are broken by the order of entries in `names`.
#   For example, searching for `['.hg' '.git']` in a directory
#   with both `.hg` and `.git` would return the path to the `.hg`
#   marker.
export def main [names: list<string>, --path: path = '.']: [
  nothing -> path
  nothing -> nothing
] {
  use std/log [] # set up `log` cmd. state

  mut path = $path | path expand

  loop {
    let parent_path = $path | path dirname

    if $parent_path == $path {
      return null
    }

    let listed = (ls --all $path | get name | where {
      ($in | path basename) in $names
    })

    if not ($listed | is-empty) {
      for name in $names {
        for entry in $listed {
          if $name == ($entry | path basename) {
            return ([$path $name] | path join)
          }
        }
      }
    }

    $path = $parent_path
  }

  return null
}

export def with [routing: record] {
  let names = $routing | columns
  let found = main $names

  if $found == null {
    error make --unspanned {
      msg: $"failed to find any marker files in ($names | to nuon)"
    }
  }

  let name = $found | path basename
  return (do ($routing | get $name) $found)
}
