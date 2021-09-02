#!/bin/bash
clamscan -r > output.txt
cat output.txt
read -a ARR <<< $(cat output.txt | grep "Infected")
if [ ${ARR[2]} != 0 ]; then
  exit 1
else
  echo "success"
fi
