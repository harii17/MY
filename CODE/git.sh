#! /bin/bash

cd /mnt/e/HUGO/dinoctdocs

echo "1.Push"
echo "2.Pull"
echo "3.Host"

read n

case $n in
	2)  	git pull
		;;

	3)	hugo server >> /dev/null
		;;
	
	*)	echo "Invalid"
		;;
esac
