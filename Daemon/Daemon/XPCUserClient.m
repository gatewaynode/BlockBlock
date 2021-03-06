//
//  file: XPCUserClient.m
//  project: BlockBlock (launch daemon)
//  description: talk to the user, via XPC
//
//  created by Patrick Wardle
//  copyright (c) 2018 Objective-See. All rights reserved.
//

#import "Rules.h"
#import "Event.h"
#import "Events.h"
#import "consts.h"
#import "logging.h"
#import "XPCListener.h"
#import "XPCUserClient.h"

/* GLOBALS */

//xpc connection
extern XPCListener* xpcListener;

@implementation XPCUserClient

//deliver alert to user
// note: this is synchronous so that errors can be detected
-(BOOL)deliverEvent:(Event*)event
{
    //flag
    __block BOOL xpcError = NO;
    
    //dbg msg
    logMsg(LOG_DEBUG, @"invoking user XPC method: 'alertShow'");
    
    //sanity check
    // no client connection?
    if(nil == xpcListener.client)
    {
        //dbg msg
        logMsg(LOG_DEBUG, @"no client is connected, alert will not be delivered");
        
        //set error
        xpcError = YES;
        
        //bail
        goto bail;
    }

    //send to user (client) to display
    [[xpcListener.client synchronousRemoteObjectProxyWithErrorHandler:^(NSError * proxyError)
    {
        //set error
        xpcError = YES;
        
        //err msg
        logMsg(LOG_ERR, [NSString stringWithFormat:@"failed to invoke USER XPC method: 'alertShow' (error: %@)", proxyError]);

    }] alertShow:[event toAlert]];
    
bail:

    return !xpcError;
}

/*

//inform user rules have changed
// note: rules have been serialized
-(void)rulesChanged:(NSDictionary*)rules
{
    //dbg msg
    logMsg(LOG_DEBUG, [NSString stringWithFormat:@"invoking user XPC method, '%s'", __PRETTY_FUNCTION__]);
    
    //no client?
    // no need to do anything...
    if(nil == xpcListener.mainApp)
    {
        //bail
        goto bail;
    }
    
    //send to user (login item) to display
    [[xpcListener.mainApp remoteObjectProxyWithErrorHandler:^(NSError * proxyError)
    {
          //err msg
          logMsg(LOG_ERR, [NSString stringWithFormat:@"failed to execute 'rulesChanged' method on launch daemon (error: %@)", proxyError]);
          
    }] rulesChanged:rules];
    
bail:
    
    return;
}

*/


@end
