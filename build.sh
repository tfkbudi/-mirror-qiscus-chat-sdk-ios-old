#!/bin/sh
say -v veena Hello ashari, Have you prayed?
echo "\033[31m Sudahkah anda sholat 🕌 (y/n)? \033[0m\n"
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ;then
	say -v veena Alhamdulillah
    echo "\033[32m Bismillahirrahmanirrahim, no error ... \033[0m\n"
else
	say -v fred Astagfirullahaladzim
    echo "\033[31m 😡 Astagfirullahaladzim sholat dulu sana \033[0m\n"
    exit
fi

WORKSPACE=QiscusCore
FRAMEWORK=QiscusCore
PUBLISH=Cocoapods
BUILD=build
FRAMEWORK_NAME_WITH_EXT=$FRAMEWORK.framework
DSYM_NAME_WITH_EXT=$FRAMEWORK_NAME_WITH_EXT.dSYM
ZIP_DIR=zip

IOS_ARCHIVE_DIR=Release-iphoneos-archive
IOS_ARCHIVE_FRAMEWORK_PATH=$BUILD/$IOS_ARCHIVE_DIR/Products/Library/Frameworks/$FRAMEWORK_NAME_WITH_EXT
IOS_ARCHIVE_DSYM_PATH=$BUILD/$IOS_ARCHIVE_DIR/dSYMs
IOS_SIM_DIR=Release-iphonesimulator
IOS_UNIVERSAL_DIR=Release-universal-iOS

say -v veena Cleaning up
echo "\033[31m Cleaning up after old builds \033[0m\n"
rm -Rf $BUILD
say -v veena Installing dependencies
echo "\033[37m Installing dependencies"
if ! [ -x "$(command -v xcpretty)" ]; then
  echo " Installing xcpretty....."
  gem install xcpretty
fi

# iOS
say -v veena Installing... cocoapods
echo " Installing cocoapods \033[0m\n"
pod install

echo "\033[32m BUILDING FOR iOS \033[0m\n"
echo "\033[35m ▹ Building for simulator (Release) \033[0m\n"
say -v veena Building for simulator, it will take a long time, - John Johnson said, - 'First, solve the problem. Then, write the code.'
xcodebuild build -workspace $WORKSPACE.xcworkspace -scheme $FRAMEWORK -sdk iphonesimulator SYMROOT=$(PWD)/$BUILD OTHER_CFLAGS="-fembed-bitcode" BITCODE_GENERATION_MODE=bitcode | xcpretty
echo "\033[35m \n ▹ Building for device (Archive) \033[0m\n"
say -v veena Building for device, it will take a long time, – Kent Beck said, - 'Make it work, make it right, make it fast.' 
xcodebuild archive -workspace $WORKSPACE.xcworkspace -scheme $FRAMEWORK -sdk iphoneos -archivePath $BUILD/Release-iphoneos.xcarchive OTHER_CFLAGS="-fembed-bitcode" BITCODE_GENERATION_MODE=bitcode | xcpretty

