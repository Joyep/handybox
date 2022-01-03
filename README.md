
# Handybox
**Directory hierarchical subcommand framework for shell**

Handybox is a flexible script collection framework intergrated with any custom scripts for linux/macOS shell environment.


## Features
1. Provide only one main command `hand` for all integrated scripts.
2. Flexible sub commands.
3. Easy to customize your own shell function, variables and commands.
4. Automaticly generate command completions.
5. Multi user configurations.


## Version
* 3.3
  * Optimize hand options, isolate command with `--`, append with option (help/pure/...).
  - Sub command completion script spec: `comp.sh` V2.3
  - Sub command properties completion script spec: `comp_props.sh` V1.0
  - Sub command spec: `cmd.sh` V2.0
* 3.1
  * Update dir structure, All sub commands located in dir with a name of `cmd.sh`
* 3.0
  * Update dir structure. Support place depended libs in the same dir of sub command.
  * Move `hand prop get/set` to `hand work getprop/setprop`
  * Add core sub command `hand git st`, which go into a dir and call `git status`
* 2.2
  * Only keep core sub commands, delete other personal commands.
* 2.1.0
  * compatible with zsh


## Installation
1. get handybox
    ```sh
    git clone git@github.com:Joyep/handybox.git
    cd handybox
    ```
2. export `hand__path` in your shell config file (such as ~/.bashrc or ~/.zshrc)
    ```sh
    sh install.sh
    ```
    It will automaticlly install `hand` command line into your home bin path(`$HOME/bin`), and show you lines which you should COPY into bash config file manually. example as below:

    ```sh
    # handybox
    export hand__path=/path/to/handybox
    source $hand__path/hand.sh
    ```
3. open new terminal and enjoy!
   ```sh
   hand
   ```

## Usage

Basic command line rules like this:

`hand [sub_command [<params...>]] [-- <option>]`

- `hand`: The main command
- `option`: options for hand, as below:
   - `-- source`: show source code of this command
   - `-- help`: show help of this command
   - `-- pure`: not display any log
   - `-- cd`: cd to sub command dir
   - `-- test`: test run the sub command
- `sub_command`: any custom sub command
- `params...`: params for sub command

### Core sub commands
* `hand update` --- reload hand main script
* `hand cd` --- cd to handybox root dir
* `hand cd config`  --- cd to your config dir
* `hand work` --- switch workspace, get/set props in workspace
* `hand work getprop` --- get prop from workspace
* `hand work setprop` --- set prop to workspace
* `hand sh` --- execute shell script with handybox env in process

## Configuration
The first time you source handybox, it will automatically generate config directory named depending on current user name and host name, located in `$hand__path/config/<user_name>_<host_name>`.
It is a copy of `$hand__path/example`, file tree shows as below:
```sh
$hand__config_path/
├── alias.sh        # your alias
├── config.sh       # your configuration scripts
└── hand            # your user scope sub commands
    └── example
      └── cmd.sh
```
> Tips: `$hand__config_path` is the path of your config dir.

### config.sh
config handybox in config.sh
```sh
# Disable debug info (default: 1)
#     0: debug enabled
#    >0: debug disabled
hand__debug_disabled=1

# Cached load sub command (default: 1)
#    1: will cached load sub command as a function
#    0: will direactly load and excute sub command
hand__cache_load=1
```

## Alias hand as h
Alias hand as h makes you more easier to use handybox, the main command just an `h`.

1. `hand cd config`, jump to your handybox config dir
2. Edit `alias.sh`, add line `alias h='hand'`
3. `hand update`
4. Using `h` instead of `hand`


Example alias:
```sh
# alias.sh
alias h='hand'
```


## Workspace
Sometimes, you need some environment, but in other times, you need others. For this reason, we need workspace.

In handybox, workspace is a file include a set of properties, named `<workspace_name>.props`, placed in config path.

Using `hand work` to show all workspace. first time, it shows like this:
```sh
$ hand work
work space:
  *  default
```
It means that you have one workspace named `default`. Now, you can put some properties into this workspace.
```sh
$ hand work setprop hello.to Daniel
$ hand work getprop hello.to
Daniel
```
Then, maybe you want to switch to another workspace, say `develop`:
```sh
$ hand work on develop
work space:
     default
  *  develop
```
It will switch to another workspace, if this workspace not exist, it will create one automatically.


