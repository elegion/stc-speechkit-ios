//
//  ViewController.m
//  SpeechKitDemo
//
//  Created by Soloshcheva Aleksandra on 17.04.2018.
//  Copyright © 2018 Speech Tehnology Center. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import <SpeechproSpeechKit/SpeechproSpeechKit.h>

#import "SynthesizeViewController.h"

#import "AuthDataModel.h"
#import "LanguageModel.h"
#import "VoiceModel.h"

@interface SynthesizeViewController ()<UITableViewDataSource>

@property (nonatomic) id<STCSynthesizeKit> synthesizeKit;
@property (nonatomic) STCSynthesizer   *synthesizer;

@property (nonatomic) STCStreamSynthesizer *streamSynthesizer;

@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic,weak) IBOutlet UITableView *voiceTableView;
@property (nonatomic,weak) IBOutlet UITextView  *textView;
@property (nonatomic,weak) IBOutlet UISwitch *isSocketsSwitcher;

@property (nonatomic) NSMutableArray<VoiceModel *> *voices;

@end

@interface SynthesizeViewController (Configure)

-(void)configureLanguages;
-(void)configureVoiceForLanguage:(NSString *)language;

@end

@interface SynthesizeViewController (Private)

-(NSString *)voice;

-(void)continueAsOnline;
-(void)continueAsSocket;

@end

@implementation SynthesizeViewController

#pragma mark - Lifecyrcle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.synthesizeKit = STCSpeechKit.sharedInstance.synthesizeKit;
    self.synthesizer   = STCSpeechKit.sharedInstance.synthesizer;
    [self configureLanguages];

    self.streamSynthesizer = STCSpeechKit.sharedInstance.streamSynthesizer;
}

#pragma mark - IBAction's

-(IBAction)onSynthesizeButtonTouchUpInside:(id)sender {    
    if (self.isSocketsSwitcher.isOn) {
        [self continueAsSocket];
    } else {
        [self continueAsOnline];
    }
}

-(IBAction)onLanguageSegmentedControlValueChanged:(id)sender {
    NSString *lang = [self.segmentedControl titleForSegmentAtIndex:self.segmentedControl.selectedSegmentIndex];
    [self configureVoiceForLanguage:lang];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.voices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kVoiceTableCellIdentifier = @"kVoiceTableCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVoiceTableCellIdentifier];

    if (cell) {
        VoiceModel *voice = [self.voices objectAtIndex:indexPath.row];
        cell.textLabel.text = voice.name;
        cell.imageView.image = [UIImage imageNamed:(voice.isMale ? @"male" : @"female")];
    } else {
        return [[UITableViewCell alloc] init];
    }
  
    return cell;
}

@end

@implementation SynthesizeViewController (Configure)

-(void)configureLanguages {
    [self.synthesizeKit obtainLanguagesWithCompletionHandler:^(NSError *error, NSArray<NSDictionary *> *result) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.segmentedControl removeAllSegments];
                for (int i = 0; i < result.count; i++) {
                    LanguageModel *language = [[LanguageModel alloc] initWithDictionary:result[i]];
                    [self.segmentedControl insertSegmentWithTitle:language.name atIndex:i animated:YES];
                }
                
                [self.segmentedControl setSelectedSegmentIndex:0];
                
                 LanguageModel *firstLanguage = [[LanguageModel alloc] initWithDictionary:result[0]];
                [self configureVoiceForLanguage:firstLanguage.name];
            });
        }
    }];
}

-(void)configureVoiceForLanguage:(NSString *)language {
    [self.synthesizeKit obtainVoicesForLanguage:language
                          withCompletionHandler:^(NSError *error, NSArray<NSDictionary *> *result) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.voices = [[NSMutableArray alloc] initWithCapacity:result.count];
                for (int i = 0; i < result.count; i++) {
                    VoiceModel *voice = [[VoiceModel alloc] initWithDictionary:result[i]];
                    [self.voices addObject:voice];
                }
                [self.voiceTableView reloadData];
            });
        }
    }];
}

@end

@implementation SynthesizeViewController (Private)

-(void)continueAsOnline {
    [self.synthesizer playText:self.textView.text
                     withVoice:self.voice withCompletionHandler:^(NSError *error) {
                         if (error) {
                             [self showError:error];
                         }
                     } ];
}

-(void)continueAsSocket {
    if (self.streamSynthesizer) {
        self.streamSynthesizer = [[STCStreamSynthesizer alloc] init];
        [self.streamSynthesizer playText:self.textView.text withVoice:self.voice
                   withCompletionHandler:^(NSError *error) {
                       if(error) {
                           [self showError:error];
                       }
                   }];
    }
}

-(NSString *)voice {
    UITableViewCell *cell = [self.voiceTableView cellForRowAtIndexPath:[self.voiceTableView indexPathForSelectedRow]];
    return cell.textLabel.text ? cell.textLabel.text : @"Alexander";
}

@end
