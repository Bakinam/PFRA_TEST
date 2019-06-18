# Script to get pct complete from a hecras run. To be used as part of cron job
#v07
#!/bin/bash
sim_folder=$1
sim_name=$2
dbsim_url="https://dbsim.azurewebsites.net"
home_folder="/home/ubuntu/sim"

# Get last 10 lines of runlog file 
# First check that file exists since it will be deleted when analysis is complete
if [ -f "$home_folder/$sim_folder/$sim_name.runlog" ]; then
	## Get first percent completion (PROGRESS) - it's good enough
	#tail -n 500 $sim_folder/$sim_name.runlog > $sim_folder/$sim_name.log
	#pct_complete=$(grep -m 1 PROGRESS $sim_folder/$sim_name.log | cut -f2- -d=)

	# Get last occurence of completion text (PROGRESS) - better than first
	pct_complete=$(grep PROGRESS $home_folder/$sim_folder/$sim_name.runlog | tail -1 | cut -f2 -d=)
	# Multipy by 100 and convert to integer (rounded value)
	pct=$(expr $pct_complete*100 | bc)
	pct2=$(echo "($pct+0.5)/1" | bc)
	# Update Database with % complete
	params="SimulationID=$sim_folder&ProgressPct=$pct2"
	curl -H "Authorization: Basic bW91cmFkb3U6YXRrX3BmcmElMDI=" -X PUT -d "$params" $dbsim_url/api/dbsim/pct
	#echo  $pct,$pct2
else
	params="SimulationID=$sim_folder&ProgressPct=100"
	curl -H "Authorization: Basic bW91cmFkb3U6YXRrX3BmcmElMDI=" -X PUT -d "$params" $dbsim_url/api/dbsim/pct
	#echo 100
fi




