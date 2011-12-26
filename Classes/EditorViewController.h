//
//  EditorViewController.h
//  Grenades
//
//  Created by Anthony Lobay on 12/22/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GopherEditProtocol.h"

@interface EditorViewController : UIViewController <
    UIAlertViewDelegate,
    UITextFieldDelegate>

- (IBAction)dismiss:(id)sender;
- (IBAction)save:(id)sender;

- (IBAction)potTool:(id)sender;
- (IBAction)hedgeTool:(id)sender;
- (IBAction)gopherTool:(id)sender;

- (IBAction)exitEditMode:(id)sender;
- (IBAction)moveTool:(id)sender;
- (IBAction)deleteTool:(id)sender;

@property (nonatomic, assign) id<GopherEditProtocol> delegate;
@property (nonatomic, assign) float yRotation;
@property (nonatomic, assign) IBOutlet UITextField *rotationText;
@property (nonatomic, assign) IBOutlet UITextField *xExtentsText;
@property (nonatomic, assign) IBOutlet UITextField *zExtentsText;

@end
