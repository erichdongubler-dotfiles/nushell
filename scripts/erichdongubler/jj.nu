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
      self.added_targets().filter(|t| !t.hidden()).len() != 0,
      self.added_targets().filter(|t| !t.hidden()).map(|t| separate(" ", self.name(), t.commit_id().short()) ++ "\n")
    )
  '
  let bookmarks_with_single_visible_added_target = jj bookmark list --conflicted -T $template | parse '{bookmark} {commit}'
  for entry in $bookmarks_with_single_visible_added_target {
    jj bookmark set $entry.bookmark -r $entry.commit
  }
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
