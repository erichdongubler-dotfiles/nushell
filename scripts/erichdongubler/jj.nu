use std log

export def "blame-stack" [
  --list,
  ...files: string,
] {
  let file_clause = $files | each { $"file\(\"($in)\"\)" } | str join ' | '
  let revset = $"--revisions=immutable\(\)..@ & \(($file_clause)\)"

  let template = if $list {
    '--template=separate("\n", erichdongubler_preferred(), self.diff().summary())'
  } else {
    '--template=erichdongubler_preferred()'
  }

  let args = [log $revset $template]
  log debug $"Running `jj ($args | each { $"'($in)'"} | str join ' ')`"
  jj ...$args
}