say -v veena Copying framework
echo "\033[32m Copying framework files \033[0m\n"
mv $BUILD/Release-iphoneos.xcarchive $BUILD/$IOS_ARCHIVE_DIR
echo "\033[32m  ▹ Create Universal directory \033[0m\n"
mkdir -p $BUILD/$IOS_UNIVERSAL_DIR
echo "\033[32m  ▹ Create Universal frameworks \033[0m\n"
cp -RL $IOS_ARCHIVE_FRAMEWORK_PATH $BUILD/$IOS_UNIVERSAL_DIR/$FRAMEWORK_NAME_WITH_EXT
echo "\033[32m  ▹ Create Universal dSYMs \033[0m\n"
cp -RL $IOS_ARCHIVE_DSYM_PATH/$DSYM_NAME_WITH_EXT $BUILD/$IOS_UNIVERSAL_DIR/$DSYM_NAME_WITH_EXT
cp -RL $BUILD/$IOS_SIM_DIR/$FRAMEWORK_NAME_WITH_EXT/Modules/$FRAMEWORK.swiftmodule/* $BUILD/$IOS_UNIVERSAL_DIR/$FRAMEWORK_NAME_WITH_EXT/Modules/$FRAMEWORK.swiftmodule
say -v veena lipo-ing the iOS frameworks together into universal framework
echo "\033[35m 🤝 lipo'ing the iOS frameworks together into universal framework \033[0m\n"
lipo -create $IOS_ARCHIVE_FRAMEWORK_PATH/$FRAMEWORK $BUILD/$IOS_SIM_DIR/$FRAMEWORK_NAME_WITH_EXT/$FRAMEWORK -output $BUILD/$IOS_UNIVERSAL_DIR/$FRAMEWORK_NAME_WITH_EXT/$FRAMEWORK
echo "\033[35m 🤝 lipo'ing the iOS dSYMs together into a universal dSYM \033[0m\n"
DSYM_PATH=$DSYM_NAME_WITH_EXT/Contents/Resources/DWARF/$FRAMEWORK
lipo -create $IOS_ARCHIVE_DSYM_PATH/$DSYM_PATH $BUILD/$IOS_SIM_DIR/$DSYM_PATH  -output $BUILD/$IOS_UNIVERSAL_DIR/$DSYM_PATH

# Rename and zip
say -v veena Copying iOS files into zip directory
echo "\033[32m Copying iOS files into zip directory \033[0m\n"
mkdir $ZIP_DIR
cp -RL LICENSE $ZIP_DIR
rm -rf $ZIP_DIR/$FRAMEWORK_NAME_WITH_EXT
rm -rf $ZIP_DIR/$DSYM_NAME_WITH_EXT
cp -RL $BUILD/$IOS_UNIVERSAL_DIR/$FRAMEWORK_NAME_WITH_EXT $ZIP_DIR/$FRAMEWORK_NAME_WITH_EXT
cp -RL $BUILD/$IOS_UNIVERSAL_DIR/$DSYM_NAME_WITH_EXT $ZIP_DIR/$DSYM_NAME_WITH_EXT
cd $ZIP_DIR
say -v veena creating universal frameworks
zip -r QiscusCore.zip LICENSE $FRAMEWORK_NAME_WITH_EXT $DSYM_NAME_WITH_EXT
echo "\033[32m Zipped resulting frameworks and dSYMs to $ZIP_DIR/QiscusCore.zip \033[0m\n"
rm -rf $ZIP_DIR/$FRAMEWORK_NAME_WITH_EXT
rm -rf $ZIP_DIR/$DSYM_NAME_WITH_EXT
echo "\033[35m Finish creating universal frameworks \n Alhamdulillah 🎊 🎊 🎁 \033[0m\n"

# checking arhitechture
say -v veena Checking framework arhitechture
echo "\033[32m \n Checking framework arhitechture, should be 4 arhitechture include arm, i386 and x86_64 \033[0m\n"
cd $FRAMEWORK_NAME_WITH_EXT
file $FRAMEWORK

# copy framework, readme, etc to publish directory
echo "\033[35m \n Copying framework and dSYMs to cocoapods directory \033[0m\n"
cd ../../ 
rm -rf $PUBLISH/$FRAMEWORK_NAME_WITH_EXT
rm -rf $PUBLISH/$DSYM_NAME_WITH_EXT
cp -RL $BUILD/$IOS_UNIVERSAL_DIR/$FRAMEWORK_NAME_WITH_EXT $PUBLISH/$FRAMEWORK_NAME_WITH_EXT
cp -RL $BUILD/$IOS_UNIVERSAL_DIR/$DSYM_NAME_WITH_EXT $PUBLISH/$DSYM_NAME_WITH_EXT
cp -RL LICENSE $PUBLISH
cp -RL README.md $PUBLISH
git add .
git commit -m "finish build for cocoapod"

say -v veena Do you want to publish to github?
echo -n "\033[31m Mau sekalian di publish ke github (y/n)? \033[0m\n"
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ;then
	say -v veena Aye aye captain
    echo "\033[32m \n Siap bos ku ... \033[0m\n"
else
	say -v veena Up to you, see you next build
    echo "\033[31m Ya sudah \033[0m\n"
    exit
fi
cd $PUBLISH
say -v veena copy new framework to publish directory
echo "\033[35m Finish copy new framework to publish directory \033[0m\n"
git add .
git commit -m "update new build"
git push origin master
echo "\033[35m Finish update cocoapod repo \n Alhamdulillah 🎉 🎉 🎉 \033[0m\n"
say -v veena Horree 🎉, - see you next build - Ashari
rm -rf $BUILD