//
//  STCTTSDiarizationURLManager.m
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 28.04.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "STCDRZURLManager.h"

static NSString *kDiarizationApiURL     = @"DiarizationApiURL";
static NSString *kDiarizationSessionURL = @"session";
static NSString *kDiarization           = @"v1/diarization";

@implementation STCDRZURLManager

+(NSString *)diarizationApiUrl {
    static dispatch_once_t once;
    static id apiurl;
    dispatch_once(&once, ^{
        apiurl = [NSBundle.mainBundle objectForInfoDictionaryKey:kDiarizationApiURL];
    });
    return apiurl;
}

+(NSString *)diarizationStartSession {
    static dispatch_once_t once_diarizationStartSession;
    static id diarizationStartSession;
    dispatch_once(&once_diarizationStartSession, ^{
        diarizationStartSession = [NSString stringWithFormat:@"%@/%@", STCDRZURLManager.diarizationApiUrl, kDiarizationSessionURL];
    });
    return diarizationStartSession;
}

+(NSString *)diarizationCloseSession {
    static dispatch_once_t once_diarizationCloseSession;
    static id diarizationCloseSession;
    dispatch_once(&once_diarizationCloseSession, ^{
        diarizationCloseSession = STCDRZURLManager.diarizationStartSession;
    });
    return diarizationCloseSession;
}

+(NSString *)diarization {
    static dispatch_once_t once_diarizationObtain;
    static id diarizationObtain;
    dispatch_once(&once_diarizationObtain, ^{
        diarizationObtain = [NSString stringWithFormat:@"%@/%@",STCDRZURLManager.diarizationApiUrl, kDiarization];
    });
    return diarizationObtain;
}

@end
