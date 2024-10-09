#include <jni.h>
#include <string.h>
#include <stdlib.h>
#include <android/log.h>

#define LOG_TAG "DirectNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define BUFFER_SIZE 1024 * 1024 // 1MB buffer

static unsigned char* sharedBuffer = NULL;
static JavaVM *jvm;
static jclass bridgeClass;
static jmethodID renderMethod;

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    jvm = vm;
    JNIEnv *env;
    if ((*jvm)->GetEnv(jvm, (void **)&env, JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    jclass localBridgeClass = (*env)->FindClass(env, "com/example/directnative/DNBridge");
    bridgeClass = (*env)->NewGlobalRef(env, localBridgeClass);
    renderMethod = (*env)->GetMethodID(env, bridgeClass, "nativeRender", "(Ljava/lang/String;)V");

    return JNI_VERSION_1_6;
}

JNIEXPORT void* JNICALL Java_com_example_directnative_DNBridge_initialize(JNIEnv *env, jobject thiz) {
    if (sharedBuffer == NULL) {
        sharedBuffer = (unsigned char*)malloc(BUFFER_SIZE);
    }
    return sharedBuffer;
}

JNIEXPORT void JNICALL Java_com_example_directnative_DNBridge_render(JNIEnv *env, jobject thiz, jint messageSize) {
    jstring jmessage = (*env)->NewStringUTF(env, (char*)sharedBuffer);
    (*env)->CallVoidMethod(env, bridgeClass, renderMethod, jmessage);
    (*env)->DeleteLocalRef(env, jmessage);
}