+++
# Projects widget.
# This widget displays all projects from `content/project/`.

date = 2016-04-20
draft = false

title = "Projects"
subtitle = ""
widget = "projects"

# Order that this section will appear in.
weight = 50

# View.
# Customize how projects are displayed.
# Legend: 0 = list, 1 = cards.
view = 0

# Filter toolbar.

# Default filter index (e.g. 0 corresponds to the first `[[filter]]` instance below).
filter_default = 1

# Add or remove as many filters (`[[filter]]` instances) as you like.
# To show all items, set `tag` to "*".
# To filter by a specific tag, set `tag` to an existing tag name.
[[filter]]
  name = "All"
  tag = "*"
  
[[filter]]
  name = "Science"
  tag = "science"

[[filter]]
  name = "Finished"
  tag = "finished"
  
[[filter]]
  name = "R Packages"
  tag = "R-Packages"

[[filter]]
  name = "AUR Packages"
  tag = "AUR-Packages"

+++
