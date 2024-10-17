use std/log

export def "advance" [
  bookmark: string@"nu-complete jj bookmark list"
] {
  jj bookmark move $bookmark --to $"($bookmark)+"
}

export def --wrapped "blame-stack" [
  --fileset: string,
  --revisions (-r): string = 'immutable()..@',
  --template (-T): string = 'erichdongubler_preferred()',
  ...args
] {
  use std/log [] # set up `log` cmd. state

  let revset = $"--revisions=($revisions) & files\(($fileset | to nuon)\)"

  let args = [log $revset --template $template ...$args]

  log debug $"Running `jj ($args | each { to nuon } | str join ' ')`"
  jj ...$args
}

export def "bookmark resolve" [
] {
  let template = '
    if(
      conflict &&
      self.added_targets().filter(|t| !t.hidden()).len() == 1,
      self.added_targets().filter(|t| !t.hidden()).map(|t| separate(" ", self.name(), t.commit_id().short()) ++ "\n")
    )
  '
  let bookmarks_with_single_visible_added_target = (
    jj bookmark list --conflicted --template $template
      | parse '{bookmark} {commit}'
  )
  for entry in $bookmarks_with_single_visible_added_target {
    jj bookmark set $entry.bookmark --revision $entry.commit
  }
}

def "effective-wc" []: nothing -> string {
  if (wc-is-empty) {
    '@-'
  } else {
    '@'
  }
}

export def "fixup" [
  --revisions (-r): string = "@-",
] {
  jj commit --message (jj fixup-line $revisions)
}

export def "gh pr push" [
  pr_ish: string,
  --repo: string,
] {
  use std/log [] # set up `log` cmd. state

  mut args = []
  if $repo != null {
    $args = $args | append [--repo $repo]
  }

  load-env {
    GIT_DIR: (jj git root)
  }

  let pr_view = (
    gh pr view
      --json headRepositoryOwner,headRepository,headRefName
      $pr_ish
      ...$args
  ) | from json
  let branch_name = $pr_view.headRefName
  let repo = $pr_view.headRepository.name
  let owner = $pr_view.headRepositoryOwner.login
  let local_branch_rev = jj rev-parse $branch_name

  load-env {
    GIT_WORK_TREE: (jj workspace root)
  }

  let bin = 'git'
  let args = [
    push
    --force
    $'git@github.com:($owner)/($repo).git'
    $'($local_branch_rev):($branch_name)'
  ]
  log info $"Running `([$bin ...$args] | str join ' ')`"
  run-external $bin ...$args
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
    let commits = (
      jj log
        --no-graph
        --template 'self.commit_id() ++ "\n"'
        --revisions $branch
        | lines
    )
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

# NOTE: This is `export`ed for the sake of `CTRL + G` completion.
export def "nu-complete jj bookmark list" [] {
  jj bookmark list --quiet --template 'name ++ "\n"' | lines | uniq
}

# Creates a new revert of either `@` (if not empty) or `@-`.
export def "reversi" [] {
  if not (wc-is-empty) {
    jj new
  }
  jj revert --revisions '@-' --before '@'
  jj describe '@-' --message ''
}

export def "util gen-completions nushell" [] {
  jj util completion nushell o> $'($nu.default-config-dir)/autoload/jj-completion.nu'
}

def "wc-is-empty" []: nothing -> bool {
  jj log --no-graph --revisions '@' --template "self.empty()" | into bool
}

export def "yeet" [
  --revisions (-r): oneof<string, nothing> = null,
] {
  use erichdongubler/random
  let revisions = $revisions | default { effective-wc }
  let name = $"erichdongubler-push-(random phrase | str join '-')"
  jj git push --named $"($name)=($revisions)"
}
