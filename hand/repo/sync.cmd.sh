hand_repo_sync()
{
	hand echo do repo sync
	while [ $? -ne 0 ]; do
		hand echo error "repo sync error, try again after 10s!"
		sleep 10
		hand echo do repo sync
	done
	echo "repo sync success!!!"
}