## Sub Command Tutorial

> The source code the turorial located in `$hand__config_path/hand/hello`

It is easy to add a new sub command into handybox. for example, you want to add a command `hand hello <person>`.
### Create sub command
在`$hand__path/hand`或`$hand__config_path/hand`目录创建`hello/cmd.sh`文件. 目录结构如下:
```
hand
└── hello
    └── cmd.sh
```
`cmd.sh`是子命令的入口, 编辑文件:
```sh
# hello/cmd.sh


case $1 in
  "-h"|"--help")
    echo -e "$hand__cmd            \t# "
    echo -e "$hand__cmd <person>   \t# Say hello to <person>"
    echo -e "$hand__cmd -h/--help  \t# Help"
    return
    ;;
esac

echo Hello ${1}!

```

这样就可以直接在hand中使用这个命令了
```
$ hand hello Daniel
Hello Daniel!
```
```
$ hand hello world
Hello world!
```
### Add completion script
为`hand hello`添加自动补全. 在`cmd.sh`同目录创建文件`comp.sh`, 内容如下:
  ```sh
  # hello/comp.sh

  if [ $# -eq 0 ]; then
      comp_provide_values "world earth"
  fi
  ```
  目录结构
  ```sh
  hand
  └── hello
      ├── cmd.sh
      └── comp.sh
  ```

  此时就有了自动补全提示
  ```sh
  $ hand hello # press [TAB]
  world earth
  ```
### Add dependencies
如果命令很复杂, 需要多个文件, 可以将其他依赖文件放在`cmd.sh`同目录, 如下:
```sh
hand
└── say
    ├── any_other_dirs_or_files
    ├── cmd.sh
    └── comp.sh
```


### Use workspace
1. Edit `hand/hello/cmd.sh`
    ```sh
    local hello_to=$1
    if [ "$hello_to" = "" ]; then
      hello_to=`hand work getprop hello.to -- pure`
      if [ $? -ne 0 ]; then
          echo "hello.to not found!"
          eval $hand__cmd -- help
          return 1
      fi
    fi
    echo "Hello, $hello_to!"
    ```
2. Test `hand hello` in different workspace
    ```
    $ hand work alice
    $ hand hello
    hello.to not found!

    $ hand work setprop hello.to Alice
    $ hand hello
    Hello, Alice!

    $ hand work bob
    $ hand work setprop hello.to Bob
    $ hand hello
    Hello, Bob!

    $ hand work alice
    $ hand hello
    Hello, Alice!
    ```

## Global variables and functions

handybox export some variables and functions in shell enviroment.

### Functions
|Function|Description|
|-|-|
| hand              | hand主函数, 将子命令懒加载到环境中执行
| hand__pure_do     | 执行命令但是只输出最后一行
| hand__shell_name  | 获取当前shell名称
| hand__get_firstline | 获取首行
| hand__get_first     | 获取首个单词
| hand__get_lastline  | 获取最后一行
| hand__get_last      | 获取最后一个单词
| hand__check_function_exist | 检查函数是否存在于环境
| hand__echo_debug  | 调试时打印
| hand__get_config_name | **内部使用** 获取当前用户的配置名
| hand__get_file_timestamp | **内部使用** 获取sh文件的加载时间戳
| hand__load_file | **内部使用** 加载sh文件
| comp_provide_files | 命令补全帮助函数: 用文件补全 |
| comp_provide_values | 命令补全帮助函数: 用字符串值补全 |
| comp_provide_cmddirs| 命令补全帮助函数: 用子命令下的目录补全|

### Variables
|Variable|Description|
|-|-|
| hand__version     | 版本
| hand__path        | handybox主目录
| hand__config_path | 用户配置目录
| hand__cmd         | 正在运行的子命令(不含参数)
| hand__cmd_dir     | 正在运行的子命令所在的文件夹
| hand__debug_disabled | 是否打印debug信息
| hand__cache_load      | 懒加载子命令cmd.sh文件

> 当启用懒加载(`hand__cache_load`)时, 系统会为每个子命令创建一个函数, 函数名为`hand_<subcmd...>`

