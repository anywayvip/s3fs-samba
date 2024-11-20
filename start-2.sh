#!/bin/bash

# 将 AWS 密钥写入 /etc/passwd-s3fs
echo "$AWSKEY:$AWSSECRET" >> /etc/passwd-s3fs
chmod 600 /etc/passwd-s3fs

# 添加 Samba 用户
useradd -ms /bin/bash "$SMBUSER"
(echo "$SMBPASS"; echo "$SMBPASS") | smbpasswd -a -s "$SMBUSER"

# 初始化 Samba 配置文件
echo "" > /etc/samba/smb.conf

# 输出桶信息
echo "Buckets are $BUCKET"

# 为每个桶配置文件夹
for B in $BUCKET; do
    echo "Configuring folders for $B"
    mkdir -p /mnt/s3fs-"$B" /mnt/s3fs-"$B"-tmp
    chmod -R 777 /mnt/s3fs-"$B"-tmp
    chown -R "$SMBUSER" /mnt/s3fs-"$B"
    
    # 将桶名替换到 Samba 配置模板中
    sed "s/_BUCKET_/$B/g" /etc/samba/smb.conf.template >> /etc/samba/smb.conf
done

# 将 Samba 用户添加到配置文件
echo "$SMBUSER" >> /etc/samba/smb.conf

# 启动 Samba 服务
service smbd start

# 为每个桶启动 s3fs
for B in $BUCKET; do
    echo "Starting s3fs for $B"
    s3fs "$B" /mnt/s3fs-"$B" -o storage_class=standard,host="$S3_HOST",allow_other,rw,umask=000,noatime,use_cache=/mnt/s3fs-"$B"-tmp,dbglevel=warn -f > /var/log/s3fs-"$B".log.txt &
done

# 保持脚本运行
tail -f /dev/null
