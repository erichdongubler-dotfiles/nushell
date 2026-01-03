export def "convert-to-gist" [
]: nothing -> nothing {
  use std/log

  let root_manifest_path = cargo locate-project | from json | get root
  let root = $root_manifest_path | path dirname

  log debug $"Attempting to convert `($root)` into a Gist-compatible layout…"

  let root_manifest = open $root_manifest_path
  let lib_specified = 'lib' in $root_manifest
  let bin_specified = 'bin' in $root_manifest
  if $lib_specified or $bin_specified {
    let rendered_issues = [
      (if $lib_specified { '`lib` key' })
      (if $bin_specified { '`bin` key' })
    ] | each {} | str join ' and '
    error make --unspanned {
      msg: $"($rendered_issues) already in root manifest, bailing"
    }
  }

  let vcs_tracked_root_file_entries = fd . $root --max-depth 1 | lines
  let dirs = ls --full-paths --directory ...$vcs_tracked_root_file_entries
    | where type == 'dir'
    | where { ls $in.name | is-not-empty }
    | get name

  let dirs_short = $dirs | each { path basename }
  let src_file_entries = match $dirs_short {
    ['src'] => { ls --full-paths ...$dirs }
    [] => {
      log info "Project is Gist-compatible already; nothing to do."
      return
    }
    _ => {
      error make --unspanned {
        msg: ([
          "expected a single top-level VCS-tracked `src/` directory, found the following tracked "
          "directories:\n"
          ($dirs_short | table)
        ] | str join)
      }
    }
  }

  let src_non_files = $src_file_entries | where type != 'file'
  if ($src_non_files | is-not-empty) {
    error make --unspanned {
      msg: ([
        "expected a flat set of VCS-tracked files in the `src/` directory, found the following "
        "non-file entries:\n"
        ($src_non_files | update name { path basename } | table)
      ] | str join)
    }
  }

  let src_file_names = $src_file_entries | get name | each { path basename }
  let manifest_additions = $src_file_names | each {
    match $in {
      'main.rs' => ({
        bin: [{
          name: $root_manifest.package.name
          path: './main.rs'
        }]
      })
      'lib.rs' => ({
        lib: {
          path: './lib.rs'
        }
      })
    }
  }

  if ($manifest_additions | is-not-empty) {
    let manifest_additions_toml = $manifest_additions
      | reduce --fold {} {|add, acc| $acc | merge $add }
      | to toml

    log debug ([
      "appending the following to the root manifest:\n\n"
      "```toml\n"
      $manifest_additions_toml
      "```"
    ] | str join)

    $manifest_additions_toml | $"\n($in)" | save --append $root_manifest_path
  } else {
    log warning "no crate entry points detected; you may not have a working crate"
    return
  }

  log debug $"Moving the following to the project root:\n($src_file_names | table)"
  mv ...($src_file_entries | get name) $root
  rm -r ([$root 'src'] | path join)
}
