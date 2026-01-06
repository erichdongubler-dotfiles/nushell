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
  --template (-T): string = 'erichdongubler_log_compact',
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
#
# - `--upstream` must be of the format `<owner>/<repo>`.
# - `--origin` must be of the format `<owner>[/<repo>]`. If `repo` is omitted, then the same `repo`
#   name from `--upstream` is assumed.
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
      } else {
        error make {
          msg: "`--upstream` should be of the format `<owner>/<repo>`"
          span: (metadata $upstream).span
        }
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
      } else {
        error make {
          msg: "`--upstream` should be of the format `<owner>[/<repo>]`"
          label: {
            span: (metadata $origin).span
          }
        }
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
      jj bookmark track --remote origin $trunk_bookmark_name
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
    jj bookmark list --conflicted --quiet --template $template
      | parse '{bookmark} {commit}'
  )
  for entry in $bookmarks_with_single_visible_added_target {
    jj bookmark set $entry.bookmark --revision $entry.commit
  }
}

# An instrumented `commit` that auto-populates the first line with an autosquash-compatible message.
#
# NOTE: Like with most tooling, no effort is made to determine that the fixup commit applies
# cleanly.
export def "fixup" [
  --revisions (-r): string = "@-",
  # The revisions being "fixed up".
  --interactive (-i),
  # Open the hunk editor to select the changes to `commit`.
  --no-edit,
  # Do not open an editor; just populate the message with `jj fixup-line`.
] {
  mut args = []

  if $interactive {
    $args = $args | append ['--interactive']
  }

  if not $no_edit {
    # NOTE: Normally, `commit` opens an editor by default, but we're providing a `--message`, so we
    # have to explicitly ask for it.
    $args = $args | append ['--editor']
  }

  let fixup_line = jj fixup-line $revisions

  jj commit --message $fixup_line ...$args
}

# Run `gh pr view …` and `git fetch …` to create a branch locally for `pr_ish`.
export def "gh pr checkout" [
  # TODO: check this
  pr_ish: oneof<string, nothing> = null,
  --repo: oneof<string, nothing> = null,
  --force, # Whether the local copy of the PR's branch should be overwritten.
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
      --json headRepositoryOwner,headRepository,headRefName,headRefOid
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
  let head_commit = $pr_view.headRefOid
  let repo = $pr_view.headRepository.name
  let owner = $pr_view.headRepositoryOwner.login

  load-env {
    GIT_WORK_TREE: (jj workspace root)
  }

  let bin = 'git'
  let args = [
    fetch
    $'https://github.com/($owner)/($repo).git'
    $'($branch_name):($branch_name)'
    ...(if $force { ['--force'] } else { [] })
  ]
  log info $"Running `([$bin ...$args] | str join ' ')`"
  run-external $bin ...$args

  jj git import
  jj new $head_commit
}

export def "gh pr push" [
  # TODO: check this
  pr_ish: oneof<string, nothing> = null,
  --repo: oneof<string, nothing> = null,
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

# `jj split` a revision, then `jj restring` it--that is, put it "after" the current change's
# immutable roots.
#
# Particularly useful for breaking a change out into its own.
export def "peel" [
  --before(-B): oneof<string, nothing> = null,
  # Forwarded to `jj restring`.
  --interactive(-i),
  # Forwarded to `jj split`.
  --revision(-r): string = '@',
  # Forwarded to `jj split`.
  ...paths: path,
  # Forwarded to `jj split`.
] {
  let revisions = (
    jj log --revision $revision --template 'change_id ++ "\n"' --no-graph
  ) | lines

  let revision = match ($revisions | length) {
    1 => {
      $revisions | first --strict
    }
    $count => {
      error make {
        msg: $"expected 1 revision; got revision\(($count)\) instead"
        labels: [
          {
            text: ""
            span: (metadata $revision).span
          }
        ]
      }
    }
  }

  mut options = []

  if $interactive {
    $options = $options | append ['--interactive']
  }

  jj split --revision $revision ...$options ...$paths

  # NOTE: The first revision is the one where selected hunks go, which keeps the same change ID we
  # resolved before.
  restring --revisions $revision --before $before
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
  # TODO: make singular
  --revisions(-r): oneof<string, nothing> = null,
  --before(-B): oneof<string, nothing> = null,
] {
  let before = $before | default '@'
  let after = $"roots\(immutable\(\)..\(($before)\)\)-"
  jj rebase --revision $revisions --before $before --after $after
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
  --allow-empty-description,
  # Forwards to `jj git push …`.
  --dry-run,
  # Forwards to `jj git push …`.
] {
  (
    yeet push
      --revisions $revisions
      --allow-empty-description=$allow_empty_description
      --dry-run=$dry_run
  )
}

# Push all unsync'd work with random branch names.
#
# A convenience wrapper for `yeet` that attempts to push all unsynchronized work found via the
# following revset:
#
# ```
# mutable() ~ ancestors(remote_bookmarks()) ~ (working_copies() & empty() & description(exact:""))
# ```
export def "yeet all" [
  --allow-empty-description,
  # Forwards to `jj git push …`.
  --dry-run,
  # Forwards to `jj git push …`.
] {
  (
    yeet push
      --revisions 'mutable() ~ ancestors(remote_bookmarks()) ~ (working_copies() & empty() & description(exact:""))'
      --allow-empty-description=$allow_empty_description
      --dry-run=$dry_run
  )
}

def "yeet push" [
  --revisions: oneof<string, nothing> = null,
  --allow-empty-description,
  # Forwards to `jj git push …`.
  --dry-run,
  # Forwards to `jj git push …`.
] {
  use erichdongubler/random
  (
    jj log
      --revisions (['heads(' $revisions ')' ] | str join)
      --no-graph
      --template 'change_id.shortest() ++ "\n"'
  )
    | lines
    | each --flatten {|change_id|
      let name = $"erichdongubler-push-(random phrase | str join '-')"
      [
        '--named'
        $"($name)=($change_id)"
      ]
    }
    | if $allow_empty_description {
      $in | prepend ['--allow-empty-description']
    } else {
      $in
    }
    | if $dry_run {
      $in | prepend ['--dry-run']
    } else {
      $in
    }
    | jj git push ...$in
}
