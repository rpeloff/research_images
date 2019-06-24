#!/bin/bash

# Run Jupyter Lab and VSCode in a Docker research enivronment for remote access.
#
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
    echo "Start Docker research container and optionally run Jupyter or a specified command."
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
    echo "        --nvidia-gpu                 Run Docker with nvidia runtime for access to GPU (Default: standard runtime)."
    echo "    -p, --port <number>              Additional port to expose (multiple -p flags may be used)."
    echo "    -r, --research-dir <dir>         Mount the research directory to the container (Default: current working directory)."
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
        fi
    fi
    # run bash after all other commands have completed or been sent to background
    if [ "${run_bash}" = true ]; then
        command="${command} bash"
    fi
    # change ownership of files from docker root to current user on exit (if run as sudo)
    if [ "${run_sudo}" = true ]; then
        command="${command} ;"
        command="${command} chown -R $(id -u):$(id -g) /research"
    fi

    command="${command} ; "
}

print_options()
{
    echo "Start Docker research container and optionally run Jupyter or specified command."
    echo "(Run script with sudo if Docker is not set up for non-root users)"
    echo ""
    echo "Docker image: ${image}"
    echo "Docker container: ${name}"
    echo "Data directory: ${data_dir}"
    echo "Research directory: ${research_dir}"
    if [ ! -z "${cmd_arg}" ]; then
        echo "User command: ${cmd_arg}"
    fi
    if [ ! -z "${jupyter}" ]; then
        echo "Running Jupyter [${jupyter}]:"
        echo "  - Jupyter server port: ${jupyter_port}"
        echo "  - Jupyter authentication token: ${jupyter_password}"
    fi
    if [ "${run_bash}" = true ]; then
        echo "Running bash in container"
    fi 

    echo "Additional ports command: ${add_port}"
    echo ""
}

docker_run()
{
    # docker run and params
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
    # work in /research, remove container on exit, and use interactive terminal
    docker_cmd="${docker_cmd} -w /research --rm -it"
    # run docker container in background if specified
    if [ "${detach}" = true ]; then
        docker_cmd="${docker_cmd} --detach"
    fi
    # expose jupyter and code-server ports if no command is specified
    if [ ! -z "${jupyter}" ]; then
        docker_cmd="${docker_cmd} -p ${jupyter_port}:${jupyter_port}"
    fi
    # expose additional ports
    docker_cmd="${docker_cmd} ${add_port}"
    # set container name
    if [ ! -z "${name}" ]; then
        docker_cmd="${docker_cmd} --name ${name}"    
    fi
    # set docker image
    docker_cmd="${docker_cmd} ${image}"
    
    # docker run with [options] the specified command
    ${docker_cmd} /bin/bash -c "${command}"
}

# -----------------------------------------------------------------------------
# MAIN SCRIPT
# -----------------------------------------------------------------------------

# not using interactive mode
interactive=
# set default values
add_port=
cmd_arg=
data_dir=
detach=false
env_list=
image=reloff/ml-research:latest
jupyter=
jupyter_port=8888
jupyter_password=
name=
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
        --jupyter-port )        shift
                                jupyter_port=$1
                                ;;
        --jupyter-password )    shift
                                jupyter_password=$1
                                ;;
        -n | --name )           shift
                                name=$1
                                ;;
        --nvidia-gpu )          use_gpu=true
                                ;;
        -p | --port )           shift
                                add_port="${add_port} -p ${1}:${1}"
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
