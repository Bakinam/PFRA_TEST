# docker image name is hardcoded in var below. It is always basehr:latest and pulled from the AWS repo
# $1 simulation name:  bossier_p01_h01_e00002

# login to AWS repo
$(aws ecr get-login --no-include-email --region us-east-1)
# pull image
docker_image=393560909802.dkr.ecr.us-east-1.amazonaws.com/basehr:latest
/snap/bin/docker pull $docker_image

# delete container if it already exists. Line below will not delete container if it is running!!
#     use docker rm -force to do that. To be evaluated
container_id=$(docker ps -aq -f name=$1)
if [ -z "$container_id"]
then
	:
else
	/snap/bin/docker rm $container_id
fi


#/snap/bin/docker run --rm -d -e "HOME=/home" -v $HOME/.aws:/home/.aws --name $2 $1 /sim/run.sh $2
/snap/bin/docker run --rm -d --name $1 $docker_image /sim/run.sh $1

# below - for debugging only
#/snap/bin/docker create -ti --name $1 $docker_image




