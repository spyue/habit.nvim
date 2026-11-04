# habit.nvim
A habit tracker insert for markdown
```
2026-11-02   M    T    W    T    F    S    S
task a      [ ]  [ ]  [ ]  [ ]  [ ]  [ ]  [ ]
task b      [ ]  [ ]  [ ]  [ ]  [ ]  [ ]  [ ]
task c      [ ]  [ ]  [ ]  [ ]  [ ]  [ ]  [ ]
```

## Features
- Inserts a tracker with columns for Monday-Sunday dated at that weeks Monday
- Columns auto line up based on longest width of string on the left margin
- Customizable tasks, day labels, and date format through spec file

## Features Coming Soon
- [ ] Flip the box under the cursor
- [ ] Parser for turning trackers into data
- [ ] Scraper for subdirectories of current for stats
- [ ] Display screen showing upon command showing streaks and tasks for the week
- [ ] More info on install on other systems and plugin managers

## Reqs
- nvim 9.0 or higher

## Install

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  "spyue/habit.nvim",
  opts = {}
}
```

### Other plugin managers
Install `spyue/habit.nvim` with your plugin manager, then call `setup()`:

```lua
require("habit").setup({})
```

## Config

These are the defaults but you can pass any of them through opts in your spec to
change them (for lazy) or to setup for other plugin managers
```lua
{
  tasks = {"task a", "task b", "task c"},
  days = {"M", "T", "W", "T", "F", "S", "S"},
  empty = "[ ]",
  done = "[X]",
  date_format = "%Y-%m-%d",
  gap = 2,
}
```

## Uses
| Keybind| Description                                  |
|--------|----------------------------------------------|
| '\hi'  | Inserts tracker on the line under the cursor |

### Lua API

```lua
require("habit").insert()  -- insert a tracker below the cursor
require("habit").build()   -- return the tracker as a list of lines, without inserting
```

## Notes 
**Markdown:** Markdown formats the "[]" natively as the link feature thus it can appear
empty with an underline there are a couple fixes:

### Code Block
If you put the weeks trackers in a code block the boxes appear correctly. I just put
the "```" at the top and bottom of my file and insert the trackers between them as the
weeks go.

### Special Symbols
You can also use special symbols with the following in your spec:
```lua
opts = {
  empty = "☐",
  done = "☑",
}
```
This will replace the "[ ]" everywhere but you will also have to have whatever done
symbol you use on hand.

## License

MIT
