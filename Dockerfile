FROM debian:buster
LABEL maintainer="markus.sitzmann@gmail.com"

ENV RDBASE="/opt/rdkit"
ENV RDKIT_BRANCH="Release_2018_09"
#ENV RDKIT_BRANCH="Release_2019_03"

ENV MOLHASH_BASE="/opt/molhash"
ENV MOLHASH_BRANCH="master"

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RDBASE/lib:/usr/lib/x86_64-linux-gnu"


RUN apt-get update && apt-get install -y --no-install-recommends  \
    git \
    gnupg2 \
    cmake \
    ca-certificates \
    build-essential \
    libboost-dev \
    libboost-all-dev \
    libboost-system1.67-dev \
    libboost-thread1.67-dev \
    libboost-serialization1.67-dev \
    libboost-python1.67-dev \
    libboost-regex1.67-dev \
    libboost-iostreams1.67-dev \
    libcairo2-dev \
    libeigen3-dev \
    python3-dev \
    python3-numpy \
    python3-pip \
    python3-pil \
    python3-pandas

WORKDIR /opt

RUN git clone -b $RDKIT_BRANCH --single-branch https://github.com/rdkit/rdkit.git

WORKDIR $RDBASE/build

RUN cmake \
  -D RDK_INSTALL_INTREE=OFF \
  -D RDK_BUILD_INCHI_SUPPORT=OFF \
  -D RDK_BUILD_AVALON_SUPPORT=OFF \
  -D RDK_BUILD_PYTHON_WRAPPERS=OFF \
  -D RDK_BUILD_CAIRO_SUPPORT=OFF \
  ..

RUN make -j $(nproc) && make install

#ENV PYTHONPATH=$RDBASE
#RUN ctest


WORKDIR /opt

RUN git clone -b $MOLHASH_BRANCH --single-branch https://github.com/nextmovesoftware/molhash.git

WORKDIR $MOLHASH_BASE/build

ENV PREFIX=$RDBASE

RUN cmake \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_PREFIX_PATH=$PREFIX \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -D TARGET=RDKIT \
    -D RDKIT_DIR=$PREFIX \
    ..

RUN cmake --build . --config Release \
    && cp molhash /opt/molhash \
    && cp libmolhashlib.a "/opt/molhash/"

