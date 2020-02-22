tmux new -s "session-name-here" -d
tmux split-window -v
tmux split-window -h
tmux split-window -h "watch -n1 nvidia-smi"
tmux split-window -v "watch -n1 free -m"
tmux a
