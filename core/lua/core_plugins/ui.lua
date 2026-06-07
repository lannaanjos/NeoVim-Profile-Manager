-- desabilita o explorer pq prefiro usar o neotree (pq dá p usar na direita
return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
      styles = {
        terminal = {
          -- wo = {
          -- winhighlight = "Normal:NormalFloat",
          -- },
        },
      },
    },
  },
}
