//
//  STCASRRecognizeNetworkingManager.h
//  SpeechKit
//
//  Created by Soloshcheva Aleksandra on 28.05.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "STCASRNetworkingManager.h"

@interface STCASRRecognizeNetworkingManager : STCASRNetworkingManager

     -(void)recognize:(NSData *)voice
          withPackege:(NSString *)package
withCompletionHandler:(CompletionBlock)completionHandler;

@end
