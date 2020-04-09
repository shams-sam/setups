name=zeus_devel

docker run --rm \
       -d \
       --name $name \
       --hostname $name \
       --gpus all \
       --ipc=host \
       -p 8888:8888 \
       -p 6006:6006 \
       -v /home/m1cro1ce/WorkSpace:/WorkSpace \
       dev-py36:latest \
       jupyter notebook \
       --ip=0.0.0.0 \
       --allow-root \
       --no-browser

