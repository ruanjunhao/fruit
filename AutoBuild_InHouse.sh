#!/bin/sh

#  AutoBuild.sh
#  CHSP
#
#  Created by  on 12-7-2.
#  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.

#set -e  # break the shell if any error occurs.

baseSDK=iphoneos8.3

##target name
targetName="wallet"

##project name
projectName="wallet"

##===============企业证书(InHouse)========bundleid:com.unionpay.chsp.inhouse========

code_sign_identity_inhouse="iPhone Distribution: China UnionPay Co., Ltd."
provisioning_profile_inhouse=~/Library/MobileDevice/Provisioning\ Profiles/953ad94a-a4a0-47fd-babf-c8365214577b.mobileprovision

##=========================================

#根目录
root_path=$PWD

#工程所在目录
project_path="${root_path}"

#ipa所在目录
ipa_path="${root_path}/IPA"

#创建目录
mkdir -p "$project_path"
mkdir -p "$ipa_path"

#打开CHSP工程目录
cd "$project_path"

#--------------开发环境企业证书版本-------------------------
#设置编译模式
build_mode=Inhouse

#clean工程
#xcodebuild clean -configuration $build_mode

#编译工程
xcodebuild ARCHS=armv7 \
ONLY_ACTIVE_ARCH=NO \
GCC_PREPROCESSOR_DEFINITIONS="UP_BUILD_FOR_RELEASE UP_ENABLE_LOG" \
-project ${projectName}.xcodeproj \
-target $targetName \
-configuration $build_mode \
-sdk $baseSDK \
build

if [ $? -ne 0 ]
then
echo "build develop inhouse error!"
exit 0
fi

#打包工程
appFile="${project_path}/build/${build_mode}-iphoneos/${projectName}.app"
ipaDir="$ipa_path/CHSP_release.ipa"

/usr/bin/xcrun -sdk $baseSDK PackageApplication -v "$appFile" -o "$ipaDir" --sign "$code_sign_identity_inhouse" --embed "$provisioning_profile_inhouse"

if [ $? -ne 0 ]
then
echo "package develop inhouse error!"
exit 0
fi

#生成md5文件
md5File="$ipa_path/MD5_release.txt"

md5 $ipaDir
ls -l $ipaDir
md5 -q  $ipaDir &>$md5File

#生成dSYM文件
dSYMFile="build/${build_mode}-iphoneos/${projectName}.app.dSYM"
/usr/bin/zip ${ipa_path}/${projectName}.app.dSYM.develop.zip -r ${dSYMFile}

