docker stop `docker ps -q -a` && docker rm `docker ps -q -a` 
docker run -d -p 80:8888 -v /mnt/www-share/www/www.duffyco.ca/html:/data --name alpine-php alpine-php
