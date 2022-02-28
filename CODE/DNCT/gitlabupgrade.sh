#!/bin/bash

currentimage=`docker images | grep gitlab | awk '{ print $3; exit }'`

echo -e "\033[31;1m Stoping Gitlab container\033[0m"
docker stop gitlab

echo -e "\033[31;1m Removing gitlab container \033[0m"

docker rm gitlab

echo -e "\033[31;1m Removing old gitlab docker image with ID:- $currentimage \033[0m"
docker rmi $currentimage

echo -e "\033[31;1m Starting Gitlab container with latest image \033[0m"

docker run -itd -h gitlab.dinoct.com -p 443:443 -p 80:80 -p 23:22 --name gitlab --restart=always -v /data/gitlab/etc:/etc/gitlab -v /data/gitlab/logs:/var/log/gitlab -v /data/gitlab/var/opt/gitlab:/var/opt/gitlab  gitlab/gitlab-ce:latest


echo -e "\033[31;1m Execute the following command to tail the log for errors\033[0m"

echo "docker logs -f gitlab"
