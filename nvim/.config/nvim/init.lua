vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.opt.autoindent = true

vim.opt.number = true
vim.opt.relativenumber= true

vim.opt.clipboard = "unnamedplus"

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wrap = false

vim.opt.scrolloff = 999

require("config.lazy")

vim.opt.virtualedit = "block"

vim.opt.inccommand = "split"

vim.opt.termguicolors = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})

vim.keymap.set("n", "<leader>nh", ":nohl<CR>", {})
vim.keymap.set("n", "<leader>sv", "<C-w>v", {})
vim.keymap.set("n", "<leader>sw", "<C-w>w", {})
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", {})

-- vim.keymap.set("n", "<leader>st", ":split| term<CR>", {})

vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", {})
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", {})
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", {})
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", {})
vim.keymap.set("n", "<leader>tb", "<cmd>tabnew %<CR>", {})

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")
vim.keymap.set("t", "jk", "<c-\\><c-n>")
vim.keymap.set("i", "jk", "<c-\\><c-n>")

local job_id = 0
vim.keymap.set("n", "<space>ss", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 15)
  -- job_id =vim.bo.channel
end)



local current_command = "!!"
vim.keymap.set("n", "<space>te", function()
  current_command = vim.fn.input("Command: ")
end)

vim.keymap.set("n", "<space>tr", function()
  if current_command == "" then
    current_command = vim.fn.input("Command: ")
  end

  vim.fn.chansend(job_id, { current_command .. "\r\n" })
end)

-- floaterminal 

local state = {
  floating = {
    buf = -1,
    win = -1,
  }
}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Create a buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  end

  -- Define window configuration
  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal", -- No borders or extra UI elements
    border = "rounded",
  }

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, win_config)
  vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat")
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= "terminal" then
      vim.cmd.terminal()
      job_id =vim.bo.channel
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

-- Example usage:
-- Create a floating window with default dimensions
vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})
vim.keymap.set("n", "<leader>tt", ":Floaterminal<CR>", {})

vim.keymap.set("n", "<leader>mt", "<cmd>Mtm<CR>", {})
vim.keymap.set("n", "<leader>mmp", "<cmd>MarkdownPreview<CR>", {})
