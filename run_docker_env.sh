#!/bin/bash

description="Simple and reuseable Docker research environments."

# Author: Ryan Eloff
# Contact: ryan.peter.eloff@gmail.com
# Date: April 2019

# -----------------------------------------------------------------------------
# DEFINE FUNCS
# -----------------------------------------------------------------------------

usage()
{
    echo ""
    echo "usage: run-docker-env [options]"
    echo ""
    echo "${description}"
    echo "(Run script with sudo if Docker is not set up for non-root users)"
    echo ""
    echo "Options:"
    echo "        --bash                       Run bash in the container (after command if specified)."
    echo "    -c, --command <string>           Specify a command to run in the container."
    echo "    -d, --data-dir <dir>             Mount a data directory to the container (multiple -d flags may be used; mounted to /data/<basename>)."
    echo "        --detach                     Run container in background (detached; alternatively, use <ctl-p, ctl-q> in attached container)."
    echo "    -e, --env <VAR=VALUE>            Set environment variables in the container (multiple -e flags may be used)."
    echo "    -h, --help                       Print this information and exit."
    echo "    -i, --image <string>             Specify the Docker image (Default: reloff/ml-research:latest)."
    echo "        --jupyter <lab/notebook>     Run Jupyter Lab or Notebook in the container (after command if specified)."
    echo "        --jupyter-password <string>  Token used to access Jupyter Lab (Default: No authentication)."
    echo "        --jupyter-port <number>      Port the Jupyter server will bind on (Default: 8888)."
    echo "    -n, --name <string>              Set the container name (Default: random)."
    echo "        --no-reuse                   Do not attempt to reuse an existing container with the same name (remove any existing container)."
    echo "        --nvidia-gpu                 Run Docker with nvidia runtime for access to GPU (Default: standard runtime)."
    echo "    -p, --port <number>              Additional port to expose (multiple -p flags may be used)."
    echo "    -r, --research-dir <dir>         Mount the research directory to the container (Default: current working directory)."
    echo "        --remove                     Remove container on exit."
    echo "        --sudo                       Run docker as root and chown files after execution (Default: run with current uid:gid)."
    echo ""
}

process_options()
{
    # init empty command string
    command=""
    # run user command if specified
    if [ ! -z "${cmd_arg}" ]; then
        command="${command} ${cmd_arg}"
        # only run subsequent commands on completion of user command
        command="${command} ;"
    fi
    # run jupyter (lab or notebook) if specified
    if [ ! -z "${jupyter}" ]; then
        # jupyter lab or notebook error check
        if [ "${jupyter}" = "lab" ]; then
            command="${command} jupyter lab"
        elif [ "${jupyter}" = "notebook" ]; then
            command="${command} jupyter notebook"
        else
            echo "Jupyter option not understood: ${jupyter}"
            usage
            exit 1
        fi
        # jupyter parameters
        command="${command} --no-browser"
        command="${command} --ip=0.0.0.0"
        command="${command} --port=${jupyter_port}"
        command="${command} --NotebookApp.token=${jupyter_password}"
        command="${command} --notebook-dir='/research'"
        if [ "${run_sudo}" = true ]; then
            command="${command} --allow-root"
        fi
        # run jupyter in background if executing bash
        if [ "${run_bash}" = true ]; then
            command="${command} &"
        else
            command="${command} ;"
        fi
    fi
    # run bash after all other commands have completed or been sent to background
    if [ "${run_bash}" = true ]; then
        command="${command} bash"
        command="${command} ;"
    fi
    # change ownership of files from docker root to current user on exit (if run as sudo)
    if [ "${run_sudo}" = true ]; then
        command="${command} chown -R $(id -u):$(id -g) /research"
        command="${command} ;"
    fi
}

print_options()
{
    echo "run-docker-env"
    echo "=============="
    echo "${description}"
    echo ""
    echo "Image: ${image}"
    echo "Container name: ${name}"
    echo "Research directory: ${research_dir}"
    echo "Data directory: ${data_dir}"
    echo "Environment variables: ${env_list}"
    if [ ! -z "${cmd_arg}" ]; then
        echo "Command: ${cmd_arg}"
    fi
    if [ ! -z "${jupyter}" ]; then
        echo "Running Jupyter [${jupyter}]:"
        echo "  - Jupyter server port (exposed): ${jupyter_port}"
        echo "  - Jupyter authentication token: ${jupyter_password}"
    fi
    echo "Exposed ports: ${port_list}"
    echo "Flags:"
    echo "  - interactive bash: ${run_bash}"
    echo "  - detached mode: ${detach}"
    echo "  - reuse container: ${reuse}"
    echo "  - remove on exit: ${remove}"
    echo "  - sudo: ${run_sudo}"
    echo "  - nvidia runtime: ${use_gpu}"
    echo ""
}

