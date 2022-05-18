zoxide init nushell --hook prompt | save ~/.zoxide.nu

let-env PROMPT_COMMAND = {
  starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}
let-env PROMPT_COMMAND_RIGHT = {
  [(date now | date format '%m/%d/%Y %r')] | str collect
}

let-env PROMPT_INDICATOR = { "" }
let-env PROMPT_INDICATOR_VI_INSERT = { "[i] " }
let-env PROMPT_INDICATOR_VI_NORMAL = { "[n] " }
let-env PROMPT_MULTILINE_INDICATOR = { "::: " }

let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) }
    to_string: { |v| $v | str collect (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) }
    to_string: { |v| $v | str collect (char esep) }
  }
}

let-env NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]
