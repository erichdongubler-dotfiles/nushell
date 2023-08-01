# TODO: remove the `str replace` once upstream has adjusted: https://github.com/ajeetdsouza/zoxide/issues/599
zoxide init nushell --hook prompt | str replace --string --all 'let-env ' '$env.' | save -f ~/.zoxide.nu

$env.PROMPT_COMMAND = {
  let esc = "\u{001B}"
  [
    ([$esc "]9;9;" ('.' | path expand) $esc '\'] | str join)
    (starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)')
  ] | str join
}
$env.PROMPT_COMMAND_RIGHT = { "" }

$env.PROMPT_INDICATOR = { "" }
$env.PROMPT_INDICATOR_VI_INSERT = { "" }
$env.PROMPT_INDICATOR_VI_NORMAL = { "" }
$env.PROMPT_MULTILINE_INDICATOR = { "::: " }

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
