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

#warning TODO docs
#define kNumberBuffers 3

@interface STCAudioPlayer : NSObject
{
    AudioQueueRef                   queue;
    AudioQueueBufferRef             mBuffers[kNumberBuffers];
    AudioStreamBasicDescription     playFormat;
    int                             index;
@public
    Boolean                         isRunning;
    Boolean                         isInitialized;
    int                             bufferByteSize;
    int                             pip_fd[2];
    UInt32                          numPacketsToRead;
}
@property AudioQueueRef queue;

-(id)init;
-(id)initWithSampleRate:(int)sampleRate;
-(void)startPlayWithBufferByteSize:(int)byteSize;
-(void)stopPlay;
-(void)putAudioData:(short*)pcmData withSize:(int)dataSize;

@end
