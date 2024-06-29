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

use ([($nu.env-path | path dirname) env os.nu] | path join) init-os-env
init-os-env | load-env

use ([($nu.env-path | path dirname) env atuin.nu] | path join) init-atuin
init-atuin

use ([($nu.env-path | path dirname) env zoxide.nu] | path join) init-zoxide
init-zoxide

use ([($nu.env-path | path dirname) env starship.nu] | path join) init-starship
init-starship
