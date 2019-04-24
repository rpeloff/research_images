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
    echo "usage: run_docker_env.sh [options]"
    echo ""
    echo "Run Jupyter Lab and VSCode in a Docker research enivronment for remote access."
    echo "(Run script with sudo if Docker is not set up for non-root users)"
    echo ""
    echo "Options:"
    echo "    -i, --image <string>             Specify the Docker image (Default: reloff/ml-research:latest)."
    echo "    -n, --name <string>              Set the Docker container name (Default: ml-research-env)."
    echo "    -d, --data-dir <dir>             Mount the data directory to the container (Default: No directory)."
    echo "    -r, --research-dir <dir>         Mount the research directory to the container (Default: current working directory)."
    echo "        --jupyter-port <number>      Port the Jupyter server will bind on (Default: 8888)."
    echo "        --vs-port <number>           Port the VSCode code-server server will bind on (Default: 8443)."
    echo "        --jupyter-password <string>  Token used to access Jupyter Lab (Default: No authentication)."
    echo "        --vs-password <string>       Token used to access VSCode code-server (Default: No authentication)."
    echo "    -e, --vs-extensions <dir>        Set the root path for extensions (Default: No directory)."
    echo "    -c, --command <string>           Specify a command to run instead of Jupyter and VSCode servers (Default: None)."
    echo "    -h, --help                       Print this information and exit."
    echo ""
}

print_options()
{
    echo "Starting Jupyter Lab and VSCode in Docker research enivronment."
    echo "(Run script with sudo if Docker is not set up for non-root users)"
    echo ""
    echo "Docker image: ${image}"
    echo "Docker container: ${name}"
    echo "Data directory: ${data_dir}"
    echo "Research directory: ${research_dir}"
    if [ -z "${cmd_arg}" ]; then
        echo "Jupyter server port: ${jupyter_port}"
        echo "VSCode code-server port: ${vs_port}"
        echo "Jupyter authentication token: ${jupyter_password}"
        echo "VSCode authentication token: ${vs_password}"
        echo "VSCode extensions directory: ${vs_extensions}"
        echo "Docker command: ${command}"
    else
        echo "Docker command: ${command}"
        echo "(Not executing Jupyter and VSCode servers)"
    fi
    echo ""
}

process_options()
{
    if [ -z "${cmd_arg}" ]; then
        command="jupyter lab"
        command="${command} --no-browser"
        command="${command} --ip=0.0.0.0"
        command="${command} --port=${jupyter_port}"
        command="${command} --NotebookApp.token=${jupyter_password}"
        command="${command} --notebook-dir='/research'"
        command="${command} --allow-root"
        command="${command} &"
        command="${command} code-server"
        command="${command} -d /research"
        command="${command} -p ${vs_port}"
        if [ -z "${vs_password}" ]; then
            command="${command} --no-auth"
        else
            command="${command} --password ${vs_password}"
        fi
        if [ ! -z "${vs_extensions}" ]; then
            command="${command} -e ${vs_extensions}"
        fi
        command="${command} --allow-http"
    else
        command="${cmd_arg}"
    fi
}

docker_run()
{
    # run command in docker (do not execute Jupyter and VSCode)
    if [ ! -z "${cmd_arg}" ]; then
        docker run \
            --runtime=nvidia \
            -v ${research_dir}:/research \
            -u $(id -u):$(id -g) \
            -w /research \
            --rm \
            -it \
            --name ${name} \
            ${image} \
            /bin/bash -c "$command"
    # run Jupyter and VSCode (no data directory)
    elif [ -z "${data_dir}" ]; then
        docker run \
            --runtime=nvidia \
            -v ${research_dir}:/research \
            -u $(id -u):$(id -g) \
            -w /research \
            --rm \
            -it \
            -p ${jupyter_port}:${jupyter_port} \
            -p ${vs_port}:${vs_port} \
            --name ${name} \
            ${image} \
            /bin/bash -c "$command"
    # run Jupyter and VSCode (with mounted data directory)
    else
        docker run \
            --runtime=nvidia \
            -v ${research_dir}:/research \
            -v ${data_dir}:/data \
            -u $(id -u):$(id -g) \
            -w /research \
            --rm \
            -it \
            -p ${jupyter_port}:${jupyter_port} \
            -p ${vs_port}:${vs_port} \
            --name ${name} \
            ${image} \
            /bin/bash -c "$command"
    fi
}

# -----------------------------------------------------------------------------
# MAIN SCRIPT
# -----------------------------------------------------------------------------

# not using interactive mode
interactive=
# set default values
image=reloff/ml-research:latest
name=ml-research-env
data_dir=
research_dir=$(pwd)
jupyter_port=8888
vs_port=8443
jupyter_password=
vs_password=
vs_extensions=
cmd_arg=

# cycle through each item by shifting through positional parameters
while [ "$1" != "" ]; do
    # process each parameter with case
    case $1 in
        -i | --image )          shift
                                image=$1
                                ;;
        -n | --name )           shift
                                name=$1
                                ;;
        -d | --data-dir )       shift
                                data_dir=$1
                                ;;
        -r | --research-dir )   shift
                                research_dir=$1
                                ;;
        --jupyter-port )        shift
                                jupyter_port=$1
                                ;;
        --vs-port )             shift
                                vs_port=$1
                                ;;
        --jupyter-password )    shift
                                jupyter_password=$1
                                ;;
        --vs-password )         shift
                                vs_password=$1
                                ;;
        -e | --vs-extensions )  shift
                                vs_extensions=$1
                                ;;
        -c | --command )        shift
                                cmd_arg=$1
                                ;;
#        -i | --interactive )    interactive=1
#                                ;;
        -h | --help )           usage
                                exit
                                ;;
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
