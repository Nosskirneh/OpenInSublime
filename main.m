//
//  main.m
//  Open in Code
//
//  Created by Sertac Ozercan on 7/9/2016.
//  Copyright Sertac Ozercan 2016. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SBObject : NSObject
- (SBObject *)target;
- (SBObject *)get;
- (NSString *)URL;
@end

@interface SBApplication : SBObject
+ (instancetype)applicationWithBundleIdentifier:(NSString *)bundleIdentifier;
@end

@interface _AMFinderApplication : SBApplication
- (id)FinderWindows;
@end

NSString *getPathToFrontFinderWindow() {
    // Get Finder SBApplication instance
    _AMFinderApplication *finderApp = (_AMFinderApplication *)[SBApplication applicationWithBundleIdentifier:@"com.apple.Finder"];

    // Get array of all active Finder windows
    NSArray *finderWindows = finderApp.FinderWindows;

    // Get the target Finder window
    // TODO: handle multi montitor support somehow
    SBObject *desiredFinderWindow = [finderWindows lastObject];

    // Get the path of the target finder window's working directory
    NSString *finderCWD = desiredFinderWindow.target.get.URL;
    finderCWD = [[NSURL URLWithString:finderCWD] path];

    // Handle non-directory being focused
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:finderCWD isDirectory:&isDir];
    if (!isDir)
        finderCWD = [finderCWD stringByDeletingLastPathComponent];

    return finderCWD;
}

int main(int argc, char *argv[]) {
    id pool = [[NSAutoreleasePool alloc] init];

    NSString *path = getPathToFrontFinderWindow();
    if (path != nil)
        [[NSTask launchedTaskWithLaunchPath:@"/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" arguments:@[path]] waitUntilExit];

    [pool release];

    return 0;
}
