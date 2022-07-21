//
//  STCTTSStreamNetworkingManager.h
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 08.05.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "../../../Common/Networking/STCNetworkingManager.h"

#import "../Base/STCTTSURLManager.h"
#import "../../../Common/Category/NSString+Language.h"

/**
 * Provides working with the stream synthesize API requests
 */
@interface STCTTSStreamNetworkingManager : STCNetworkingManager

/**
 * Starts the stream transaction and provides the stream url
 * @param voice The voice for synthesis
 * @param completionHandler The synthesis completion handler
 */
-(void)streamWithVoice:(NSString *)voice
 withCompletionHandler:(CompletionHandler)completionHandler
   startSessionHandler:(void (^)(void)) startSessionHandler;

/**
 * Closes the stream transaction 
 */
-(void)closeStreamWithCompletionHandler:(CompletionHandler)completionHandler;

@end
