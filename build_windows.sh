#!/bin/bash
set -e

# 安装基本工具链
# sudo apt-get update
# sudo apt-get install -y \
#   mingw-w64 \
#   pkg-config \
#   make \
#   autoconf \
#   libtool \
#   gettext

# 基本环境变量设置
export HOST=x86_64-w64-mingw32
export PREFIX=/usr/local/$HOST
export PATH=$PATH:$PREFIX/bin
export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig

# 创建安装目录
# sudo mkdir -p $PREFIX
# sudo chown $(whoami) $PREFIX
# mkdir -p ~/builds

# 清理构建目录
make distclean || true

# 配置编译选项 - 使用已编译好的GMP库
# 添加-static-libstdc++ -static-libgcc确保静态链接C++和GCC运行时库
./configure \
  --host=$HOST \
  --prefix=$PREFIX \
  --enable-static \
  --disable-shared \
  --disable-nls \
  --without-openssl \
  --with-libgmp \
  --without-libnettle \
  --without-libgcrypt \
  --without-libexpat \
  --without-libxml2 \
  --without-libcares \
  --without-sqlite3 \
  --without-libz \
  --without-libssh2 \
  CPPFLAGS="-I$PREFIX/include" \
  LDFLAGS="-L$PREFIX/lib -static" \
  CXXFLAGS="-static-libstdc++ -static-libgcc" \
  PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

# 编译
make -j$(nproc)

# 创建输出目录
mkdir -p dist/aria2-windows
mkdir -p dist/aria2-windows/bin

# 安装
make install

# 拷贝可执行文件到发布目录
cp src/aria2c.exe dist/aria2-windows/bin/

# 移除调试符号，减小文件体积
echo "正在移除调试符号..."
$HOST-strip dist/aria2-windows/bin/aria2c.exe

# 创建压缩包
echo "创建分发压缩包..."
cd dist
zip -r aria2-windows-x64.zip aria2-windows
cd ..

echo "构建完成！"
echo "Windows版本的aria2已生成到 dist/aria2-windows/bin/ 目录"
echo "压缩包位置: dist/aria2-windows-x64.zip"
ls -lh dist/aria2-windows-x64.zip