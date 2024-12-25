export def dark-theme []: nothing -> record {
  use std/config dark-theme

  const sublime_aqua = "#66d9ef"
  const sublime_green = "#a6e22d"
  const sublime_offwhite = "#f8f8f2"
  const sublime_orange = "#fd9720"
  const sublime_pink = "#f92772"
  const sublime_purple = "#ae81ff"
  const sublime_yellow = '#e6db74'
  const sublime_darkgray = "dark_gray"

  dark-theme | merge deep {
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
    "cell-path": $sublime_offwhite
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
    shape_glob_interpolation: { fg: $sublime_purple attr: "i" }
    shape_globpattern: { fg: $sublime_purple attr: "i" }
    shape_int: { fg: $sublime_purple attr: "b" }
    shape_internalcall: { fg: $sublime_aqua attr: "b" }
    shape_keyword: { fg: $sublime_aqua attr: "b" }
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
    shape_vardecl: $sublime_offwhite
    shape_variable: $sublime_purple
    shape_raw_string: $sublime_purple

    background: "#272822"
    foreground: $sublime_offwhite
    cursor: $sublime_offwhite
  }
}
