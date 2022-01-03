
# Handybox
**Shell环境目录层次子命令框架**

`handybox`可以将你常用的命令(或脚本)以子命令的方式分层次放置在一个主命令`hand`之下. 适用于bash/zsh等shell环境.
> 此项目在bash和zsh下测试通过, 其他shell环境请自行验证.

## 特点
1. 提供唯一的主命令 `hand`(或简写成`h`)
2. 容易定制自己的子命令
3. 定制补全脚本
4. 多工作区
5. 多用户配置, 支持继承.

## 安装
1. 获取`handybox`
    ```sh
    git clone https://github.com/Joyep/handybox.git
    cd handybox
    ```
2. 安装
    ```sh
    sh install.sh
    ```
    脚本将会自动安装 `hand` 命令到你的`$HOME/bin`目录, 然后显示如下几行字, 你需要手动拷贝到shell配置文件中(例如 `~/.bashrc` 或 `~/.zshrc`):

    ```sh
    # handybox
    hand__path=/path/to/handybox
    source $hand__path/hand.sh
    ```
3. 打开新终端, 可以了!
   ```sh
   hand
   ```

## 使用方法

### 基本的命令行规则

`hand [sub_command [<params...>]] [-- <option>]`

- `hand`: 主命令
- `sub_command [<params...>]`: 子命令及其参数
- `option`: 特殊选项, 如下:
   - `-- source`: 显示子命令源码
   - `-- help`: 显示子命令帮助
   - `-- pure`: 执行时不打印多余的信息
   - `-- cd`: 跳转到子命令所在的目录
   - `-- test`: 测试运行子命令(实验阶段)
   - `-- edit`: 使用vim编辑子命令
   - `-- editcomp`: 使用vim编辑子命令的补全脚本
   - `-- new`: 使用模版创建子命令
   - `-- remove`: 删除子命令


### 预置子命令
* `hand update` --- 重新加载handybox
* `hand cd` --- 跳转到handybox主目录
* `hand cd config`  --- 跳转到你的配置目录
* `hand work` --- 工作区
* `hand work getprop` --- 获取属性, 优先从当前工作区获取
* `hand work setprop [-g]` --- 设置属性. `-g`表示设置到全局工作区
* `hand sh` --- 在独立进程中执行shell脚本

## 用户配置
首次加载handybox时, 会自动以用户名和电脑名用户创建配置目录, 即`$hand__path/config/<user_name>_<host_name>`.
它的内容是`$hand__path/example`的一个拷贝, 目录结构如下:
```sh
$hand__config_path/
├── alias.sh        --- 别名脚本
├── config.sh       --- 用户配置脚本
└── hand            --- 用户专属hand子命令
    └── example
      └── cmd.sh
```
> `$hand__path`: handybox主目录
> `$hand__config_path`: 用户配置目录

### 配置入口
`config.sh`文件是用户配置的入口文件. 你可以对handybox做一些配置, 例如:
```sh
# Disable debug info (default: 1)
#     0: debug enabled
#    >0: debug disabled
hand__debug_disabled=1

# Cached load sub command (default: 1)
#    1: will cached load sub command as a function
#    0: will direactly load sub command cmd.sh file
hand__cache_load=1
```
也可以在任意定义变量和函数, 以便在shell环境中使用.
### 设置快捷的别名
用户配置目录下的`alias.sh`文件用来放置所有的别名. 你可以为`hand`设置别名为`h`, 使你更容易使用`hand`, 主命令仅仅是一个`h`. 步骤如下:

1. `hand cd config`, 跳转到你的用户配置目录
2. 编辑 `alias.sh`, 增加行 `alias h='hand'`
3. `hand update` 重新加载`handybox`
4. 现在可以用 `h` 代替 `hand` 了.


你可以按照自己的需要设置更多的别名, 例如:
```sh
# alias.sh
alias h='hand'
alias getprop='hand work getprop'
alias setprop='hand work setprop'
...
```

### 基准配置
如果多个用户配置都差不多, 可以设置一个基准配置, 将用户配置中的公共的内容放在基准配置中. 以`my_base_config`举例如下:

1. 指向基准配置
   编辑用户配置目录下的`base.config.txt`文件, 写入基准配置名. 例如:
    ```txt
    my_base_config
    ```
2. 创建my_base_config目录
   ```sh
   mkdir $hand__path/config/my_base_config
   ```
3. 将公共配置放入`my_base_config`目录中
4. `hand update`重新加载

## 工作区
> 请参考帮助信息: `hand work -- help`

有时候你需要一些环境变量, 有时候你又需要另一些. 基于此, 我们需要工作区.

在handybox里, 工作区是一个包含一系列属性值的文件, 位于用户配置目录, 命名为 `<workspace_name>.props`.

使用 `hand work` 命令可以展示所有的工作区. 默认工作区叫做`default`.
```sh
$ hand work
work space:
  *  default
```
现在, 你可以在`当前工作区`设置属性.
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

### 全局工作区
`_global.props`是一个特殊的隐藏工作区, 存放全局属性, 称为`用户全局工作区`. 如果有基准配置, 则在基准配置中也可能有全局工作区, 称为`基准全局工作区`.

- 读取时优先从`当前工作区`读取
  ```sh
  hand work getprop <key>
  ```
  > 顺序读取: 
  > 1. `当前工作区`
  > 2. `全局工作区`
  > 3. `基准全局工作区`

- 写入`当前工作区`
  ```sh
  hand work setprop <key> <value>
  ```
你还可以读写属性时指定具体的工作区, 如下:
- 从`用户全局工作区`读取
  ```sh
  hand work getprop -g <key>
  ```
- 从`基准全局工作区`读取
  ```sh
  hand work getprop -g -b <key>
  ```
- 写入`用户全局工作区`
  ```sh
  hand work setprop -g <key> <value>
  ```
- 写入`基准全局工作区`
  ```sh
  hand work setprop -g -b <key> <value>
  ```

## 如何创建子命令

> 此教程源码位于 `example/hand/hello`

在handybox里, 你可以很容易的创建子命令, 比如你想要一个这样的子命令 `hand hello <person>`.

### 使用模版创建
最简单的方式是使用模版创建子命令, 然后按照你的需求修改.
```sh
# 创建 hand hello 子命令和补全脚本
hand hello -- new
# 编辑
hand hello -- edit
# 执行
hand hello
```
> 提示: 删除子命令使用`hand hello -- remove`
### 手动创建
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
### 添加补全脚本
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
### 添加依赖
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
2. 在不同的工作区测试 `hand hello`
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
## 参考: 导出的环境变量

handybox在当前shell环境中导出了一些变量和函数.

### 全局函数
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

### 全局变量
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

