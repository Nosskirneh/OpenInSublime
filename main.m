//
//  main.m
//  Open in Code
//
//  Created by Sertac Ozercan on 7/9/2016.
//  Copyright Sertac Ozercan 2016. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <objc/message.h>

NSString *getPathToFrontFinderWindow()
{
    // Get Finder SBApplication instance
    id finderApp = ((id (*)(id, SEL, NSString *))objc_msgSend)(objc_getClass("SBApplication"), sel_registerName("applicationWithBundleIdentifier:"), @"com.apple.Finder");
    
    // Get array of all active Finder windows
    NSArray *finderWindows = ((id (*)(id, SEL))objc_msgSend)(finderApp, sel_registerName("FinderWindows"));
    
    // Get the target Finder window
    // TODO: handle multi montitor support somehow
    id desiredFinderWindow = [finderWindows lastObject];
    id desiredFinderWindowTarget = ((id (*)(id, SEL))objc_msgSend)(desiredFinderWindow, sel_registerName("target"));
    desiredFinderWindowTarget = ((id (*)(id, SEL))objc_msgSend)(desiredFinderWindowTarget, sel_registerName("get"));
    
    // Get the path of the target finder window's working directory
    NSString *finderCWD = ((id (*)(id, SEL))objc_msgSend)(desiredFinderWindowTarget, sel_registerName("URL"));
    finderCWD = [[NSURL URLWithString:finderCWD] path];
    
    // Handle non-directory being focused
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:finderCWD isDirectory:&isDir];
    if (!isDir)
    {
        finderCWD = [finderCWD stringByDeletingLastPathComponent];
    }
    
    return finderCWD;
}

int main(int argc, char *argv[])
{
    id pool = [[NSAutoreleasePool alloc] init];
    
    NSString *path = getPathToFrontFinderWindow();
    if (path != nil)
    {
        [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:@[@"-n", @"-b" ,@"com.microsoft.VSCode", @"--args", path]] waitUntilExit];
    }
    
    [pool release];
    
    return 0;
}
