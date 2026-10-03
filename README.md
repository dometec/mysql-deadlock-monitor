# mysql-deadlock-monitor

Container Docker che monitora i deadlock di un database MySQL usando
[`pt-deadlock-logger`](https://docs.percona.com/percona-toolkit/pt-deadlock-logger.html)
di Percona Toolkit. Ogni `MYSQL_INNODB_STATUS_INTERVAL` secondi interroga
`SHOW ENGINE INNODB STATUS` e scrive i deadlock rilevati (formato tab-separated)
sullo standard output e nel file `/usr/src/app/logs/deadlock-logger.log`.

## Contenuto

| File | Descrizione |
|------|-------------|
| `Dockerfile` | Immagine basata su `perl:stable-bookworm` con Percona Toolkit, client MySQL 8.4 LTS (repository Percona `pdps-84-lts`) ed `expect`. |
| `command_exp_wrapper.sh` | Script di avvio: legge la configurazione dalle variabili d'ambiente e lancia `pt-deadlock-logger` tramite `expect`. |

## Build

```bash
docker build -t mysql-deadlock-monitor .
```

## Utilizzo

```bash
docker run -d --name deadlock-monitor \
  -e MYSQL_HOST=db.example.com \
  -e MYSQL_USER=monitor \
  -e MYSQL_PASSWORD=secret \
  -e MYSQL_DB=mysql \
  -v "$(pwd)/logs:/usr/src/app/logs" \
  mysql-deadlock-monitor
```

Per leggere l'output: `docker logs -f deadlock-monitor`.

## Configurazione

Tutte le variabili sono opzionali e hanno un valore di default.

| Variabile | Default | Descrizione |
|-----------|---------|-------------|
| `MYSQL_HOST` | `127.0.0.1` | Host del server MySQL. |
| `MYSQL_USER` | `quarkus` | Utente MySQL. |
| `MYSQL_PASSWORD` | `quarkus` | Password dell'utente. |
| `MYSQL_DB` | `mysql` | Database a cui connettersi. |
| `MYSQL_INNODB_STATUS_INTERVAL` | `1` | Intervallo (secondi) tra due letture di `SHOW ENGINE INNODB STATUS`. |
| `START_WAIT` | `1` | Attesa (secondi) prima di avviare il comando, utile ad esempio per attendere l'avvio del database. |

L'utente MySQL deve avere il privilegio `PROCESS`, necessario per eseguire
`SHOW ENGINE INNODB STATUS`.

## Note

- Se si vuole conservare il log, montare un volume su `/usr/src/app/logs`.
- Le credenziali di default sono pensate solo per sviluppo: in produzione
  usare un utente dedicato con i soli privilegi necessari.
