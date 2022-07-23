export def ansi-set-title [title: string] {
	echo [(ansi -o '0') $title (char bel)] | str collect
}

export def rn [path: path, name: string] {
	mv $path (echo (echo $path | path dirname) $name | path join)
}
