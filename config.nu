use std/config dark-theme

const sublime_aqua = "#66d9ef"
const sublime_green = "#a6e22d"
const sublime_offwhite = "#f8f8f2"
const sublime_orange = "#fd9720"
const sublime_pink = "#f92772"
const sublime_purple = "#ae81ff"
const sublime_yellow = '#e6db74'
const sublime_darkgray = "dark_gray"

let sublime_monokai_theme = dark-theme | merge deep {
  separator: $sublime_darkgray
  leading_trailing_space_bg: { attr: "n" }
  header: { fg: $sublime_green attr: "b" }
  empty: $sublime_aqua
  bool: $sublime_purple
  int: $sublime_purple
  filesize: $sublime_purple
  duration: $sublime_purple
  date: $sublime_purple
  range: $sublime_purple
  float: $sublime_purple
  string: $sublime_yellow
  nothing: $sublime_purple
  binary: $sublime_purple
  cellpath: $sublime_offwhite
  row_index: { fg: $sublime_green attr: "b" }
  record: $sublime_offwhite
  list: $sublime_offwhite
  block: $sublime_offwhite
  hints: $sublime_darkgray
  search_result: { fg: $sublime_offwhite bg: $sublime_offwhite }

  shape_binary: { fg: $sublime_purple attr: "b" }
  shape_block: { fg: $sublime_aqua attr: "b" }
  shape_bool: $sublime_purple
  shape_custom: $sublime_green
  shape_datetime: { fg: $sublime_purple attr: "b" }
  shape_directory: { fg: $sublime_yellow attr: "iu" }
  shape_external: { fg: $sublime_orange attr: "i" }
  shape_externalarg: { fg: $sublime_yellow attr: "i" }
  shape_filepath: { fg: $sublime_yellow attr: "i" }
  shape_flag: { fg: $sublime_orange attr: "b" }
  shape_float: { fg: $sublime_purple attr: "b" }
  shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: "b" }
  shape_globpattern: { fg: $sublime_purple attr: "i" }
  shape_int: { fg: $sublime_purple attr: "b" }
  shape_internalcall: { fg: $sublime_aqua attr: "b" }
  shape_list: { fg: $sublime_offwhite attr: "b" }
  shape_literal: $sublime_aqua
  shape_match_pattern: $sublime_green
  shape_matching_brackets: { attr: "u" }
  shape_nothing: $sublime_purple
  shape_operator: $sublime_pink
  shape_pipe: { fg: $sublime_pink attr: "b" }
  shape_range: { fg: $sublime_orange attr: "b" }
  shape_record: { fg: $sublime_purple attr: "b" }
  shape_redirection: { fg: $sublime_pink attr: "b" }
  shape_signature: { fg: $sublime_green attr: "b" }
  shape_string: $sublime_yellow
  shape_string_interpolation: { fg: $sublime_purple attr: "b" }
  shape_table: { fg: $sublime_offwhite attr: "b" }
  shape_var: $sublime_pink
  shape_vardecl: $sublime_offwhite
  shape_variable: $sublime_purple

  background: "#272822"
  foreground: $sublime_offwhite
  cursor: $sublime_offwhite
}

$env.config = {
  bracketed_paste: true
  color_config: $sublime_monokai_theme
  completions: {
    algorithm: prefix
    case_sensitive: true
    quick: true
    partial: true
    external: {
      enable: true
      max_results: 100
      completer: {|spans|
        match $spans.0 {
          z | zi | __zoxide_z | __zoxide_zi => {
            $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
          }
          _ => null
        }
      }
    }
  }
  cursor_shape: {
    emacs: underscore
    vi_insert: line
    vi_normal: block
  }
  edit_mode: vi
  filesize: {
    unit: "binary",
  }
  float_precision: 2
  footer_mode: 25 # always, never, number_of_rows, auto
  highlight_resolved_externals: true
  history: {
    file_format: "sqlite"
    isolation: true
    max_size: 10_000
    sync_on_enter: true
  }
  ls: {
    use_ls_colors: true
  }
  rm: {
    always_trash: false
  }
  shell_integration: {
    osc2: true
    osc7: true
    osc8: true # clickable file links in `ls` output
    osc133: false # needed to avoid newlines on each keystroke: <https://github.com/nushell/nushell/issues/5585>
    osc633: true
    reset_application_mode: true
  }
  show_banner: false,
  table: {
    mode: rounded
  }
  menus: [
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
  ]
  keybindings: [
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
}

use $SCRIPTS_DIR erichdongubler clipboard clip
use $SCRIPTS_DIR erichdongubler jj

use $ENV_DIR atuin ATUIN_INIT_PATH
source $ATUIN_INIT_PATH
hide ATUIN_INIT_PATH

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
