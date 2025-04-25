# [r]e[n]ame a file to [name] by specifying its full [path] only _once_, please!
export def main [path: path, name: string] {
	mv $path ($path | path basename --replace $name)
}
