docker-killingfloor2-server
===========================

- [GitHub](https://github.com/nvllsvm/docker-killingfloor2-server)
- [Docker Hub](https://hub.docker.com/r/nvllsvm/killingfloor2-server)

Ports
-----

| #     | Type | Description |
|-------|------|-------------|
| 7777  | UDP  | Game        |
| 27015 | UDP  | Query       |
| 8080  | TCP  | Web Admin   |

Environment Variables
---------------------

| Name               | Default            |
|--------------------|--------------------|
| `KF_ADMIN_PASS`    | random             |
| `KF_DIFFICULTY`    | `0`                |
| `KF_ENABLE_WEB`    | `false`            |
| `KF_GAME_LENGTH`   | `0`                |
| `KF_GAME_MODE`     | `Survival`         |
| `KF_MAP`           | random             |
| `KF_PORT`          | `7777`             |
| `KF_QUERY_PORT`    | `257015`           |
| `KF_SERVER_NAME`   | `Killing Floor 2`  |
| `KF_WEBADMIN_PORT` | `8080`             |

Volumes
-------

| Name    | Description                 |
|---------|-----------------------------|
| `/data` | Server software and content |


Example
-------

```
docker run \
    -p 7777:7777/udp \
    -p 27015:27015/udp \
    -v $HOME/kf2:/data \
    nvllsvm/killingfloor2-server
```
