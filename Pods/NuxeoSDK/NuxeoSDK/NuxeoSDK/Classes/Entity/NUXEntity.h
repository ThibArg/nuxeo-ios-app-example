//
//  NUXEntity.h
//  NuxeoSDK
//
//  Created by Matthias ROUBEROL on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NUXEntityPersistable <NSObject>

@required
-(NSString *)entityId;

@end

@interface NUXEntity : NSObject
{
    
}

-(id)initWithEntityType: (NSString *)entityType;

@property (nonatomic, retain, readonly) NSString * entityType;

@end
