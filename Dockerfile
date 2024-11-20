FROM ubuntu:latest

# 安装依赖
RUN apt-get update && \
    apt-get install -y git automake autotools-dev g++ libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config samba fuse && \
    apt-get clean

# 克隆并编译 s3fs-fuse
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git && \
    cd s3fs-fuse && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

# 添加 Samba 配置文件
ADD smb-config-add /etc/samba/smb.conf.template

# 暴露端口
EXPOSE 139
EXPOSE 445

# 添加启动脚本并赋予执行权限
ADD start.sh /start.sh
RUN chmod +x /start.sh

# 设置默认命令
CMD ["/start.sh"]
