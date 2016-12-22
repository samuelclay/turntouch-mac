//
//  TTModeNestDelegateManager.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 12/22/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NestThermostatManager.h"
#import "NestStructureManager.h"

@interface TTModeNestDelegateManager : NSObject <NestStructureManagerDelegate, NestThermostatManagerDelegate> {
    
}

@property (nonatomic) NSMutableArray *delegates;


@end
