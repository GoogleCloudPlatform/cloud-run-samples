# Build stage
FROM nvidia/cuda:12.1.0-devel-ubuntu22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential cmake git pkg-config yasm nasm \
    libx264-dev libx265-dev libvpx-dev libfdk-aac-dev \
    libmp3lame-dev libopus-dev libvorbis-dev libass-dev \
    libssl-dev wget
# Use a specific version of nv-codec-headers that's compatible with NVENC API 12.1
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git && \
    cd nv-codec-headers && \
    git checkout n12.1.14.0 && \
    make install && cd .. && rm -rf nv-codec-headers
# --enable-nvenc and --enable-cuda-llvm
RUN git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg && \
    cd ffmpeg && \
    ./configure \
        --prefix=/usr/local --enable-gpl --enable-version3 --enable-nonfree \
        --enable-cuda-nvcc --enable-cuda-llvm --enable-cuvid --enable-nvenc \
        --enable-nvdec --enable-libnpp --extra-cflags=-I/usr/local/cuda/include \
        --extra-ldflags=-L/usr/local/cuda/lib64 --enable-libx264 --enable-libx265 \
        --enable-libvpx --enable-libfdk-aac --enable-libmp3lame --enable-libopus \
        --enable-libvorbis --enable-libass --enable-openssl && \
    make -j$(nproc) && make install

# --- Runtime stage ---
FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,video,utility

# Install system dependencies AND the Google Cloud SDK
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Your original dependencies
    python3 \
    python3-pip \
    bc \
    libx264-163 libx265-199 libvpx7 libfdk-aac2 libmp3lame0 libopus0 \
    libvorbis0a libvorbisenc2 libass9 libssl3 \
    # Dependencies needed for adding a new repository
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    && \
    # Add the Google Cloud SDK repository
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    # Update sources and install the SDK
    apt-get update && apt-get install -y google-cloud-sdk && \
    # Clean up APT cache
    rm -rf /var/lib/apt/lists/*

# Install required Python libraries
RUN pip3 install google-cloud-storage google-auth

# Copy compiled ffmpeg/ffprobe tools from the builder stage
COPY --from=builder /usr/local /usr/local

# Set library and binary paths
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV PATH=/usr/local/bin:$PATH

# Create a workspace and temp directory for processing
WORKDIR /workspace
RUN mkdir -p /tmp/transcode

# Copy the new entrypoint script
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Create non-root user for security
RUN addgroup --system app && adduser --system --ingroup app app
RUN chown -R app:app /workspace /tmp/transcode
USER app

# Set the entrypoint to our new wrapper script
ENTRYPOINT ["./entrypoint.sh"]
