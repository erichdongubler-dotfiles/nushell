# NOTE: I'm trying to keep this in sync with
# <https://github.com/nushell/nushell/blob/main/docs/sample_config/default_config.nu> where
# possible. Of course, I have some of my own changes on top of it I like. :)

let default_theme = {
  separator: pink
  leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
  header: green_bold
  empty: blue
  bool: white
  int: white
  filesize: white
  duration: white
  date: white
  range: white
  float: white
  string: yellow
  nothing: white
  binary: white
  cellpath: white
  row_index: green_bold
  record: white
  list: white
  block: white
  hints: dark_gray

  # Command syntax highlighting
  shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b}
  shape_binary: purple_bold
  shape_bool: light_cyan
  shape_int: purple_bold
  shape_float: purple_bold
  shape_range: yellow_bold
  shape_internalcall: green_bold
  shape_external: darkorange
  shape_externalarg: white
  shape_external_resolved: green
  shape_literal: red
  shape_operator: pink
  shape_signature: green_bold
  shape_string: yellow
  shape_string_interpolation: cyan_bold
  shape_datetime: cyan_bold
  shape_list: cyan_bold
  shape_table: blue_bold
  shape_record: cyan_bold
  shape_block: blue_bold
  shape_filepath: { fg: cyan attr: u }
  shape_globpattern: { fg: cyan attr: u }
  shape_variable: cyan_italic
  shape_flag: blue_bold
  shape_custom: green
  shape_nothing: light_cyan
}

$env.config = {
  bracketed_paste: true
  color_config: $default_theme
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
    metric: false
    format: "auto"
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
