# moodle
Dockerized Moodle LMS using external Postgres

## Usage

```
docker run -d --name pgdata -v /var/lib/postgresql/data busybox sh
docker run -d --name moodledata -v /var/www/moodledata busybox sh
docker run -d --name postgresql -p 5432:5432 --volumes-from pgdata -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres postgres:9.1
docker run -d -P --name moodle -p 8080:80 -l pgdata:DB --volumes-from moodledata -e MOODLE_URL=http://192.168.99.100:8080 -e DBHOST=192.168.99.100 moodle:v0.1
```
