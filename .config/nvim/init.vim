set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

call plug#begin()

" Editor
Plug 'tpope/vim-fugitive'

" Gui
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'jnurmine/zenburn'
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

" Semantic language support
Plug 'tpope/vim-commentary'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'hrsh7th/cmp-nvim-lsp', {'branch': 'main'}
Plug 'hrsh7th/cmp-buffer', {'branch': 'main'}
Plug 'hrsh7th/cmp-path', {'branch': 'main'}
Plug 'hrsh7th/nvim-cmp', {'branch': 'main'}
Plug 'ray-x/lsp_signature.nvim'

" Only because nvim-cmp _requires_ snippets
Plug 'hrsh7th/cmp-vsnip', {'branch': 'main'}
Plug 'hrsh7th/vim-vsnip'

" Syntatic language support
Plug 'rhysd/vim-clang-format'
Plug 'sheerun/vim-polyglot'
Plug 'rust-lang/rust.vim'
Plug 'jupyter-vim/jupyter-vim'

call plug#end()

" Colors
set t_Co=256
colors zenburn

" Rust-lang
syntax enable
filetype plugin indent on

" LSP configuration
lua << END
local cmp = require'cmp'

local lspconfig = require'lspconfig'
cmp.setup({
  snippet = {
    -- REQUIRED by nvim-cmp. get rid of it once we can
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    -- Tab immediately completes. C-n/C-p to select.
    ['<Tab>'] = cmp.mapping.confirm({ select = true })
  },
  sources = cmp.config.sources({
    -- TODO: currently snippets from lsp end up getting prioritized -- stop that!
    { name = 'nvim_lsp' },
  }, {
    { name = 'path' },
  }),
  experimental = {
    ghost_text = true,
  },
})

-- Enable completing paths in :
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  })
})

-- Setup lspconfig.
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

  -- Get signatures (and _only_ signatures) when in argument lists.
  require "lsp_signature".on_attach({
    doc_lines = 0,
    handler_opts = {
      border = "none"
    },
  })
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      completion = {
	postfix = {
	  enable = false,
	},
      },
    },
  },
  capabilities = capabilities,
}

lspconfig.clangd.setup {}

lspconfig.pyright.setup {}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
-- cpp debug
require'dap'.adapters.cppdbg = {
  type = 'executable',
  command = '/home/mikolaj/.vscode/extensions/ms-vscode.cpptools-1.7.1/debugAdapters/bin/OpenDebugAD7',
}
require'dap'.configurations.cpp = {
  {
    name = "Debug file",
    type = "cppdbg",
    request = "launch",
    program = "${workspaceFolder}/build/main",
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    externalConsole = false,
    MIMode = 'gdb',
    miDebuggerPath = '/usr/bin/gdb',
  }
}
require'dap'.configurations.c = require'dap'.configurations.cpp
require'dap'.configurations.rust = require'dap'.configurations.cpp

-- dapui
require("dapui").setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = { "o" },
    remove = "d",
    edit = "e",
    repl = "r",
  },
  sidebar = {
    -- You can change the order of elements in the sidebar
    elements = {
      -- Provide as ID strings or tables with "id" and "size" keys
      { id = "breakpoints", size = 0.10 },
      { id = "stacks", size = 0.25 },
      { id = "watches", size = 00.25 },
      {
        id = "scopes",
        size = 0.25, -- Can be float or integer > 1
      },
    },
    size = 40,
    position = "left", -- Can be "left", "right", "top", "bottom"
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
})
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
END

" Lightline
let g:lightline = {
      \ 'colorscheme': '16color',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileencoding', 'filetype' ] ],
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \   'gitbranch': 'gitbranch#name'
      \ },
      \ }
function! LightlineFilename()
  return expand('%:t') !=# '' ? @% : '[No Name]'
endfunction

set guioptions-=T " Remove toolbar
set laststatus=2
set noshowmode
set so=10
set cursorline

set number relativenumber
set showcmd
set mouse=a
set shiftwidth=2

" Quick-save
nmap <leader>w :w<CR>

" Autocompile
autocmd FileType c,cpp,cc,h nnoremap <leader>cb <cmd>!cd build;cmake ..;make;cd ..<CR>
autocmd FileType c,cpp,cc,h nnoremap <leader>mb <cmd>!make<CR>
autocmd FileType c,cpp,cc,h nnoremap <leader>mc <cmd>!make clean<CR>

" Debug
nnoremap <silent> <F5> <cmd>lua require'dap'.continue()<CR>
nnoremap <silent> <F9> <cmd>lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <S-F9> <cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <F10> <cmd>lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> <cmd>lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> <cmd>lua require'dap'.step_out()<CR>
nnoremap <silent> <leader>dr <cmd>lua require'dap'.repl.open()<CR>
nnoremap <silent> <leader>ds <cmd>lua require'dapui'.toggle()<CR>

set completeopt=menuone,noinsert,noselect
set cmdheight=2
set updatetime=300

let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
let g:rust_clip_command = 'xclip -selection clipboard'

" YCM
" let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
" let g:ycm_filetype_blacklist = {'sql': 1}

" Alt
" for i in range(97,122)
"   let c = nr2char(i)
"   exec "map \e".c." <M-".c.">"
"   exec "map! \e".c." <M-".c.">"
" endfor

" For moving lines 
nnoremap <A-j> mz:m-2<CR>`z==
nnoremap <A-k> mz:m+1<CR>`z==
inoremap <A-j> <Esc>:m-2<CR>==gi
inoremap <A-k> <Esc>:m+1<CR>==gi
vnoremap <A-j> :m'<-2<CR>gv=`>my`<mzgv`yo`z
vnoremap <A-k> :m'>+1<CR>gv=`<my`>mzgv`yo`z

" Copy Paste
nnoremap <leader>p "+p
vnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>P "+P
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+y$
