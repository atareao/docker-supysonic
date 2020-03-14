#!/bin/sh

# create config
cat > /etc/supysonic <<EOF
[base]
database_uri = sqlite:////var/lib/supysonic/supysonic.db
EOF

# create user
adduser -D -u $UID -g $GID -h /var/lib/supysonic supysonic

# Create or update database
echo Create or update database
pip install /supysonic-$TAG
sleep 10

ans=$(supysonic-cli user list | grep "$USER")
if [ "$ans" = '' ]
then
    echo Adding user $USER
    supysonic-cli user add $USER -p $PASSWORD
    echo Changing permissions
    supysonic-cli user setroles -a $USER
    echo Changing owner of config dir
    chown -R supysonic:supysonic ~supysonic
    echo Changing owner of media dir
    chown -R supysonic:supysonic /media
fi
ans=$(supysonic-cli folder list | grep "/media")
if [ "$ans" = '' ]
then
    echo Adding and scanning Library in /media
    supysonic-cli folder add Library /media
    supysonic-cli folder scan -f Library
fi

# run watcher in background, if not disabled
if [ "$RUN_WATCHER" == "true" ]; then
    sudo -u supysonic -g supysonic sh -c "while sleep 1; do supysonic-watcher; done" &
fi

# run uwsgi
exec uwsgi --http-socket :8080 \
           --wsgi-file /supysonic-$TAG/cgi-bin/supysonic.wsgi \
           --master \
           --processes 4 --threads 2 \
           --uid $UID --gid $GID
