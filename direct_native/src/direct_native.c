#include <string.h>
#include <stdlib.h>

#ifdef __ANDROID__
#include <jni.h>
#include <android/log.h>
#define LOG_TAG "DirectNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#else
#include <objc/runtime.h>
#include <objc/message.h>
#define LOGI(...)
#endif

#define BUFFER_SIZE 1024 * 1024 // 1MB buffer

static unsigned char* sharedBuffer = NULL;

void* initialize() {
    if (sharedBuffer == NULL) {
        sharedBuffer = (unsigned char*)malloc(BUFFER_SIZE);
    }
    return sharedBuffer;
}

#ifdef __ANDROID__
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

void notifyNative(int messageSize) {
    JNIEnv *env;
    (*jvm)->AttachCurrentThread(jvm, &env, NULL);

    jstring jmessage = (*env)->NewStringUTF(env, (char*)sharedBuffer);
    (*env)->CallVoidMethod(env, bridgeClass, renderMethod, jmessage);

    (*env)->DeleteLocalRef(env, jmessage);
    (*jvm)->DetachCurrentThread(jvm);
}

#else // iOS

static Class bridgeClass;
static SEL renderSelector;

__attribute__((constructor))
static void initialize_ios() {
    bridgeClass = objc_getClass("DNBridge");
    renderSelector = sel_registerName("nativeRender:");
}

void notifyNative(int messageSize) {
    id bridge = ((id (*)(Class, SEL))objc_msgSend)(bridgeClass, sel_registerName("alloc"));
    bridge = ((id (*)(id, SEL))objc_msgSend)(bridge, sel_registerName("init"));
    
    id nsString = ((id (*)(Class, SEL, const char *))objc_msgSend)(objc_getClass("NSString"), sel_registerName("stringWithUTF8String:"), (char*)sharedBuffer);
    
    ((void (*)(id, SEL, id))objc_msgSend)(bridge, renderSelector, nsString);
}

#endif
