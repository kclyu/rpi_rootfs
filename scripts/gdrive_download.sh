#!/bin/bash
# this script borrowed from https://www.matthuisman.nz/2019/01/download-google-drive-files-wget-curl.html
fileid=$1
filename=$2
wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='${fileid} -O- \
     | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > confirm.txt
wget --load-cookies cookies.txt -O $filename \
     'https://docs.google.com/uc?export=download&id='${fileid}'&confirm='$(<confirm.txt)
rm -f confirm.txt cookies.txt
