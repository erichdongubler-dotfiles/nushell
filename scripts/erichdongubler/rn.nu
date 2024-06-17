# [r]e[n]ame a file to [name] by specifying its full [path] only _once_, please!
export def main [path: path, name: string] {
	let path_with_new_basename = ($path | path dirname | path join $name)
	mv $path $path_with_new_basename
}
