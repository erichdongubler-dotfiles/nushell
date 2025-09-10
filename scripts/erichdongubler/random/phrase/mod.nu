export def "main" [] {
  use std-rfc/random

  const MODIFIERS = path self ./modifiers.lst
  let modifiers = open $MODIFIERS | lines

  const ADJECTIVES = path self ./adjectives.lst
  let adjectives = open $ADJECTIVES | lines

  const NOUNS = path self ./nouns.lst
  let nouns = open $NOUNS | lines

  [$modifiers $adjectives $nouns] | each { random choice | first }
}
