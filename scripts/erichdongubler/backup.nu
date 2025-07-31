const DEFAULT_LOCAL = '~/Downloads/Sync/'

export def "diff shallow" [
  dir: string,
  --local: oneof<directory, nothing> = null,
  --remote: directory,
] {
  let local = $local | default $DEFAULT_LOCAL | path expand --strict
  $local | path join $dir | path expand --strict

  let remote = $remote | path expand --strict
  $remote | path join $dir | path expand --strict

  let fs_entries = {|kind, root|
    (
      fd .
        --base-directory $root
        --search-path $dir
        --hidden
        --path-separator '/'
    )
      | lines
      | sort
  }

  let tmp_dir = mktemp --directory | path join $dir | tee { mkdir $in }
  cd $tmp_dir

  do $fs_entries 'local' $local o> local.list
  do $fs_entries 'remote' $remote o> remote.list

  git diff --no-index local.list remote.list
}
