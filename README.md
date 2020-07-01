
# Handy Box Tool Scripts

Handybox is a tool with many shell scripts integrated for linux/macOS environment.

[TOC]

## Features
1. provide only one main command `hand` for many shell scripts.
2. Flexible sub command, lazy load.
3. Easy to customize your shell environment.

## Installation
1. get handybox
    ```
    git clone git@github.com:Joyep/handybox.git
    cd handybox
    git submodule init
    git submodule update
    ```
2. export `hand__path` in your shell config file (such as ~/.bashrc)
    ```
    sh install.sh
    ```
    It will automaticlly install `hand` command line in your home bin path(`$HOME/bin`), and show you lines to add into bash config file. as below:

    ```
    export hand__path=/path/to/handybox
    source $hand__path/hand.sh
    source $hand__path/hand-completions.sh
    ```
3. open new terminal and enjoy!
   ```
   hand
   ```

## Usage

Basic command line rules like this:

`hand [<options...>] [sub_command [<params...>]]`

- `hand`: The main command
- `options...`: options for hand, as below:
   - `--show`: show source code of this command
   - `--help`: show help of this command
   - `--silence`: not display any log

- `sub_command`: any custom sub command
- `params...`: params for sub command

### Intergrated sub commands
* `hand update` --- update hand and sub command scripts
* `hand update completions` --- update completions
* `hand cd` --- cd to handybox root dir
* `hand cd config`  --- cd to your config dir
* `hand work` --- switch workspace
* `hand prop get/set` --- get/set properties in you workspace

### command type
There is 2 types of command, called `EffectFunction` and `PureFunction`. 
- `EffectFunction` commands does modify current shell environment. list as below:
  - cd
  - work
  - prop
  - update
- `PureFunction` commands does not modify current shell environment.

> If you want to run cmd in standalone process, please use `$HOME/bin/hand` executable bin, or use `hand__hub` instead of `hand`, to run `PureFunction` commands in standalone process.

## Configuration
The first time you source handybox, it will automatically generate config directory named depending on current user name and host name, located in `$hand__path/config/<user_name>_<host_name>`.
It is a copy of `$hand__path/example`, file tree shows as below:
```
example/
├── alias.sh        --- your alias
├── custom.sh       --- your custom scripts
└── hand            --- your custom commands
    └── example.sh
```
> Tips: `$hand__config_path` is your config dir path.


## Alias hand as h
Alias hand as h makes you more easy to use handybox, the main command just an `h`.

1. `hand cd config`, jump to your handybox config dir
2. Edit `alias.sh`, add line `alias h='hand'`
3. `hand update`
4. Using `h` instead of `hand`

> Tips: If you prefer call `hand__hub` instead of `hand`, using `alias h='hand__hub`.



## Workspace
Sometimes, you need some environment, but in other times, you need some other environment. For this reason, we need workspace.

In handybox, workspace is a file include a set of properties, named `<workspace_name>.props`, placed in config path.

Using `hand work` to show all workspace. first time, it shows like this:
```sh
$ hand work
work space:
  *  default
```
It means that you have one workspace named `default`. Now, you can put some properties into this workspace.
```sh
$ hand prop set hello.to Daniel
$ hand prop get hello.to
Daniel
```
Then, maybe you want to switch to another workspace, say `develop`:
```sh
$ hand work develop
work space:
     default
  *  develop
```
It will switch to another workspace, if this workspace not exist, it will create one automatically.


## Custom sub command

It is easy to add a new sub command, for example if you want to add a command `hand hello`.
1. create file `$hand__path/hand/hello.sh`or`$hand__config_path/hand/hello.sh`, and write shell script as below:
```
function hand_hello()
{
    echo "Hello, world!"
}
```
> Notice: function name must be `hand_hello` if your command is `hand hello`.
2. enjoy!
```
$ hand hello
Hello, world!
```

### Use workspace in sub command
1. Edit `$hand__path/hand/hello.sh`
    ```sh
    function hand_hello()
    {
        hello_to=`hand__pure_do hand prop get hello.to`
        if [ $? -ne 0 ]; then
            echo "hello.to not found!"
            return 1
        fi
        echo "Hello, $hello_to"
    }
    ```
2. Test `hand hello` in different workspace
    ```
    $ hand work alice
    $ hand hello
    hello.to not found!

    $ hand prop set hello.to Alice
    $ hand hello
    Hello, Alice

    $ hand work bob
    $ hand prop set hello.to Bob
    $ hand hello
    Hello, Bob

    $ hand work alice
    $ hand hello
    Hello, Alice
    ```

## Global variables and functions

handybox export some variables and functions in enviroment.

### Functions
- hand
- hand__hub
- hand__help
- hand__show_help
- hand__getprop
- hand__get_file_timestamp
- hand__get_computer_name
- hand__get_file_timestamp
- hand__get_firstline
- hand__get_first
- hand__get_lastline
- hand__get_last
- hand__echo_debug
- hand__check_function_exist

- hand__load_file
- hand__pure_do
- hand__shell_name

### Variables
- hand__path
- hand__version
- hand__timestamp
- hand__timestamp_* --- 自命令的时间戳, 用于懒加载
- hand__complist_*  --- 自动补全信息
- hand__debug       --- 是否打印debug信息
- hand__config_path --- 用户配置目录
- hand_work__name

## Version
* next
    * Support `hand install` command to install extra function. 
* 2.1.0
    * compatible with zsh

