#!/bin/bash
#=================================================================================#
# gpfs-nfs4-bind-mounts.sh - This routine is called after a GPFS file system has  #
#                            been mounted and right before an unmount is to be    #
#                            processed. That is so it can mount and unmount the   #
#                            bind mounts required for NFSv4.                      #
#---------------------------------------------------------------------------------#
# Chad Kerner, ckerner@illinois.edu                                               #
# Senior Storage Engineer, Storage Enabling Technologies                          #
# National Center for Supercomputing Applications                                 #
# University of Illinois, Urbana-Champaign                                        #
#---------------------------------------------------------------------------------#
# To install this callback, you can run the make from the git repository.  Or,    #
# you can issue the following command:                                            #
#                                                                                 #
# /usr/lpp/mmfs/bin/mmaddcallback NFSbind \                                       #
#     --command /var/mmfs/etc/gpfs-nfs4-bind-mounts.sh --event mount,preUnmount \ #
#     -N server1,server2 --sync --timeout 30 --onerror continue                   #
#     --parms "%eventName %fsName" --parms "%eventName %fsName"                   #
#                                                                                 #
#---------------------------------------------------------------------------------#
# Parameters Received                                                             #
#                                                                                 #
#   %eventName    - Specifies the name of the event that triggered the callback.  #
#                   Valid Values: preMount, preUnmount, mount, unmount            #
#                                                                                 #
#   %fsName       - The name of the file system triggering the event.             #
#---------------------------------------------------------------------------------#
#                                                                                 #
#                                                                                 #
#=================================================================================#

GPFSEVENT=$1
GPFSFS=$2

MOUNT=`which mount 2>/dev/null`
UMOUNT=`which umount 2>/dev/null`

function mforge_ready {
   MOUNTED=0
   while [ ${MOUNTED} -eq 0 ] ; do
      if [[ -f "/mforge/.MOUNTED" ]] ; then
         MOUNTED=1
      else
         sleep 1
      fi
   done
}

function mount_mforge {
   mforge_ready
   ${MOUNT} --bind /mforge/esx /export/esx
}

function unmount_mforge {
   ${UMOUNT} /export/esx
}

function mount_fs {
   MYFS=$1
   case "${MYFS}" in
      mforge)   mount_mforge ;;
      *)        echo "MOUNT ERROR: Unknown File System: ${MYFS}" ;;
   esac
}

function unmount_fs {
   MYFS=$1
   case "${MYFS}" in
      mforge)   unmount_mforge ;;
      *)        echo "UNMOUNT ERROR: Unknown File System: ${MYFS}" ;;
   esac
}

case "${GPFSEVENT}" in
   mount)       mount_fs ${GPFSFS} ;;
   preUnmount)  unmount_fs ${GPFSFS} ;;
   *)           echo "EVENT ERROR: Unknown Event: ${GPFSEVENT}" ;;
esac


