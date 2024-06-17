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
  footer_mode: "25" # always, never, number_of_rows, auto
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
      name: commands_menu
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
      source: { |buffer, position|
        scope commands
          | where command =~ $buffer
          | each { |it| {value: $it.command description: $it.usage} }
      }
    }
    {
      name: vars_menu
      only_buffer_difference: true
      marker: "(variables) "
      type: {
        layout: list
        page_size: 10
      }
      style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
      }
      source: { |buffer, position|
        scope variables
          | where name =~ $buffer
          | sort-by name
          | each { |it| {value: $it.name description: $it.type} }
      }
    }
    {
      name: commands_with_description
      only_buffer_difference: true
      marker: "(commands-help) "
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
      source: { |buffer, position|
        scope commands
            | where command =~ $buffer
            | each { |it| {value: $it.command description: $it.usage} }
      }
    }
  ]
  keybindings: [
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
      name: commands_menu
      modifier: control
      keycode: char_t
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: commands_menu }
    }
    {
      name: vars_menu
      modifier: control
      keycode: char_y
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: vars_menu }
    }
    {
      name: commands_with_description
      modifier: control
      keycode: char_u
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: commands_with_description }
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
      name: git_refs
      modifier: control
      keycode: char_g
      mode: [emacs, vi_insert]
      event: {
        send: ExecuteHostCommand
        cmd: "commandline edit --insert (
          git branch -l "--format=%(refname:short)"
            | lines
            | str join (char -i 0)
            | fzf
              --multi
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
