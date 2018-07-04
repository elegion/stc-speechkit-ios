//
//  STCRecognizer.m
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 28.05.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "STCRecognizer.h"
#import "OPCSCaptureVoice2BufferManager.h"
#import "STCRecognizeKitImplementation.h"

@interface STCRecognizer()

@property (nonatomic) RecognizingCompletionHandler recognizeCompletionHandler;
@property (nonatomic) OPCSCaptureVoice2BufferManager *voiceManager;
@property (nonatomic) STCRecognizeKitImplementation *recognizeKit;
@property (nonatomic) NSString *package;

@end

@implementation STCRecognizer

-(id)init {
    self = [super init];
    if (self) {
        
        self.voiceManager = [[OPCSCaptureVoice2BufferManager alloc] initWithSampleRate:8000];
        __weak typeof(self) weakself = self;
        self.voiceManager.loadDataBlock = ^(NSData *data, NSError *error) {
            if (error) {
                weakself.recognizeCompletionHandler(error, nil);
                return ;
            }
            
            if (weakself.package) {
                [weakself.recognizeKit recognize:data
                                     withPackage:weakself.package
                           withCompletionHandler:^(NSError *error, NSDictionary *result) {
                               weakself.recognizeCompletionHandler(error, result[@"text"]);
                           }];
            } else {
                [weakself.recognizeKit recognize:data
                           withCompletionHandler:^(NSError *error, NSDictionary *result) {
                               weakself.recognizeCompletionHandler(error, result[@"text"]);
                           }];
            }
        };
        
        self.recognizeKit = [[STCRecognizeKitImplementation alloc] init];
    }
    return self;
}

-(void)startWithCompletionHandler:(RecognizingCompletionHandler)completionHandler {
    self.recognizeCompletionHandler = completionHandler;
    [self.voiceManager record];
}

-(void)startWithPackage:(NSString *)package withCompletionHandler:(RecognizingCompletionHandler)completionHandler {
    self.package = package;
    [self startWithCompletionHandler:completionHandler];
}

-(void)stop {
    [self.voiceManager stop];
}

@end
