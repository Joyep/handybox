# user workspace
# used by "hand work"



# workspace list
hand_work__list=("default" "test")

# workspace functions
function hand_work__workspace_default()
{
	hand echo info "load default"
	hand_adb_connect__prefix="192.168.199"
}
function hand_work__workspace_test()
{
	hand echo info "load test"
	hand_adb_connect__prefix="192.168.201"
}

