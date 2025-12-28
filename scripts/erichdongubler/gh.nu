export const GH_IDENT_RE = '[-_a-zA-Z0-9]+'

export const GH_OWNER_AND_REPO_RE = ([
'(?P<owner>' $GH_IDENT_RE ')'
'/'
'(?P<repo>' $GH_IDENT_RE ')'
] | str join)

export def "pr next-id" [
  owner_and_repo_path: oneof<string, nothing> = null,
]: nothing -> int {
  let owner_and_repo = if $owner_and_repo_path != null {
    $owner_and_repo_path
      | parse --regex $'^($GH_OWNER_AND_REPO_RE)$'
      | try {
        first --strict
      } catch {
        error make --unspanned {
          msg: $"expected argument of the form `<owner>/<repo>`, got ($owner_and_repo_path)"
        }
      }
  } else {
    gh repo view --json owner,name
      | from json
      | rename --column { name: repo }
      | update owner { get login }
  }

  (
    http get
      ([
        'https://internal.floralily.dev/next-pr-number-api/'
        $'?owner=($owner_and_repo.owner)'
        $'&name=($owner_and_repo.repo)'
      ] | str join)
  ) | into int
}
