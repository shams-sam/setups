tmux new -s "session-name-here" -d
tmux split-window -v
tmux split-window -h
tmux split-window -h "watch -n15 nvidia-smi"
tmux select-layout main-horizontal
tmux a
