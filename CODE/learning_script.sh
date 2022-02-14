#! /bin/bash

# echo $BASH

#echo "Enter Name: "
#read n
#echo "Name is $n"

#read -p "username: " n
#read -sp "password: " m  # -s will hide te input that we type
#echo ""
#echo "Username is $n"

#echo "Enter names: "
#read -a name
#echo "Names : ${name[1]} ${name[0]}"

#echo "Enter names : "
#read n
#read m
#echo "Namaes are $n $m"

#read -p "names: " n  # we can type the input along with the line
#read m
#echo "names are $m $n"

# run scriptfile and add arguments along with it
#args=("$@") 
#echo ${args[0]} ${args[1]} ${args[2]} ${args[3]}  #it will print 3 arguments
#echo $@  # it will print all arguments
#echo $#  # it will print the count of all arguments

#read -p "Enter a number: " n
#if [ $n -eq 10 ]
#then
#    echo "condition is true"
#elif [ $n -eq 11 ]
#then
#    echo "True"
#else
#    echo "condition is false"
#fi 

#echo -e "Enter Name: \c"   # cursor is on the same line
#read p
#echo $p


# To find specific files and excluded /mnt from searching
echo -e "Enter File Name: \c"
read q
echo -e "Enter Location: \c"
read x
find $x -path /mnt -prune -o -iname $q
#d=$(find $x -path /mnt -prune -o -iname $q | grep $q) > /dev/null

if [ $? -eq 0 ]
then
    echo "$q found"
    echo " "
    echo "Location is $d"
else
    echo "$q not found"
fi

 
