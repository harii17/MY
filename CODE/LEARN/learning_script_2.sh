#!/bin/bash

for file in /*/*
do
	if [ "${file}" == "/etc/resolv.conf" ]
	then
		countNameservers=$(grep -c nameserver /etc/resolv.conf)
		echo "Total  ${countNameservers} nameservers defined in ${file}"
		break
	fi
done

for file in /home/hari/*
do
	echo $file
done
#FILES="$@"
#for f in $FILES
#do
# if .bak backup file exists, read next file
#	if [ -f ${f}.bak ]
#	then
#		echo "Skiping $f file..."
#		continue  # read next file and skip the cp command
#	fi
	# we are here means no backup file exists, just use cp command to copy file
#	/bin/cp $f $f.bak
#done

#a=("a" "b" "c")
#echo "${a[1]}"
#echo $a

#a=ab
#b=cd

#echo "${a[@]}" "${b[@]}"

#a=$b
#echo $a

#abc () {
#	name=aaaaa
#	echo $name
#}
#abc

echo  -e "Enter the name of the file(with file location): \c"
read a

while read p
do
	echo $p
done < $a
