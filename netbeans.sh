#!/bin/bash

#docker run -ti --rm -p 8080:8080 -e DISPLAY=$DISPLAY -v `pwd`:/workspace -v /tmp/.X11-unix:/tmp/.X11-unix sdd330/grails-netbeans
docker run -ti --rm -p 8080:8080 -e DISPLAY=$DISPLAY -v `pwd`:/workspace sdd330/grails-netbeans
