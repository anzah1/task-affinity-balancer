# task-affinity-balancer
Locks processes child threads to core that has least amount of load.

This can be used as workaround if Linux kernel or program starts moving threads
or processes too frequently between cores. That can cause severe stutter in
interactive applications (each move causes cache flush).

At least for me this started to be problem for me when I updated to 4.9.17
Linux kernel.

Easiest way to see if that's happening is to install htop and check if core
used by thread or process keeps changing.

## requirements
Scripts uses pgrep and taskset commands. They should be included by default in
default in most Linux distributions. It's unlikely that this script works
outside Linux.

## install

There's no install as such. Script can be used as is without install.

## usage

* Start up the target process. Launch the script and add processes binary name
  as parameter (script will use pgrep to find the PID), like this:
  `./affinity-lock.sh ThreadedBinary`

## TODO
- [ ] Make script faster by skipping finding most idle core if thread or process
doesn't use much CPU (it makes the script more complicated though). 

- [ ] Make the output nicer and move most of the current output under debug command
  line parameter.

- [ ] Handle case where multiple processes match in sane way. Now script picks the
  oldest process.

