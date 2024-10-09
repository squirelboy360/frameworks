#import <Foundation/Foundation.h>
#import "DirectNative.h"

@implementation DirectNative

static void *sharedBuffer = NULL;
static const int BUFFER_SIZE = 1024 * 1024; // 1MB buffer

+ (void *)initialize {
    if (sharedBuffer == NULL) {
        sharedBuffer = malloc(BUFFER_SIZE);
    }
    return sharedBuffer;
}

+ (void)render:(NSData *)data {
    memcpy(sharedBuffer, data.bytes, data.length);
    [[DNBridge sharedInstance] nativeRender:data];
}

@end