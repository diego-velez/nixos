---@module "overseer"
---@type overseer.TemplateFileDefinition
return {
  name = 'Maven Build',
  builder = function(_)
    local files = vim.fs.find(
      { 'mvnw' },
      { upward = true, limit = math.huge, type = 'file', path = vim.fn.expand '%:p' }
    )
    local cwd = vim.fs.dirname(files[1]) or vim.uv.cwd()
    local rel_cwd = vim.fs.basename(cwd)
    ---@type overseer.TaskDefinition
    return {
      cmd = './mvnw',
      args = { 'install', '-U', '-DskipTests' },
      name = string.format('Maven Build in %s', rel_cwd),
      cwd = cwd,
    }
  end,
  tags = { require('overseer.constants').TAG.BUILD },
  module = 'java',
}
