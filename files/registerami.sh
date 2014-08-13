#!/bin/sh
#
# usage: sh ./registerami.sh [-s] -i </path/to/file> -a <aws_account_number> -b <s3_bucket> -t <pv|hvm>
#
# ex. sh ./registerami.sh -i images/CentOS-7.0-x86_64-201410021234/CentOS-7.0-x86_64-201410021234-aws-pv-disk1.vmdk -a 96593828405 -b prod-amis -t pv
#

DEFAULT_KERNEL="aki-919dcaf8" # PV-GRUB
SRIOV_ARG=''

while getopts "a:b:i:t:s" opt; do
    case $opt in
        a)
            ACCOUNTNUM=$OPTARG
            ;;
        b)
            BUCKET=$OPTARG
            ;;
        i)
            IMAGE_FILE_VB=$OPTARG
            ;;
        t)
            VIRT_TYPE=$OPTARG
            ;;
        s)
            SRIOV_ARG='--sriov simple'
            ;;
        *)
            echo "Invalid option: $opt"
            exit 1
    esac
done

cleanup_image () {
    rm -rf $TEMPDIR
    # We deleted the paravirt vbox disk
    VBoxManage closemedium disk $IMAGE_FILE --delete
    VBoxManage closemedium disk $IMAGE_FILE_VB
}


# Check our VIRT_TYPE and set other vars accordingly.
if [ "$VIRT_TYPE" = "paravirt" ]; then
    VIRT_ARGS="--kernel $DEFAULT_KERNEL"
elif [ "$VIRT_TYPE" = "hvm" ]; then
    VIRT_ARGS="--virtualization-type hvm"
else
    echo "Must set virtualization type: paravirt|hvm"
    exit 1
fi

IMAGE_DIR=$(dirname $IMAGE_FILE_VB)
IMAGE_FILE=$(echo $IMAGE_FILE_VB | sed 's/-disk1.vmdk/.img/')
IMAGE_NAME=$(echo $(basename $IMAGE_FILE_VB) | sed 's/-disk1.vmdk//')
if [ "$SRIOV_ARG" != '' ]; then
    IMAGE_NAME="${IMAGE_NAME}-sriov"
fi


# Make sure we have login creds for EC2
SETUP_PASS=1
if [ -z $AWS_ACCESS_KEY ]; then
    echo 'You must define $AWS_ACCESS_KEY'
    SETUP_PASS=0
fi

if [ -z $AWS_SECRET_KEY ]; then
    echo 'You must define $AWS_SECRET_KEY'
    SETUP_PASS=0
fi

if [ -z $EC2_PRIVATE_KEY ]; then
    echo 'You must define $EC2_PRIVATE_KEY'
    SETUP_PASS=0
fi

if [ -z $EC2_CERT ]; then
    echo 'You must define $EC2_CERT'
    SETUP_PASS=0
fi

if [ "$SETUP_PASS" = '0' ]; then
    exit 1
fi


# Get RAW disk file
VBoxManage clonehd $IMAGE_FILE_VB $IMAGE_FILE --format RAW
if [ $? -ne 0 ]; then
    echo "Export failed!"
    echo "Artifact:     $IMAGE_FILE_VB"
    echo "Destination:  $IMAGE_FILE"
    exit 1
fi

# Paravirt images require that we extract the partition from the disk image
# and alter GRUB to match.
#
# NOTE: While it's possible to boot a paravirt AMI that is a full disk image
# by having grub look at disk (hd0,0), CentOS 6 panics during boot because
# the OS claims it is unable to find the root disk.  Did not work using UUID
# or LABEL in grub.conf.  Once 6 is gone this process can be revisited.
#
# We use fdisk to get the block offset ($skip) of the partition from within
# the disk and then get the block count of the partition.  That information
# is passed to `dd` to write out the raw partition to a file.
#
# NOTE: Once we have the partition file we overwrite the image created by
# VBoxManage.
#
if [ "$VIRT_TYPE" = "paravirt" ]; then
    UNAME_S=$(uname -s)

    if [ "$UNAME_S" = "Darwin" ]; then
        skip=$(fdisk $IMAGE_FILE | egrep '^\*' | awk '{ print $11 }')
        # By adding 0 we force the value to be a number and discard the
        # trailing ']' from the field. #StupidAWKTricks
        count=$(fdisk $IMAGE_FILE | egrep '^\*' | awk '{ print $13+0 }')
    elif [ "$UNAME_S" = "Linux" ]; then
        skip=$(fdisk -ul $IMAGE_FILE | egrep "^${IMAGE_FILE}" | awk '{ print $3 }')
        end=$(fdisk -ul $IMAGE_FILE | egrep "^${IMAGE_FILE}" | awk '{ print $4 }')
        count=$(expr $end - $skip + 1)
    fi

    dd if=$IMAGE_FILE of=${IMAGE_FILE}-part skip=$skip count=$count

    # We now overwrite ${IMAGE_FILE} with ${IMAGE_FILE}-part
    mv ${IMAGE_FILE}-part ${IMAGE_FILE}
fi

TEMPDIR=`mktemp -d /tmp/tmp.XXXXXXXXXX`

ec2-bundle-image -c $EC2_CERT -k $EC2_PRIVATE_KEY -u $ACCOUNTNUM -i $IMAGE_FILE -d $TEMPDIR -p ${IMAGE_NAME} -r x86_64
ec2-upload-bundle -b $BUCKET -a $AWS_ACCESS_KEY -s $AWS_SECRET_KEY -m ${TEMPDIR}/${IMAGE_NAME}.manifest.xml
if [ $? -ne 0 ]; then
    echo "Image upload failed!"

    cleanup_image

    exit 1
fi


ec2-register $SRIOV_ARG -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY -n ${IMAGE_NAME} -d ${IMAGE_NAME} ${BUCKET}/${IMAGE_NAME}.manifest.xml $VIRT_ARGS

if [ $? -ne 0 ]; then
    echo "Registration failed!"
    echo "This is usally caused by an existing image in S3 with the same name."
    echo "Use the following to resolve this issue and rerun this script:"
    echo "ec2-deregister <existing_ami_id>"

    cleanup_image

    exit 1
fi

cleanup_image
