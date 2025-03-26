use std/log

export def "advance" [
  bookmark: string@"nu-complete jj bookmark list"
] {
  jj bookmark move $bookmark --to $"($bookmark)+"
}

export def "blame-stack" [
  --list,
  --fileset: string,
  --revisions (-r): string = 'immutable()..@',
] {
  use std/log [] # set up `log` cmd. state

  let template = if $list {
    '--template=separate("\n", erichdongubler_preferred(), self.diff().summary())'
  } else {
    '--template=erichdongubler_preferred()'
  }

  let revset = $"--revisions=($revisions) & files\(($fileset | to nuon)\)"

  let args = [log $revset $template]

  log debug $"Running `jj ($args | each { $"'($in)'"} | str join ' ')`"
  jj ...$args
}

export def "gh pr push" [
  pr_ish: string,
  --repo: string,
] {
  mut args = []
  if $repo != null {
    $args = $args | append [--repo $repo]
  }
  let pr_view = gh pr view --json headRepositoryOwner,headRepository,headRefName $pr_ish ...$args | from json
  let branch_name = $pr_view.headRefName
  let repo = $pr_view.headRepository.name
  let owner = $pr_view.headRepositoryOwner.login
  let local_branch_rev = jj rev-parse $branch_name
  git push --force $'git@github.com:($owner)/($repo).git' $'($local_branch_rev):($branch_name)'
}

export def "nu-complete jj bookmark list" [] {
  jj bookmark list --quiet --template 'name ++ "\n"' | lines | uniq
}
