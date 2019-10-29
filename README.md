# docker-ojs

A OJS image

## Usage
### compose/local/Dockerfile example
```
FROM docker-ojs
```
### docker-compose.yml example
```
version: '3.5'
services:
  ojs:
    build:
      context: .
      dockerfile: ./compose/local/Dockerfile
    environment:
      - OJS_DB_HOST=mariadb
      - OJS_DB_USER=ojs
      - OJS_DB_PASSWORD=ojs
      - OJS_DB_NAME=ojs
      - SERVERNAME=localhost
      - APACHE_LOG_DIR=/var/log/apache2
      - LOG_NAME=ojs-app
    depends_on:
      - mariadb
    ports:
      - "80:80"
    volumes:
      - ./log:/var/log/apache2/
      - ./locale/pt_BR:/var/www/html/locale/pt_BR
      - ./uploads/files:/var/www/files
      - ./uploads/public:/var/www/html/public

  mariadb:
    image: mariadb:10.4
    environment:
      - MYSQL_ROOT_PASSWORD=ojs
      - MYSQL_USER=ojs
      - MYSQL_DATABASE=ojs
      - MYSQL_PASSWORD=ojs
      - TERM=xterm

```
