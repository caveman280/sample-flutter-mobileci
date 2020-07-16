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
    bash -c ". /home/gitpod/.sdkman/bin/sdkman-init.sh \
             && export identifier=\"$(sdk ls java | grep -m 1 -o ' 15.*.open ' | awk '{print $NF}')\" \
             && echo \"$identifier\" && sdk install java $identifier"

## Android SDK
# WORKDIR is already in /home/gitpod (from the gitpod/workspace-full image)
RUN mkdir -p $ANDROID_SDK_ROOT && \
    mkdir -p $HOME/.android && \
    echo '### User Sources for Android SDK Manager ###' > $HOME/.android/.repositories.cfg && \
    curl -o android-sdk-tools.zip -q "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_TOOLS}_latest.zip" && \
    unzip -q android-sdk-tools.zip -d ${ANDROID_SDK_ROOT} && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/tools && \
    find ${ANDROID_SDK_ROOT}/cmdline-tools -maxdepth 1 -mindepth 1 -not -name tools \
        -exec mv '{}' ${ANDROID_SDK_ROOT}/cmdline-tools/tools \; && \
    sdkmanager --update && yes | sdkmanager --licenses > /dev/null && \
    sdkmanager "tools" > /dev/null && \
    sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" > /dev/null && \
    sdkmanager "platforms;android-$ANDROID_VERSION" && \
    sdkmanager "platform-tools" && \
    sdkmanager "extras;android;m2repository" && \
    sdkmanager "system-images;android-$ANDROID_VERSION;$GOO;$ANDROID_ARCHITECTURE" && \
    sdkmanager "emulator"

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
    wget https://github.com/Dart-Code/Dart-Code/releases/download/v3.12.2/dart-code-3.12.2.vsix && \
    wget https://github.com/Dart-Code/Flutter/releases/download/v3.12.2/flutter-3.12.2.vsix && \
    chown gitpod:gitpod -R /var/vsix/
USER gitpod
