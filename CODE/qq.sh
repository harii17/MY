region=$(cat /home/hari/.aws/config | awk 'NR==3 { print $3 }')
echo $region

read -p "enter region($region): " r
if [ -z "$r" ]
then
   reg=$region
else
   reg=$r
fi

echo $reg


read -p "Enter Bucket name to be created: " b
aws s3 ls | awk '{print $3}' | grep -w $b 

until [ "$?" == "0" ]
do
	read -p "Enter Bucket name to be created: " b
	aws s3 ls | awk '{print $3}' | grep -w $b	
done
	

