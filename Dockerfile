# 使用更小的基础镜像
FROM alpine:latest
# 安装必要的包
RUN apk add --no-cache git automake autoconf g++ libcurl fuse samba
# 克隆并编译 s3fs-fuse
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git && \
    cd s3fs-fuse && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf s3fs-fuse

# 添加 Samba 配置模板
ADD smb-config-add /etc/samba/smb.conf.template

# 暴露 Samba 端口
EXPOSE 139 445

# 添加启动脚本
ADD start.sh /start.sh
RUN chmod +x /start.sh

# 设置默认命令
CMD ["/start.sh"]

