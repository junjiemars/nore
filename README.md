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

The older [Autotools](https://www.gnu.org/software/automake/manual/html_node/Autotools-Introduction.html) has the same problems as CMake and less a installer like CMake already had to solve portable issues.

**Nore** try to find out another way, use everything that you had learned before: shell, shell script,
 make, makefile to make a build system for variant platforms.

Allways keep the following in mind:
* Keep classic workflow: configure, make, make install
* Keep things simple: just shell and make, easy to get job done
* Keep the controls on everythings: everythings can be hacked by your needs


**Nore** build a set of basic rules first then let the individual units (call it **stick**) 
to build itself, it's up to bottom follow. There should be some basic rules 
which face to variant build environments. And there must be individual units which 
decide how to build itself base on or not the baisc rules.

What about **Shell** and **Make**: Make drived by shell and Make controls building rules.
So the natural way: shell controls the basic rules which use to build the basic Makefiles 
then let make play with **sticks**' Makefiles. 

On Unix-like environment you need install or configure nothing. 
On Windows, you just need [Git Bash](https://git-scm.com/downloads), 
[GNU Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm), 
and those things can be done by Nore itself.

**Why use GNU Make**
Darwin and Linux has [GNU Make](https://www.gnu.org/software/make/) build-in, 
on Windows **Nore** use [GNU Make for Window](http://gnuwin32.sourceforge.net/packages/make.htm).
Paul Smith in [Rules of Makefile](#http://make.mad-scientist.net/papers/rules-of-makefiles/)
said:
> Don’t hassle with writing portable makefiles, use a portable make instead!

**Why use Git-Bash on Windows**
The foremost reason is Git-Bash provides the automatic translation between Windows Path and 
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

If you had a C project in your working directory already
```sh
# go into your working directory
# <where> to put nore down, PREFIX is optional
$ [PREFIX=<where>] bash <(curl https://raw.githubusercontent.com/junjiemars/nore/master/bootstrap.sh)
$ ./configure --has-<what>
$ make
```

On Windows, needs to setup bash environment first:
download [Git Bash](https://git-scm.com/downloads), select 'unix compatible tools' when installing.
 

Another way to try and play is to clone [Nore Lessons](https://github.com/junjiears/nore_lessons) then go.

### Workflow
Write your makefile first, and configure or version files if neccessery.
```sh
# go into your working directory

# <where> to put nore down, PREFIX is optional
$ [PREFIX=<where>] bash <(curl https://raw.githubusercontent.com/junjiemars/nore/master/bootstrap.sh)

# nore's help
$ ./configure --help

# dir structure: src/<what>/{Makefile,sources,headers}
# write your Makefile and then
$ ./configure --has-<what>

# or update Nore to date first, and then
$ ./configure --update --has-<what>

$ make
$ make install

# build without **warnings** info
$ ./configure --without-warn

# build without **optimized**
$ ./configure --without-optimize

# build without **debugging** info
$ ./configure --without-debug

# build with **verbose** 
$ ./configure --with-verbose
```

### Nore on Windows
1. open **CMD** prompt, then run **.vs-inc.bat** in HOME directory.
2. run **bash** in **CMD** prompt
3. go into your C project, play as you go
```cmd
CMD> %USERPROFILE%\.vs-inc.bat
CMD> bash

$ cd -d /d/nore_lessons
$ ./configure --has-step1
```

### IDE debugger
* Xcode
The compiled program can be debugged by **GDB** or **LLDB**, and **Xcode**'s debugger too if on MacOS.
  1. Open Xcode
  2. **Create a new Xcode project** and then choose **Empty** project
  4. **Product** > **Scheme** > **New Scheme**, set **Info>Executable**, 
  set **Arguments>Environement Variables** : DYLD_LIBRARY_PATH=<where-lib>
  7. **Debug** > **Breakpoints** > **Create Symbolic Breakpoints**
* Visual Studio
  1. Open **Visual Studio**
  2. **File** > Open **Project/Solution** and then select **EXE project files**
  3. Select your **exe** file 
