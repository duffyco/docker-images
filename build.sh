#!/bin/bash

#plan is to have a clean node
# 1) delete everything
# 2) build each container with YY:MM
# 3) Pull all images in use label as *:current
# 4) Build as latest (as I'm using base images and they need an identifiable starting point *:latest
# 4) Tag everything with registry.duffyco.ca:5000/....
# 5) Push
#TAG=`date +%Y%m%d`
TAG=20200331

cat active.txt | xargs -I % docker build -t registry.duffyco.ca:5000/%:$TAG ./%
cat active.txt | xargs -I % docker push registry.duffyco.ca:5000/%:$TAG 
