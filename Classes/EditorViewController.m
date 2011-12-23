//
//  EditorViewController.m
//  Grenades
//
//  Created by Anthony Lobay on 12/22/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import "EditorViewController.h"

@implementation EditorViewController

- (IBAction)dismiss:(id)sender
{
    [self.view removeFromSuperview];
}

- (IBAction)save:(id)sender 
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Not implemented" 
                                                     message:nil 
                                                    delegate:nil 
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

- (IBAction)potTool:(id)sender { [self dismiss:nil]; }
- (IBAction)hedgeTool:(id)sender { [self dismiss:nil]; }
- (IBAction)gopherTool:(id)sender { [self dismiss:nil]; }
- (IBAction)exitEditMode:(id)sender { [self dismiss:nil]; }
- (IBAction)moveTool:(id)sender  { [self dismiss:nil]; }
- (IBAction)deleteTool:(id)sender  { [self dismiss:nil]; }

@end
