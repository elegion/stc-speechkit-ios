//
//  STCStreamSynthesizer.m
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 08.05.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "STCStreamSynthesizer.h"
#import "STCSynthesizeKitImplementation.h"
#import "STCWebSocket.h"
#import "STCAudioPlayer.h"
#import "NSString+Language.h"

@interface STCStreamSynthesizer()<NSStreamDelegate>

@property (nonatomic) STCWebSocket   *socket;
@property (nonatomic) NSString       *startingText;

@property (nonatomic) STCAudioPlayer *audioplayer;
@property (nonatomic) BOOL isPlayerInitialized;

@property (nonatomic) SynthesisCompletionHandler synthesizeDoneBlock;
@property (nonatomic) STCSynthesizeKitImplementation *synthesizeKit;

@end

@interface STCStreamSynthesizer(Private)

-(void)startStreamWithURL:(NSString *)urlString;

@end

@implementation STCStreamSynthesizer

- (void)cancel {
    self.startingText = nil;
    self.isPlayerInitialized = NO;
    [self.audioplayer stopPlay];
    self.audioplayer = nil;
  //  [self.socket disconnect];
    
    __weak typeof(self) weakself = self;
    [self.synthesizeKit closeStream:^(NSError *error, NSString *stream) {
        if (error) {
            weakself.synthesizeKit = nil;
            weakself.synthesizeDoneBlock(error);
            weakself.synthesizeDoneBlock = nil;
            return;
        }
    }];
}

- (void)playText:(NSString *)text
       withVoice:(NSString *)voice
withCompletionHandler:(SynthesisCompletionHandler)synthesizeDoneBlock{
    self.isPlayerInitialized = NO;
    self.startingText = text;
    self.synthesizeKit = [[STCSynthesizeKitImplementation alloc] init];
    self.synthesizeDoneBlock = synthesizeDoneBlock;
    [self.synthesizeKit streamWithVoice:voice
withCompletionHandler:^(NSError *error, NSObject *result) {
      if (error) {
          synthesizeDoneBlock(error);
          return ;
      }
      
      [self startStreamWithURL:(NSString *)result];
      synthesizeDoneBlock(nil);
  }];
}

- (void)addTextToPlay:(NSString *)text {
    if (self.socket) {
        [self.socket writeString:text];
    }
}

@end

@implementation STCStreamSynthesizer(Private)

-(void)startStreamWithURL:(NSString *)urlString {
    self.audioplayer = [[STCAudioPlayer alloc] initWithSampleRate:22050];
    
    __weak typeof(self) weakself = self;
    self.socket = [[STCWebSocket alloc] initWithURL:[NSURL URLWithString:urlString] protocols:@[@"chat",@"superchat"]];
    self.socket.onData = ^(NSData * _Nullable data) {
        if (!weakself.isPlayerInitialized) {
            [weakself.audioplayer startPlayWithBufferByteSize:(int)data.length];
            weakself.isPlayerInitialized = YES;
        }
        [weakself.audioplayer putAudioData:data.bytes withSize:(int)data.length];
    };
    self.socket.onConnect = ^{
        [weakself.socket writeString:weakself.startingText];
        [weakself.synthesizeKit closeStream:^(NSError *error, NSString *stream) {
            if (error) {
                weakself.synthesizeDoneBlock(error);
                return;                
            }
        }];
        
    };
    self.socket.onDisconnect = ^(NSError * _Nullable error) {
        if (weakself.synthesizeDoneBlock) {
            weakself.synthesizeDoneBlock(error);
        }
    };

    [self.socket connect];
}

@end
