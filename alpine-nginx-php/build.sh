#!/bin/bash

DOCKER='/usr/bin/docker'

${DOCKER} build -t pietervandereems/armhf-alpine-nextcloud .
echo To Push: ${DOCKER} push pietervandereems/armhf-alpine-nextcloud
