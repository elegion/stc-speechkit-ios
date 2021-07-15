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

void AQBufferCallback(void *                inUserData ,
                      AudioQueueRef         inAQ,
                      AudioQueueBufferRef   inBuffer) {
    STCAudioPlayer *THIS = (__bridge STCAudioPlayer *)(inUserData);
    

    ssize_t res = 0;
    
    if(THIS->isRunning) {
        
        if(THIS->bufferByteSize <= 0){
            THIS->buffersNum -= 1;
            if(THIS->buffersNum == 0) {
                [THIS playEnded];
            }
            return;
        }
        
        res = read(THIS->pip_fd[0], inBuffer->mAudioData, MIN(THIS->bufferByteSize, 4000));
        THIS->bufferByteSize -= res;
        inBuffer->mPacketDescriptionCount = res/2;

        inBuffer->mAudioDataByteSize = res;

        if(res > 0 ){
            AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
        }
    }
}

-(void) playEnded {
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
        buffersNum = 0;
        memset(&playFormat, 0, sizeof(playFormat));
        playFormat.mFormatID = kAudioFormatLinearPCM;
        playFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked ;
        playFormat.mBitsPerChannel = 16;
        playFormat.mChannelsPerFrame = 1;
        playFormat.mBytesPerPacket = playFormat.mBytesPerFrame = (playFormat.mBitsPerChannel / 8) * playFormat.mChannelsPerFrame;
        playFormat.mFramesPerPacket = 1;
        playFormat.mSampleRate = sampleRate;
        isRunning = false;
        isInitialized = false;
    }
    return self;
}

-(void)start {
    if (isInitialized) {
        return;
    }
    [sysnLock lock];
    bufferByteSize = 0;
    AudioQueueNewOutput(&playFormat, AQBufferCallback, (__bridge void *)(self), nil, nil, 0, &queue);
    for (int i=0; i<kNumberBuffers; i++) {
        buffersNum += 1;
        AudioQueueAllocateBuffer( queue, kBufferSize, &mBuffers[i]);
    }
    
    AudioQueueSetParameter( queue, kAudioQueueParam_Volume, 1.0);

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);

    isInitialized = true;
    int ret = pipe(pip_fd);
    if (ret == -1) {
        NSLog(@"create pipe failed");
    }
    [sysnLock unlock];
}

-(void)stop  {
    if(!isInitialized) {
        return;
    }
    [sysnLock lock];
    close(pip_fd[0]);
    close(pip_fd[1]);
    AudioQueueStop(queue, false);
    if (queue){
        AudioQueueDispose(queue, true);
        queue = NULL;
        isRunning = false;
    }
    isInitialized = false;
    [sysnLock unlock];
}

-(void)putAudioData:(short*)pcmData withSize:(int)dataSize{
    [sysnLock lock];
    if (buffersNum < kNumberBuffers) {
        [sysnLock unlock];
        return;
    }
    if (!isRunning) {
        memcpy(mBuffers[index]->mAudioData, pcmData, dataSize);
        mBuffers[index]->mAudioDataByteSize = dataSize;
        mBuffers[index]->mPacketDescriptionCount = dataSize/2;
        AudioQueueEnqueueBuffer(queue, mBuffers[index], 0, NULL);
        NSLog(@"fill audio queue buffer[%d]",index);
        if(index == kNumberBuffers - 1) {
            isRunning = true;
            index = 0;
            AudioQueueStart(queue, NULL);
        } else {
            index++;
        }
    } else {
        bufferByteSize += dataSize;
        if(write(pip_fd[1], pcmData, dataSize) < 0){
            NSLog(@"write to the pipe failed!");
        }
    }
    [sysnLock unlock];
}
@end
