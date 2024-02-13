export def init-zoxide [] {
	zoxide init nushell --hook prompt | save -f ~/.zoxide.nu
}
