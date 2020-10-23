FROM gitpod/workspace-full
                    
USER gitpod

ENV ANDROID_TOOLS=6858069
# TODO: Bump to API Level: 29
# The current compileSdkVersion from build.gradle
ENV ANDROID_VERSION=28
ENV ANDROID_ARCHITECTURE=x86_64
ENV GOO=google_apis_playstore
# Depends on compileSdkVersion
ENV ANDROID_BUILD_TOOLS_VERSION=28.0.3
ENV ANDROID_HOME=${HOME}/android-sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV FLUTTER_CHANNEL=stable
ENV FLUTTER_HOME=${HOME}/flutter
ENV PATH=${FLUTTER_HOME}/bin:${ANDROID_HOME}:${ANDROID_HOME}/emulator:${ANDROID_HOME}/cmdline-tools/tools/bin:${ANDROID_HOME}/platform-tools:/home/gitpod/.sdkman/candidates/java/current/bin:${PATH}


RUN sudo rm /etc/apt/sources.list.d/llvm.list && sudo apt-get update && \
    sudo apt-get install -y \
    libglu1-mesa \
    uidmap && \
    sudo rm -rf /var/lib/apt/lists/* && \
    export identifier=`curl -s 'https://api.sdkman.io/2/candidates/java/Linux64/versions/list?installed' | grep -m 1 -o '12.*.open' | awk '{print $NF}'` && \
    bash -c ". $HOME/.sdkman/bin/sdkman-init.sh \
             && echo $identifier && yes "y" | sdk install java $identifier"

## Android SDK
# WORKDIR is already in /home/gitpod (from the gitpod/workspace-full image)
RUN mkdir -p $ANDROID_SDK_ROOT && \
    mkdir -p $HOME/.android && \
    echo '### User Sources for Android SDK Manager ###' > $HOME/.android/repositories.cfg && \
    curl -o android-sdk-tools.zip -q "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_TOOLS}_latest.zip" && \
    unzip -q android-sdk-tools.zip -d ${ANDROID_SDK_ROOT} && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/tools && \
    find ${ANDROID_SDK_ROOT}/cmdline-tools -maxdepth 1 -mindepth 1 -not -name tools \
        -exec mv '{}' ${ANDROID_SDK_ROOT}/cmdline-tools/tools \; && \
    sdkmanager --update && yes | sdkmanager --licenses > /dev/null && \
    sdkmanager "tools" > /dev/null && \
    sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" > /dev/null && \
    sdkmanager "platforms;android-$ANDROID_VERSION" && \
    sdkmanager "platforms;android-29" && \
    sdkmanager "platform-tools" && \
    sdkmanager "extras;android;m2repository" && \
    sdkmanager "system-images;android-$ANDROID_VERSION;$GOO;$ANDROID_ARCHITECTURE" && \
    sdkmanager "emulator"

RUN echo "Fixing for accepting the Android Licenses as per https://stackoverflow.com/a/63426536 / flutter/flutter#62924" && \
    cd ${ANDROID_SDK_ROOT}/tools && \
    mkdir jaxb_lib && \
    curl -s https://repo1.maven.org/maven2/javax/activation/activation/1.1.1/activation-1.1.1.jar -o jaxb_lib/activation.jar && \
    curl -s https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.3/jaxb-impl-2.3.3.jar -o jaxb_lib/jaxb-impl.jar && \
    curl -s https://repo1.maven.org/maven2/com/sun/istack/istack-commons-runtime/3.0.11/istack-commons-runtime-3.0.11.jar -o jaxb_lib/istack-commons-runtime.jar && \
    curl -s https://repo1.maven.org/maven2/org/glassfish/jaxb/jaxb-xjc/2.3.3/jaxb-xjc-2.3.3.jar -o jaxb_lib/jaxb-xjc.jar && \
    curl -s https://repo1.maven.org/maven2/org/glassfish/jaxb/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar -o jaxb_lib/jaxb-core.jar && \
    curl -s https://repo1.maven.org/maven2/org/glassfish/jaxb/jaxb-jxc/2.3.3/jaxb-jxc-2.3.3.jar -o jaxb_lib/jaxb-jxc.jar && \
    curl -s https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar -o jaxb_lib/jaxb-api.jar && \
    sed -ie 's%^CLASSPATH=.*%\0:$APP_HOME/jaxb_lib/*%' bin/sdkmanager bin/avdmanager && \
    echo "Fixed!" 

## Flutter 
RUN git clone --depth 1 --branch ${FLUTTER_CHANNEL} https://github.com/flutter/flutter.git && \
    flutter config --no-analytics && \
    flutter precache && \
    yes "y" | flutter doctor --android-licenses && \
    flutter doctor

## Fix while we can't add our own plugin
ENV GITPOD_STATIC_PLUGINS=/var/vsix
USER root
RUN mkdir -p /var/vsix/ && cd /var/vsix/ && \
    wget -q https://github.com/Dart-Code/Dart-Code/releases/download/v3.12.2/dart-code-3.12.2.vsix && \
    wget -q https://github.com/Dart-Code/Flutter/releases/download/v3.12.2/flutter-3.12.2.vsix && \
    chown gitpod:gitpod -R /var/vsix/
USER gitpod
