xhost +local:
docker run -i -t --rm --name octavegui  -v /tmp/.X11-unix:/tmp/.X11-unix \
-e DISPLAY=unix$DISPLAY -v $HOME:$HOME --user $UID:$GID \
simexp/octave:4.2.1_cross_u16 /bin/bash -c "export HOME=$HOME; USER=$USER; \
cd $HOME; source /opt/minc-itk4/minc-toolkit-config.sh; octave --force-gui"