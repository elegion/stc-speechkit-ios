//
//  BaseViewController.m
//  SpeechKitDemo
//
//  Created by Soloshcheva Aleksandra on 13.06.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,weak) IBOutlet UIButton *playStopButton;

@end

@implementation BaseViewController 

-(void)showActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
    });
}

-(void)hideActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
    });
}

-(BOOL)isPlayMode {
    return !self.playStopButton.isSelected;
}

-(BOOL)isStopMode {
    return self.playStopButton.isSelected;
}

-(void)configureButtonAsPlay {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playStopButton.selected = NO;
    });
}
-(void)configureButtonAsStop {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playStopButton.selected = YES;
    });
}

-(void)showError:(NSError *)error{
    NSLog(@"%@",error);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
