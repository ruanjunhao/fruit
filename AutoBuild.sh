#!/bin/sh

#  AutoBuild.sh
#  CHSP
#
#  Created by  on 12-7-2.
#  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.

#set -e  # break the shell if any error occurs.

baseSDK=iphoneos8.1

##target name
targetName="wallet"

##project name
projectName="wallet"

##===============企业证书(InHouse)========bundleid:com.unionpay.chsp.inhouse========

code_sign_identity_inhouse="iPhone Distribution: China UnionPay Co., Ltd."
provisioning_profile_inhouse=~/Library/MobileDevice/Provisioning\ Profiles/953ad94a-a4a0-47fd-babf-c8365214577b.mobileprovision

##===============发布证书(Appstore)=======bundleid:com.unionpay.chsp================

code_sign_identity_appstore="iPhone Distribution: China Unionpay Co.,Ltd. (P3V7X37F97)"
provisioning_profile_appstore=~/Library/MobileDevice/Provisioning\ Profiles/3613b77a-75df-430c-bdcc-c4eff8a2f647.mobileprovision

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
xcodebuild clean -configuration $build_mode

#编译工程
xcodebuild ARCHS="armv7 arm64" \
ONLY_ACTIVE_ARCH=NO \
GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS="UP_BUILD_FOR_DEVELOP UP_ENABLE_LOG" \
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
ipaDir="$ipa_path/CHSP_develop.ipa"

/usr/bin/xcrun -sdk $baseSDK PackageApplication -v "$appFile" -o "$ipaDir" --sign "$code_sign_identity_inhouse" --embed "$provisioning_profile_inhouse"

if [ $? -ne 0 ]
then
echo "package develop inhouse error!"
exit 0
fi

#生成md5文件
md5File="$ipa_path/MD5_develop.txt"

md5 $ipaDir
ls -l $ipaDir
md5 -q  $ipaDir &>$md5File

#生成dSYM文件
dSYMFile="build/${build_mode}-iphoneos/${projectName}.app.dSYM"
/usr/bin/zip ${ipa_path}/${projectName}.app.dSYM.develop.zip -r ${dSYMFile}

#--------------测试室环境企业证书版本-------------------------
#设置编译模式
build_mode=Inhouse

#clean工程
xcodebuild clean -configuration $build_mode

#编译工程
xcodebuild ARCHS="armv7 arm64" \
    ONLY_ACTIVE_ARCH=NO \
    GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS="UP_BUILD_FOR_TEST UP_ENABLE_LOG" \
    -project ${projectName}.xcodeproj \
    -target $targetName \
    -configuration $build_mode \
    -sdk $baseSDK \
    build

if [ $? -ne 0 ]
then
echo "build test inhouse error!"
exit 0
fi

#打包工程
appFile="${project_path}/build/${build_mode}-iphoneos/${projectName}.app"
ipaDir="$ipa_path/CHSP_test.ipa"

/usr/bin/xcrun -sdk $baseSDK PackageApplication -v "$appFile" -o "$ipaDir" --sign "$code_sign_identity_inhouse" --embed "$provisioning_profile_inhouse"

if [ $? -ne 0 ]
then
echo "package test inhouse error!"
exit 0
fi

#生成md5文件
md5File="$ipa_path/MD5_test.txt"

md5 $ipaDir
ls -l $ipaDir
md5 -q  $ipaDir &>$md5File

#生成dSYM文件
dSYMFile="build/${build_mode}-iphoneos/${projectName}.app.dSYM"
/usr/bin/zip ${ipa_path}/${projectName}.app.dSYM.test.zip -r ${dSYMFile}

#--------------生产环境企业证书版本-------------------------
#设置编译模式
build_mode=Inhouse

#clean工程
xcodebuild clean -configuration $build_mode

#编译工程
xcodebuild ARCHS="armv7 arm64" \
ONLY_ACTIVE_ARCH=NO \
GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS="UP_BUILD_FOR_RELEASE UP_ENABLE_LOG" \
-project ${projectName}.xcodeproj \
-target $targetName \
-configuration $build_mode \
-sdk $baseSDK \
build

if [ $? -ne 0 ]
then
echo "build release inhouse error!"
exit 0
fi

#打包工程
appFile="${project_path}/build/${build_mode}-iphoneos/${projectName}.app"
ipaDir="$ipa_path/CHSP_release.ipa"

/usr/bin/xcrun -sdk $baseSDK PackageApplication -v "$appFile" -o "$ipaDir" --sign "$code_sign_identity_inhouse" --embed "$provisioning_profile_inhouse"

if [ $? -ne 0 ]
then
echo "package release inhouse error!"
exit 0
fi

#生成md5文件
md5File="$ipa_path/MD5_release.txt"

md5 $ipaDir
ls -l $ipaDir
md5 -q  $ipaDir &>$md5File

#生成dSYM文件
dSYMFile="build/${build_mode}-iphoneos/${projectName}.app.dSYM"
/usr/bin/zip ${ipa_path}/${projectName}.app.dSYM.release.zip -r ${dSYMFile}

#-------------------生产环境发布证书版本------------------------
#设置编译模式
build_mode=Distribution

#clean工程
xcodebuild clean -configuration $build_mode

#编译工程
xcodebuild ARCHS="armv7 arm64" \
ONLY_ACTIVE_ARCH=NO \
GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS="UP_BUILD_FOR_RELEASE" \
-project ${projectName}.xcodeproj \
-target $targetName \
-configuration $build_mode \
-sdk $baseSDK \
build

if [ $? -ne 0 ]
then
echo "build release distribution error!"
exit 0
fi

#打包工程
appFile="${project_path}/build/${build_mode}-iphoneos/${projectName}.app"
ipaDir="$ipa_path/CHSP.ipa"

/usr/bin/xcrun -sdk $baseSDK PackageApplication -v "$appFile" -o "$ipaDir" --sign "$code_sign_identity_appstore" --embed "$provisioning_profile_appstore"

if [ $? -ne 0 ]
then
echo "package release distribution error!"
exit 0
fi

#生成md5文件
md5File="$ipa_path/MD5.txt"

md5 $ipaDir
ls -l $ipaDir
md5 -q  $ipaDir &>$md5File

#生成dSYM文件
dSYMFile="build/${build_mode}-iphoneos/${projectName}.app.dSYM"
/usr/bin/zip ${ipa_path}/${projectName}.app.dSYM.appstore.zip -r ${dSYMFile}

#打包
cd "$ipa_path"
ipaTar="ipa.tar"
tar -cvf ipa.tar *.ipa *.txt *.zip
rm *.ipa *.txt *.zip

#---------------------------------------------检查是否成功---------------------------------------------
if [ -f "${ipaTar}" ]
then
echo "\n"
echo "\n"
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo +++++++++++       如果你看到该信息，则表明ipa包生成成功          ++++++++++++
echo +++++++++++     BY 中国银联.移动支付应用开发室.客户端开发小组    ++++++++++++
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "\n"
echo "\n"
fi