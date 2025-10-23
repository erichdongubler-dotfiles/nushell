use std/log

export def "advance" [
  bookmark: string@"nu-complete jj bookmark list"
] {
  jj bookmark move $bookmark --to $"($bookmark)+"
}

export def --wrapped "blame-stack" [
  --fileset: string,
  --fileset-pattern: oneof<nothing, string>@"nu-complete blame-stack fileset pattern" = null,
  --revisions (-r): string = 'immutable()..@',
  --template (-T): string = 'erichdongubler_preferred()',
  ...args
] {
  use std/log [] # set up `log` cmd. state

  let pattern_prefix = if $fileset_pattern == null {
    ""
  } else {
    $"($fileset_pattern):"
  }

  let revset = $"--revisions=($revisions) & files\(($pattern_prefix)($fileset | to nuon)\)"

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
  )
  if $env.LAST_EXIT_CODE != 0 {
    error make --unspanned {
      msg: "failed to fetch pull request metadata; maybe the ref. or auth. are incorrect?"
    }
  }
  let pr_view = $pr_view | from json

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

def "nu-complete blame-stack fileset pattern" [] {
  [
    ""
    "cwd"
    "file"
    "cwd-file"
    "glob"
    "cwd-glob"
    "root"
    "root-file"
    "root-glob"
  ]
}

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

# Rebases the specified revisions to be parents `@` and children of the first immutable commits in
# `@`'s lineage.
export def "restring" [
  --revisions(-r): oneof<string, nothing> = null,
  --before(-B): oneof<string, nothing> = null,
] {
  let before = $before | default '@'
  let after = $"roots\(immutable\(\)..\(($before)\)\)-"
  jj rebase --revisions $revisions --before $before --after $after
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
