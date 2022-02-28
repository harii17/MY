#!/bin/bash

echo "1) Instance"
echo "2) Volume"
echo "3) SecurityGroup"
echo "4) Snapshot"

read n

case $n in
1)	echo " "
	echo " "
	echo "0.Describe Instances"
	echo "1.Create Instance"
	echo "2.Stop Instance"
	echo "3.Reboot Instance"
	echo "4.StartInstance"
	echo "5.Terminate Instance"

	read m

	if [ $m == '0' ]
	then
		echo " "
		echo " "
		echo "1.Instance Name"
		echo "2.Instance State"
		read Inst
		if [ $Inst == '1' ]
		then
			echo " "
			echo -e "Enter Instance Name: \c"
			read name1
			echo " "
			echo " "
			echo "1.Describe all details of instance"
			echo "2.Describe specific details of instance(InstanceId,PublicIp,PrivateIp,AvailabilityZone,Key)"
			read name
			if [ $name == '1' ]
			then
				aws ec2 describe-instances --filter "Name=tag-value,Values=$name1"
			elif [ $name == '2' ]
			then
				aws ec2 describe-instances --filter "Name=tag-value,Values=$name1" --query "Reservations[].Instances[].{Id:InstanceId,PublicIp:PublicIpAddress,PrivateIp:PrivateIpAddress,Key:KeyName,AZ:Placement.AvailabilityZone,State:State.Name}"
			else
				echo "Invalid Input"
			fi
		elif [ $Inst == '2' ]
		then	
			echo " "
			echo " "
			echo "1.Running"
			echo "2.Stopped"
			echo "3.All"
			read state
			if [ $state == '1' ]
			then
				echo " "
				echo " "
				echo "1.Describe all details of instance"
				echo "2.Describe specific details of instance(InstanceId,PublicIp,PrivateIp,AvailabilityZone,Key)"
				read details
				if [ $details == '1' ]
				then
					aws ec2 describe-instances --filter "Name=instance-state-name,Values=running"
				elif [ $details == '2' ]
				then
					aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].{Name:Tags[?Key=='Name']|[0].Value,Id:InstanceId,PublicIp:PublicIpAddress,PrivateIp:PrivateIpAddress,AZ:Placement.AvailabilityZone,Key:KeyName}"
				else
					echo "Invalid Input"
				fi
			elif [ $state == '2' ]
			then
				echo " "
				echo " "
				echo "1.Describe all details of instance"
				echo "2.Describe specific details of instance(InstanceId,PrivateIp,AvailabilityZone,Key)"
				read details2
				if [ $details2 == '1' ]
				then
					aws ec2 describe-instances --filter "Name=instance-state-name,Values=stopped"
				elif [ $details2 == '2' ]
				then
					aws ec2 describe-instances --filter "Name=instance-state-name,Values=stopped" --query "Reservations[].Instances[].{Name:Tags[?Key=='Name']|[0].Value,Id:InstanceId,PrivateIp:PrivateIpAddress,AZ:Placement.AvailabilityZone,Key:KeyName}"
				else
					echo "Invalid Input"
				fi
			elif [ $state == '3' ]
			then
				echo " "
				echo " "
				echo "1.Describe all details of instance"
				echo "2.Describe specific details of instance(InstanceId,PrivateIp,PublicIp,KeyName,AvailabilityZone,InstanceState)"
				read details3
				if [ $details3 == '1' ]
				then
					aws ec2 describe-instances
				elif [ $details3 == '2' ]
				then
					aws ec2 describe-instances --query "Reservations[].Instances[].{Name:Tags[?Key=='Name']|[0].Value,Id:InstanceId,PublicIp:PublicIpAddress,PrivateIp:PrivateIpAddress,Key:KeyName,AZ:Placement.AvailabilityZone,State:State.Name}"
				else
					echo "Invalid Input"
				fi

			else
				echo "Invalid Input"
			fi
		else
			echo "Invalid Input"
		fi
		


	elif [ $m == '1' ]
	then
		echo -e "Type image id (ubuntu): \c"
		read o
                if [ -z "$o" ]
		then
			img_id='ami-0e9182bc6494264a4'
		else
			img_id=$o	
		fi
		echo -e "Type Subnet (Default): \c"
		read p
		if [ -z "$p" ]
		then
			sub_id='subnet-3793f07b'
		else
			sub_id=$p
		fi
		echo -e "Type security group (default): \c"
		read s
		if [ -z "$s" ]
		then
			sg_id='sg-a14dc2c2'
		else
			sg_id=$s
		fi
		echo -e "Type key name (default): \c"
		read t
		if [ -z "$t" ]
		then
			key_name='ubuntu'
		else
			key_name=$t
		fi
		echo -e "Type Tag Name: \c"
		read u
		
		aws ec2 run-instances --image-id $img_id --count 1 --instance-type t2.micro --security-group-ids $sg_id --subnet-id $sub_id --key-name $key_name --tag-specifications "ResourceType=instance, Tags=[{Key=Name,Value=$u}]"

	elif [ $m == 2 ]
	then
		echo -e "Type instance id: \c"
		read id
		aws ec2 stop-instances --instance-ids $id
		echo "instance stopped"
	elif [ $m == 3 ]
	then
		echo -e "Type Instance Id: \c"
		read id
		aws ec2 reboot-instances --instance-ids $id
		echo "instance rebooted"
	elif [ $m == 4 ]
	then
		echo -e "Type Instance Id: \c"
		read id
		aws ec2 start-instances --instance-ids $id
		echo "instance started"
	elif [ $m == 5 ]
	then
		echo -e "Type Instance Id: \c"
		read id
		aws ec2 terminate-instances --instance-ids $id
		echo "instance terminated"
	else
		echo " "
		echo " "
		echo "Invalid Input"
	fi
	;;

