//
//  AlertPrompt.m
//  Grenades
//
//  Created by Anthony Lobay on 12/24/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import "AlertPrompt.h"

@implementation AlertPrompt

@synthesize textField = textField_;
@synthesize enteredText = enteredText_;

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
           delegate:(id)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
      okButtonTitle:(NSString *)okayButtonTitle
{
    
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 32.0, 260.0, 25.0)]; 
        [theTextField setBackgroundColor:[UIColor whiteColor]]; 
        [self addSubview:theTextField];
        self.textField = theTextField;
        [theTextField release];
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 20.0); 
        [self setTransform:translate];
    }
    return self;
}

- (void)show
{
    [self.textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText
{
    return self.textField.text;
}

- (void)dealloc
{
    [textField_ release];
    [super dealloc];
}
@end
