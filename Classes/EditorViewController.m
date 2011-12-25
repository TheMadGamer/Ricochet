//
//  EditorViewController.m
//  Grenades
//
//  Created by Anthony Lobay on 12/22/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import "EditorViewController.h"

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

#import "AlertPrompt.h"
#import "NSString+Extensions.h"

@implementation EditorViewController

@synthesize delegate=delegate_;

- (void)viewDidLoad {
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    [testObject setObject:@"bar" forKey:@"foo"];
    [testObject save];
}

- (IBAction)dismiss:(id)sender
{
    [self.view removeFromSuperview];
}

- (IBAction)save:(id)sender 
{
    AlertPrompt *alert = [[[AlertPrompt alloc] initWithTitle:@"Save File?" message:@"Enter file name" delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"Save"] autorelease];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) 
    {
        AlertPrompt *prompt = (AlertPrompt *)alertView;
        if ([prompt.enteredText hasNonWhitespace]) 
        {
            [self.delegate saveLevel:prompt.enteredText];
        }
    }
}

- (IBAction)potTool:(id)sender { 
    [self.delegate startPotTool];
    [self dismiss:nil]; 

}
- (IBAction)hedgeTool:(id)sender { [self dismiss:nil]; }
- (IBAction)gopherTool:(id)sender { [self dismiss:nil]; }
- (IBAction)exitEditMode:(id)sender 
{ 
    [self.delegate endEdit];
    [self dismiss:nil];
}

- (IBAction)moveTool:(id)sender  { [self dismiss:nil]; }
- (IBAction)deleteTool:(id)sender  { [self dismiss:nil]; }

@end
