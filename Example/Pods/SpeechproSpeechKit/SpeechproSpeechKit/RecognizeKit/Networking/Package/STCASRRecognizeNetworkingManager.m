//
//  STCASRRecognizeNetworkingManager.m
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 28.05.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "STCASRRecognizeNetworkingManager.h"
#import "STCASRURLManager.h"

@interface STCASRRecognizeNetworkingManager()

@property (nonatomic) NSString *voiceBase64;
@property (nonatomic) NSString *package;

@end

@implementation STCASRRecognizeNetworkingManager

-(NSString *)method {
    return @"POST";
}

-(NSDictionary *)body {
    return @{ @"audio":@{ @"data":self.voiceBase64,
                          @"mime":@"audio/x-wav" },
         @"package_id": self.package};
}

-(NSString *)request {
    return STCASRURLManager.asrRecognize;
}

-(void)recognize:(NSData *)voice
     withPackege:(NSString *)package
withCompletionHandler:(CompletionBlock)completionHandler {
    self.voiceBase64 = [voice base64EncodedStringWithOptions:0];
    self.package = package;
    
    [self obtainWithCompletionHandler:completionHandler];
}

@end
