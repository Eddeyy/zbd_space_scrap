# Space scrap simulation - Application in database

## Description

## Setup
Setting up requires git and a bash shell to run the run.sh script.
### Getting the database up and running
1. Clone the repository using
```
  git clone git@github.com:Eddeyy/zbd_space_scrap.git
```
2. Using any bash shell execute the _run.sh_ script
3. After a while database connections should be available via _localhost:5432_

### Opening the psql terminal
1. Using the command below find your container name
```
  docker ps
```
Container names are generated as _scrap_pg__ + the timestamp at which the container was started.

2. Using docker exec run bash on the container
```
  docker exec -it scrap_pg_1716210493 bash
```
3. Switch to _postgres_ user
```
  su postgres
```
4. You can now start up _psql_ directly

## Clean setup
If you have previous versions of the image locally or any containers already running but for some reason they got corrupted or you want to update something from scratch feel free to use the _run.sh_ script's _clean_ option like so:
```
  ./run.sh -c
```
or
```
  ./run.sh --clean
```
Upon confirming this will proceed to stop the containers, remove them, remove their volumes and finally remove the image before creating everyting over again.