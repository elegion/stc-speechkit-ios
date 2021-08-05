//
//  AudioPlayer.m
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 22.05.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "STCAudioPlayer.h"

@implementation STCAudioPlayer
@synthesize queue;
@synthesize bufferByteSize;

void AQBufferCallback(void * inUserData,
                      AudioQueueRef inAQ,
                      AudioQueueBufferRef inBuffer) {
    STCAudioPlayer *THIS = (__bridge STCAudioPlayer *)(inUserData);
    if (THIS->isInitialized == NO) {
        return;
    }
    ssize_t res = 0;
    if(THIS->bufferByteSize > 0) {
        res = read(THIS->pip_fd[0], inBuffer->mAudioData, MIN(THIS->bufferByteSize, 4000));
    }
    if(res > 0 ){
        THIS->bufferByteSize -= res;
        inBuffer->mPacketDescriptionCount = res/2;
        inBuffer->mAudioDataByteSize = res;
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    } else {
        int bufferIndex = [THIS getIndexForBuffer: inBuffer];
        if(bufferIndex >= 0) {
            THIS->audioQueueUsed[bufferIndex] = NO;
            if(![THIS bufferHasUsed]) {
                [THIS playEnded];
            }
        }
    }
}

-(void)playEnded {
    if( self.delegate != nil) {
        [[self delegate] playEnded:self];
    }
}

-(id)init {
    return [self initWithSampleRate:22050];
}

-(id)initWithSampleRate:(int)sampleRate {
    self = [super init];
    if(self) {
        sysnLock = [[NSLock alloc]init];
        memset(&playFormat, 0, sizeof(playFormat));
        playFormat.mFormatID = kAudioFormatLinearPCM;
        playFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked ;
        playFormat.mBitsPerChannel = 16;
        playFormat.mChannelsPerFrame = 1;
        playFormat.mBytesPerPacket = playFormat.mBytesPerFrame = (playFormat.mBitsPerChannel / 8) * playFormat.mChannelsPerFrame;
        playFormat.mFramesPerPacket = 1;
        playFormat.mSampleRate = sampleRate;
        isInitialized = false;
        audioQueueIsStarted = false;
    }
    return self;
}

-(void)start {
    [sysnLock lock];
    if (isInitialized) {
        [sysnLock unlock];
        return;
    }
    isInitialized = true;
    bufferByteSize = 0;
    AudioQueueNewOutput(&playFormat, AQBufferCallback, (__bridge void *)(self), nil, nil, 0, &queue);
    for (int i=0; i<kNumberBuffers; i++) {
        AudioQueueAllocateBuffer( queue, kBufferSize, &mBuffers[i]);
        audioQueueUsed[i] = NO;
    }
    AudioQueueSetParameter( queue, kAudioQueueParam_Volume, 1.0);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
    int ret = pipe(pip_fd);
    if (ret == -1) {
        NSLog(@"create pipe failed");
    }
    [sysnLock unlock];
}

-(void)stop {
    [sysnLock lock];
    if(!isInitialized) {
        [sysnLock unlock];
        return;
    }
    isInitialized = false;
    close(pip_fd[0]);
    close(pip_fd[1]);
    AudioQueueStop(queue, false);
    if (queue){
        AudioQueueDispose(queue, true);
        queue = NULL;
    }
    [sysnLock unlock];
}

-(void)putAudioData: (short*)pcmData withSize: (int)dataSize {
    [sysnLock lock];
    if(!isInitialized) {
        [sysnLock unlock];
        return;
    }
    int bufferIndex = [self getNotUsedBufferIndex];
    if (bufferIndex >= 0) {
        AudioQueueBufferRef audioQueueBuffer = mBuffers[bufferIndex];
        memcpy(audioQueueBuffer->mAudioData, pcmData, dataSize);
        audioQueueBuffer->mAudioDataByteSize = dataSize;
        audioQueueBuffer->mPacketDescriptionCount = dataSize/2;
        AudioQueueEnqueueBuffer(queue, audioQueueBuffer, 0, NULL);
        audioQueueUsed[bufferIndex] = YES;
        if (!audioQueueIsStarted && ![self bufferHasNotUsed]) {
            audioQueueIsStarted = true;
            AudioQueueStart(queue, NULL);
        }
    } else {
        bufferByteSize += dataSize;
        if(write(pip_fd[1], pcmData, dataSize) < 0){
            NSLog(@"STCAudioPlayer: write to the pipe failed!");
        }
    }
    [sysnLock unlock];
}

-(BOOL)bufferHasUsed {
    for (int i = 0; i < kNumberBuffers; i++) {
        if (YES == audioQueueUsed[i]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)bufferHasNotUsed {
    for (int i = 0; i < kNumberBuffers; i++) {
        if (NO == audioQueueUsed[i]) {
            return YES;
        }
    }
    return NO;
}
 
-(int)getNotUsedBufferIndex {
    for (int i = 0; i < kNumberBuffers; i++) {
        if (NO == audioQueueUsed[i]) {
            return i;
        }
    }
    return -1;
}

-(int)getIndexForBuffer: (AudioQueueBufferRef) audioQueueBuffer{
    for (int i = 0; i < kNumberBuffers; i++) {
        if (audioQueueBuffer == mBuffers[i]) {
            return i;
        }
    }
    return -1;
}

@end
