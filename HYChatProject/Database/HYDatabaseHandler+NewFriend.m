//
//  HYDatabaseHandler+NewFriend.m
//  HYChatProject
//
//  Created by erpapa on 16/5/11.
//  Copyright © 2016年 erpapa. All rights reserved.
//

#import "HYDatabaseHandler+HY.h"
#import "HYLoginInfo.h"
#import "HYNewFriendModel.h"

@implementation HYDatabaseHandler(NewFriend)

- (BOOL)insertFriend:(HYNewFriendModel *)friendModel
{
    __block BOOL result = YES;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db insertFriend:friendModel];
    }];
    
    return result;
}
- (BOOL)deleteFriend:(HYNewFriendModel *)friendModel
{
    __block BOOL result = YES;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db deleteFriend:friendModel];
    }];
    return result;
}
- (BOOL)allNewFriends:(NSMutableArray *)friends
{
    __block BOOL result = YES;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db allNewFriends:friends];
    }];
    return result;
}

@end

@implementation FMDatabase(NewFriend)

- (void)createNewFriendTable
{
    [self executeUpdate:@"CREATE TABLE IF NOT EXISTS T_CHAT_NEWFRIEND (id integer primary key autoincrement,myJid text,friendBare text,friendResource text,body text,time double)"];
}

- (BOOL)insertFriend:(HYNewFriendModel *)friendModel
{
    HYLoginInfo *loginInfo = [HYLoginInfo sharedInstance];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO T_CHAT_NEWFRIEND(myJid,friendBare,friendResource,body,time) VALUES('%@','%@','%@','%@','%lf')",loginInfo.jid.full,friendModel.jid.bare,friendModel.jid.resource,friendModel.body,friendModel.time];
    if(![self executeUpdate:sql])
    {
        HYLog(@"%@ fail,%@",sql,[[self lastError] localizedDescription]);
        return NO;
    }
    return YES;
}
- (BOOL)deleteFriend:(HYNewFriendModel *)friendModel
{
    HYLoginInfo *loginInfo = [HYLoginInfo sharedInstance];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM T_CHAT_NEWFRIEND WHERE myJid='%@' AND friendBare='%@'",loginInfo.jid.full,friendModel.jid.bare];
    if(![self executeUpdate:sql])
    {
        HYLog(@"%@ fail,%@",sql,[[self lastError] localizedDescription]);
        return NO;
    }
    return YES;
}
- (BOOL)allNewFriends:(NSMutableArray *)friends
{
    HYLoginInfo *loginInfo = [HYLoginInfo sharedInstance];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM T_CHAT_RECENTCHAT WHERE myJid='%@' order by time desc",[loginInfo.jid full]];
    FMResultSet *rs = [self executeQuery:sql];
    if(rs == nil)
    {
        HYLog(@"%@ fail,%@",sql,[[self lastError] localizedDescription]);
        return NO;
    }
    
    [friends removeAllObjects];
    while ([rs next])
    {
        HYNewFriendModel *model = [[HYNewFriendModel alloc] init];
        [self friendModel:model fromResultSet:rs];
        [friends addObject:model]; // 添加到models
    }
    
    [rs close];
    return YES;
}

- (void)friendModel:(HYNewFriendModel *)friendModel fromResultSet:(FMResultSet *)rs
{
    NSString *friendBare = [rs stringForColumn:@"friendBare"];
    NSString *friendResource = [rs stringForColumn:@"friendResource"];
    XMPPJID *friendJid = [XMPPJID jidWithString:friendBare resource:friendResource];
    NSString *body = [rs stringForColumn:@"body"];
    NSTimeInterval time = [rs doubleForColumn:@"time"];
    
    [friendModel setJid:friendJid];
    [friendModel setBody:body];
    [friendModel setTime:time];
}




@end