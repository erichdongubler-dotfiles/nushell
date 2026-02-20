use std/log

use (path self './gh.nu') [GH_IDENT_RE, GH_OWNER_AND_REPO_RE]

const EFFECTIVE_WC_REVSET = "heads(@- | present(@ ~ empty()))"

export def "advance" [
  bookmark: string@"nu-complete jj bookmark list"
] {
  jj bookmark move $bookmark --to $"($bookmark)+"
}

export def --wrapped "blame-stack" [
  --fileset: path,
  --fileset-pattern: oneof<nothing, string>@[
    "cwd"
    "file"
    "cwd-file"
    "glob"
    "cwd-glob"
    "root"
    "root-file"
    "root-glob"
  ] = null,
  --revisions (-r): string = 'immutable()..@',
  --template (-T): string = 'erichdongubler_preferred()',
  ...args
] {
  use std/log [] # set up `log` cmd. state

  let pattern_prefix = $fileset_pattern
    | each { $"($in):" }
    | default ""

  let revset = $"--revisions=($revisions) & files\(($pattern_prefix)($fileset | to nuon)\)"

  let args = [log $revset --template $template ...$args]

  log debug $"Running `jj ($args | each { to nuon } | str join ' ')`"
  jj ...$args
}

# Clone `upstream` and add `origin` as another repo, with the latter being treated as a fork.
export def --wrapped "git clone-contrib" [
  --upstream: oneof<string, nothing> = null,
  --origin: oneof<string, nothing> = null,
  # --fork: oneof<string, nothing> = null, # TODO: create fork on popular platforms :D
  destination: oneof<path, nothing> = null,
  ...clone_args,
] {
  use std/log

  let upstream = $upstream
    | each {|upstream|
      if ($upstream =~ $'^($GH_OWNER_AND_REPO_RE)$') {
        return $'https://github.com/($upstream)'
      }
    }
    | default {
      error make --unspanned {
        msg: "no `--upstream` provided"
      }
    }

  let last_upstream_path_segment = $upstream
    | url parse
    | get path
    | split row '/'
    | reject 0
    | last
    | str replace --regex '.git$' ''

  log debug $"inferred repo name to be `($last_upstream_path_segment)`"

  let matches_single_gh_ident = {
    $in =~ $'^($GH_IDENT_RE)$'
  }

  let origin = $origin
    | each {|origin|
      if ($origin | do $matches_single_gh_ident) {
        return $'git@github.com:($origin)/($last_upstream_path_segment)'
      }
      if ($origin =~ $GH_OWNER_AND_REPO_RE) {
        return $'git@github.com:($origin)'
      }
    }
    | default {
      log info "no `--origin` provided; cloning with only an `upstream` remote…"
    }

  let destination = $destination | default $last_upstream_path_segment

  jj git clone --remote upstream $upstream $destination ...$clone_args

  if $origin != null {
    cd $destination

    jj git remote add origin $origin

    jj config set --repo 'git.fetch' '["upstream", "origin"]'

    let bookmarks_at_trunk = (
      jj bookmark list --revisions 'trunk()' --template 'name ++ "\n"'
    ) | lines
    if ($bookmarks_at_trunk | length) == 1 {
      let trunk_bookmark_name = $bookmarks_at_trunk | first
      jj bookmark track $'($trunk_bookmark_name)@origin'
    } else {
      log warning "unable to determine which `origin` mainline bookmark to track"
    }

    jj git fetch
  }
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

export def "hoist" [
  --revisions(-r): string,
  --before(-B): string = "@",
] {
  if $revisions == null {
    error make --unspanned {
      msg: "no `--revisions` specified"
    }
  }
  jj rebase --revisions $revisions --before $"roots\(immutable\(\)..\(($before)\)\)"
}

def "nu-complete blame-stack fileset pattern" [] {
  [
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

# Push new (randomized) bookmark(s) for heads of the provided revisions.
export def "yeet" [
  --revisions (-r): string = $EFFECTIVE_WC_REVSET,
  # Revision(s) to push.
  #
  # The name is plural to be consistent with other CLIs.
] {
  yeet push --revisions $revisions
}

def "yeet push" [
  --revisions: oneof<string, nothing> = null,
] {
  use erichdongubler/random
  (
    jj log
      --revisions (['heads(' $revisions ')' ] | str join)
      --no-graph
      --template 'change_id.shortest() ++ "\n"'
  )
    | each --flatten {|change_id|
      let name = $"erichdongubler-push-(random phrase | str join '-')"
      [
        '--named'
        $"($name)=($change_id)"
      ]
    }
    | jj git push ...$in
}
