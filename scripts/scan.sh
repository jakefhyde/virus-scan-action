#!/bin/bash
mode=$1
images_filename=$2
infected_images=""
is_infected=false

download_image_layers() {
  dl_image=$1
  docker pull ${dl_image}
  image_path=$(tr ':' '-' <<< $(tr '/' '-' <<< ${dl_image}.tar))
  docker save ${dl_image} > $image_path
  file ${image_path}
  echo "saved image tar: " $image_path
  tar -xvf ${image_path}
  layers=$(jq '.[].Layers' manifest.json | grep .tar)
  for layer in ${layers[@]}; do
    layer_tar_name=${layer#\"}
    layer_tar_name=${layer_tar_name%,}
    layer_tar_name=${layer_tar_name%\"}
    tar -xvf ${layer_tar_name}
  done
}

scan_current_dir() {
  clamscan -r > output.txt
  cat output.txt
  read -a arr <<< $(cat output.txt | grep "Infected")
  if [ ${arr[2]} = 0 ]; then
    is_infected=false
    return
  fi
  is_infected=true
}

add_infected_image() {
  infected_image=$1  
  if [[ ${infected_images} = "" ]]; then
    infected_images=${infected_image}
  else
    infected_images+=",${infected_image}"
  fi
}

if [[ ${mode} = "multi" ]]; then
  readarray -t images < ${images_filename}
  mkdir images_scan
  cat ${images_filename}
  cd images_scan
  for image in ${images[@]}
  do
    download_image_layers ${image}
    echo "scanning image: ${image}"
    scan_current_dir
    if [[ ${is_infected} = true ]]; then
      add_infected_image ${image}
    fi
    rm -rf *
  done
  if [[ ${infected_images} != "" ]]; then
    echo "Infected files found: ${infected_images}"
    exit 1
  fi
elif [[ ${mode} = "single" ]]; then
  scan_current_dir
  if [[ ${is_infected} = true ]]; then
    echo "Virus(es) found"
    exit 1
  fi
else
  echo "Invalid mode: ${mode}"
  exit 1
fi

echo "No viruses found"
