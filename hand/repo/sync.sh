function hand_repo_sync() 
{
	repo sync
	while [ $? -ne 0 ]; do
		hand echo error "repo sync error, try again after 10s!"
		sleep 10
		repo sync
	done
	echo "repo sync success!!!"
}