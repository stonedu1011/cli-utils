# CLI Utilities

Useful scripts I create to help my work

## Package, Install and Share

Not all scripts is suitable to other machine. Many of them were turned to work on particular file structure or configuration on my laptop. 

I've picked some sharable scripts and created a `Makefile` to build/package them. 

At the root of this project:

```
$ make
$ ln -s $(pwd)/dist/devenvctl/devenvctl.sh /usr/local/bin/devenvctl 
```

If you want to share these shell scripts with others, please copy all files in `dist`

<br>


## Utility `devenvctl`

`devenvctl.sh` allows me to quickly build, start, stop and switch development environments using [Docker](https://www.docker.com/). 

See [devenvctl guide](docs/devenvctl.md)
