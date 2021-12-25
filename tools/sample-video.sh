#!/usr/bin/bash

# Check dependencies first. Surface all missing dependencies and THEN fail.
SCRIPT_NAME=$(basename "$0")
FAILED_DEPS_CHECK=false
if ! command -v yt-dlp > /dev/null; then
    echo "$SCRIPT_NAME requires yt-dlp to run. Put that shiz in your PATH"
    FAILED_DEPS_CHECK=true
fi

if ! command -v ffmpeg > /dev/null; then
    echo "$SCRIPT_NAME requires ffmpeg to run. Put that shiz in your PATH"
    FAILED_DEPS_CHECK=true
fi

if $FAILED_DEPS_CHECK; then
    echo "Failed dependencies check. Exiting."
    exit
fi

# Process args
VIDEO_URL=
OUT_PATH=
SAMPLE_INTERVAL=
DOWNLOAD_LIST=
while (($#)); do
    case $1 in 
        "--video-url")
            shift
            VIDEO_URL=$1
            ;;
        "--out-path")
            shift
            OUT_PATH=$1
            ;;
        "--sample-interval")
            shift
            SAMPLE_INTERVAL=$1
            ;;
        "--download-list")
            shift
            DOWNLOAD_LIST=$1
            ;;
    esac
    shift
done

# Check args
USAGE="$SCRIPT_NAME --video-url <video URL> --out-path <directory> --sample-interval <seconds> --download-list <filename>"
if [ -z $VIDEO_URL ] || [ -z $OUT_PATH ] || [ -z $SAMPLE_INTERVAL ]; then
    echo "Usage: $USAGE"
    exit
fi

# Make the output path if it doesn't exist
if [ ! -d "$OUT_PATH" ]; then
    mkdir -p "$OUT_PATH"
fi

START_NUMBER=0
NUM_FILES=$(find $OUT_PATH -iname out_*.png | wc -l)
if [ $NUM_FILES -gt 0 ]; then
    START_NUMBER=$(($NUM_FILES + 1))
fi

INPUT=$(yt-dlp -f best --get-url "$VIDEO_URL")
echo ffmpeg -i "$INPUT" -vf fps=1/$SAMPLE_INTERVAL -f image2 -start_number $START_NUMBER "$OUT_PATH/out_%09d.png"
ffmpeg -i "$INPUT" -vf fps=1/$SAMPLE_INTERVAL -f image2 -start_number $START_NUMBER "$OUT_PATH/out_%09d.png"
if [ $? -eq 0 ]; then
    echo "$VIDEO_URL samplerate=$SAMPLE_INTERVAL to $OUT_PATH" >> $DOWNLOAD_LIST
fi
