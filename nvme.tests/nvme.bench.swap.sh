#!/bin/bash

fio --name=swap-latency \
    --filename=fio.test \
    --ioengine=libaio \
    --direct=1 \
    --rw=randread \
    --bs=4k \
    --iodepth=1 \
    --numjobs=1 \
    --time_based=1 \
    --runtime=10 \
    --group_reporting

rm fio.test