export def init-zoxide [] {
	# TODO: Remove `str replace` once <https://github.com/ajeetdsouza/zoxide/pull/642> has merged.
	zoxide init nushell --hook prompt | str replace --all "def-env" "def --env" | save -f ~/.zoxide.nu
}
