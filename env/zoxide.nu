export const ZOXIDE_INIT_PATH = ($nu.cache-dir | path join zoxide init.nu)

# Creates an `init.nu` file via `zoxide init …` at `ZOXIDE_INIT_PATH`.
export def init-zoxide [] {
	mkdir ($ZOXIDE_INIT_PATH | path dirname)
	zoxide init nushell --hook prompt | save -f $ZOXIDE_INIT_PATH
}
