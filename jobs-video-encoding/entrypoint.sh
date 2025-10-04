#!/bin/bash
set -e

# Debug: Check NVIDIA driver and CUDA version
echo "Checking NVIDIA environment..."
nvidia-smi || echo "nvidia-smi not available" && exit 1
echo "CUDA Version check:"
nvcc --version || echo "nvcc not available" && exit 1

# Expecting: ./entrypoint.sh input_video.mp4 output_video.mp4 -vcodec h264_nvenc ...
INPUT_FILE=$1
OUTPUT_FILE=$2
# All remaining arguments are passed to ffmpeg
shift 2
FFMPEG_ARGS=("$@")

# Build paths based on mounted contains
INPUT_PATH=/inputs/$INPUT_FILE
OUTPUT_PATH=/outputs/$OUTPUT_FILE

# Define local processing directory
WORK_DIR="/tmp/transcode"

# Build local transcoding paths
LOCAL_INPUT="${WORK_DIR}/${INPUT_FILE}"
LOCAL_OUTPUT="${WORK_DIR}/${OUTPUT_FILE}"

# Copy mounted file into local temp for processing
cp "$INPUT_PATH" "$LOCAL_INPUT"

echo "==============================================="
echo "Starting transcode job"
echo "Source: ${INPUT_PATH}"
echo "Target: ${OUTPUT_PATH}"
echo "==============================================="

# Extract video information using ffprobe
VIDEO_INFO=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate,nb_frames,duration -of json "${LOCAL_INPUT}")
if [ $? -ne 0 ]; then
    echo "WARNING: Could not extract video information"
    VIDEO_WIDTH="unknown"
    VIDEO_HEIGHT="unknown"
    FRAME_RATE="unknown"
    TOTAL_FRAMES="unknown"
    DURATION="unknown"
else
    VIDEO_WIDTH=$(echo "$VIDEO_INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['streams'][0].get('width', 'unknown'))")
    VIDEO_HEIGHT=$(echo "$VIDEO_INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['streams'][0].get('height', 'unknown'))")
    FRAME_RATE_STR=$(echo "$VIDEO_INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['streams'][0].get('r_frame_rate', '0/1'))")
    TOTAL_FRAMES=$(echo "$VIDEO_INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['streams'][0].get('nb_frames', 'unknown'))")
    DURATION=$(echo "$VIDEO_INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['streams'][0].get('duration', 'unknown'))")

    # Calculate frame rate as decimal
    if [ "$FRAME_RATE_STR" != "0/1" ] && [ "$FRAME_RATE_STR" != "unknown" ]; then
        FRAME_RATE=$(echo "$FRAME_RATE_STR" | python3 -c "import sys; parts=sys.stdin.read().strip().split('/'); print(float(parts[0])/float(parts[1]) if len(parts)==2 else 0)")
    else
        FRAME_RATE="unknown"
    fi
fi

echo "Input video information:"
echo "  Resolution: ${VIDEO_WIDTH}x${VIDEO_HEIGHT}"
echo "  Frame rate: ${FRAME_RATE} fps"
echo "  Total frames: ${TOTAL_FRAMES}"
echo "  Duration: ${DURATION} seconds"

# Step 3: Run FFmpeg transcoding
echo ""
echo "Step 3: Starting FFmpeg transcoding..."
echo "FFmpeg command: ffmpeg -y -c:v h264_cuvid -i ${LOCAL_INPUT} ${FFMPEG_ARGS} -preset p7 ${LOCAL_OUTPUT}"

# Record start time
TRANSCODE_START=$(date +%s.%N)
TRANSCODE_START_READABLE=$(date '+%Y-%m-%d %H:%M:%S')
echo "Transcoding started at: ${TRANSCODE_START_READABLE}"

# Execute ffmpeg with hardware acceleration
ffmpeg -y -c:v h264_cuvid -i "${LOCAL_INPUT}" "${FFMPEG_ARGS[@]}" -preset p7 "${LOCAL_OUTPUT}" 2>&1 | tee /tmp/ffmpeg.log
FFMPEG_EXIT_CODE=${PIPESTATUS[0]}

