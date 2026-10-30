# GitHub workflow support in Neovim

Status: complete
Completed: 2026-10-06

## What changed

Added the YAML Tree-sitter parser for syntax highlighting. Added Mason-managed
`yamlls` for ordinary YAML files and GitHub's official Actions language server
(`gh_actions_ls`, using the `actions-languageserver` executable) for workflow
files. Installed both servers and the YAML parser on this Mac.

Files directly inside `.github/workflows/` with either `.yml` or `.yaml`
extensions use the `yaml.ghactions` filetype. That filetype retains YAML
highlighting and attaches only the Actions server, avoiding duplicate YAML
and workflow diagnostics. Ordinary YAML files use `yamlls` with validation,
completion, hover documentation, and SchemaStore enabled.

Updated the existing completion filter to allow YAML snippet suggestions,
including key and workflow block insertions. Existing completion shortcuts
remain `<C-Space>` to request suggestions, `<C-n>` and `<C-p>` to select, and
`<CR>` to accept. `K` opens LSP hover documentation.

Applied the changes to `~/dotfiles/nvim` and the separate active copy at
`~/.config/nvim`. Preserved the existing edits in both directories.

## Verification

Ran the active Neovim configuration headlessly against temporary fixtures.

- Both workflow extensions received `yaml.ghactions`, attached only
  `gh_actions_ls`, and used an active YAML Tree-sitter highlighter.
- Real LSP completion requests returned `name` for a partial workflow key
  and `ref` inside `${{ github. }}`. The completion filter accepted them.
- A misspelled `runs-onn` key produced `Unexpected value 'runs-onn'`.
- An ordinary YAML file attached only `yamlls`, used YAML highlighting,
  and reported malformed YAML indentation.
- Confirmed the edited config files match between the dotfiles and active
  copies. `git diff --check` passed.

## What is left

Restart existing Neovim sessions to load the configuration. Workflow-specific
suggestions apply to `.github/workflows/*.yml` and `*.yaml`; YAML files elsewhere
receive general YAML support. No GitHub token was configured. Repository-specific
remote suggestions that require authentication are outside this change.

## References

- [GitHub Actions language server setup](https://github.com/actions/languageservices/blob/main/languageserver/README.md)
- [YAML language server](https://github.com/redhat-developer/yaml-language-server)

The installed nvim-lspconfig configurations and Mason registry supplied the
server definitions and package mappings used here.
