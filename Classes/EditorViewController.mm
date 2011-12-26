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
#import "NotificationTags.h"
#import "NSString+Extensions.h"

@implementation EditorViewController

@synthesize delegate = delegate_;
@synthesize yRotation = yRotation_;
@synthesize rotationText = rotationText_;
@synthesize xExtentsText = xExtentsText_;
@synthesize zExtentsText = zExtentsText_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.yRotation = 0;
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedLevels
                                                                object:nil];
        }
    }
}

- (IBAction)potTool:(id)sender { 
    [self.delegate startPotTool];
    [self dismiss:nil]; 

}
- (IBAction)hedgeTool:(id)sender 
{ 
    btVector3 extents([self.xExtentsText.text floatValue], 10, [self.zExtentsText.text floatValue]);
    [self.delegate startHedgeToolWithExtents:extents yRotation:[self.rotationText.text floatValue]];
    [self dismiss:nil]; 
}

- (IBAction)gopherTool:(id)sender 
{ 
     [self.delegate startGopherTool];
    [self dismiss:nil]; 
}
- (IBAction)exitEditMode:(id)sender 
{ 
    [self.delegate endEdit];
    [self dismiss:nil];
}

- (IBAction)moveTool:(id)sender  { [self dismiss:nil]; }
- (IBAction)deleteTool:(id)sender  { [self dismiss:nil]; }

@end
