$env.EDITOR = "nvim"

export const ENV_DIR = path self './env/mod.nu'

use $ENV_DIR os init-os-env
init-os-env | load-env
hide init-os-env

let init_jobs = [
	{
		use $ENV_DIR atuin init-atuin
		init-atuin
	}
	{
		use $ENV_DIR carapace init-carapace
		init-carapace
	}
	{
		use $ENV_DIR zoxide init-zoxide
		init-zoxide
	}
	{
		use $ENV_DIR starship init-starship
		init-starship
	}
	{
		use $ENV_DIR starship gen-completions-starship
		gen-completions-starship
	}
]
$init_jobs
  | par-each --threads ($init_jobs | length) { do $in }
  | reduce --fold {} {|env, acc| $acc | merge $env }
  | reject PWD
  | load-env

export const SCRIPTS_DIR = ($nu.config-path | path dirname | path join scripts)
# NOTE: No need to `mkdir` or `touch …/mod.nu` here, since this should be created by my dotfiles
# history.
