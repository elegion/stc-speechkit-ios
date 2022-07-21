//
//  STCASRStreamNetworkingManager.h
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 04.06.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "../../../Common/Networking/STCNetworkingManager.h"

/**
 * Provides working with the stream recognition API requests
 */
@interface STCASRStreamNetworkingManager : STCNetworkingManager

/**
 * Starts the stream transaction and provides the stream url
 * @param completionHandler The recognition completion handler
 */
-(void)startStreamWithCompletionHandler:(CompletionHandler)completionHandler;

/**
 * Starts the stream transaction with the specific package and provides the stream url
 * @param package The specific package
 * @param completionHandler The recognition completion handler
 */
-(void)startStreamWithPackage:(NSString *)package
        withCompletionHandler:(CompletionHandler)completionHandler
          startSessionHandler:(void (^)(void)) startSessionHandler;

/**
 * Closes the stream transaction and provides the finished result
 * @param completionHandler The recognition completion handler
 */
-(void)closeStreamWithCompletionHandler:(CompletionHandler)completionHandler
                            transformId:(NSString *)transformId;

@end
