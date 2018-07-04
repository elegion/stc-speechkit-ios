//
//  STCTTSNetworkingManager.m
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 28.04.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "STCTTSNetworkingManager.h"

#import "STCTTSURLManager.h"
@implementation STCTTSNetworkingManager

-(NSString *)sessionRequest {
    return STCTTSURLManager.ttsStartSession;
}

@end
