
# Handy Box Tool Scripts
Handybox is a tool with many shell scripts intergrated for linux/unix environment


## Features
1. provide only one main command `hand` for many shell scripts
2. Flexable sub command, lazy load
3. Easy to customize your shell enviroment

## Install
1. get handybox
    ```
    git clone git@github.com:Joyep/handybox.git
    git submodule init
    git submodule update
    cd handybox
    ```
2. export `HAND_PATH` in your bash config file (such as ~/.bashrc)
    ``` 
    export HAND_PATH=/path/to/handybox_pub
    source $HAND_PATH/hand.sh
    ```
   > tips:you can run `bash install.sh` to get that two line above.
3. open new terminal or source your bash config file
    ```
    source ~/.bashrc
    ```
4. enjoy!
   ```
   hand
   ```

## Usage
* `hand` --- then main command
* `hand update` --- update hand and sub command scripts
* `hand update completions` --- update bash completions for handybox
* `hand cd config`  --- cd to your config path
* `hand work` --- setup workspace
* `hand <sub command> [<params...>]`  --- call sub command


## Config
The first time you source handybox, it would automatically generate config directory depend on user name and host name.
`$HAND_PATH/config/<user name>_<host name>/`
It is a copy of `$HAND_PATH/config/example`
```
config/
`-- example
    |-- alias.sh  --- your shell alias definition
    |-- custom.sh  --- your custom scripts
    |-- short.sh   --- short name for command
    `-- workspace.sh  --- workspace definition
```

## How to add new sub command
It is easy to add a new sub command, for example you want add a command `hand hello`
1. create file `$HAND_PATH/hand/hello.sh`, and write shell script as below
```
function hand_hello()
{
    echo "Hello, world!"
}
```
2. update handybox with `hand update`
3. enjoy!
```
$ hand hello
Hello, world!
```
> Tips: you can olso add your own custom sub command in your config path `$HAND_PATH/config/<your config dir>/hand/`


## Workspace
Sometimes, you need some environment, but in other times, we need some other enviroment. For this reason, we need workspace.
### Config your workspaces
1. cd your config path by `hand cd config`
2. edit `workspace.sh`, add 2 workspace (test1 and test2) for example.
    ```
    # workspace list
    hand_work__list=("test1" "test2")

    # workspace functions
    function hand_work__workspace_test1()
    {
    	echo "load default"
    	hand_hello__to="Daniel"
    }
    function hand_work__workspace_test2()
    {
    	hand echo info "load test"
    	hand_hello__to="Bob"
    }
    ```
3. show workspace list
    ```
    $ hand update
    $ hand work
    test1
    test2
    ```
4. change workspace
    ```
    $ hand work test1
    $ echo $hand_hello__to
    Daniel
    ```

    ```
    hand work test2
    $ echo $hand_hello__to
    Bob
    ```

### use workspace in sub command
1. Edit $HAND_PATH/hand/hello.sh
    ```
    function hand_hello()
    {
        echo "Hello, $hand_hello__to"
    }
    function hand_hello__workspace_default()
    {
        hand_hello__to="Alice" #say hello to Alice by default
    }
    hand work --load hand_hello
    ```
2. Update handybox by `hand update`
3. Test `hand hello` in different workspace
    ```
    $ hand work test1
    $ hand hello
    Hello, Daniel

    $ hand work test2
    $ hand hello
    Hello, Bob
    ```



## Alias hand as h
alias hand as h makes you more easy to use handybox, the main command just an `h`
    ```
    1, hand cd config
    2, Edit alias.sh, set alias h='hand'
    3, hand update and Enjoy!
    ```

## Add libs for dependency
Please palce all depended libs into $HAND_PATH/libs



