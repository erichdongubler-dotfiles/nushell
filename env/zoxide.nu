export const ZOXIDE_INIT_PATH = ($nu.cache-dir | path join zoxide init.nu)

# The `__zoxide_z`/`__zoxide_zi` definition lines in `zoxide init nushell`
# output. `export ` is optional: zoxide only added it in 0.10.0.
const ZOXIDE_DEF_PATTERN = '(?m)^((?:export )?def --env --wrapped __zoxide_zi?\b)'

# Creates an `init.nu` file via `zoxide init …` at `ZOXIDE_INIT_PATH`, with
# `@complete external` injected onto the jump commands.
#
# Nushell 0.116 stopped routing `def --wrapped` arguments to
# `$env.config.completions.external.completer`. Internal commands now opt in
# explicitly via the `@complete external` attribute, which zoxide does not
# emit, so `z <TAB>` resolves as an ordinary positional and the
# `zoxide query -l` completer in `config.nu` is never consulted.
#
# Upgrading zoxide is not an alternative. 0.10.0 does retype the rest argument
# as `directory`, but that shipped 2026-07-04, nearly three months before
# Nushell 0.116.0 (2026-09-26), so it is unrelated to this; its effect is to
# complete subdirectories of the cwd, which cannot reach the database at all.
export def init-zoxide [] {
	mkdir ($ZOXIDE_INIT_PATH | path dirname)

	let init = (
		zoxide init nushell --hook prompt
			| str replace --all --regex $ZOXIDE_DEF_PATTERN "@complete external\n$1"
	)

	# Catch zoxide's template drifting out from under the pattern. Losing the
	# attribute costs only completion, which nothing else would flag.
	let injected = $init | lines | where { $in == '@complete external' } | length
	if $injected != 2 {
		error make --unspanned {
			msg: $"expected to annotate 2 `__zoxide_z*` definitions in `zoxide init nushell` output, annotated ($injected); its Nushell template has changed"
		}
	}

	$init | save --force $ZOXIDE_INIT_PATH
}
