# [r]e[n]ame a file to [name] by specifying its full [path] only _once_, please!
export def main [
  path: path,
  name: string@"nu-complete rn name",
] {
  mv $path ($path | path basename --replace $name)
}

export def "nu-complete rn name" [
  context: string,
] {
  [($context | path basename)]
}
