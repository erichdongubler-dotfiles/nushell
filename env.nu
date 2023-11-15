# TODO: Remove `str replace` once <https://github.com/ajeetdsouza/zoxide/pull/642> has merged.
zoxide init nushell --hook prompt | str replace --all "def-env" "def --env" | save -f ~/.zoxide.nu

mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
}

$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

$env.EDITOR = "nvim"
