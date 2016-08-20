%% HACS very simple tutorial.
%%
%% Copyright (c) 2016 Kristoffer Rose <krisrose@crsx.org>
%% License: CC-BY version 4.0
%%
\documentclass[11pt]{article} %style: font size.
\usepackage[utf8]{inputenc}

\usepackage[type={CC},modifier={by},version={4.0}]{doclicense}

%% Style.
\usepackage[margin=.7in]{geometry}
\usepackage[T1]{fontenc}
\bibliographystyle{plainurl}
\renewcommand{\rmdefault}{pplx}\usepackage{eulervm}\AtBeginDocument{\SelectTips{eu}{11}}

%% Base format.
\input{setup}
\numberwithin{equation}{section}

%% Topmatter.
\title{
  Transscribing to \HAX 
}
\author{
  Kristoffer H. Rose
}

\begin{document}
\maketitle

\begin{abstract}\noindent
  We develop a compiler in the \HAX language from the really simple expression language in the first
  chapter of the ``Dragon Book.'' The full \HAX code is included in literate programming style.

  \compacttableofcontents

  \bigskip\noindent\doclicenseImage[imagewidth=3em]\quad%
  This document is © 2016 Kristoffer Rose licensed under \doclicenseNameRef.
\end{abstract}


\section{Introduction}

In this document we will introduce the \HAX compiler specification language by implementing a very
simple compiler from a small language (with just assignment and numeric expressions) to assembly
language. The language comipiles programs like "initial:=1; rate:=1.0; position:=initial+rate*60;".


This is not a manual: we expect you to have access to the proper \HAX manual~\cite{Rose:ts2016}, as
well as some knowledge of programming languages, assembly programming, and compiler construction, in
particular the notion of syntax-directed definitions (\aka attribute grammars) as explained, for
example, in the dragon book~\cite{Aho+:2006}.

The \HAX code will be introduced as we write it, inline in ``Code'' blocks; you can always consult
the full \emph{first.hx} file if you need a more compact version.\footnote{The \emph{first.hx} file
  is actually generated from the \LaTeX source of this document.}  Indeed, we have to start the \HAX
specification by defining which module we are creating, which is done as follows, where you can see
the line number used to indicate that this is \HAX code:
%%
\begin{hacs}{module}
module org.crsx.hacs.tut.First {
\end{hacs}

\section{Lexical Analysis}

Our first task is to encode the tokens that require regular expressions. For our trivial sample
language this is just two categories:
%%
\begin{description}

\item[Identifiers,] denoted \tk{id}, which are tokens that match the regular expression
%%
  \begin{equation}
    \label{eq:lex-id}
    [A{-}Za{-}z][0{-}9A{-}Za{-}z]^*
  \end{equation}

\item[Numbers,] denoted \tk{num}, which match
  %%
  \begin{equation}
    \label{eq:lex-num}
    [0{-}9]^+\bigl([.][0{-}9]^+\bigr)^?
  \end{equation}

\end{description}
%%
In addition, all white space should be skipped.

\begin{quote}\it\noindent
  There are more tokens, namely ``constant'' tokens, like ``+,'' however, we follow usual practice
  of just specifying these in the grammar.
\end{quote}

These can be transcribed directly into \HAX. In \HAX, regular expressions are encoded as ``token''
that look like this:
%%
\begin{hacs}{Tokens}
token ID  |  [A-Za-z] [A-Za-z0-9]* ;
token NUM  |  [0-9]+ ( "." [0-9]+ )? ;
\end{hacs}
%%
You can see that the \HAX code corresponds rather closely to the regular expressions, with the
following extensions:
%%
\begin{itemize}

\item Token declarations start with the \kw{token} \HAX keyword and ends with a
  semi-colon~(\verb|;|).

\item Tokens have a \emph{name} for use in productions later.

\item The actual regular expression definition starts with a \emph{vertical bar}.

\item Text in double quotes (\verb|"|) is \emph{literal text}.

\item Spaces are not significant on the outermost level of \HAX, only in sensitive constructs (such
  as character classes and literal text).

\end{itemize}





declarations where spaces are not significant (except inside quotes and character classes).




\section{Wrapping Up}

The compiler components are done. We can now write the main scheme, invoked from the command line.
%%
\begin{hacs}{main}
sort Asm  |  scheme Compile(Prog) ;
Compile(#P) → CodeGen(TypeCheck(#P)) ;
\end{hacs}

Finally, we need to close up the module opened in the introduction.
%%
\begin{hacs}{end}
}
\end{hacs}


\bibliography{crs}

\end{document}

%%---------------------------------------------------------------------
% Tell Emacs that this is a LaTeX document and how it is formatted:
% Local Variables:
% mode:latex
% fill-column:100
% TeX-master: t
% End:
