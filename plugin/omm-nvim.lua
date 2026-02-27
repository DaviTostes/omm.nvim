if vim.g.loaded_omm_nvim == 1 then
  return
end
vim.g.loaded_omm_nvim = 1

vim.api.nvim_create_user_command("Omm", function(opts)
  require("omm-nvim").toggle()
end, {
  nargs = 0,
  desc = "Toggle OMM UI",
})
