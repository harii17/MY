#! /bin/bash

echo -e "Enter date: \c"
read a


if [[ -z "$a" ]]
then
	echo ""
	echo "Next day is"
	date +"%y-%m-%d" -d "+1 day"
else
	echo ""
	echo "Next Day is"
	date -d "$a +1 day" +"%y-%m-%d"
fi
