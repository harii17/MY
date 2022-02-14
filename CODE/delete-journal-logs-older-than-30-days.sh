#!/bin/bash

sudo find /var/log/journal/45ed4424191785307f7023855f9a99b8 -mtime +55 -exec mv "{}" /home/hari/journal-log-test/ \; && sudo tar -czvf test-files-$(date +%F).tar.gz /home/hari/journal-log-test && sudo rm  journal-log-test/*
