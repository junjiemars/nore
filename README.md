# Nore

No More than a C building system for clang, gcc and msvc.


## How to Play

```sh
$ cd <your-c-apps-dir>

# run bootstrap from github, it will generate a configure file in current directory
$ bash <(curl https://raw.githubusercontent.com/junjiemars/nore/master/bootstrap.sh)

# compose a Makefile then
$ ./configure --has-<app-name-or-src-dirname>

$ make
```

On Windows, to setup bash environment first via:
download [Git Bash](https://git-scm.com/downloads), select 'unix compatible tools' when installing. Then run your __VS command prompt__, and start __bash__ in it.
 

Use ```./configure --help``` to show help message.


## How to Upgrade Nore

```sh
# in your C apps dir
$ ./configure --update
```


[story](story.md)