2)	echo " "
	echo " "
	echo "1.Create Volume"
	echo "2.Describe Volumes"
	echo "3.Attach/Detach Volume"
	echo "4.Delete Volume"

	read m

	if [ $m == 1 ]
	then
		echo " "
		echo " "
		echo -e "Create volume Using Snapshot?(y/n): \c"
		read a
		if [ $a == n ]
		then
			echo -e "Type AvailabilityZone(ap-south-1a): \c"
			read n
			if [ -z "$n" ]
			then
				az=ap-south-1a
			else
				az=$n
			fi
			echo -e "Enter Volume type(gp2): \c"
			read p
                        if [ -z "$p" ]
			then
				typee=gp2
			else
				typee=$p
			fi
			echo -e "Enter the Size: \c"
                	read o

			aws ec2 create-volume --availability-zone $az --size $o --volume-type $typee
		elif [ $a == y ]
		then
			echo ""
			echo ""
			echo -e "Type Snapshot-Id: \c"
			read b
			echo -e "Type AvailabilityZone(ap-south-1a): \c"
			read c
			if [ -z "$c" ]
                        then
                                az=ap-south-1a
                        else
                                az=$c
                        fi
			echo -e "Enter Volume type(gp2): \c"
                        read d
                        if [ -z "$d" ]
                        then
                                typee=gp2
                        else
                                typee=$d
                        fi
                        echo -e "Enter the Size: \c"
                        read e
		else
			echo "Invalid input"
		fi


	elif [ $m == 2 ]
	then
		echo ""
		echo ""
		echo "1.Describe All Volumes"
		echo "2.Describe Specific Volumes"

		read j

		if [ $j == 1 ]
		then
			aws ec2 describe-volumes
		elif [ $j == 2 ]
		then
			echo ""
			echo ""
		else
			echo "Invalid Input"
		fi
	elif [ $m == 4 ]
	then
		echo ""
		echo ""
		echo -e "Type VolumeId: \c"
		read z

		aws ec2 delete-volume --volume-id $z
	else
		echo "Invalid Input"
	fi



	;;

*) 	 	echo "Invalid"
		;;
esac
