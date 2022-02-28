#!/bin/bash

pwd=/home/hari/Chrome-os/Scripts
region=$(cat /home/hari/.aws/config | awk 'NR==3 { print $3 }')

Create-Bucket-S3()
{
    read -p "Enter region($region): " r
        if [ -z "$r" ]
        then
            reg=$region
        else
            reg=$r
        fi

        read -p "Enter Bucket name to be created: " b
        aws s3 ls | awk '{print $3}' | grep -w $b > /dev/null 2>&1

        while [ "$?" == "0" ]
        do
            echo "Bucket already exist in your account"
            read -p "Re-enter the Bucket name again: " b
            aws s3 ls | awk '{print $3}' | grep -w $b > /dev/null 2>&1
        done
        
        aws s3 mb s3://$b --region $reg > $pwd/test.txt 2>&1

        cat $pwd/test.txt | grep -i BucketAlreadyExists > /dev/null 2>&1 

        while [ "$?" == "0" ]
        do
            rm $pwd/test.txt
            echo "Bucket name has been already taken. Choose another name"
            read -p "Re-enter the Bucket name again: " b
            aws s3 mb s3://$b --region $reg > $pwd/test.txt 2>&1
            cat $pwd/test.txt | grep -i BucketAlreadyExists > /dev/null 2>&1
        done

        rm $pwd/test.txt
        echo ""
        echo "bucket($b) successfully created"
}

Delete-Bucket-S3()
{
    echo "Listing all Buckets..."
    sleep 3
    aws s3 ls | awk '{print $3}'
    read -p "Enter the Bucket name to be deleted: " del
        aws s3 ls | awk '{print $3}' | grep -w $del > /dev/null 2>&1

        while [ "$?" != "0" ]
        do
            echo "Bucket doesn't exist in your account"
            read -p "Re-enter the Bucket name again: " del
            aws s3 ls | awk '{print $3}' | grep -w $del > /dev/null 2>&1
        done

        aws s3 rb s3://$del > $pwd/del-s3-bckt.txt 2>&1

        cat $pwd/del-s3-bckt.txt | grep -i BucketNotEmpty > /dev/null 2>&1

        if [ "$?" == "0" ]
        then
            rm $pwd/del-s3-bckt.txt
            read -p "Bucket not empty. Do you want to forcefully delete?(Y/N): " delete
            case $delete in
            Y|y)
                aws s3 rb s3://$del --force $pwd/del-s3-bckt.txt 2>&1
            ;;
            N|n)
                exit
            ;;
            *)
                echo "Invalid"
            ;;
            esac
        else
            rm $pwd/del-s3-bckt.txt
            echo "Bucket($del) successfully deleted"
        fi
}

s3()
{
    echo "Select any"
    echo "1) List All Buckets"
    echo "2) List Contents in Bucket"
    echo "3) Create Bucket"
    echo "4) Delete Bucket"
    read buckets
    echo ""

    case $buckets in
    1)
        echo "Listing all buckets...."
        sleep 3
        aws s3 ls
    ;;
    2)
        echo "List of Buckets"
        aws s3 ls | awk '{print $3}'
        echo ""
        read -p "Enter bucket name:" n
        aws s3 ls | awk '{print $3}' | grep -w $n > /dev/null 2>&1

        while [ "$?" != "0" ]
        do
            echo "Bucket doesn't exist in your account"
            read -p "Re-enter the Bucket name again: " n
            aws s3 ls | awk '{print $3}' | grep -w $n > /dev/null 2>&1
        done
        echo ""
        aws s3 ls s3://$n --recursive --human-readable --summarize
    ;;
    3)
        Create-Bucket-S3
    ;;
    4)
        Delete-Bucket-S3
    ;;
    *)
        echo "Invalid"
    ;;
    esac
}


echo "Welcome to AWS"
echo ""
echo "Select any service"
echo "1) ec2"
echo "2) S3"
echo "3) RDS"
echo ""

read service
echo ""

case $service in
ec2|1)
    echo "you are selected EC2"
;;
S3|s3|2)
    s3
;;
RDS|rds|3)
    echo "you are selected RDS"
;;
*)
    echo "Invalid"
;;
esac



