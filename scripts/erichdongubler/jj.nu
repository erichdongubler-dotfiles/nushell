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

export def --env "review continue" [
] {
  use std/log [] # set up `log` cmd. state

  loop {
    let change = try {
      $env.ERICHDONGUBLER_JJ_REVIEW_QUEUE | first
    } catch {
      print --stderr "review queue is empty 🎉"
      review stop
      return
    }

    try {
      print --stderr $"Showing next change in review queue: ($change)"
      jj show $change
    }


    let prompt = ([
      "Review queue: You may:"
      ""
      "- Go to the [n]ext change,"
      "- [p]ut this change back in the queue and pause,"
      "- [f]inish and clear the queue,"
      "- or (q)uit and maybe come back."
      ""
    ] | str join "\n")
    print --stderr $prompt
    loop { 
      match (input | str downcase) {
        "n" => {
          $env.ERICHDONGUBLER_JJ_REVIEW_QUEUE = $env.ERICHDONGUBLER_JJ_REVIEW_QUEUE | slice 1..
          break
        }
        "p" => {
          # Leave `ERICHDONGUBLER_JJ_REVIEW_QUEUE` defined.
          return
        }
        "f" => {
          review stop
          return
        }
        "q" => {
          $env.ERICHDONGUBLER_JJ_REVIEW_QUEUE = $env.ERICHDONGUBLER_JJ_REVIEW_QUEUE | slice 1..
          # Leave `ERICHDONGUBLER_JJ_REVIEW_QUEUE` defined.
          return
        }
        _ => {
          print --stderr "Didn't understand that, come again?"
        }
      }
    }
  }
}

export def --env "review start" [
  --revisions (-r): string = "trunk()..@",
] {
  use std/log [] # set up `log` cmd. state

  let review_queue_existed_and_was_not_empty = try {
    $env.ERICHDONGUBLER_JJ_REVIEW_QUEUE | is-not-empty
  } catch {
    false
  }
  if $review_queue_existed_and_was_not_empty {
    log warning $"throwing away existing queue of ($env.ERICHDONGUBLER_JJ_REVIEW_QUEUE | to nuon)"
  }

  $env.ERICHDONGUBLER_JJ_REVIEW_QUEUE = ^jj log --no-graph --revisions $revisions -T 'change_id ++ "\n"'
    | lines
    | reverse

  review continue
}

export def --env "review stop" [
] {
  hide-env ERICHDONGUBLER_JJ_REVIEW_QUEUE
}

export def "nu-complete jj bookmark list" [] {
  jj bookmark list --quiet --template 'name ++ "\n"' | lines | uniq
}
