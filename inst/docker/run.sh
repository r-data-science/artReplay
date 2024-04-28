sudo docker build -t bfatemi/replayapp:latest -f inst/docker/Dockerfile .
docker tag bfatemi/replayapp:latest bfatemi/replayapp:latest
docker push bfatemi/replayapp:latest
sudo docker run --name replayapp -p 3939:3939 --rm -dt bfatemi/replayapp:latest

# sudo docker pull \
#   bfatemi/apptemplate1:latest
#

