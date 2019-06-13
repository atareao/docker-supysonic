# Supysonic docker container

Just a simple Docker container that gets rebuild on every python update.

Currently only supports local sqlite as storage.

### Attention

* Be sure to add `/var/lib/supysonic` as a volume to store passwords and your music databse
* Add your music in `/media` as a volume
* You can specify a own password by using a docker secred named `supysonic`
* If you do not specify a secret you will see one in the logs
* The webserver runs on port `8080`
* If you want to disable the watcher use the `RUN_WATCHER` environment variable

### Example for docker-compose

Here is a simple example for docker-compose and Traefik.

```yaml
  supysonic:
    image: foosinn/supysonic
    volumes:
      - "/tank/Musik:/media:ro"  # add your music folder hiere
      - "/opt/supysonic:/var/lib/supysonic"  # config folder
    labels:
      - "traefik.frontend.rule=Host: musik.example.com"
      - "traefik.port=8080"
```


```
docker run --name supysonic -v $HOME/docker/supysonic:/var/lib/supysonic -v /media:/media -p 8080:8080 ugeek/supysonic
```
