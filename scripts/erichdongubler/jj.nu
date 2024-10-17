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

export def "git by-remote push" [
  branches_by_repo_path: record,
  --force,
] {
  let repo_paths = $branches_by_repo_path | columns
  for repo_path in $repo_paths {
    let branches = $branches_by_repo_path | get $repo_path

    let ref_pushes = git ref-pushes ...$branches

    let cmd = "git"
    mut args = ["push"]
    if $force {
      $args = $args | append "--force"
    }
    $args = $args | append $ref_pushes

    run-external $cmd ...$args
  }
}

export def "git ref-pushes" [
  ...branches: string
] {
  if ($branches | is-empty) {
    error make {
      msg: "no branches were specified"
      label: {
        text: ""
        span: (metadata $branches).span
      }
    }
  }

  $branches | each {|branch|
    let commits = jj log --no-graph --template 'self.commit_id() ++ "\n"' --revisions $branch | lines
    let commit = match ($commits | length)  {
      1 => { $commits | first }
      0 => {
        error make {
          msg: "revset does not refer to any changes"
          label: {
            text: ""
            span: (metadata $branch).span
          }
        }
      }
      _ => {
        error make {
          msg: "revset refers to more than one change"
          label: {
            text: ""
            span: (metadata $branch).span
          }
        }
      }
    }

    $"($commit):($branch)"
  }
}

export def "nu-complete jj bookmark list" [] {
  jj bookmark list --template 'name ++ "\n"' | lines | uniq
}
