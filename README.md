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
| | | .---------- month (1 - 12) OR jan,feb,mar ...
| | | | .-------- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue ...
| | | | |
* * * * * task
```

Example to set day folder at 8 am and night folder at 8pm:

```plain
# comment
   #indented comment
0  8 * * * /path/to/dayfolder/ <interval in seconds (integer), default 1800 (30min)>
0 20 * * * /path/to/nightimage.png
```

The config file allows comments at lines starting with a `#`, leading whitespace allowed.
