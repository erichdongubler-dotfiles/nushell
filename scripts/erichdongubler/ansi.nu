export def set-title [title: string = " "] {
	echo [
		(ansi -o "0;")
		$title
		(char bel)
	] | str join
}
