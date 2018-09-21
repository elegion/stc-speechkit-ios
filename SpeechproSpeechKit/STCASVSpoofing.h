//
//  STCASVSpoofing.h
//  Pods-STCSpeechKitDemo
//
//  Created by Soloshcheva Aleksandra on 18.09.2018.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The automatic speaker verification spoofing protocol
 */

/**
 * The automatic speaker verification spoofing completion handler type defenition
 * @param error The error
 */

typedef void (^SpoofingCompletionHandler) ( NSError *error, NSDictionary *result);

@protocol STCASVSpoofing <NSObject>

/**
 * Starts recording and automatic speaker verification spoofing
 * @param handler The automatic speaker verification spoofing completion handler
 */
-(void)startWithCompletionHandler:(SpoofingCompletionHandler)handler;

/**
 * Stops automatic speaker verification spoofing
 */
-(void)stop;

@end

NS_ASSUME_NONNULL_END
