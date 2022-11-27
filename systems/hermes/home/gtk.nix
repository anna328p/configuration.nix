{ ... }:

{
	gtk.gtk3.bookmarks = [

	] ++ (map (d: "file:///home/anna/${d}") [
		"work"
	]);
}
