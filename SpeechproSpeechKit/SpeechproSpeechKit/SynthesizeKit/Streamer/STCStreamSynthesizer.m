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

@property (nonatomic) BOOL isPlaying;
@property (atomic) BOOL isCanceling;

@property (nonatomic) PlayCompletionHandler playCompletionHandler;

@end

@interface STCStreamSynthesizer(Private)

-(void)startStreamWithURL:(NSString *)urlString;

@end

@interface STCStreamSynthesizer(ConfigureSocket)

-(void)configureOnData;
-(void)configureOnConnect;
-(void)configureOnDisconnect;

@end

@implementation STCStreamSynthesizer

- (void)cancelWithCompletionHandler:(SynthesisCompletionHandler)synthesizeDoneBlock {
    __weak typeof(self) weakself = self;
    self.synthesizeDoneBlock = nil;
    self.socket.onDisconnect = ^(NSError * _Nullable error) {
        if( synthesizeDoneBlock ) {
            synthesizeDoneBlock(nil);
        }
        
        
    };
    self.isCanceling = YES;
    [self.socket disconnect];
    self.socket.onData = nil;
    self.socket.onConnect = nil;
    [self.audioplayer stop];
}

- (void)playText:(NSString *)text
       withVoice:(NSString *)voice
withCompletionHandler:(SynthesisCompletionHandler)synthesizeDoneBlock
    playCompletionHandle:(PlayCompletionHandler)playCompletionHandler{
    self.isCanceling = NO;
    self.isPlaying = NO;
    self.isPlayerInitialized = NO;
    self.playCompletionHandler = playCompletionHandler;
    self.startingText = text;
    self.synthesizeKit = [[STCSynthesizeKitImplementation alloc] init];
    self.synthesizeDoneBlock = synthesizeDoneBlock;
    [self.synthesizeKit streamWithVoice:voice
withCompletionHandler:^(NSError *error, NSObject *result) {
        if (self.isCanceling) {
            return ;
        }
    
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
    
    if (self.isCanceling) {
        return;
    }
    NSLog(@"startStreamWithURL");

    self.socket = [[STCWebSocket alloc] initWithURL:[NSURL URLWithString:urlString] protocols:@[@"chat",@"superchat"] queue: dispatch_queue_create("stream.synthesizer.socket.queue", NULL)];
    
    [self configureOnData];
    [self configureOnConnect];
    [self configureOnDisconnect];
    
    [self.socket connect];
}

@end

@implementation STCStreamSynthesizer(ConfigureSocket)

-(void)configureOnData {
    __weak typeof(self) weakself = self;
    self.socket.onData = ^(NSData * _Nullable data) {
        if (weakself.isCanceling) {
            return ;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!weakself.isPlayerInitialized) {
                weakself.isPlayerInitialized = YES;
                [weakself.audioplayer start];
            }
        });
        
        [weakself.audioplayer putAudioData:(short*)data.bytes withSize:(int)data.length];
    };
}

-(void)configureOnConnect {
    __weak typeof(self) weakself = self;
    self.socket.onConnect = ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakself setUpPlayer];
            [weakself.socket writeString:weakself.startingText];
            NSLog(@"%@",weakself.startingText);
    //        [weakself.synthesizeKit closeStream:^(NSError *error, NSString *stream) {
    //
    //        }];
        });
    };

}


-(void)setUpPlayer {
    self.audioplayer = [[STCAudioPlayer alloc] initWithSampleRate:22050];
    self.audioplayer.delegate = self;
}

-(void)configureOnDisconnect {
    __weak typeof(self) weakself = self;
    self.socket.onDisconnect = ^(NSError * _Nullable error) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (weakself) {
                    weakself.synthesizeDoneBlock(error);
                }
            });
        }
    };
}

-(void)playEnded: (STCAudioPlayer*)player {
    if(self.playCompletionHandler != nil){
        self.playCompletionHandler();
        self.playCompletionHandler = nil;
    }
}

@end
