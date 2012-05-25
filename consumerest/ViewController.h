//
//  ViewController.h
//  consumerest
//
//  Created by Damiano Fusco on 5/18/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    
}

@property (weak, nonatomic) IBOutlet UITextView *textFieldOutput;
@property (weak, nonatomic) IBOutlet UITextView *textFieldDebug;
@property (weak, nonatomic) IBOutlet UILabel *textHttpStatus;
@property (weak, nonatomic) IBOutlet UITextField *textFieldUser;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;

- (IBAction)btnCallService:(id)sender;
- (IBAction)btnClearCookie:(id)sender;
- (IBAction)btnBackground:(id)sender;

@end
