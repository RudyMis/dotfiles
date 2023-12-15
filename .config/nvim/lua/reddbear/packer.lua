-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.2',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  use('theprimeagen/harpoon')
  use('mbbill/undotree')

  use {
	  'tanvirtin/vgit.nvim',
	  requires = {
		  'nvim-lua/plenary.nvim'
	  }
  }

  use {
    'numToStr/Comment.nvim',
    config = function() require('Comment').setup() end
  }

  use {
	  'nvim-treesitter/nvim-treesitter', tag = 'v0.8.3',
	  run = ':TSUpdate'
  }

  use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v2.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'}, 

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'L3MON4D3/LuaSnip'},
	  }
  }

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  use {
	  "phha/zenburn.nvim",
	  config = function() require("zenburn").setup() end
  }


  use('eandrju/cellular-automaton.nvim')

end)
