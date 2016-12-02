# Nore
Why we need another C build system?

## A Story
I'd programming in C language long time ago, sometimes I want to try some code snappets, but I cannot find it in hand, or can not run the code which had been wrote on another machine. 

Those are all sadly cases, old dog always build somethings new else.
* Run the build system from anywhere.
* Run and write code on anywhere: in Linux, Darwin, Windows or Docker.
* Easy to try some idea but have no more than necessary.


## Philosophy 
The key question is how to build C code in varied OS by varied Compilers.
Before I do the job, it is awesome that [Nginx](https://www.nginx.com/resources/wiki/#) can build itself on varied platforms. Keep things simple: just use shell and make to build is one thing I learned from Nginx although Nginx is not a general C build system.

The [CMake](https://cmake.org/) is great but its not a natural way for building. CMake introduces a lot of unnecessary things that you cannot control it easyly, debugging unfriendly, poorly documents.

The older [Autotools](https://www.gnu.org/software/automake/manual/html_node/Autotools-Introduction.html) has the same problems as CMake had.

**Nore** try to find out another way, use everything that you had learned before: shell, shell script, make and makefile to build C code on varied platforms.

Always keep the following three rules in mind:
* Keep classic workflow: configure, make, make install.
* Keep things simple: only shell and make.
* Keep controls on everything and everything can be hacked if neccessary.


**Nore** build a set of basic rules first then let the individual units (call it **stick**) to build itself, it is a up-bottom and then bottom-up style. There should be some basic rules which face to varied building environments. And there must be allowed that individual units which can decide how to build itself base on the former basic rule or not.

What about **Shell** and **Make**: Make drived by shell, Make controls building rules. So the natural way is: shell controls the basic rules which use to build the basic Makefiles. Then, let **Make** play with **sticks**'s Makefiles, let **stick**'s **configure** play in bottom to up style.

On Unix-like environment you do not need to install or configure anything.
On Windows, you just need [Git Bash](https://git-scm.com/downloads), 
[GNU Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm), 
and those jobs can be done by Nore itself.

**Why use GNU Make**
Darwin and Linux has [GNU Make](https://www.gnu.org/software/make/) build-in, 
on Windows **Nore** use [GNU Make for Window](http://gnuwin32.sourceforge.net/packages/make.htm).
Paul Smith in [Rules of Makefile](#http://make.mad-scientist.net/papers/rules-of-makefiles/)
said:
> Don’t hassle with writing portable makefiles, use a portable make instead!

**Why use Git-Bash on Windows**
The foremost reason is Git-Bash provides the automatic translation between Windows Path and POSIX Path and more: Unix utilities can be used with native toolchains and other native Windows tools seamlessly.


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

$ cd /d/nore_lessons
# update nore?
$ ./configure --update

$ ./configure --has-<what>
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
