# Keep LaTeX build output out of source folders

Status: complete
Completed: 2026-10-06

## What changed

VimTeX now writes all Tectonic and latexmk output to
`stdpath("cache")/latex/<sha256-of-project-directory>/`. On this Mac that is
`~/.cache/nvim/latex/`. PDFs, logs, auxiliary files, and SyncTeX stay together
there, so source folders receive no generated files. Hashing the canonical
project directory prevents separate projects with the same document name
from overwriting each other's output.

Texlab uses VimTeX's main-document directory as its project root. Its explicit
build command and auxiliary, log, and PDF search paths use the same cache
directory. Tectonic's compile-on-save behavior and the existing preview
shortcuts are retained. The workflow help explains the output location.

Applied the changes to both `~/dotfiles/nvim` and the separate active copy at
`~/.config/nvim`. Preserved the other existing dotfiles edits.

Moved the existing `docs/research/research_template.log` into the document's
cache directory as `research_template.previous.log`. No source content was
edited. The research folder now contains `research_template.tex` and the
existing `topics.md`.

## Verification

- Ran real Tectonic builds through the active Neovim configuration. Saving a
  chapter with a root directive rebuilt its main document in the cache.
- Confirmed PDF, log, auxiliary, and SyncTeX files are cached, and VimTeX's
  output-file lookup finds each of them. Source folders stayed clean.
- Sent real `textDocument/build` requests to Texlab for two projects with
  spaces in their paths. Both builds succeeded using the cached output path.
- Confirmed the two projects' same-named `main.tex` files use distinct cache
  directories, and Texlab's project root and output settings match VimTeX.
- Compiled the current research template successfully to a cached PDF.
- Built a temporary document with an undefined environment. Its failure log
  stayed in the cache, and `VimtexErrors` showed the corresponding error.
- Confirmed all four changed config/help files match the active copy.
- `git diff --check` passed.

## What is left

Restart existing Neovim sessions to load the changed configuration.
latexmk is not installed on this Mac, so its real compiler execution was not
tested; its documented `out_dir` option is configured for the same cache path.

During the failure checks, VimTeX v2.16's existing LaTeX log parser omitted a
plain Tectonic `Undefined control sequence` error from quickfix. An undefined
environment error was parsed correctly. That parser behavior was not changed
by this task; the complete compiler output remains available with `<Space>lo`.

## References

- VimTeX v2.16's installed `:help g:vimtex_compiler_tectonic` and
  `:help g:vimtex_compiler_latexmk` document dynamic output directories.
- [Texlab configuration](https://github.com/latex-lsp/texlab/wiki/Configuration)
  documents build arguments and auxiliary, log, and PDF search directories.

## Follow-up: viewer cannot read PDF

Resolved on 2026-10-06. Opening `research_7_ux_test_git.tex` and running
`VimtexView` reproduced `Viewer cannot read PDF file!`. VimTeX's PDF lookup
returned an empty path because compilation had failed, leaving only a log.
The log reported `Misplaced alignment tab character &` while expanding the
title at `\maketitle`. There was no PDF elsewhere and no compiler still running.

Escaped the title's literal ampersand as `Git \& Project Quality` in the source
document. Ran `VimtexCompileSS` through the active Neovim configuration and
waited for its completion callback. Compilation succeeded, and the same
viewer lookup returned the readable cached `research_7_ux_test_git.pdf`.
The research directory still contains no generated files.

An already-open editor buffer may need `:checktime` to load the one-character
source correction before the next save. `<Space>lv` can open the cached PDF.

## Follow-up: research questions extend into the margin

Resolved on 2026-10-06. Both research documents used
`\item [Research question 1]` for their placeholders. LaTeX treats square
brackets after `\item` as an optional custom label, so it rendered each entire
question in the space reserved for the enumeration number.

Changed all four questions in `research_7_ux_test_git.tex` and
`research_template.tex` to `\item {[Research question N]}`. Braces keep the
placeholder text in the item body while preserving its visible brackets.
Recompiled the research document through VimTeX, rendered the first PDF page
with Poppler, and visually confirmed four numbered, indented questions inside
the text margins. Build output remains in the cache. `git diff --check` passed.

Existing editor buffers may need `:checktime` before saving the updated source.
