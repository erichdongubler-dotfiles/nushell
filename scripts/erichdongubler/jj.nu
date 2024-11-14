use std/log

export def "advance" [
  bookmark: string@"nu-complete jj bookmark list"
] {
  jj bookmark move $bookmark --to $"($bookmark)+"
}

export def "blame-stack" [
  --list,
  ...files: string,
  --revisions: string = 'immutable()..@'
] {
  use std/log [] # set up `log` cmd. state

  if ($files | is-empty) {
    error make {
      msg: "no files specified"
      label:{
        text: ""
        span: (metadata $files).span
      }
    }
  }

  let file_clause = $files | each { $"files\(\"($in)\"\)" } | str join ' | '
  let revset = $"--revisions=($revisions) & \(($file_clause)\)"

  let template = if $list {
    '--template=separate("\n", erichdongubler_preferred(), self.diff().summary())'
  } else {
    '--template=erichdongubler_preferred()'
  }

  let args = [log $revset $template]
  log debug $"Running `jj ($args | each { $"'($in)'"} | str join ' ')`"
  jj ...$args
}

export def "nu-complete jj bookmark list" [] {
  jj bookmark list --template 'name ++ "\n"' | lines | uniq
}
