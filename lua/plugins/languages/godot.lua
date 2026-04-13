-- ============================================================================
-- Godot GDScript Language Support (Optional)
-- ============================================================================

return {
  -- GDScript support
  {
    "habamax/vim-godot",
    ft = { "gdscript", "gdshader" },
    config = function()
      vim.g.godot_executable = "godot"
    end,
  },
}
