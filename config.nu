use $SCRIPTS_DIR erichdongubler theme sublime_monokai

$env.config.bracketed_paste = true
$env.config.color_config = (sublime_monokai dark-theme)
$env.config.completions.algorithm = "prefix"
$env.config.completions.case_sensitive = true
$env.config.completions.external.completer = {|spans|
  match $spans.0 {
    z | zi | __zoxide_z | __zoxide_zi => {
      $spans | skip 1 | zoxide query -l ...$in | lines | where { $in != $env.PWD }
    }
    _ => null
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

$env.config.menus = [
  {
    name: completion_menu
    only_buffer_difference: false
    marker: "(completion) "
    type: {
      layout: columnar
      columns: 4
      col_width: 20
      col_padding: 2
    }
    style: {
      text: green
      selected_text: green_reverse
      description_text: yellow
    }
  }
  {
    name: history_menu
    only_buffer_difference: true
    marker: "(history) "
    type: {
      layout: list
      page_size: 10
    }
    style: {
      text: green
      selected_text: green_reverse
      description_text: yellow
    }
  }
  {
    name: help_menu
    only_buffer_difference: true
    marker: "(help) "
    type: {
      layout: description
      columns: 4
      col_width: 20
      col_padding: 2
      selection_rows: 4
      description_rows: 10
    }
    style: {
      text: green
      selected_text: green_reverse
      description_text: yellow
    }
  }
  {
    name: ide_completion_menu
    only_buffer_difference: false
    marker: ""
    type: {
      layout: ide
      min_completion_width: 0,
      max_completion_width: 50,
      max_completion_height: 10,
      padding: 0,
      border: true,
      cursor_offset: 0,
      description_mode: "prefer_right"
      min_description_width: 0
      max_description_width: 50
      max_description_height: 10
      description_offset: 1
      correct_cursor_pos: false
    }
    style: {
      text: green
      selected_text: { attr: r }
      description_text: yellow
      match_text: { attr: u }
      selected_match_text: { attr: ur }
    }
  }
]
$env.config.keybindings = [
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
    name: completion_previous
    modifier: shift
    keycode: backtab
    mode: [emacs, vi_normal, vi_insert]
    event: { send: menuprevious }
  }
  {
    name: ide_completion_menu
    modifier: control
    keycode: space
    mode: [emacs vi_normal vi_insert]
    event: {
      until: [
        { send: menu name: ide_completion_menu }
        { send: menunext }
        { edit: complete }
      ]
    }
  }
  {
    name: history_menu
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
    name: history_menu
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
    name: next_page
    modifier: control
    keycode: char_x
    mode: emacs
    event: { send: menupagenext }
  }
  {
    name: undo_or_previous_page
    modifier: control
    keycode: char_z
    mode: emacs
    event: {
      until: [
        { send: menupageprevious }
        { edit: undo }
      ]
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
    name: ctrl_w_deleteword
    modifier: control
    keycode: char_w
    mode: [emacs, vi_insert]
    event: { edit: backspaceword }
  }
]

use $SCRIPTS_DIR erichdongubler jj
use $SCRIPTS_DIR erichdongubler lr
use std/clip

use $ENV_DIR atuin ATUIN_INIT_PATH
source $ATUIN_INIT_PATH
hide ATUIN_INIT_PATH

use $ENV_DIR carapace CARAPACE_INIT_PATH
source $CARAPACE_INIT_PATH
hide CARAPACE_INIT_PATH

use $ENV_DIR zoxide ZOXIDE_INIT_PATH
source $ZOXIDE_INIT_PATH
hide ZOXIDE_INIT_PATH

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
