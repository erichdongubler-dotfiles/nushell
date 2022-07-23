export def rn [path: path, name: string] {
	mv $path (echo (echo $path | path dirname) $name | path join)
}
