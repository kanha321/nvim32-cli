-- EditorConfig plugin for respecting project-specific settings
return {
  'editorconfig/editorconfig-vim',
  config = function()
    -- Support for EditorConfig files to manage indentation per project
    vim.g.EditorConfig_preserve_formatoptions = 1
    -- Disable for certain file types to avoid conflicts
    vim.g.EditorConfig_exclude_patterns = {'fugitive://.*', 'scp://.*'}
  end,
}
