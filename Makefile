########################################################
# The following commands are used for running application

# Create Spa DB. Create and run a new database server.
create-db:
	docker build -f Dockerfile.db -t widgets-spa-server-db .
	docker run --net=host --name widgets-spa-mysql-app --health-cmd='mysqladmin ping --silent' -e MYSQL_ROOT_PASSWORD=mysql-secret-pw -d widgets-spa-server-db
# Run Spa DB container
start-db:
	docker start `docker ps -aqf "name=widgets-spa-mysql-app"`
# Stop Spa DB container
stop-db:
	docker stop `docker ps -aqf "name=widgets-spa-mysql-app"`
# Check if app database is up and running. DB takes sometime to start after the first creation.
status-db:
	docker inspect --format "{{json .State.Health.Status }}" widgets-spa-mysql-app

# Start app container
start-app:
	docker start `docker ps -aqf "name=widgets-spa-app"`
# Stop app container
stop-app:
	docker stop `docker ps -aqf "name=widgets-spa-app"`
# Check if app database is up and running. DB takes sometime to start after the first creation.
# Run Spa server. Create an app image, create a container based on this image and run it.
run-app:
	docker build -f Dockerfile.app -t widgets-spa-server .
	docker rm `docker ps -aqf "name=widgets-spa-app"`
	docker run -d --name widgets-spa-app --net=host widgets-spa-server
# Interative mode: docker run -it --rm --name widgets-spa-app --net=host widgets-spa-server

########################################################
# The following commands are used for testing purpose

# Run test cases. Run "test-db" command once to create DB for testing before executing this command.
# WARNING: This tests will alter the DB content. So, make sure that Spa DB has been stopped before running tests.
test-app:
	docker start `docker ps -aqf "name=widgets-spa-mysql-test"`
	docker stop `docker ps -aqf "name=widgets-spa-mysql-app"`
	docker build -f Dockerfile.test -t widgets-spa-server-test .
	docker run -it --rm --name widgets-spa-app-test --net=host widgets-spa-server-test
	docker stop `docker ps -aqf "name=widgets-spa-mysql-test"`
# Run test database.
test-db:
	docker stop `docker ps -aqf "name=widgets-spa-mysql-app"`
	docker stop `docker ps -aqf "name=widgets-spa-mysql-test"`
	docker rm `docker ps -aqf "name=widgets-spa-mysql-test"`
	docker build -f Dockerfile.db -t widgets-spa-server-db-test .
	docker run --net=host --name widgets-spa-mysql-test --health-cmd='mysqladmin ping --silent' -e MYSQL_ROOT_PASSWORD=mysql-secret-pw -d widgets-spa-server-db-test
# Check if app database is up and running. DB takes sometime to start after the first creation.
test-db-status:
	docker inspect --format "{{json .State.Health.Status }}" widgets-spa-mysql-test


########################################################
# Auxiliary commands

# Dump the running database into dump.sql file. This file is used to recreate the Spa database
dump-db:
	docker run --net=host --rm mysql sh -c 'exec mysqldump -h"127.0.0.1" -P"3306" -uroot -p"mysql-secret-pw" --databases spa' > dump.sql 2>/dev/null

# Connects to a database server that is running
connect-db:
	docker run -it --net=host --rm mysql sh -c 'exec mysql -h"127.0.0.1" -P"3306" -uroot -p"mysql-secret-pw"'

# Run a Swagger-UI instance
swagger-ui:
	docker run --rm -it -p 8082:8080 swaggerapi/swagger-ui
