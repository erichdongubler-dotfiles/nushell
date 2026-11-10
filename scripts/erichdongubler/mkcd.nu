# `mkdir` and `cd` to a (presumably new) directory.
export def "main" --env [
  dir_path: directory,
  # The directory path to `mkdir` and then `cd` into.
  --fail-if-exists,
  # Forwarded to `mkdir`.
] {
  mkdir $dir_path --fail-if-exists=$fail_if_exists
  cd $dir_path
}
