local ls = require("luasnip")
local s, i = ls.snippet, ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
    s({ trig = "texdoc", name = "Article starter" }, fmt([[
\documentclass[a4paper,11pt]{{article}}
\usepackage{{amsmath,amssymb,graphicx,booktabs,hyperref}}
\title{{{}}}
\author{{{}}}
\date{{\today}}

\begin{{document}}
\maketitle

\begin{{abstract}}
{}
\end{{abstract}}

\section{{Introduction}}
{}

\end{{document}}
]], { i(1, "Title"), i(2, "Author"), i(3, "Abstract"), i(0) })),
    s({ trig = "env", name = "Environment" }, fmt([[
\begin{{{}}}
  {}
\end{{{}}}
]], { i(1, "itemize"), i(0), rep(1) })),
    s({ trig = "sec", name = "Section" }, fmt("\\section{{{}}}\n\\label{{sec:{}}}\n{}",
        { i(1, "Title"), i(2, "label"), i(0) })),
    s({ trig = "ssec", name = "Subsection" }, fmt("\\subsection{{{}}}\n{}", { i(1, "Title"), i(0) })),
    s({ trig = "eq", name = "Labelled equation" }, fmt([[
\begin{{equation}}
  \label{{eq:{}}}
  {}
\end{{equation}}
]], { i(1, "label"), i(0) })),
    s({ trig = "align", name = "Aligned equations" }, fmt([[
\begin{{align}}
  {}
\end{{align}}
]], { i(0) })),
    s({ trig = "fig", name = "Figure" }, fmt([[
\begin{{figure}}[htbp]
  \centering
  \includegraphics[width={}\linewidth]{{{}}}
  \caption{{{}}}
  \label{{fig:{}}}
\end{{figure}}
{}
]], { i(1, "0.8"), i(2, "figures/example"), i(3, "Caption"), i(4, "label"), i(0) })),
    s({ trig = "tbl", name = "Booktabs table" }, fmt([[
\begin{{table}}[htbp]
  \centering
  \caption{{{}}}
  \label{{tab:{}}}
  \begin{{tabular}}{{{}}}
    \toprule
    {} \\
    \midrule
    {} \\
    \bottomrule
  \end{{tabular}}
\end{{table}}
{}
]], { i(1, "Caption"), i(2, "label"), i(3, "ll"), i(4, "Heading & Heading"), i(5, "Value & Value"), i(0) })),
    s({ trig = "items", name = "Bullet list" }, fmt([[
\begin{{itemize}}
  \item {}
\end{{itemize}}
]], { i(0) })),
    s({ trig = "cite", name = "Citation" }, fmt("\\cite{{{}}}", { i(1, "key") })),
    s({ trig = "ref", name = "Reference" }, fmt("\\ref{{{}}}", { i(1, "label") })),
    s({ trig = "frac", name = "Fraction" }, fmt("\\frac{{{}}}{{{}}}", { i(1), i(2) })),
    s({ trig = "bf", name = "Bold text" }, fmt("\\textbf{{{}}}", { i(1) })),
    s({ trig = "it", name = "Italic text" }, fmt("\\textit{{{}}}", { i(1) })),
}
