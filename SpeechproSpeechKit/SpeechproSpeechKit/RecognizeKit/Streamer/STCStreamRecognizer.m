//
//  STCStreamRecognizer.m
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 04.06.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "STCStreamRecognizer.h"
#import "OPCSCaptureVoice2BufferManager.h"
#import "STCRecognizeKitImplementation.h"
#import "STCWebSocket.h"

@interface STCStreamRecognizer()

@property (nonatomic) PeakPowerHandler peakPowerHandler;
@property (nonatomic) RecognizingCompletionHandler recognizeCompletionHandler;
@property (nonatomic) RecognizingCompletionHandler recognizeStopCompletionHandler;
@property (nonatomic) OPCSCaptureVoice2BufferManager *voiceManager;
@property (nonatomic) STCRecognizeKitImplementation *recognizeKit;
@property (nonatomic) STCWebSocket *socket;
@property (nonatomic) NSDictionary *package;

@property (nonatomic) BOOL isSocketConnected;
@property (nonatomic) NSMutableData *voiceBuffer;

@end

@interface STCStreamRecognizer(Configure)

-(void)configureVoiceManager;
-(void)configureRecognizeKit:(void (^)(void)) startSessionHandler;

@end

@interface STCStreamRecognizer(Private)

-(void)startSocketWithURL:(NSString *)urlString ;
-(void)closeSocket;

-(void)handleResult:(NSDictionary *)result
           withError:(NSError *)error;

-(void)handleData:(NSData *)data;

@end

@implementation STCStreamRecognizer

-(id)init {
    self = [super init];
    if (self) {
        self.peakPowerHandler = nil;
        [self configureVoiceManager];
        self.isSocketConnected = NO;
        self.voiceBuffer = [[NSMutableData alloc] init];
    }
    return self;
}

-(void)startWithCompletionHandler:(RecognizingCompletionHandler)completionHandler {
    self.package = nil;
    [self configureRecognizeKit: nil];
    self.recognizeCompletionHandler = completionHandler;
}

-(void)startWithPackage:(NSDictionary *)package withCompletionHandler:(RecognizingCompletionHandler)completionHandler startSessionHandler:(void (^)(void)) startSessionHandler{
    self.package = package;
    [self configureRecognizeKit: startSessionHandler];
    self.recognizeCompletionHandler = completionHandler;
}

- (void)setUpPeakPowerHandler: (PeakPowerHandler)peakPowerHandler {
    self.peakPowerHandler = peakPowerHandler;
}

- (void)stop {
    [self.voiceManager stop];
    [self closeSocket];
}


-(void)stopWithCompletionHandler:(RecognizingCompletionHandler)completionHandler {
    self.recognizeCompletionHandler = nil;
    self.recognizeStopCompletionHandler = completionHandler;
    [self.voiceManager stop];
    [self closeSocket];
}

@end

@implementation STCStreamRecognizer(Private)

-(void)startSocketWithURL:(NSString *)urlString {
    self.isSocketConnected = NO;
    self.socket = [[STCWebSocket alloc] initWithURL:[NSURL URLWithString:urlString] protocols:@[@"chat",@"superchat"]];
    __weak typeof(self) weakself = self;
    self.socket.onText = ^(NSString * _Nullable text) {
        if( weakself.recognizeCompletionHandler ){
            weakself.recognizeCompletionHandler(nil, text);
        }
    };
    self.socket.onConnect = ^{
        weakself.isSocketConnected = YES;
    };
    self.socket.onDisconnect = ^(NSError * _Nullable error) {
        if (error) {
            if (weakself.recognizeCompletionHandler) {
                weakself.recognizeCompletionHandler(error, nil);
            }
            [weakself closeSocket];
            return ;
        }
        if (weakself.recognizeCompletionHandler) {
            weakself.recognizeCompletionHandler(nil, nil);
        }
        
    };
    
    [self.socket connect];
}

-(void)closeSocket {
    [self.recognizeKit closeStreamWithCompletionHandler:^(NSError *error, NSDictionary *result) {
        if (self.recognizeCompletionHandler) {
            self.recognizeCompletionHandler(error,  result[@"text"]);
        }
        if (self.recognizeStopCompletionHandler) {
            self.recognizeStopCompletionHandler(error,  result[@"text"]);
            self.recognizeStopCompletionHandler = nil;
        }
       // [self.socket disconnect];
    }];
}

-(void)handleResult:(NSDictionary *)result
           withError:(NSError *)error {
    if (error) {
        if(self.recognizeCompletionHandler) {
            self.recognizeCompletionHandler(error, nil);
        }
        
        return ;
    }
    [self.voiceManager record];
    [self startSocketWithURL:result[@"url"]];
}

-(void)handleData:(NSData *)data {
    if (self.isSocketConnected) {
        if (self.voiceBuffer.length > 0) {
            [self.voiceBuffer appendData:data];
            [self.socket writeData:self.voiceBuffer];
            self.voiceBuffer = nil;
        } else {
            [self.socket writeData:data];
        }
    } else {
        [self.voiceBuffer appendData:data];
    }
}

@end

@implementation STCStreamRecognizer(Configure)

-(void)configureVoiceManager {
    __weak typeof(self) weakself = self;
    self.voiceManager = [[OPCSCaptureVoice2BufferManager alloc] initWithSampleRate:16000 withMode:OPCSCaptureVoiceModePortion];
    self.voiceManager.loadDataBlock = ^(NSData *data, NSError *error, Float32 peakPower) {
        if (error) {
            if(weakself.recognizeCompletionHandler){
                weakself.recognizeCompletionHandler(error, nil);
            }
            return;
        }
        if(weakself.peakPowerHandler != nil){
            weakself.peakPowerHandler(peakPower);
        }
        
        [weakself handleData:data];
    };
}

-(void)configureRecognizeKit:(void (^)(void)) startSessionHandler {
    __weak typeof(self) weakself = self;
    self.recognizeKit = [[STCRecognizeKitImplementation alloc] init];
    if (self.package!=nil) {
        [self.recognizeKit streamWithPackage:self.package[@"model_id"]
                       withCompletionHandler:^(NSError *error, NSDictionary *result) {
                           [weakself handleResult:result withError:error];
        } startSessionHandler: startSessionHandler];
    } else {
        [self.recognizeKit streamWithCompletionHandler:^(NSError *error, NSDictionary *result) {
            [weakself handleResult:result withError:error];
        }];
    }
}

@end
