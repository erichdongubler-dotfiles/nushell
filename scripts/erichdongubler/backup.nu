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

export def "diff shallow" [
  dir: string,
  --local: oneof<directory, nothing> = null,
  --remote: directory,
] {
  let resolved = check-dirs $dir --local $local --remote $remote
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
