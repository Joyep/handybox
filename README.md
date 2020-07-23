
# HandyBox, A Tool Scripts for Shell

Handybox is a tool with many shell scripts integrated for linux/macOS shell environment.

[TOC]

## Features
1. provide only one main command `hand` for many shell scripts.
2. Flexible sub command.
3. Easy to customize your own shell environment and commands.
4. Automaticly generate command completions


## Version
* 3.1
  * 更新目录结构, 命令全部使用目录, 目标命令文件统一命名为`cmd.sh`
* 3.0
  * 全新目录结构, 允许复杂命令将依赖库放在一起.
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
    source $hand__path/hand-completions.sh
    ```
3. open new terminal and enjoy!
   ```sh
   hand
   ```

## Usage

Basic command line rules like this:

`hand [<options...>] [sub_command [<params...>]]`

- `hand`: The main command
- `options...`: options for hand, as below:
   - `--show`: show source code of this command
   - `--help`: show help of this command
   - `--pure`: not display any log

- `sub_command`: any custom sub command
- `params...`: params for sub command

### Intergrated sub commands
* `hand update` --- reload hand script
* `hand update completions` --- update completions
* `hand cd` --- cd to handybox root dir
* `hand cd config`  --- cd to your config dir
* `hand work` --- switch workspace, get/set props in workspace
* `hand work getprop` --- get props from workspace
* `hand work setprop` --- set props to workspace

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
> Tips: `$hand__config_path` is the path of your config dir.


## Alias hand as h
Alias hand as h makes you more easier to use handybox, the main command just an `h`.

1. `hand cd config`, jump to your handybox config dir
2. Edit `alias.sh`, add line `alias h='hand'`
3. `hand update`
4. Using `h` instead of `hand`


Example alias:
```sh
alias h='hand'
alias hh='h --help'
alias hs='h --show'
```


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


## Create a sub command

It is easy to add a new sub command, for example if you want to add a command `hand hello`.
1. 在`hand`目录创建`hello/cmd.sh`文件.
    目录结构如下:
    ```
    hand
    └── hello
        └── cmd.sh
    ```
    `cmd.sh`是命令的入口, 文件内容:
    ```sh
    # cmd.sh
    hand_hello()
    {
        echo "Hello ${1}!"
    }
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

    > Notice:
    > 1. 命令文件名必须是`cmd.sh`

2. 为`hand hello`添加自动补全

    在`cmd.sh`同目录创建文件`comp.sh`, 内容如下
    ```sh
    # comp.sh
    hand__comp_hello="world earth"
    ```
    目录结构
    ```sh
    hand
    └── hello
        ├── cmd.sh
        └── comp.sh
    ```
    然后更新自动补全信息
    ```sh
    $ hand update completions
    update Handy Box Completions success!
    ```
    此时就有了自动补全提示
    ```sh
    $ hand hello [TAB]
    world earth
    ```

3. 如果命令很复杂, 需要多个文件, 可以放在`cmd.sh`同目录, 如下:
    ```sh
    hand
    └── say
        ├── any_other_dirs_or_files
        ├── cmd.sh
        └── comp.sh
    ```
> `cmd.sh`所在目录可以使用`$hand__cmd_dir`变量访问.


### Use workspace in sub command
1. Edit `hand/hello/cmd.sh`
    ```sh
    function hand_hello()
    {
        local hello_to
        hello_to=`hand --pure work getprop hello.to`
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

    $ hand work setprop hello.to Alice
    $ hand hello
    Hello, Alice

    $ hand work bob
    $ hand work setprop hello.to Bob
    $ hand hello
    Hello, Bob

    $ hand work alice
    $ hand hello
    Hello, Alice
    ```

## Global variables and functions

handybox export some variables and functions in shell enviroment.

### Functions
- hand              --- hand主函数, 将子命令懒加载到环境中执行
- hand__hub         --- hand函数变体, 尽量将子命令放在独立进程执行(不缓存在环境)
- hand__pure_do     --- 执行命令但是只输出最后一行
- hand__help        --- hand帮助函数
- hand__shell_name  --- 获取当前shell名称
- hand__get_firstline --- 获取首行
- hand__get_first     --- 获取首个单词
- hand__get_lastline  --- 获取最后一行
- hand__get_last      --- 获取最后一个单词
- hand__check_function_exist --- 检查函数是否存在于环境
- hand__echo_debug  --- 调试时打印
- hand__get_config_name --- [内部使用]获取当前用户的配置名
- hand__get_file_timestamp --- [内部使用]获取sh文件的加载时间戳
- hand__load_file --- [内部使用]加载sh文件

### Variables
- hand__path        --- handybox主目录
- hand__cmd_dir     --- path that current cmd in
- hand__version     --- 版本
- hand__complist_*  --- 自动补全信息
- hand__debug       --- 是否打印debug信息
- hand__config_path --- 用户配置目录
<!-- - hand__cmd_dir     --- 正在运行的子命令所在的目录 -->


> 其他子命令导出的变量, 都以hand_(cmd)__开头

