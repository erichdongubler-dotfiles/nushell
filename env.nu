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

use $ENV_DIR os init-os-env
init-os-env | load-env
hide init-os-env

use $ENV_DIR atuin init-atuin
init-atuin
hide init-atuin

use $ENV_DIR zoxide init-zoxide
init-zoxide
hide init-zoxide

use $ENV_DIR starship init-starship
init-starship
hide init-starship

export const SCRIPTS_DIR = ($nu.config-path | path dirname | path join scripts)
