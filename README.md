
# Handy Box Tool Scripts
Handybox is a tool which include many shell scripts integrated for linux/macOS environment.

## Version
* 2.1.0
    * compatible with zsh

## Features
1. provide only one main command `hand` for many shell scripts.
2. Flexible sub command, lazy load.
3. Easy to customize your shell environment.

## Installation
1. get handybox
    ```
    git clone git@github.com:Joyep/handybox.git
    git submodule init
    git submodule update
    cd handybox
    ```
2. export `hand__path` in your shell config file (such as ~/.bashrc)
    ```
    sh install.sh
    ```
    It will automaticlly install `hand` command line in your own bin path(`$HOME/bin`), and show you lines to add into bash config file. as below:

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
* `hand` --- then main command
* `hand update` --- update hand and sub command scripts
* `hand update completions` --- update completions
* `hand cd` --- cd to handybox root dir
* `hand cd config`  --- cd to your config dir
* `hand work` --- switch workspace
* `hand prop get/set` --- get/set properties in you workspace
* `hand <sub command> [<params...>]`  --- call sub command

> Tips: If you want to run cmd in standalone process, please use `$HOME/bin/hand`. Also, you can use `hand__hub` instead of `hand` to run most of commands in standalone process.

## Configuration
The first time you source handybox, it will automatically generate config directory depending on user name and host name.
```
$hand__path/config/<user_name>_<host_name>/
```
It is a copy of `$hand__path/example`
```
example/
├── alias.sh --- your alias
├── custom.sh --- your custom scripts
└── hand --- your custom commands
    └── example.sh
```
> Tips: `$hand__config_path` is your config path.

## How to add new sub command
It is easy to add a new sub command, for example if you want to add a command `hand hello`.
1. create file `$hand__path/hand/hello.sh`, and write shell script as below:
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
> Tips: you can also put your own custom sub command into your config path (`$hand__config_path/hand/`)


## Workspace
Sometimes, you need some environment, but in other times, you need some other environment. For this reason, we need workspace.

In handybox, workspace is a file include a set of properties, named `<workspace_name>.props`, placed in config path.

Using `hand work` to show all workspace. first time, it shows like this:
```
$ hand work
work space:
  *  default
```
It means that you have one workspace named `default`. Now, you can put some properties into this workspace.
```
$ hand prop set hello.to Daniel
$ hand prop get hello.to
Daniel
```
Then, maybe you want switch to another workspace, say `develop`:
```
$ hand work develop
work space:
     default
  *  develop
```
It will switch to another workspace, if this workspace not exist, it will create one automatically.

### Use workspace in sub command
1. Edit `$hand__path/hand/hello.sh`
    ```
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



## Alias hand as h
Alias hand as h makes you more easy to use handybox, the main command just an `h`.

1. `hand cd config`
2. Edit `alias.sh`, add line `alias h='hand'`
3. `hand update`
4. Using `h` instead of `hand`

> Tips: If you prefer call `hand__hub` instead of `hand`, using `alias h='hand__hub`.



