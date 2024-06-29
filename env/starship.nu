export const STARSHIP_INIT_PATH = ($nu.cache-dir | path join starship init.nu)

# Creates an `init.nu` file via `starship init …` at `STARSHIP_INIT_PATH`.
export def init-starship [] {
	mkdir ($STARSHIP_INIT_PATH | path dirname)
	starship init nu | save -f $STARSHIP_INIT_PATH
}
