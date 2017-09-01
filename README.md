# Nore

No More than a C build system for clang, gcc and msvc.


## How to play

```sh
$ cd <your-c-apps-dir>

# run bootstrap from github, it will generate a configure file in current directory
$ bash <(curl https://raw.githubusercontent.com/junjiemars/nore/master/bootstrap.sh)

# compose a Makefile then
$ ./configure --has-<app-name-or-src-dirname>

$ make
```

Use ```./configure --help``` to show help message.


## How to upgrade 

```sh
# in your C apps dir
$ ./configure --update
```


[story](story.md) | [wiki](wiki.md)
