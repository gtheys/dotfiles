#!/bin/sh
# 
# Script to git commit my vimwiki


cd ~/Google\ Drive/vimwiki && /usr/local/bin/hub add .
cd ~/Google\ Drive/vimwiki && /usr/local/bin/hub commit -am "weekly crontab backup `date`"
cd ~/Google\ Drive/vimwiki && /usr/local/bin/hub push origin master

