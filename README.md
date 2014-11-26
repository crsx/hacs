HACS
====

HACS abbreviates *Higher-order Attribute Contraction Schemes*, which
is a formal system for symbolic rewriting extended with programming
idioms commonly used in compiler rewriting.

A compiler written in HACS consists of a single program with a series
of formal sections, each corresponding to a stage of the compiler, and
each written in a formal style suitable for that stage.

HACS is implemented on top of the [CRSX](http://crsx.org) rewriting
engine.


How to Install
----

The current version of HACS is version 0.9.

The installation method depends on how you obtained HACS.

In any case you must have internet access when installing.

### Installing from downloaded hacs.zip archive

The simplest mechanism is to download the
[hacs-0.9.zip](http://crsx.org/hacs-0.9.zip) archive and install with
these commands:

```
wget http://crsx.org/hacs-0.9.zip
unzip hacs-0.9.zip
make -C hacs all install install-support
```

This creates the following directories (you can change the default `prefix=$HOME/.hacs` if you wish):

* `$HOME/.hacs/bin/hacs` - the main executable shell script.
* `$HOME/.hacs/lib/hacs` - directory with utility binaries.
* `$HOME/.hacs/share/hacs` - directory with non-binary utility files.
* `$HOME/.hacs/share/java` - directory with Java libraries.
* `$HOME/.hacs/share/doc/hacs` - directory with documentation.


### Making from source

You can clone the [crsx/hacs](https://github.com/crsx/hacs) github
project and then

```
make all install install-support
```
