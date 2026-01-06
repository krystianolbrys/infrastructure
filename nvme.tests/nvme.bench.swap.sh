#!/bin/bash

fio --name=swap-read \
    --filename=fio1.test \
    --size=2G \
    --ioengine=libaio \
    --direct=1 \
    --rw=randread \
    --bs=4k \
    --iodepth=1 \
    --numjobs=1 \
    --time_based=1 \
    --runtime=30 \
    --group_reporting


fio --name=swap-mix \
    --filename=fio2.test \
    --size=2G \
    --ioengine=libaio \
    --direct=1 \
    --rw=randrw \
    --rwmixread=50 \
    --bs=4k \
    --iodepth=4 \
    --numjobs=1 \
    --time_based=1 \
    --runtime=30 \
    --group_reporting