//
//  VLOPoi.h
//  Volo
//
//  Created by Seongmin on 8/10/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "VLOLocationCoordinate.h"

@interface VLOPoi : MTLModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) VLOLocationCoordinate *coordinates;

@end
