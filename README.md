````markdown
<h1 align="center">
    omm.nvim
</h1>

<p align="center">
    nvim integration for <a href="https://github.com/dhth/omm">omm</a>
</p>

---

## Requirements

- [omm](https://github.com/dhth/omm)
- `omm` executable available in your `$PATH`
- Neovim 0.9+ (recommended 0.10+)

---

## Installation

### lazy.nvim

```lua
{
  "davitostes/omm-nvim",
  opts = {
    position = "float", -- left|right|top|bottom|float
    size = 0.35,        -- number or 0-1 fraction
    cmd = "omm",
    float = {
      width = 0.8,
      height = 0.8,
      border = "rounded",
    },
    editor = "vi"
  },
  config = function(_, opts)
    require("omm-nvim").setup(opts)
  end,
}
````

---

### vim.pack (Neovim 0.12+)

```lua
vim.pack.add({
  { src = "https://github.com/davitostes/omm-nvim" }
})

require("omm-nvim").setup({
  position = "float", -- left|right|top|bottom|float
  size = 0.35,
  cmd = "omm",
  float = {
    width = 0.8,
    height = 0.8,
    border = "rounded",
  },
  editor = "vi"
})
```

---

## Usage

The plugin adds the command:

```
:Omm
```

This toggles the omm UI window.

You can also pass a position:

```
:Omm float
:Omm left
:Omm right
:Omm top
:Omm bottom
```

---

## Keybinding Example

```lua
vim.keymap.set("n", "<leader>o", "<cmd>Omm<CR>", { desc = "Toggle OMM" })
```

---

## Configuration Options

```lua
require("omm-nvim").setup({
  cmd = "omm",
  position = "bottom", -- left|right|top|bottom|float
  size = 20,           -- height/width or 0-1 fraction
  enter_insert = true,
  focus = true,
  float = {
    width = 0.8,       -- 0-1 fraction or absolute
    height = 0.8,
    border = "rounded",
  },
  editor = "vi"
})
```

---

## Behavior

* Reuses the same terminal buffer.
* Supports split or floating layouts.
* `q` closes the window.
* Automatically enters terminal mode (configurable).

---

## Screenshots

![Command](./images/command.png)

![Window](./images/window.png)

```
```
