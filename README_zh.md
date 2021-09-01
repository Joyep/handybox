
# HandyBox, 一套Shell工具集

Handybox集成了很多实用小工具, 具有很强的扩展性, 适用于linux/macOS shell环境.

## 功能
1. 提供唯一的主命令 `hand`.
2. 容易定制自己的子命令.
3. 自动生成补全脚本
4. 多工作区
5. 多用户配置

## 版本
* 3.3
  * 优化hand选项, 在命令的最后用 `--` 隔开, 后接选项(help/pure/...).
  - 命令补全脚本规范: `comp.sh` V2.3
  - 属性补全脚本规范: `comp_props.sh` V1.0
  - 子命令书写规范: `cmd.sh` V2.0
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

## 安装
1. 获取`handybox`
    ```sh
    git clone git@github.com:Joyep/handybox.git
    cd handybox
    ```
2. 安装
    ```sh
    sh install.sh
    ```
    脚本将会自动安装 `hand` 命令到你的`$HOME/bin`目录, 然后显示如下几行字, 你需要手动拷贝到shell配置文件中(例如 `~/.bashrc` 或 `~/.zshrc`):

    ```sh
    # handybox
    export hand__path=/path/to/handybox
    source $hand__path/hand.sh
    ```
3. 打开新终端, 可以了!
   ```sh
   hand
   ```

## 使用方法

基本的命令行规则如下:

`hand [sub_command [<params...>]] [-- <option>]`

- `hand`: 主命令
- `option`: hand的选项, 如下:
   - `-- source`: 显示子命令源码
   - `-- help`: 显示子命令帮助
   - `-- pure`: 执行时不打印多余的信息
   - `-- cd`: cd to sub command dir
   - `-- test`: test run the sub command
- `sub_command`: 子命令
- `params...`: 子命令的参数

### 核心子命令
* `hand update` --- 重新加载handybox
* `hand cd` --- 跳转到handybox主目录
* `hand cd config`  --- 跳转到你的配置目录
* `hand work` --- 工作区
* `hand work getprop` --- 获取属性, 优先从当前工作区获取
* `hand work setprop [-g]` --- 设置属性. `-g`表示设置到全局工作区
* `hand sh` --- 在导入handybox的进程中执行shell脚本

## 配置
首次加载handybox时, 会自动以用户名和电脑名创建配置目录, 位于`$hand__path/config/<user_name>_<host_name>`.
它是`$hand__path/example`的一个拷贝, 目录结构如下:
```sh
$hand__config_path/
├── alias.sh        --- 别名
├── custom.sh       --- 客制化脚本
└── hand            --- 客制化hand子命令
    └── example
      └── cmd.sh
```
> 提示: `$hand__config_path` 是配置目录.

### custom.sh
config handybox in custom.sh
```sh
# Disable debug info (default: 1)
#     0: debug enabled
#    >0: debug disabled
hand__debug_disabled=1

# Lazy load sub command (default: 1)
#    1: will lazy load sub command as a function
#    0: will direactly source load sub command
hand__lazy_load=1
```

## 设置快捷的别名
为`hand`设置别名`h`, 使你更容易使用`hand`, 主命令仅仅是一个`h`. 步骤如下:

1. `hand cd config`, 跳转到你的配置目录
2. 编辑 `alias.sh`, 增加行 `alias h='hand'`
3. `hand update` 重新加载handybox
4. 现在可以用 `h` 代替 `hand` 了.


你可以按照自己的需要设置更多的别名, 例如:
```sh
# alias.sh
alias h='hand'
```


## 工作区
有时候你需要一些环境变量, 有时候你又需要另一些. 基于此, 我们需要工作区.

在handybox里, 工作区是包含一组属性的文件, 位于配置目录, 命名为 `<workspace_name>.props`.

使用 `hand work` 命令可以展示所有的工作区. 默认工作区叫做`default`.
```sh
$ hand work
work space:
  *  default
```
现在, 你可以在当前工作区设置属性.
```sh
$ hand work setprop hello.to Daniel
$ hand work getprop hello.to
Daniel
```
这时, 你可能需要切换到其他工作区, 比如 `develop`:
```sh
$ hand work on develop
work space:
     default
  *  develop
```
这样会切换到另一个工作区, 如果这个工作区不存在则会自动创建一个.
以下是接下来的演示, 你会发现, 属性的值会根据工作区而变化.
```sh
$ hand work setprop hello.to China
$ hand work getprop hello.to
China
hand work on default
$ hand work getprop hello.to
Daniel
```

## 创建子命令教程

> 此教程源码位于 `example/hand/hello`

在handybox里, 你可以很容易的创建子命令, 比如你想要一个这样的子命令 `hand hello <person>`.

### Create sub command
在`$hand__path/hand`或`$hand__config_path/hand`目录创建`hello/cmd.sh`文件. 目录结构如下:
```
hand
└── hello
    └── cmd.sh
```
`cmd.sh`是子命令的入口, 编辑文件:
```sh
##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# hand hello [$params...]
##


case $1 in
  "-h"|"--help")
    echo -e "$hand__cmd            \t# "
    echo -e "$hand__cmd <person>   \t# Say hello to <person>"
    echo -e "$hand__cmd -h/--help  \t# Help"
    ;;
  *)
    echo Hello ${1}!
    ;;
esac

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
为`hand hello`添加自动补全
在`cmd.sh`同目录创建文件`comp.sh`, 内容如下
  ```sh
  ##
  # Handybox subcommand completion script
  # V2.3
  #
  # Environment Functions:
  #           comp_provide_values [$complist...]
  #           comp_provide_files
  #
  # Environment Varivables
  #            comp_editing  # Editing word
  #            comp_params   # command params
  #            comp_dir      # command dir
  # Params:    
  #            comp_params
  ##

  ##
  # hand hello
  ##

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
### Add depended libs
如果命令很复杂, 需要多个文件, 可以将其他依赖文件放在`cmd.sh`同目录, 如下:
```sh
hand
└── say
    ├── any_other_dirs_or_files
     ├── cmd.sh
     └── comp.sh
```


### 在子命令中使用工作区
1. 编辑 `hand/hello/cmd.sh`
    ```sh
    function hand_hello()
    {
        local hello_to
        hello_to=`hand work getprop hello.to -- pure`
        if [ $? -ne 0 ]; then
            echo "hello.to not found!"
            return 1
        fi
        echo "Hello, $hello_to"
    }
    ```
2. 在不同的工作区测试 `hand hello`
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

## 参考: 导出的环境变量

handybox在当前shell环境中导出了一些变量和函数.

### 全局函数
|Function|Description|
|-|-|
|hand              | hand主函数, 将子命令懒加载到环境中执行
|hand__hub         | hand函数变体, 尽量将子命令放在独立进程执行(不缓存在环境)
| hand__pure_do     | 执行命令但是只输出最后一行
| hand__help        | hand帮助函数
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

### 全局变量
|Variable|Description|
|-|-|
| hand__version     | 版本
| hand__path        | handybox主目录
| hand__config_path | 用户配置目录
| hand__cmd         | 正在运行的子命令(不含参数)
| hand__cmd_dir     | 正在运行的子命令所在的文件夹
| hand__debug_disabled       | 是否打印debug信息
| hand__lazy_load      | 懒加载子命令cmd.sh文件

> 当启用懒加载(`hand__lazy_load`)时, 系统会为每个子命令创建一个函数, 函数名为`hand_<subcmd...>`

