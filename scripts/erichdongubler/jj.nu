use std/log

export def "advance" [
  bookmark: string@"nu-complete jj bookmark list"
] {
  jj bookmark move $bookmark --to $"($bookmark)+"
}

export def "blame-stack" [
  --list,
  ...files: string,
  --revisions (-r): string = 'immutable()..@'
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

export def "bookmark resolve" [
] {
  let template = '
    if(
      self.added_targets().filter(|t| !t.hidden()).len() != 0,
      self.added_targets().filter(|t| !t.hidden()).map(|t| separate(" ", self.name(), t.commit_id().short()) ++ "\n")
    )
  '
  let bookmarks_with_single_visible_added_target = jj bookmark list --conflicted -T $template | parse '{bookmark} {commit}'
  for entry in $bookmarks_with_single_visible_added_target {
    jj bookmark set $entry.bookmark -r $entry.commit
  }
}

export def "fixup" [
  --revisions (-r): string,
] {
  jj commit --message (jj fixup-line $revisions)
}

export def "gh pr push" [
  pr_ish: string,
] {
  let pr_view = gh pr view --json headRepositoryOwner,headRepository,headRefName $pr_ish | from json
  let branch_name = $pr_view.headRefName
  let repo = $pr_view.headRepository.name
  let owner = $pr_view.headRepositoryOwner.login
  let local_branch_rev = jj rev-parse $branch_name
  git push --force $'git@github.com:($owner)/($repo).git' $'($local_branch_rev):($branch_name)'
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
  jj bookmark list --quiet --template 'name ++ "\n"' | lines | uniq
}

export def "util gen-completions nushell" [] {
  jj util completion nushell o> $'($nu.default-config-dir)/autoload/jj-completion.nu'
}
