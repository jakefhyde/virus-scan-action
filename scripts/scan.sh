#!/bin/bash
MODE=$1
IMAGES_FILENAME=$2
if [ ${MODE} = "multi" ]; then
  IFS=$'\n' read -a IMAGES <<< $(cat $IMAGES_FILENAME)
  mkdir images_scan
  echo ${IMAGES}
  for image in ${IMAGES}
  do
    ls -R
    docker pull ${image}
    image_path=images_scan/$(tr '/' '-' <<< ${image}.tar)
    file $image_path
    sudo docker save ${image} > $image_path
    echo "saved image tar: " $image_path
    tar -x $image_path
  done
  cd images_scan
elif [ ${MODE} != "single" ]; then
  echo "Invalid mode: ${MODE}"
  exit 1
fi
clamscan -r > output.txt
cat output.txt
read -a ARR <<< $(cat output.txt | grep "Infected")
if [ ${ARR[2]} != 0 ]; then
  exit 1
else
  echo "success"
fi
