zoxide init nushell --hook prompt | save --force ~/.zoxide.nu

let-env PROMPT_COMMAND = {
  let esc = "\u{001B}"
  [
    ([$esc "]9;9;" ('.' | path expand) $esc '\'] | str join)
    (starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)')
  ] | str join
}
let-env PROMPT_COMMAND_RIGHT = { "" }

let-env PROMPT_INDICATOR = { "" }
let-env PROMPT_INDICATOR_VI_INSERT = { "" }
let-env PROMPT_INDICATOR_VI_NORMAL = { "" }
let-env PROMPT_MULTILINE_INDICATOR = { "::: " }

let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
}

let-env NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

let-env NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

let-env EDITOR = "nvim"
