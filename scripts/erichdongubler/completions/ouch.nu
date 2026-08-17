export extern "compress" [
  --level(-l): int, # Compression level, applied to all formats
  --yes(-y), # Skip [Y/n] questions, default to yes
  --fast, # Fastest compression level possible, conflicts with --level and --slow
  --no(-n), # Skip [Y/n] questions, default to no
  --accessible(-A) # Activate accessibility mode, reducing visual noise [env: ACCESSIBLE=]
  --slow, # Slowest (and best) compression level possible, conflicts with --level and --fast
  --hidden(-H), # Ignore hidden files
  --follow-symlinks(-S), # Read from target files instead of from symlinks (relevant for `tar` and `zip`)
  --quiet(-q) # Silence output
  --gitignore(-g), # Ignore files match by git's ignore files
  --format(-f): string@"nu-complete ouch compress format", # Specify the format of the archive
  --password(-p): string, # Decompress or list with password
  --threads(-c): int, # Concurrent working threads
  --help(-h), # Print help
  ...files: path, # Files to be compressed, or "-" for stdin
]

export extern "decompress" [
  --dir(-d): directory,
  --yes(-y), # Skip [Y/n] questions, default to yes
  --here, # Extract directly into the current directory, like `tar -xf` and `unzip` do
  --no(-n), # Skip [Y/n] questions, default to no
  --accessible(-A) # Activate accessibility mode, reducing visual noise [env: ACCESSIBLE=]
  --hidden(-H), # Ignore hidden files
  --quiet(-q) # Silence output
  --gitignore(-g), # Ignore files match by git's ignore files
  --format(-f): string@"nu-complete ouch decompress format" # Specify the format of the archive
  --password(-p): string, # Decompress or list with password
  --threads(-c): int, # Concurrent working threads
  --help(-h), # Print help
  ...files: path, # Files to be decompressed, or "-" for stdin
  output: path, # The resulting file. Its extensions can be used to specify the compression formats.
]

export extern "list" [
  --tree(-t), # Show archive contents as a tree
  --yes(-y), # Skip [Y/n] questions, default to yes
  --no(-n), # Skip [Y/n] questions, default to no
  --accessible(-A) # Activate accessibility mode, reducing visual noise [env: ACCESSIBLE=]
  --hidden(-H), # Ignore hidden files
  --quiet(-q) # Silence output
  --gitignore(-g), # Ignore files match by git's ignore files
  --format(-f): string@"nu-complete ouch decompress format" # Specify the format of the archive
  --password(-p): string, # Decompress or list with password
  --threads(-c): int, # Concurrent working threads
  --help(-h), # Print help
  ...files: path, # Files to be decompressed, or "-" for stdin
  output: path, # The resulting file. Its extensions can be used to specify the compression formats.
]

def "nu-complete ouch compress format" [
] {
  nu-complete ouch formats
    | where write
    | nu-complete ouch formats-to-completions
}

export def "nu-complete ouch decompress format" [
]: nothing -> table<value: string description: oneof<nothing, string>> {
  nu-complete ouch formats
    | where read
    | nu-complete ouch formats-to-completions
}

def "nu-complete ouch formats" [
]: nothing -> table<format: string, read: bool, write: bool, streaming: bool, parallel: bool, aliases: list<string>> {
  # NOTE: This is taken from the project's `README`.
  let format_table = "
Format 	.tar 	.zip 	.7z 	.gz 	.sz 	.zst 	.xz 	.lzma 	.lz 	.bz, .bz2 	.bz3 	.lz4 	.rar 	.br
Supported 	✓ 	✓¹ 	✓¹ 	✓² 	✓² 	✓² 	✓ 	✓ 	✓ 	✓ 	✓ 	✓ 	✓³ 	✓
"
  | from tsv --trim all
  | transpose
  | headers
  | update Format {
    let original = $in
    let trimmed = $original | str trim --left --char '.'
    if $trimmed == $original {
      error make {
        msg: "internal error: `raw_table` in `ouch formats` helper missing leading `.`"
        labels: [
          text: ""
          span: (metadata $original).span
        ]
      }
    }
    $trimmed
  }
  | rename --column { 'Format': 'format' }
  | update Supported {
    # ✓: Supports compression and decompression.
    #
    # ✓¹: Due to limitations of the compression format itself, (de)compression can't be done with streaming.
    #
    # ✓²: Supported, and compression runs in parallel.
    #
    # ✓³: Due to RAR's restrictive license, only decompression and listing can be supported.
    match $in {
      '✓' => {
        read: true,
        write: true,
        streaming: true,
        parallel: false,
      }
      '✓¹' => {
        read: true,
        write: true,
        streaming: false,
        parallel: false,
      }
      '✓²' => {
        read: true,
        write: true,
        streaming: true,
        parallel: true,
      }
      '✓³' => {
        read: true,
        write: false,
        streaming: true,
        parallel: false,
      }
    }
  }
  | flatten Supported


  let aliases = "
tar: tgz, tbz, tbz2, tlz4, txz, tlzma, tsz, tzst, tlz, cbt
zip: cbz, epub
7z: cb7
rar: cbr
"
  | lines
  | where { is-not-empty }
  | parse "{format}: {aliases}"
  | update aliases { split row  ", " }


  $format_table | join --left $aliases 'format'
}

def "nu-complete ouch formats-to-completions" [
]: table<'format': string, streaming: bool, parallel: bool, aliases: list<string>> -> table<value: string, description: string> {
  each --flatten {|entry|
    let capability_notes = [
      'streaming'
      'parallel'
    ]
      | each {|cap|
        if not ($entry | get $cap) {
          $"($cap): false"
        }
      }
    [
      {
        'format': $entry.format
        notes: []
      }
      ...($entry.aliases | each {|alias|
        {
          'format': $alias
          notes: [$"alias of `($entry.format)`"]
        }
      })
    ] | each {|entry|
      let notes = $entry.notes | append $capability_notes
      let description = if ($notes | is-not-empty) {
        $notes | str join ', '
      }

      {
        value: $entry.format
        description: $description
      }
    }
  }
}
