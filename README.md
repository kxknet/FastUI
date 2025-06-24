Использование:
Смотреть локальные снапшоты:
rloc snapshots

Смотреть файлы в последнем локальном бэкапе:
rloc ls latest

Смотреть облачные снапшоты:
rs3 snapshots

Смотреть файлы в последнем облачном бэкапе:
rs3 ls latest

Восстановить что-то локально:
rloc restore latest --target /tmp/restore --include /etc/nginx

Восстановить что-то из облака:
rs3 restore latest --target /tmp/restore --include /etc/nginx



Examples:
  rbackup            # backup locally and to cloud
  rforget            # remove old backups (local+cloud)
  rrestore-local     # restore all locally to /tmp/restore
  rrestore-s3        # restore all from cloud to /tmp/restore
  rloc snapshots     # show local snapshots
  rs3 snapshots      # show cloud snapshots
