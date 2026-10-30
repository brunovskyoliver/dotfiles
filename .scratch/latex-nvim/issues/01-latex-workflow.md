# Neovim LaTeX workflow

Status: complete
Completed: 2026-09-30

## What changed

Fixed the error shown when opening `research/template-research_paper.tex`.
The installed Homebrew `tree-sitter` formula supplied the library, but the
`tree-sitter-cli` executable was missing. Installing the CLI exposed a second
problem: the existing Tree-sitter plugin passed the removed `--no-bindings`
argument. The config now supplies generation arguments with Neovim's supported
ABI, installs the LaTeX and BibTeX parsers, and skips CLI-dependent installation
when the executable is absent.

Kept the Tree-sitter plugin on its `master` API for Neovim 0.11. VimTeX handles
LaTeX syntax and indentation so math text objects and prose spelling work;
the LaTeX Tree-sitter parser remains usable by structural tools.

Added VimTeX v2.16, Texlab configuration, 14 report snippets, English spelling,
visual wrapping, screen-line movement, and two-space indentation. Completion
includes citation keys and labels, with Tab/Shift-Tab snippet navigation.

Installed `tree-sitter-cli` 0.27.0, Tectonic 0.17.0, Texlab 5.26.0, and Skim
1.7.17. Added them to the Brewfile. Tectonic compiles open projects when their
TeX or bibliography files are saved. Texlab's automatic build is disabled to
avoid duplicate compilers. If `latexmk` is installed later, both integrations
select it at startup and VimTeX manages its continuous build mode.

Configured Skim's PDF reload and inverse-search preferences. The command is
`/opt/homebrew/bin/nvim` with arguments
`--headless -c "VimtexInverseSearch %line '%file'"`.

Applied the changed config files to `~/.config/nvim` as well as `~/dotfiles/nvim`.
The active directory is a separate copy, not a symlink. Preserved the existing
edits to `.zshrc`, the OmniSharp setup, and the original plugin lock entries.
No commit or remote write was made.

## Verification

Reproduced the original failure before changing the config:

```sh
cd /Users/oliver/Programming/SDU/team-os/docs
nvim --headless research/template-research_paper.tex \
  '+lua print("FILETYPE=" .. vim.bo.filetype)' '+qa!'
```

It produced `tree-sitter CLI not found: tree-sitter is not executable` from the
BufReadPost/FileType autocommands. The same file now opens without that error,
and its LaTeX Tree-sitter parser returns a `source_file` tree.

The headless integration check passed all of the following:

- LaTeX and BibTeX parsing, LaTeX filetype detection, and chapter root detection.
- One initialized Texlab client; real completion requests for `sec:intro` and
  `test2026` returned the expected label and citation key.
- Saving a chapter compiled its main document and generated PDF, SyncTeX,
  and a resolved bibliography.
- Saving its bibliography successfully rebuilt the open report.
- `<Space>la` stopped automatic builds on subsequent saves.
- The exact configured Skim inverse-search command returned to line 3 of the
  chapter in the existing Neovim process.
- `<Space>lv` opened the generated PDF in Skim, confirmed through AppleScript.
- All 14 snippets were registered; `texdoc` expanded an article and abstract.
- `:help latex-reports` opened the installed workflow guide.
- Simulating a missing CLI excluded LaTeX from required parser installation.

Compiled a temporary copy of the original `artikel1` report with Tectonic,
including its equation, booktabs table, bibliography, and SyncTeX output.
The source report was unchanged. The copy used a test-only bibliography
because the source directory has no `references.bib`.

`:checkhealth vimtex` reports the editor, compiler, and Skim as working.
It warns that external `bibtex` and `biber` executables are absent. Tectonic's
internal BibTeX and Texlab completion were both verified. `git diff --check`
passes. Temporary fixtures, backups, and checks were kept in session scratch.

Repeat the parser regression check with:

```sh
cd /Users/oliver/Programming/SDU/team-os/docs
nvim --headless research/template-research_paper.tex \
  '+lua assert(vim.treesitter.get_parser(0,"latex"):parse()[1]); assert(not vim.v.errmsg:find("tree%-sitter")); print("PASS")' \
  '+qa!'
```

## Using the setup

Restart Neovim to load the changed config. Open a `.tex` file normally.

| Keys | Action |
| --- | --- |
| `<Space>ll` | Compile the report |
| `<Space>lv` | Open the PDF at the current source location |
| `<Space>la` | Toggle Tectonic builds on save |
| `<Space>le` | Open compilation errors |
| `<Space>lt` | Open the table of contents |
| `<Space>lh` | Open the workflow guide |
| `Ctrl-Space` | Request completion |
| `Ctrl-k` | Expand a typed snippet trigger |
| `Tab` / `Shift-Tab` | Move between snippet placeholders |
| `Shift-Command-click` in Skim | Return to the source location |

Snippet triggers: `texdoc`, `env`, `sec`, `ssec`, `eq`, `align`, `fig`, `tbl`,
`items`, `cite`, `ref`, `frac`, `bf`, and `it`.

## What is left

No remaining config work. Existing Neovim processes need a restart.
The original report needs its own `references.bib` beside the `.tex` file to
resolve `wilkinson2016`; no bibliography content was added to the report.
Projects requiring Biber, a different TeX engine, or shell-escape tools need
a suitable TeX Live/MacTeX installation and latexmk.

## References

- [VimTeX v2.16 documentation](https://github.com/lervag/vimtex/blob/v2.16/doc/vimtex.txt)
- [Tree-sitter legacy configuration](https://github.com/nvim-treesitter/nvim-treesitter/blob/master/README.md)
- [Texlab configuration](https://github.com/latex-lsp/texlab/wiki/Configuration)
- [Tectonic](https://github.com/tectonic-typesetting/tectonic)

## Follow-up: local leader startup warning

Fixed on 2026-09-30. The initial setup assigned `vim.g.maplocalleader` inside
VimTeX's plugin `init`, after Lazy had captured the leader settings. Lazy's
change detector then displayed the warning about setting it before loading.
The first headless check exited too early to catch that delayed warning.

Moved the assignment to `lua/theprimeagen/remap.lua`, beside `mapleader`.
That module loads before `theprimeagen.lazy_init`. Removed the assignment
from the VimTeX plugin and applied both files to the active Neovim config.

Verified the mismatch before the fix: Lazy stored `nil`, while the current
local leader was a space. After the fix, both store a space. Explicitly ran
Lazy's change detector, processed its scheduled callbacks, and checked that
no leader warning appeared. The report still opens, and `<Space>ll` and
`<Space>lv` still point to the VimTeX compile and view mappings.
`git diff --check` passes. Restart existing Neovim sessions to load the fix.
