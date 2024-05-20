#!/bin/bash

image_name="scrap_pg"

function yes_or_no() {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

function print_help {
    echo "ZBD SPACE SCRAP RUN SCRIPT"
    echo "===================================================="
    echo "Usage:   run.sh [OPTIONS]"
    echo "===================================================="
    echo "This script is used to create the docker image"
    echo "and then run the container while initializing the"
    echo "database with scripts provided in the changelog"
    echo "folder. The initdb.sh script within iterates through"
    echo "all sql files in all folders during the startup"
    echo "of the db."
    echo ""
    echo "Additional options are listed below:"
    echo "----------------------------------------------------"
    echo "   -c|--clean  additionally removes all containers  "
    echo "               deletes the associated volumes and   "
    echo "               obliterates the existing local image."
}

function clear_docker {
    docker ps -a | awk '{ print $1,$2 }' | grep ${image_name} | awk '{print $1 }' | xargs -I {} docker stop {}
    log "All containers stopped. Proceeding to remove them"
    docker ps -a | awk '{ print $1,$2 }' | grep ${image_name} | awk '{print $1 }' | xargs -I {} docker rm {}
    log "All containers removed. Proceeding to remove the volumes"
    docker volume ls -q | grep ${image_name} | xargs -r docker volume rm
    log "All volumes removed. Proceeding to remove the image"
    docker rmi ${image_name}
    log "scrap_pg image removed"
    log "Clearing done"
}

function log() {
    local text="$1"
    echo "[RUN.SH] ${text}."
}

while test $# -gt 0; do
    case "$1" in
        --help|-h)
            print_help
            exit 0;
            ;;
        --clear|-c)
            yes_or_no "$(log 'You are about to delete all scrap_db containers and images. Are you sure you want to do that?')" && clear_docker
            shift
            ;;
    esac
done

if docker images --format '{{.Repository}}' | grep -q "^${image_name}$"; then
    log "Image present. No need to generate"
else
    log "Image not present. Generating ${image_name} from dockerfile"
    docker build -t "${image_name}" .
fi

container_name="${image_name}_$(date "+%s")"
volume_name="${container_name}_vol"
local_changelog="$(pwd -W)"/changelog

log "Creating volume ${volume_name} for postgresql data"
docker volume create "${volume_name}"
log "Created"

log "Starting ${container_name}"
docker run -p 5342:5432 -v "${local_changelog}":/docker-entrypoint-initdb.d --name "${container_name}" -v "${volume_name}":/var/lib/postgresql/data -d "${image_name}"
log "Done"