FROM floydhub/dl-docker:gpu
# All-in-one Docker image
FROM bvlc/caffe:gpu 

ENV DEBIAN_FRONTEND=noninteractive
ENV BASE=/code/up
ARG COMMIT_HASH_UP=bf67bc4a1e488b3b0e35f43dfd602b7225a03641
RUN apt-get update && apt-get install -y \
		bc \
		build-essential \
		cmake \
		curl \
		g++ \
		gfortran \
		git \
		libffi-dev \
		libpng12-dev \
		libssl-dev \
		libtiff5-dev \
		libwebp-dev \
		libzmq3-dev \
		nano \
		pkg-config \
		python-dev \
		software-properties-common \
		unzip \
		vim \
		wget \
		zlib1g-dev \
		qt5-default \
		libvtk6-dev \
		zlib1g-dev \
		libjpeg-dev \
		libwebp-dev \
		libpng-dev \
		libtiff5-dev \
		libjasper-dev \
		libopenexr-dev \
		libgdal-dev \
		libdc1394-22-dev \
		libavcodec-dev \
		libavformat-dev \
		libswscale-dev \
		libtheora-dev \
		libvorbis-dev \
		libxvidcore-dev \
		libx264-dev \
		yasm \
		libopencore-amrnb-dev \
		libopencore-amrwb-dev \
		libv4l-dev \
		libxine2-dev \
		libtbb-dev \
		libeigen3-dev \
		python-dev \
		python-tk \
		python-numpy \
		python3-dev \
		python3-tk \
		python3-numpy \
		ant \
		default-jdk \
		doxygen 
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        realpath \
        unzip && \
    rm -rf /var/lib/apt/lists/*

# Create code dir an download UP
# https://github.com/classner/up
RUN mkdir /code
WORKDIR /code
COPY deployment/requirements.txt .
RUN wget https://github.com/classner/up/archive/${COMMIT_HASH_UP}.zip \
    && unzip ${COMMIT_HASH_UP}.zip \
    && mv up-${COMMIT_HASH_UP} up/ \
    && rm ${COMMIT_HASH_UP}.zip
WORKDIR ${BASE}

# Install python packages
RUN pip install -r /code/requirements.txt

# Adding models: caffe & smpl
COPY models /models/

RUN cd /models \
    && mkdir -p ${BASE}/pose/training/model/pose/ \
    && curl -O http://files.is.tuebingen.mpg.de/classner/up/models/p91.zip \
    && unzip p91.zip -d ${BASE}/pose/training/model/pose/ \
    && unzip SMPL_python_v.1.0.0.zip \
    && mv -v smpl/* /usr/lib/python2.7/dist-packages/ \
    && rm *.zip

# Add the entrypoint.sh
COPY deployment/docker-entrypoint.sh /usr/local/bin/
RUN chmod ugo+x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/bin/bash", "/usr/local/bin/docker-entrypoint.sh"]

CMD ["bash"]