docker_run()
{
    # docker run and params
    
    if [ ! -z "${name}" ] && [ ! -z "$(docker container ls -a -q -f name=${name})" ]; then
        if [ "${reuse}" = false ]; then
            docker container stop ${name}
            docker container rm ${name}
        else
            # get original image name (without tag after : delimiter)
            original_image="$(docker inspect --format='{{.Config.Image}}' ${name})"
            # original_image="$(print \"${original_image}\" | cut -d: -f1)"
            original_image="${original_image%:*}"
            commit_image="${original_image}:tmp_state_${name}"
            echo "Found container '${name}' with image '${original_image}'."
            echo "Commiting container state to '${commit_image}' for reuse."

            docker commit ${name} ${commit_image}
            docker container stop ${name}
            docker container rm ${name}

            image=${commit_image}
            echo ""
            echo "Attempting run in commited image: ${image}"
            echo ""
        fi
    fi
    docker_cmd="docker run"
    # use nvidia-gpu runtime if specified
    if [ "${use_gpu}" = true ]; then
        docker_cmd="${docker_cmd} --runtime=nvidia"
    fi
    # mount research directory to /research (current dir if not specified)
    docker_cmd="${docker_cmd} -v ${research_dir}:/research"
    # mount data directory to /data if specified
    if [ ! -z "${data_dir}" ]; then
        #docker_cmd="${docker_cmd} -v ${data_dir}:/data/"
        docker_cmd="${docker_cmd} ${data_dir}"
    fi
    # set environment variables
    if [ ! -z "${env_list}" ]; then
        docker_cmd="${docker_cmd} ${env_list}"
    fi
    # run with current user uid:gid if --sudo not specified
    if [ "${run_sudo}" = false ]; then
        docker_cmd="${docker_cmd} -u $(id -u):$(id -g)"
    fi
    # work in /research and use interactive terminal
    docker_cmd="${docker_cmd} -w /research -it"
    # remove container on exit if specified
    if [ "${remove}" = true ]; then
        docker_cmd="${docker_cmd} --rm"
    fi
    # run docker container in background if specified
    if [ "${detach}" = true ]; then
        docker_cmd="${docker_cmd} --detach"
    fi
    # expose jupyter and code-server ports if no command is specified
    if [ ! -z "${jupyter}" ]; then
        docker_cmd="${docker_cmd} -p ${jupyter_port}:${jupyter_port}"
    fi
    # expose additional ports
    docker_cmd="${docker_cmd} ${port_list}"
    # set container name
    if [ ! -z "${name}" ]; then
        docker_cmd="${docker_cmd} --name ${name}"    
    fi
    # set docker image
    docker_cmd="${docker_cmd} ${image}"
    
    # docker run with [options] the specified command (echo for info)
    echo "${docker_cmd} /bin/bash -c ${command}"
    ${docker_cmd} /bin/bash -c "${command}"
}

# -----------------------------------------------------------------------------
# MAIN SCRIPT
# -----------------------------------------------------------------------------

# not using interactive mode (not implemented)
interactive=
# set default values
port_list=
cmd_arg=
data_dir=
detach=false
env_list=
image=reloff/ml-research:latest
jupyter=
jupyter_port=8888
jupyter_password=
name=
reuse=true
remove=false
research_dir=$(pwd)
run_bash=false
run_sudo=false
use_gpu=false

# cycle through each item by shifting through positional parameters
while [ "$1" != "" ]; do
    # process each parameter with case
    case $1 in
        --bash )                run_bash=true
                                ;;
        -c | --command )        shift
                                cmd_arg=$1
                                ;;
        -d | --data-dir )       shift
                                data_dir="${data_dir} -v ${1}:/data/$(basename ${1})"
                                ;;
        --detach )              shift
                                detach=true
                                ;;
        -e | --env )            shift
                                env_list="${env_list} -e ${1}"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        -i | --image )          shift
                                image=$1
                                ;;
        --jupyter )             shift
                                jupyter=$1
                                ;;
        --jupyter-password )    shift
                                jupyter_password=$1
                                ;;
        --jupyter-port )        shift
                                jupyter_port=$1
                                ;;
        -n | --name )           shift
                                name=$1
                                ;;
        --no-reuse )            reuse=false
                                ;;
        --nvidia-gpu )          use_gpu=true
                                ;;
        -p | --port )           shift
                                port_list="${port_list} -p ${1}:${1}"
                                ;;
        --remove )              remove=true
                                ;;
        -r | --research-dir )   shift
                                research_dir=$1
                                ;;
        --sudo )                run_sudo=true
                                ;;
#        -i | --interactive )    interactive=1  # TODO possible future use
#                                ;;
        * )                     echo "Parameter not understood: ${1}"
                                usage
                                exit 1
    esac
    shift
done

# Post-process options
process_options

# Display selected options
print_options

# Run docker with specified options
docker_run
