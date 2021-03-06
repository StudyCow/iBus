//
//  FollowingStationListController.h
//  iBus-iPhone
//
//  Created by yanghua on 6/10/13.
//  Copyright (c) 2013 yanghua. All rights reserved.
//

#import "BaseController.h"

@interface FavoriteListController : BaseController
<
UITableViewDataSource,
UITableViewDelegate
>

@property (nonatomic,retain) NSMutableArray         *dataSourceForLine;
@property (nonatomic,retain) NSMutableArray         *dataSourceForStation;
@property (nonatomic,retain) UITableView            *tableView;

@end
