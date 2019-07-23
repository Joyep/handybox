# eosio

function hand_eos()
{
	local sub=$1
	shift
	case $sub in
	"node")
		hand_eos__node $*
		;;
	"keosd")
		hand_eos__keosd $*
		;;
	"killnode")
		local pid=`hand_eos__pid_of_nodeos`
		echo "nodeos pid="$pid
		hand_eos__kill $pid
		;;
	"killkeosd")
		local pid=`hand_eos__pid_of_keosd`
		echo "keosd pid="$pid
		hand_eos__kill $pid
		;;
	"status")
		hand_eos__status $*
		;;
	"unlock")
		hand_eos__unlock $*
		;;
	"init_accounts")
		cleos create account eosio alice $1
		cleos create account eosio bob $1
		cleos create account eosio eosio.token $1
		;;
	*)
		hand echo error "$sub unsupported"
		;;
	esac
}

function hand_eos__unlock() {
	local pass=
	if [ "$1" ]; then
		pass=$1
	elif [ "$hand_eos__password" ]; then
		pass=$hand_eos__password
	else
		cleos wallet unlock
		return
	fi
	cleos wallet unlock --password $pass
}

function hand_eos__pid_of_keosd() {
	# ps -aux | grep keosd | grep eosio | awk '{print $2}'
	ps -ax | grep keosd | sed  '/grep/d' | awk '{print $1}'
}

function hand_eos__pid_of_nodeos() {
	ps -ax | grep nodeos | sed  '/grep/d' | awk '{print $1}'
}

function hand_eos__status() {
	local pid_keosd=`hand_eos__pid_of_keosd`
	local pid_nodeos=`hand_eos__pid_of_nodeos`
	if [ "$pid_keosd" ]; then
		hand echo green "keosd\t\ton\t\t$pid_keosd"
	else
		hand echo red "keosd\t\toff"
	fi
	if [ "$pid_nodeos" ]; then
		hand echo green "nodeos\t\ton\t\t$pid_nodeos"
	else
		hand echo red "nodeos\t\toff"
	fi
}


function hand_eos__kill()
{
	local pid=$1
	if [ "$pid" ]; then
		hand echo yellow "killing $pid ..."
		kill -9 $pid
		echo "killed!"
	else
		echo "not running!"
	fi
}


function hand_eos__keosd() {
	keosd &
}

function hand_eos__node()
{
	if [ "$1" != "" ]; then
		hand_eos__path=$1
	fi
	if [ "$hand_eos__path" == "" ]; then
		hand_eos__path=`pwd`
		# hand echo error "$hand_eos__path not found!"
	fi
	echo "start nodeos ... dir=${hand_eos__path}"
	nodeos -e -p eosio \
		--plugin eosio::producer_plugin \
		--plugin eosio::chain_api_plugin \
		--plugin eosio::http_plugin \
		--plugin eosio::history_plugin \
		--plugin eosio::history_api_plugin \
		--data-dir ${hand_eos__path}/data \
		--config-dir ${hand_eos__path}/config \
		--access-control-allow-origin='*' \
		--contracts-console \
		--http-validate-host=false \
		--verbose-http-errors \
		--filter-on='*' >> ${hand_eos__path}/nodeos.log 2>&1 &
		
	tail -f ${hand_eos__path}/nodeos.log
}

function hand_eos__workspace_default()
{
	:
	# hand_eos__path
	# hand_eos__password
}

# hand work --load hand_eos

# hand_eos "$@"
