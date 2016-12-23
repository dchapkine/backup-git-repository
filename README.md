
# Backup GIT Repos

Recursively backup all your git repos using a single command


## USAGE

```

USAGE: ./backup-git.sh -i SRC_DIR -o DST_DIR -m MODE
  -i: directory path, where to look for git repositoies to backup
  -o: directory path, where to store backups
  -m: output mode: recursive 'tree', or 'flat' named backups all in one folder

```

## EXAMPLE 1: backup

```
./backup-git.sh -i ~/git -o ~/tmp -m flat
```

Will recursively backup all git repos in ~/git into ~/tmp, using flat structure


## EXAMPLE 2: dry run

```
./backup-git.sh -i ~/git -o ~/tmp -m tree --dry yes
```


## EXAMPLE 3: dry run trick

```
./backup-git.sh -i ~/git -o ~/tmp -m tree --dry yes > real_backup.sh
```

what's cool about dry run, is that you can actualy save the output as script, to run it later