# Record end time
TRANSCODE_END=$(date +%s.%N)
TRANSCODE_END_READABLE=$(date '+%Y-%m-%d %H:%M:%S')
TRANSCODE_DURATION=$(echo "$TRANSCODE_END - $TRANSCODE_START" | bc)

echo "Transcoding ended at: ${TRANSCODE_END_READABLE}"
echo "TRANSCODING DURATION: ${TRANSCODE_DURATION} seconds"

if [ "$FFMPEG_EXIT_CODE" -ne 0 ]; then
    echo "ERROR: FFmpeg transcoding failed with exit code ${FFMPEG_EXIT_CODE}"
    # Clean up input file to save space
    rm -f "${LOCAL_INPUT}"
    exit "$FFMPEG_EXIT_CODE"
fi
echo "Transcoding complete. Output file size: $(du -h ${LOCAL_OUTPUT} | cut -f1)"

# Calculate megapixels per second if we have the necessary information
if [ "$VIDEO_WIDTH" != "unknown" ] && [ "$VIDEO_HEIGHT" != "unknown" ] && [ "$FRAME_RATE" != "unknown" ] && [ "$DURATION" != "unknown" ]; then
    TOTAL_PIXELS=$(echo "$VIDEO_WIDTH * $VIDEO_HEIGHT" | bc)
    MEGAPIXELS=$(echo "scale=2; $TOTAL_PIXELS / 1000000" | bc)

    # If we don't have total frames, calculate from duration and frame rate
    if [ "$TOTAL_FRAMES" == "unknown" ]; then
        TOTAL_FRAMES=$(echo "$DURATION * $FRAME_RATE" | bc | cut -d. -f1)
    fi

    TOTAL_MEGAPIXELS=$(echo "scale=2; $MEGAPIXELS * $TOTAL_FRAMES" | bc)
    MEGAPIXELS_PER_SECOND=$(echo "scale=2; $TOTAL_MEGAPIXELS / $TRANSCODE_DURATION" | bc)

    echo ""
    echo "=== PERFORMANCE METRICS ==="
    echo "Video resolution: ${VIDEO_WIDTH}x${VIDEO_HEIGHT} (${MEGAPIXELS} MP per frame)"
    echo "Total frames processed: ${TOTAL_FRAMES}"
    echo "Total megapixels processed: ${TOTAL_MEGAPIXELS} MP"
    echo "Transcoding time: ${TRANSCODE_DURATION} seconds"
    echo "MEGAPIXELS PER SECOND: ${MEGAPIXELS_PER_SECOND} MP/s"
    echo "Frames per second (encoding speed): $(echo "scale=2; $TOTAL_FRAMES / $TRANSCODE_DURATION" | bc) fps"
    echo "Real-time factor: $(echo "scale=2; $DURATION / $TRANSCODE_DURATION" | bc)x"
    echo "=========================="
fi

# Step 4: Verify the output file
echo ""
echo "Step 4: Verifying output file..."
if [ ! -f "${LOCAL_OUTPUT}" ]; then
    echo "ERROR: Output file not found at ${LOCAL_OUTPUT}"
    rm -f "${LOCAL_INPUT}"
    exit 1
fi
ffprobe -v error -show_format -show_streams "${LOCAL_OUTPUT}" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "WARNING: Output file may be corrupted"
fi

# Step 5: Copy the output file mounted path
echo ""
echo "Step 5: Copying output file to GCS mounted path..."
cp "$LOCAL_OUTPUT" "$OUTPUT_PATH"

echo ""
echo "==============================================="
echo "TRANSCODE JOB SUMMARY"
echo "==============================================="
echo "Input: $INPUT_PATH"
echo "Output: $OUTPUT_PATH"
echo "Download time: ${DOWNLOAD_TIME} seconds"
echo "TRANSCODE TIME: ${TRANSCODE_DURATION} seconds"
echo "Upload time: ${UPLOAD_TIME} seconds"
echo "Total job time: $(echo "$DOWNLOAD_TIME + $TRANSCODE_DURATION + $UPLOAD_TIME" | bc) seconds"
if [ "$MEGAPIXELS_PER_SECOND" != "" ]; then
    echo "Performance: ${MEGAPIXELS_PER_SECOND} megapixels/second"
fi
echo "==============================================="
echo "Transcode job completed successfully!"
echo "==============================================="

exit 0
