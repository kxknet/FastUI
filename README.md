Использование:
Смотреть локальные снапшоты:

bash
Copy
Edit
rloc snapshots
Смотреть файлы в последнем локальном бэкапе:

bash
Copy
Edit
rloc ls latest
Смотреть облачные снапшоты:

bash
Copy
Edit
rs3 snapshots
Смотреть файлы в последнем облачном бэкапе:

bash
Copy
Edit
rs3 ls latest
Восстановить что-то локально:

bash
Copy
Edit
rloc restore latest --target /tmp/restore --include /etc/nginx
Восстановить что-то из облака:

bash
Copy
Edit
rs3 restore latest --target /tmp/restore --include /etc/nginx



Examples:
  rbackup            # backup locally and to cloud
  rforget            # remove old backups (local+cloud)
  rrestore-local     # restore all locally to /tmp/restore
  rrestore-s3        # restore all from cloud to /tmp/restore
  rloc snapshots     # show local snapshots
  rs3 snapshots      # show cloud snapshots
