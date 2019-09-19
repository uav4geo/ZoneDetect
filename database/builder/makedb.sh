#!/bin/bash
set -eo pipefail
__dirname=$(cd $(dirname "$0"); pwd -P)
cd "${__dirname}"

check_command(){
	check_msg_prefix="Checking for $1... "
	check_msg_result="\033[92m\033[1m OK\033[0m\033[39m"

	hash $1 2>/dev/null || not_found=true 
	if [[ $not_found ]]; then
		
		# Can we attempt to install it?
		if [[ ! -z "$3" ]]; then
			echo -e "$check_msg_prefix \033[93mnot found, we'll attempt to install\033[39m"
			run "$3 || sudo $3"

			# Recurse, but don't pass the install command
			check_command "$1" "$2"	
		else
			check_msg_result="\033[91m can't find $1! Check that the program is installed and that you have added the proper path to the program to your PATH environment variable before launching WebODM. If you change your PATH environment variable, remember to close and reopen your terminal. $2\033[39m"
		fi
	fi

	echo -e "$check_msg_prefix $check_msg_result"
	if [[ $not_found ]]; then
		return 1
	fi
}

check_command "wget" "" "apt install -y wget"
check_command "unzip" "" "apt install -y unzip"
check_command "zip" "" "apt install -y zip"
check_command "g++" "" "apt install -y g++"

g++ builder.cpp -o builder -lshp -std=c++11

rm -rf out naturalearth timezone db.zip
mkdir -p out
mkdir -p out_v1
mkdir -p naturalearth; cd naturalearth
wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries_lakes.zip
unzip ne_10m_admin_0_countries_lakes.zip
cd ..
./builder C naturalearth/ne_10m_admin_0_countries_lakes ./out/country16.bin 16 "Made with Natural Earth, placed in the Public Domain." 0
./builder C naturalearth/ne_10m_admin_0_countries_lakes ./out/country21.bin 21 "Made with Natural Earth, placed in the Public Domain." 0
./builder C naturalearth/ne_10m_admin_0_countries_lakes ./out_v1/country16.bin 16 "Made with Natural Earth, placed in the Public Domain." 1
./builder C naturalearth/ne_10m_admin_0_countries_lakes ./out_v1/country21.bin 21 "Made with Natural Earth, placed in the Public Domain." 1

mkdir timezone; cd timezone
wget https://github.com/evansiroky/timezone-boundary-builder/releases/download/2019b/timezones.shapefile.zip
unzip timezones.shapefile.zip
cd ..
./builder T timezone/dist/combined-shapefile ./out/timezone16.bin 16 "Contains data from Natural Earth, placed in the Public Domain. Contains information from https://github.com/evansiroky/timezone-boundary-builder, which is made available here under the Open Database License (ODbL)." 0
./builder T timezone/dist/combined-shapefile ./out/timezone21.bin 21 "Contains data from Natural Earth, placed in the Public Domain. Contains information from https://github.com/evansiroky/timezone-boundary-builder, which is made available here under the Open Database License (ODbL)." 0
./builder T timezone/dist/combined-shapefile ./out_v1/timezone16.bin 16 "Contains data from Natural Earth, placed in the Public Domain. Contains information from https://github.com/evansiroky/timezone-boundary-builder, which is made available here under the Open Database License (ODbL)." 1
./builder T timezone/dist/combined-shapefile ./out_v1/timezone21.bin 21 "Contains data from Natural Earth, placed in the Public Domain. Contains information from https://github.com/evansiroky/timezone-boundary-builder, which is made available here under the Open Database License (ODbL)." 1
rm -rf naturalearth
zip db.zip out/* out_v1/*
