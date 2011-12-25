//
//  AlertPrompt.h
//  Grenades
//
//  Created by Anthony Lobay on 12/24/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface AlertPrompt : UIAlertView 

@property (nonatomic, retain) UITextField *textField;
@property (readonly) NSString *enteredText;

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
      okButtonTitle:(NSString *)okButtonTitle;

@end
