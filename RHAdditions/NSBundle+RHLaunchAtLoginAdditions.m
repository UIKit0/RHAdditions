//
//  NSBundle+RHLaunchAtLoginAdditions.m
//
//  Created by Richard Heard on 4/07/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSBundle+RHLaunchAtLoginAdditions.h"

@implementation NSBundle (RHLaunchAtLoginAdditions)

-(BOOL)launchAtLogin{
    return RHLaunchAtLoginEnabledForBundleIdentifier(self.bundleIdentifier);
}

-(BOOL)setLaunchAtLogin:(BOOL)enabled{
    return RHLaunchAtLoginSetEnabledForBundleIdentifier(self.bundleIdentifier, enabled);
}

@end

extern BOOL RHLaunchAtLoginEnabledForBundleIdentifier(NSString *bundleIdentifier){
    if (!bundleIdentifier) return NO;
    
    BOOL enabled = NO;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //See: rdar://17951732 ER: Need a way to query a given a given domains SMLoginItemSetEnabled() state given that SMCopyAllJobDictionaries is deprecated in 10.10.
    CFArrayRef jobs = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
#pragma clang diagnostic pop

    if (!jobs) return NO;
    
    for (CFIndex i = 0; i < CFArrayGetCount(jobs); i++) {
        NSDictionary *job = CFArrayGetValueAtIndex(jobs, i);
        if ([bundleIdentifier isEqualToString:[job objectForKey:@"Label"]]){
            enabled = [[job objectForKey:@"OnDemand"] boolValue];
            break;
        }
    }
    
    CFRelease(jobs);
    
    return enabled;
}

extern BOOL RHLaunchAtLoginSetEnabledForBundleIdentifier(NSString *bundleIdentifier, BOOL enabled){
    if (!bundleIdentifier) return NO;
    return SMLoginItemSetEnabled((__bridge CFStringRef)bundleIdentifier, enabled);
}

//include an implementation in this file so we don't have to use -load_all for this category to be included in a static lib
@interface RHFixCategoryBugClassNSBRHLALA : NSObject @end @implementation RHFixCategoryBugClassNSBRHLALA @end

