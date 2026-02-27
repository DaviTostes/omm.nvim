local M = {}

M.config = {
  cmd = "omm",
  position = "bottom", -- left|right|top|bottom|float
  size = 20,           -- height for top/bottom, width for left/right (int or 0-1)
  enter_insert = true,
  focus = true,
  float = {
    width = 0.8,
    height = 0.8,
    border = "rounded",
  },
}

local state = {
  buf = nil,
  win = nil,
  job = nil,
}

local function clamp(n, lo, hi)
  if n < lo then return lo end
  if n > hi then return hi end
  return n
end

local function merge_config(user)
  M.config = vim.tbl_deep_extend("force", M.config, user or {})
end

local function valid_position(p)
  return p == "left" or p == "right" or p == "top" or p == "bottom" or p == "float"
end

local function to_abs(v, total, minv, maxv)
  local n
  if type(v) ~= "number" then
    n = math.floor(total * 0.8)
  elseif v <= 1 then
    n = math.floor(total * v)
  else
    n = math.floor(v)
  end
  return clamp(n, minv, maxv)
end

local function ensure_buf()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    return state.buf
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "omm"
  vim.api.nvim_buf_set_name(buf, "omm://terminal")

  state.buf = buf
  return buf
end

local function open_split(buf)
  local pos = M.config.position
  local size = M.config.size

  local cols = vim.o.columns
  local lines = vim.o.lines

  if pos == "bottom" or pos == "top" then
    local h = to_abs(size, lines, 1, lines - 2)
    if pos == "bottom" then
      vim.cmd(("botright %dsplit"):format(h))
    else
      vim.cmd(("topleft %dsplit"):format(h))
    end
  else
    local w = to_abs(size, cols, 1, cols - 2)
    if pos == "left" then
      vim.cmd(("topleft %dvsplit"):format(w))
    else
      vim.cmd(("botright %dvsplit"):format(w))
    end
  end

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  return win
end

local function open_float(buf)
  local ui = vim.api.nvim_list_uis()[1]
  local cfg = M.config.float or {}

  local w = to_abs(cfg.width, ui.width, 20, ui.width - 2)
  local h = to_abs(cfg.height, ui.height, 5, ui.height - 2)
  local row = math.floor((ui.height - h) / 2)
  local col = math.floor((ui.width - w) / 2)

  return vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w,
    height = h,
    row = row,
    col = col,
    style = "minimal",
    border = cfg.border or "rounded",
  })
end

local function ensure_job_running()
  if state.job ~= nil then
    return
  end
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return
  end

  -- garante que o termopen vai “pegar” o buffer certo
  vim.api.nvim_set_current_buf(state.buf)

  state.job = vim.fn.termopen(M.config.cmd, {
    on_exit = function()
      state.job = nil
    end,
  })
end

local function enter_terminal_if_needed()
  if M.config.enter_insert then
    vim.cmd("startinsert")
  end
end

local function set_buf_keymaps(buf)
  -- in terminal mode
  vim.keymap.set("t", "q", function()
    require("omm-nvim").close()
  end, { buffer = buf, noremap = true, silent = true })

  -- if user leaves terminal-mode and is in normal mode in that buffer
  vim.keymap.set("n", "q", function()
    require("omm-nvim").close()
  end, { buffer = buf, noremap = true, silent = true })
end

local function ensure_open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    if M.config.focus then
      vim.api.nvim_set_current_win(state.win)
      enter_terminal_if_needed()
    end
    return
  end

  local buf = ensure_buf()

  if M.config.position == "float" then
    state.win = open_float(buf)
  else
    state.win = open_split(buf)
  end

  set_buf_keymaps(buf)
  ensure_job_running()
  enter_terminal_if_needed()
end

function M.setup(opts)
  merge_config(opts)
  if not valid_position(M.config.position) then
    M.config.position = "bottom"
  end
end

function M.open()
  ensure_open()
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close()
  else
    M.open()
  end
end

return M
