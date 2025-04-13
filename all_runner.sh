#!/bin/bash
rm -rf scratch
rm -rf tmp
rm -rf out*
./sub_runner.sh 40 3 600 0 &
sleep 0.2
./sub_runner.sh 40 3 600 1 &
sleep 0.2
./sub_runner.sh 40 3 600 2 &
sleep 0.2
wait
echo "All done"
