# Nore
Why we need another C building system?


## Story

Frequently, I want to know how things works in machine level, so I need to
try something in C on popular platforms, but sadly, there are no 
handy weapons to do that.

* Keep things simple: classic workflow (configure, make and make install), 
debuggable, automatically setup.
* Write, Run and Build code on anywhere: Linux, Darwin, Windows or Docker.
* Easy to try some new ideas but have no more unnecessary.


Before I do this job, I'd known there are already aswsome tools exists: such
as [Autotools](https://www.gnu.org/software/automake/manual/html_node/Autotools-Introduction.html) and [CMake](https://cmake.org/).
The key question is how to easy build C code in varied OS by varied Compilers, among those things I just pick the most critical ones: **Make** and **Shell**.
 
So the story begins...

