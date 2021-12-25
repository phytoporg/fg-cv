#!/usr/bin/bash
# 
# This script iterates over a directory of PNG images and presents a labeling choice alongside
# the image via feh and rofi's dmenu emulation.

# Check dependencies first. Surface all missing dependencies and THEN fail.
SCRIPT_NAME=$(basename "$0")
FAILED_DEPS_CHECK=false
if ! command -v rofi > /dev/null; then
    echo "$SCRIPT_NAME requires rofi to run. Put that shiz in your PATH"
    FAILED_DEPS_CHECK=true
fi

if ! command -v feh > /dev/null; then
    echo "$SCRIPT_NAME requires feh to run. Put that shiz in your PATH"
    FAILED_DEPS_CHECK=true
fi

# Process args
IMAGES_PATH=
LABELS_FILE=
LABELS_PREFIX=labels_
SKIP_LABELED_FILES=false
while (($#)); do
    case $1 in 
        "--images-path")
            shift
            IMAGES_PATH=$1
            ;;
        "--labels-file")
            shift
            LABELS_FILE=$1
            ;;
        "--labels-prefix")
            shift
            LABELS_PREFIX=$1
            ;;
        "--skip-labeled")
            SKIP_LABELED_FILES=true
            ;;
    esac
    shift
done

# Check args
USAGE="$SCRIPT_NAME --images-path <directory> --labels-file <filepath> --labels-prefix [prefix] --skip-labeled"
if [ -z $IMAGES_PATH ] || [ -z $LABELS_FILE ]; then
    echo "Usage: $USAGE"
    exit
fi

for i in $(find $IMAGES_PATH -iname *.png); do
    IM_BASENAME=$(basename $i .png)
    LABEL_FILENAME=$IMAGES_PATH/$LABELS_PREFIX$IM_BASENAME
    if $SKIP_LABELED_FILES && [ -f "$LABEL_FILENAME" ]; then
        continue
    fi

    feh $i &
    FEH_PID=$!
    LABEL_CHOICE=$(cat $LABELS_FILE <(echo "quit") | rofi -dmenu -i -only-match -matching fuzzy -p "choose label" -location 7)
    if [ $LABEL_CHOICE == "quit" ]; then
        kill -9 $FEH_PID > /dev/null
        exit
    fi

    echo "$LABEL_CHOICE" >> $LABEL_FILENAME
    kill -9 $FEH_PID > /dev/null
done
