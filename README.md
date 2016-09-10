# Nore
No **M**ore than a build system.

It is not **[C Lessons](https://github.com/junjiemars/c_lessons)** at all :). 
I'd programming in C long long time ago, sometimes I want to pick something up, 
but I cannot find the peice of code somewhere or cannot run the code on 
a machine that been wrote in another machine. 

Sadly, old dog need learn something new
* Access the code from anywhere, oh, GitHub is good one
* Run or Write code on anywhere, so Linux, Darwin, or Windows, Docker Box
* Easy to try and learn something new


## Philosophy 
The key question is how to build C code in variant OS environments by variant Compilers. 
Before I do the job, how [Nginx](https://www.nginx.com/resources/wiki/#)
build itself is the question that I always think about it: Nginx build itself 
from bottom to up and final is holy big one, but what about individual's freedom? 
so it is not the answer. 

The [CMake](https://cmake.org/) is great but not for how it do it's job. 
CMake introduce a lot of things you need to learn it's can not be accepted by old dog sometimes, 
and CMake is not debug friendly and poor documented.

The **Nore** try to find out another way, use everything that you had learned: shell, shell script,
 make, makefile to make a build system for variant platform.

Allways keep the following in my mind:
* Keep classic workflow: configure, make, make install
* Keep things simple: shell, make
* Keep things easy to get it done


**Nore** build a set of basic rules first then let the individual units (call it **stick**) 
to build itself, it's up to bottom follow. There should be some basic rules 
which face to variant build environments. And there must be individual units which 
decide how to build itself base on or not the baisc rules.

What about **Shell** and **Make**: Make run in shell and Make controls building rules.
So the natrual way: shell controls the basic rules which use to build the basic Makefiles 
then let make play with **sticks**' Makefiles. 

On Unix-like environment you need install or configure nothing. 
On Windows, you just need [Git Bash](https://git-scm.com/downloads), 
[GNU Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm), 
and both things can be done just by one bash script.

**Why use GNU Make**
Darwin and Linux has [GNU Make](https://www.gnu.org/software/make/) build-in, 
on Windows we use [GNU Make for Window]().
Paul Smith in [Rules of Makefile](#http://make.mad-scientist.net/papers/rules-of-makefiles/)
said:
> Don’t hassle with writing portable makefiles, use a portable make instead!

**Why use Git-Bash on Windows**
The most import reason is Git-Bash provides the automatic translation between Windows Path and 
POSIX Path and more: Unix utilities can be used with native toolchains and other native Windows
tools seamlessly.


## How to Play
Try **Nore** itself is very easy
```sh
$ git clone https://github.com/junjiemars/nore.git
$ auto/configure --has-hi --has-env --has-geo --has-math
$ make
$ make install
```

Another way to play is to download [C Lessons](https://github.com/junjiears/c_lessons) then do the following.


### Working On Unix-like
```sh
# go into your working directory
$ PREFIX=<where> bash <(curl https://raw.githubusercontent.com/junjiemars/nore/master/bootstrap.sh)

# dir structure: src/<what>/{Makefile,sources,headers}
# write your Makefile and then
$ ./configure --has-<what>

$ make
$ make install
```

### Working On Windows
* Prerequisites: [Git Bash](https://git-scm.com/downloads)
* Configure Nore:
```sh
# go into your working directory
$ PREFIX=<where> bash <(curl https://raw.githubusercontent.com/junjiemars/nore/master/bootstrap.sh)
```
* Play
```sh
# open cmd window first then execute vsvars32.bat 
# or open Developer Command Prompt for VS2015 directly
CMD> %VS140COMNTOOLS%\vsvars32.bat
CMD> bash

# play with Nore
$ configure --has-<what>
$ make
$ make install
```
