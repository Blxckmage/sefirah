local M = {}

M.isNixCats = vim.g[ [[nixCats-special-rtp-entry-nixCats]] ] ~= nil

function M.setup(_)

end

function M.lazyAdd(v, o)
  if M.isNixCats then
    return o
  end
  return v
end

return M
