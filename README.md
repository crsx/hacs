HACS
====

*Higher-order Attribute Contraction Schemes*, or HACS, is a formal system for symbolic rewriting extended with programming idioms commonly used when coding compilers.

HACS is developed as a front-end to the [CRSX](http://crsx.org) higher-order rewriting engine, although HACS users need not be concerned with the details of higher-order rewriting (even if those are, in fact, most interesting).

A compiler written in HACS consists of a single specification file with a series of formal sections, each corresponding to a stage of the compiler. Each section is written in a formal style suitable for that stage of the compiler.

Installing
----------

Clone [crsx/hacs](https://github.com/crsx/hacs) and:

```
make all install install-support
```

This will create the following directories (you can change the default `prefix=$HOME/.hacs` if you wish):

* `$HOME/.hacs/bin/hacs` - the main executable shell script.
* `$HOME/.hacs/lib/hacs` - directory with utility binaries.
* `$HOME/.hacs/share/hacs` - directory with non-binary utility files.
* `$HOME/.hacs/share/java` - directory with Java libraries.
* `$HOME/.hacs/share/doc/hacs` - directory with documentation.
