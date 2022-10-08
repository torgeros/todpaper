# Time of Day Wallpaper

Wallpaper utility for KDE.

Uses [ksetwallpaper]https://github.com/pashazz/ksetwallpaper) to set the wallpaper to different slideshows for different parts of the day.

## How to use

### Config file

Time syntax as in crontab:

```plain
.---------------- minute (0 - 59)
| .-------------- hour (0 - 23)
| | .------------ day of month (1 - 31)
| | | .---------- month (1 - 12)
| | | | .-------- day of week (IGNORED IN CURRENT SETUP)
| | | | |
* * * * * /path/to/wallpaper.png
```

Note that text notation like `jan,feb,mar ...` for month is not allowed. Day of week does not work and is treated as `'*'`.

The config file allows comments at lines starting with a `#`, leading whitespace allowed.

Example to set day-wallpaper at 8 am and night-wallpaper at 8pm:

```plain
# comment
   #indented comment
0 8 * * * /path/to/dayimage.png
0 20 * * * /path/to/nightimage.jpg
```

### Apply config file

To apply the config file, just run `setup-cron.sh`. This automatically runs `apply-current.sh` to apply the current wallpaper.

### Uninstall

Using an empty config file with `setup-cron.sh` removes all cron jobs that were generated by this program.

Then you have to manually remove the link to `login-job.sh` from `~/.profile`.
