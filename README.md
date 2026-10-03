# mysql-deadlock-monitor

Docker container that monitors deadlocks on a MySQL database using
[`pt-deadlock-logger`](https://docs.percona.com/percona-toolkit/pt-deadlock-logger.html)
from Percona Toolkit. Every `MYSQL_INNODB_STATUS_INTERVAL` seconds it queries
`SHOW ENGINE INNODB STATUS` and writes the detected deadlocks (tab-separated)
to standard output and to `/usr/src/app/logs/deadlock-logger.log`.

## Contents

| File                     | Description                                                                                                                           |
|--------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| `Dockerfile`             | Image based on `perl:stable-bookworm` with Percona Toolkit, the MySQL 8.4 LTS client (Percona `pdps-84-lts` repository) and `expect`. |
| `command_exp_wrapper.sh` | Startup script: reads the configuration from environment variables and runs `pt-deadlock-logger` through `expect`.                    |

## Build

```bash
docker build -t mysql-deadlock-monitor .
```

## Usage

```bash
docker run -d --name deadlock-monitor \
  -e MYSQL_HOST=db.example.com \
  -e MYSQL_USER=monitor \
  -e MYSQL_PASSWORD=secret \
  -e MYSQL_DB=mysql \
  -v "$(pwd)/logs:/usr/src/app/logs" \
  mysql-deadlock-monitor
```

To follow the output: `docker logs -f deadlock-monitor`.

## Configuration

All variables are optional and have a default value.

| Variable                       | Default     | Description                                                                            |
|--------------------------------|-------------|----------------------------------------------------------------------------------------|
| `MYSQL_HOST`                   | `127.0.0.1` | MySQL server host.                                                                     |
| `MYSQL_USER`                   | `quarkus`   | MySQL user.                                                                            |
| `MYSQL_PASSWORD`               | `quarkus`   | User password.                                                                         |
| `MYSQL_DB`                     | `mysql`     | Database to connect to.                                                                |
| `MYSQL_INNODB_STATUS_INTERVAL` | `1`         | Interval (seconds) between two `SHOW ENGINE INNODB STATUS` reads.                      |
| `START_WAIT`                   | `1`         | Delay (seconds) before starting the command, e.g. to wait for the database to come up. |

The MySQL user needs the `PROCESS` privilege, required to run
`SHOW ENGINE INNODB STATUS`.

## Notes

- To keep the log, mount a volume on `/usr/src/app/logs`.
- The default credentials are meant for development only: in production use a
  dedicated user with the minimum required privileges.
