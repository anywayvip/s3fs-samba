# 从环境变量中获取 Docker Secrets 名称
AWSKEY_FILE=${AWSKEY_FILE:-aws_key}
AWSSECRET_FILE=${AWSSECRET_FILE:-aws_secret}
SMBUSER_FILE=${SMBUSER_FILE:-smb_user}
SMBPASS_FILE=${SMBPASS_FILE:-smb_pass}

# 从 Docker Secrets 中读取 AWS 密钥
AWSKEY=$(cat $AWSKEY_FILE)
AWSSECRET=$(cat $AWSSECRET_FILE)

# 从 Docker Secrets 中读取 Samba 用户和密码
SMBUSER=$(cat $SMBUSER_FILE)
SMBPASS=$(cat $SMBPASS_FILE)

# 将 AWS 密钥写入文件
echo "$AWSKEY:$AWSSECRET" >> /etc/passwd-s3fs
chmod 600 /etc/passwd-s3fs

# 创建用户
useradd -ms /bin/bash "$SMBUSER"
(echo "$SMBPASS"; echo "$SMBPASS") | smbpasswd -a -s "$SMBUSER"

# 初始化 Samba 配置
echo "" > /etc/samba/smb.conf
echo "Buckets are $BUCKET"

# 配置 S3 桶
for B in $BUCKET; do
    echo "Configuring folders for $B"
    mkdir -p /mnt/s3fs-"$B" /mnt/s3fs-"$B"-tmp
    chmod -R 777 /mnt/s3fs-"$B"-tmp
    chown -R "$SMBUSER" /mnt/s3fs-"$B"
    sed "s/_BUCKET_/$B/g" /etc/samba/smb.conf.template >> /etc/samba/smb.conf
done

echo "$SMBUSER" >> /etc/samba/smb.conf
service smbd start

# 启动 s3fs
for B in $BUCKET; do
    echo "Starting s3fs for $B"
    s3fs "$B" /mnt/s3fs-"$B" -o storage_class=standard,host="$S3_HOST",allow_other,rw,umask=000,noatime,use_cache=/mnt/s3fs-"$B"-tmp,dbglevel=warn -f > /var/log/s3fs-"$B".log.txt &
done

# 保持容器运行
tail -f /dev/null
