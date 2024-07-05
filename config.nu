use $SCRIPTS_DIR erichdongubler theme sublime_monokai

$env.config.bracketed_paste = true
$env.config.color_config = (sublime_monokai dark-theme)
$env.config.completions.algorithm = "prefix"
$env.config.completions.case_sensitive = true
$env.config.completions.external.completer = {|place|
  match $place.command.0 {
    z | zi | __zoxide_z | __zoxide_zi => {
      $place.command | skip 1 | zoxide query -l ...$in | lines | where { $in != $env.PWD }
    }
    _ => {
      carapace $place.command.0 nushell ...$place.command
        | from json
        | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
    }
  }
}
$env.config.cursor_shape.emacs = "underscore"
$env.config.cursor_shape.vi_insert = "line"
$env.config.cursor_shape.vi_normal = "block"
$env.config.edit_mode = "vi"
$env.config.filesize.unit = "binary"
$env.config.highlight_resolved_externals = true
$env.config.history.file_format = "sqlite"
$env.config.history.isolation = true
$env.config.history.max_size = 10_000
$env.config.rm.always_trash = false
$env.config.shell_integration.osc133 = false # needed to avoid newlines on each keystroke: <https://github.com/nushell/nushell/issues/5585>
$env.config.show_banner = false

# NOTE: Assigning a list to `menus` or `keybindings` replaces Nushell's defaults wholesale, so
# only layer differences over them.
#
# A menu replaces any earlier one of the same `name` as a whole, so patch defaults in place. Overrides
# are applied with `record apply --strict`, so that ones made stale by upstream renaming or removing
# a menu or field get reported, rather than silently doing nothing.
do --env {
  use std/log

  let menu_overrides = {
    completion_menu: { marker: { "(completion) " } }
    history_menu: { marker: { "(history) " } }
    help_menu: { marker: { "(help) " } type: { description_rows: { 10 } } }
    ide_completion_menu: { marker: { "" } type: { min_description_width: { 0 } } }
  }

  let unknown_menu_names = $menu_overrides
    | columns
    | where $it not-in ($env.config.menus | get name)
  if ($unknown_menu_names | is-not-empty) {
    log warning $"ignoring overrides for unknown menus: ($unknown_menu_names | to nuon)"
  }

  $env.config.menus = $env.config.menus | each {|menu|
    let overrides = $menu_overrides | get --optional $menu.name
    if $overrides == null {
      return $menu
    }
    try {
      $menu | record apply --strict $overrides
    } catch {|e|
      log warning $"ignoring overrides for `($menu.name)` menu: ($e.msg)"
      $menu
    }
  }
}
# A keybinding replaces any earlier one of the same `modifier` and `keycode`, per `mode`. Use
# `event: null` to unbind a key.
$env.config.keybindings ++= [
  {
    name: unix_enter
    modifier: control
    keycode: char_j
    mode: [emacs vi_normal vi_insert]
    event: { send: enter }
  }
  {
    name: completion_menu
    modifier: none
    keycode: tab
    mode: [emacs vi_normal vi_insert]
    event: {
      until: [
        { send: menu name: completion_menu }
        { send: menunext }
      ]
    }
  }
  {
    name: history_menu_ctrl_r
    modifier: control
    keycode: char_r
    mode: [emacs, vi_normal, vi_insert]
    event: {
      send: ExecuteHostCommand
      cmd: "commandline edit --replace (
        history
          | get command
          | reverse
          | uniq
          | str join (char -i 0)
          | fzf
            --multi
            --scheme=history
            --read0
            --layout=reverse
            --height=40%
            --bind=change:top
            -q (commandline)
          | decode utf-8
          | str trim
      )"
    }
  }
  {
    name: history_menu_ctrl_b
    modifier: control
    keycode: char_b
    mode: [emacs, vi_normal, vi_insert]
    event: {
      send: ExecuteHostCommand
      cmd: "commandline edit --insert (
        history
          | get command
          | reverse
          | uniq
          | str join (char -i 0)
          | fzf
            --multi
            --scheme=history
            --read0
            --layout=reverse
            --height=40%
            --bind=change:top
          | decode utf-8
          | lines
          | str join '; '
      )"
    }
  }
  {
    name: files
    modifier: control
    keycode: char_f
    mode: [emacs, vi_insert]
    event: {
      send: ExecuteHostCommand
      cmd: "commandline edit --insert (
        fd
          | lines
          | str join (char -i 0)
          | fzf
            --multi
            --scheme=path
            --read0
            --layout=reverse
            --height=40%
            --bind=change:top
          | decode utf-8
          | lines
          | str join ' '
      )"
    }
  }
  {
    name: version_control_refs
    modifier: control
    keycode: char_g
    mode: [emacs, vi_insert]
    event: {
      send: ExecuteHostCommand
      cmd: "
        use erichdongubler find-up
        use erichdongubler jj

        let name = find-up with {
          ".jj": {
            jj nu-complete jj bookmark list
          }
          ".git": {
            git branch -l "--format=%(refname:short)" | lines
          }
        }

        commandline edit --insert (
          $name
            | str join (char -i 0)
            | fzf
              --multi
              --scheme=path
              --read0
              --layout=reverse
              --height=40%
              --bind=change:top
            | decode utf-8
            | lines
            | str join ' '
        )"
    }
  }
  {
    name: zellij-workspace-refs
    modifier: "alt"
    keycode: char_z
    mode: [emacs, vi_insert]
    event: {
      send: ExecuteHostCommand
      cmd: "
        commandline edit --insert (
          zellij list-sessions --no-formatting
            | parse --regex ([
              '^(?P<name>.*) '
              '\\[Created (?P<created_datetime>.+?) ago\\]'
              '(?P<ready_to_resurrect> \\(EXITED - attach to resurrect\\))?'
            ] | str join)
            | update ready_to_resurrect { $in | is-not-empty }
            | each { $in.name }
            | str join (char -i 0)
            | fzf
              --scheme=path
              --read0
              --layout=reverse
              --height=40%
              --bind=change:top
            | decode utf-8
        )"
    }
  }
  {
    name: ctrl_w_deleteword
    modifier: control
    keycode: char_w
    mode: [emacs, vi_insert]
    event: { edit: backspaceword }
  }
  {
    name: alt_w_deleteword
    modifier: alt
    keycode: char_w
    mode: [emacs, vi_insert]
    event: { edit: backspaceword }
  }
]

use $SCRIPTS_DIR erichdongubler completions *
use $SCRIPTS_DIR erichdongubler gh
use $SCRIPTS_DIR erichdongubler jj
use $SCRIPTS_DIR erichdongubler lr
use $SCRIPTS_DIR erichdongubler mkcd
use std/clip

use $ENV_DIR starship STARSHIP_INIT_PATH
use $STARSHIP_INIT_PATH
hide STARSHIP_INIT_PATH
let old_prompt = $env.PROMPT_COMMAND
$env.PROMPT_COMMAND = {
  print --no-newline $'(ansi esc)]9;9;('.' | path expand)(ansi esc)\'
  do $old_prompt
}
$env.PROMPT_INDICATOR_VI_INSERT = { "" }
$env.PROMPT_INDICATOR_VI_NORMAL = { "" }
