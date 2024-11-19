# s3fs-samba
A docker container which mounts s3 buckets and shares them using samba

To use:

docker run --name s3fs-samba \
	--restart always -d --privileged \
	-p 139:139 \
	-p 445:445 \
        -e AWSKEY_FILE=aws_key \
        -e AWSSECRET_FILE=aws_secret \
        -e SMBUSER_FILE=smb_user \
        -e SMBPASS_FILE=smb_pass \
        -e BUCKET="your_bucket_name" \
        -e S3_HOST="your_s3_host" \
	anyway/s3fs-samba
 
 ## Environment Variables
 
- `AWSKEY_FILE`: Docker Secret name containing the AWS Access Key (default: `aws_key`).
- `AWSSECRET_FILE`: Docker Secret name containing the AWS Secret Access Key (default: `aws_secret`).
- `SMBUSER_FILE`: Docker Secret name containing the Samba username (default: `smb_user`).
- `SMBPASS_FILE`: Docker Secret name containing the Samba password (default: `smb_pass`).
- `BUCKET`: Name(s) of the S3 bucket(s) to mount (can be multiple, separated by spaces).
- `S3_HOST`: Hostname for S3-compatible storage.

  
Note that:

* The s3fs mount is configure to use a local cache at /mnt/s3fs-***-tmp and according to https://github.com/s3fs-fuse/s3fs-fuse/wiki/FAQ this is unbounded!  This can be turned off in the fstab line in start.sh
* The s3fs mount is configured to use reduced redundancy storage. This can also be modified in the fstab line in start.sh
