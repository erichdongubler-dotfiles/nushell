$env.ENV_CONVERSIONS = {
	"PATH": {
		from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
		to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
	}
	"Path": {
		from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
		to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
	}
}

$env.EDITOR = "nvim"

export const ENV_DIR = ($nu.env-path | path dirname | path join env)

use ($ENV_DIR | path join os.nu) init-os-env
init-os-env | load-env

use ($ENV_DIR | path join atuin.nu) init-atuin
init-atuin

use ($ENV_DIR | path join zoxide.nu) init-zoxide
init-zoxide

use ($ENV_DIR | path join starship.nu) init-starship
init-starship
