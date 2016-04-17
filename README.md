IMP3 - Translating imperative programs to TVLA3
===============================================

TVLA (<http://www.cs.tau.ac.il/~tvla/>) is a parametric shape analysis tool that
can prove properties about heap-manipulating programs. It has a rather low-level
input syntax. The `imp3c` compiler translates high-level while-programs into the
transition systems of TVLA.

G. Ernst, G. Schellhorn, and W. Reif.
*Verification of B+ trees by integration of shape analysis and interactive theorem proving.*
Software & Systems Modeling (SOSYM), 14(1):27–44, 2013.

See also <https://swt.informatik.uni-augsburg.de/swt/projects/btree.html>,
which provides minimal documentation, the case study,
and an outdated version of the tool.

Dependencies
------------

-   python

-   python-setuptools

-   yapps 2.* <http://theory.stanford.edu/~amitp/yapps/>

    easy_install yapps

Installation
------------

generate the parser

    make

install (default: `$HOME/bin`)

    make install [ PREFIX=$HOME ]

VIM syntax highlighting

    cp imp3.vim ~/.vim/syntax
