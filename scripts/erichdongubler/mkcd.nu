# `mkdir` and `cd` to a (presumably new) directory.
export def "main" --env [
  dir_path: directory,
  --fail-if-exists,
] {
  mkdir dir_path --fail-if-exists=$fail_if_exists
  cd $dir_path
}
