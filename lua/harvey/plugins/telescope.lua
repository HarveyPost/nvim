return {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
        local telescope = require('telescope')

        telescope.setup({
            defaults = {
                vimgrep_arguments = {
                    'rg',
                    '--color=never',
                    '--no-heading',
                    '--with-filename',
                    '--line-number',
                    '--column',
                    '--smart-case',
                    '--hidden',
                    '--no-ignore',
                    '--no-ignore-parent',
                    '--follow',
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
                    no_ignore = true,
                    no_ignore_parent = true,
                    follow = true,
                    find_command = {
                        'rg',
                        '--files',
                        '--hidden',
                        '--no-ignore',
                        '--no-ignore-parent',
                        '--follow',
                    },
                },
            },
        })

        pcall(telescope.load_extension, 'fzf')
    end,
}
