//
//  AudioPlayer.h
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 22.05.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#include <unistd.h>
#import "STCSynthesizing.h"

#define kNumberBuffers 3
#define kBufferSize 100000

@class STCAudioPlayer;

@protocol STCAudioPlayerDelegate <NSObject>

-(void)playEnded: (STCAudioPlayer*)player;

@end

@interface STCAudioPlayer : NSObject
{
    AudioQueueRef                   queue;
    AudioQueueBufferRef             mBuffers[kNumberBuffers];
    AudioStreamBasicDescription     playFormat;
    NSLock *sysnLock;
    BOOL audioQueueUsed[kNumberBuffers];
    BOOL audioQueueIsStarted;
@public
    Boolean                         isInitialized;
    int                             pip_fd[2];
    UInt32                          numPacketsToRead;
}
@property int bufferByteSize;
@property AudioQueueRef queue;
@property (weak) id <STCAudioPlayerDelegate> delegate;

-(id)init;
-(id)initWithSampleRate:(int)sampleRate;
-(void)start;
-(void)stop;
-(void)putAudioData:(short*)pcmData withSize:(int)dataSize;

@end
