#!/bin/bash

s3()
{
    echo "Select any"
    echo "1) List All Buckets"
    echo "2) List Contents in bucket"
    read buckets
    echo ""

    case $buckets in
    1)
        aws s3 ls
    ;;
    2)
        read -p "Enter bucket name:" n
        aws s3 ls s3://$n --recursive --human-readable --summarize
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



