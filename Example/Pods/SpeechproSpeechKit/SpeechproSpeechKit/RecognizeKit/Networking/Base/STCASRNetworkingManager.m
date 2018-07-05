//
//  STCASRNetworkingManager.m
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 04.05.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "STCASRNetworkingManager.h"

#import "STCASRURLManager.h"

@implementation STCASRNetworkingManager

-(NSString *)sessionRequest {
    return STCASRURLManager.asrStartSession;
}

@end
