//
//  UIApplication+FrankAutomation.m
//  Frank
//
//  Created by Ondrej Hanslik on 9/15/13.
//
//

#import "UIApplication+FrankAutomation.h"
#import <objc/runtime.h>

static NSMutableArray* FEX_registeredWindows;

@interface UIWindow (FEX_WindowRegister)

@end

@implementation UIWindow (FEX_WindowRegister)

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(initWithFrame:)),
                                   class_getInstanceMethod(self, @selector(FEX_initWithFrame:)));
    
    method_exchangeImplementations(class_getInstanceMethod(self, NSSelectorFromString(@"dealloc")),
                                   class_getInstanceMethod(self, @selector(FEX_dealloc)));
}

- (id)FEX_initWithFrame:(CGRect)frame {
    id instance = [self FEX_initWithFrame:frame];
    
    if (FEX_registeredWindows == nil) {
        CFArrayCallBacks callbacks;
        callbacks.version = 0;
        callbacks.retain = NULL;
        callbacks.release = NULL;
        callbacks.copyDescription = CFCopyDescription;
        callbacks.equal = CFEqual;
        
        CFMutableArrayRef arrayWithWeakReferences = CFArrayCreateMutable(CFAllocatorGetDefault(), 0, &callbacks);
        FEX_registeredWindows = (NSMutableArray*) arrayWithWeakReferences;
    }
    
    [FEX_registeredWindows addObject:instance];
    
    return instance;
}

- (void)FEX_dealloc {
    [FEX_registeredWindows removeObject:self];
    
    [self FEX_dealloc];
}

@end

@interface FEXKeyboardObserver : NSObject

@property (nonatomic, assign, readwrite) BOOL keyboardVisible;
@property (nonatomic, assign, readwrite) NSUInteger keyboardAnimationCounter;

@end

static FEXKeyboardObserver* FEX_keyboardObserver;

@implementation FEXKeyboardObserver

@synthesize keyboardVisible = _keyboardVisible;
@synthesize keyboardAnimationCounter = _keyboardAnimationCounter;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FEX_keyboardObserver = [[FEXKeyboardObserver alloc] init];
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:FEX_keyboardObserver selector:@selector(onKeyboadNotification:) name:UIKeyboardWillShowNotification object:nil];
        [notificationCenter addObserver:FEX_keyboardObserver selector:@selector(onKeyboadNotification:) name:UIKeyboardDidShowNotification object:nil];
        [notificationCenter addObserver:FEX_keyboardObserver selector:@selector(onKeyboadNotification:) name:UIKeyboardWillHideNotification object:nil];
        [notificationCenter addObserver:FEX_keyboardObserver selector:@selector(onKeyboadNotification:) name:UIKeyboardDidHideNotification object:nil];
        [notificationCenter addObserver:FEX_keyboardObserver selector:@selector(onKeyboadNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [notificationCenter addObserver:FEX_keyboardObserver selector:@selector(onKeyboadNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
    });
}

- (BOOL)isKeyboardAnimating {
    return (self.keyboardAnimationCounter > 0);
}

- (void)onKeyboadNotification:(NSNotification*)notification {
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        self.keyboardVisible = YES;
        self.keyboardAnimationCounter++;
    }
    else if ([notification.name isEqualToString:UIKeyboardDidShowNotification]) {
        self.keyboardAnimationCounter--;
    }
    else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        self.keyboardAnimationCounter++;
    }
    else if ([notification.name isEqualToString:UIKeyboardDidHideNotification]) {
        self.keyboardVisible = NO;
        self.keyboardAnimationCounter--;
    }
    else if ([notification.name isEqualToString:UIKeyboardWillChangeFrameNotification]) {
        self.keyboardAnimationCounter++;
    }
    else if ([notification.name isEqualToString:UIKeyboardDidChangeFrameNotification]) {
        self.keyboardAnimationCounter--;
    }
}

@end

@implementation UIApplication (FrankAutomation)

- (NSArray*)FEX_windows {
    NSMutableArray* windows = [[[self windows] mutableCopy] autorelease];
    
    for (UIWindow* window in FEX_registeredWindows) {
        if (![windows containsObject:window]) {
            [windows addObject:window];
        }
    }
    
    NSComparisonResult (^levelComparator)(id, id) = ^NSComparisonResult(id obj1, id obj2) {
        UIWindow* window1 = obj1;
        UIWindow* window2 = obj2;
        
        if (window1.windowLevel < window2.windowLevel) {
            return NSOrderedAscending;
        }
        else if (window1.windowLevel < window2.windowLevel) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    };
    
    [windows sortWithOptions:NSSortStable
             usingComparator:levelComparator];
    
    return [[windows copy] autorelease];
}

- (BOOL)FEX_isKeyboardVisible {
    return [FEX_keyboardObserver keyboardVisible];
}

- (BOOL)FEX_isKeyboardAnimating {
    return [FEX_keyboardObserver isKeyboardAnimating];
}

@end

