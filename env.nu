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

let init_jobs = [
	{
		use $ENV_DIR os init-os-env
		init-os-env
	}
	{
		use $ENV_DIR atuin init-atuin
		init-atuin
	}
	{
		use $ENV_DIR zoxide init-zoxide
		init-zoxide
	}
	{
		use $ENV_DIR starship init-starship
		init-starship
	}
]
$init_jobs | par-each --threads ($init_jobs | length) {
  do $in | default {}
} | reduce --fold {} {|env, acc| $acc | merge $env } | reject PWD | load-env

export const SCRIPTS_DIR = ($nu.config-path | path dirname | path join scripts)
# NOTE: No need to `mkdir` or `touch …/mod.nu` here, since this should be created by my dotfiles
# history.
