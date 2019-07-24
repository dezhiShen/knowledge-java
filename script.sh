export BUILD_ID=dontKillMe
nohup gitbook serve > logfile.txt & echo $! > pidfile.txt