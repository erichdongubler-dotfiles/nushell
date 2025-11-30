const DEFAULT_LOCAL = '~/Downloads/Sync/'

def "check-dirs" [
  dir: string,
  --local: oneof<directory, nothing> = null,
  --remote: directory,
]: nothing -> record<dir: string, local: directory, local_root: directory, remote: directory, remote_root: directory> {
  let local = ($local | default $DEFAULT_LOCAL | path join $dir | path expand --strict)
  let remote = ($remote | path join $dir | path expand --strict)
  {
    dir: $dir
    local: $local
    local_root: ($local | path dirname)
    remote: $remote
    remote_root: ($remote | path dirname)
  }
}

export def "copy-missing" [
  dir: string,
  --local: oneof<directory, nothing> = null,
  --remote: directory,
  --to: string@"nu-complete local-or-remote" = "remote",
] {
  let resolved = check-dirs $dir --local $local --remote $remote

  let files = $resolved
    | impl diff shallow
    | lines
    | where (($it | str starts-with '-') and (not ($it | str starts-with '---')))
    | str replace --regex '^-' ''
    | ls ...$in
    | where $it.type == file
    | get name

  for file in $files {
    let target_path = $resolved.remote | path join $file
    mkdir --verbose ($target_path | path dirname)
    cp --verbose $file $'F:/($target_path)'
  }
}

export def "diff shallow" [
  dir: string,
  --local: oneof<directory, nothing> = null,
  --remote: directory,
] {
  check-dirs $dir --local $local --remote $remote | impl diff shallow
}

def "impl diff shallow" [
]: record<dir: string, local: directory, local_root: directory, remote: directory, remote_root: directory> -> any {
  let resolved = $in
  let dir = $resolved.dir
  let local = $resolved.local
  let remote = $resolved.remote

  let fs_entries = {|kind, root|
    (
      fd .
        --base-directory $root
        --search-path $resolved.dir
        --hidden
        --path-separator '/'
    )
      | lines
      | sort
  }

  let tmp_dir = mktemp --directory | path join $resolved.dir | tee { mkdir $in }
  cd $tmp_dir

  do $fs_entries 'local' $resolved.local_root o> local.list
  do $fs_entries 'remote' $resolved.remote_root o> remote.list

  git diff --no-index local.list remote.list
}

def "nu-complete local-or-remote" [] {
  [
    "local"
    "remote"
  ]
}
