export def notify [body: string, --title: string = ""] {
	if (($title | str length) > 0) {
		print (["\e]777;notify;" $title ";" $body "\e\\"] | str join)
	} else {
		print (["\e]9;" $body "\e\\"] | str join)
	}
}

export def set-tab-title [text: string] {
	print (["\e]1;" $text "\e\\"] | str join)
}

export def set-window-title [text: string] {
	print (["\e]2;" $text "\e\\"] | str join)
}
