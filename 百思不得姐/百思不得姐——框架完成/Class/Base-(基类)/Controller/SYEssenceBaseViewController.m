//
//  SYEssenceBaseViewController.m
//  百思不得姐——框架完成
//
//  Created by 码农界四爷__King on 16/6/6.
//  Copyright © 2016年 码农界四爷__King. All rights reserved.
//  最基本的帖子内容

#import "SYEssenceBaseViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "UIImageView+WebCache.h"
#import "SYTextItem.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "SYWholeCell.h"

static NSString *const ID = @"cell";

@interface SYEssenceBaseViewController ()
//帖子数据
@property (nonatomic,strong) NSMutableArray *textItems;
//当前页码
@property (nonatomic,assign) NSInteger page;
//当加载下一页数据是需要这个参数
@property (nonatomic,copy) NSString *maxtime;
//上一次请求
@property (nonatomic,strong) NSDictionary *params;

@end

@implementation SYEssenceBaseViewController

//懒加载
- (NSMutableArray *)textItems
{
    if (_textItems == nil) {
        _textItems = [NSMutableArray array];
    }
    return _textItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化控件
    [self setupNavigationStyles];
    
    //添加刷新控件
    [self setupRefresh];
    
    
}
- (void)setupNavigationStyles
{
    self.tableView.contentInset = UIEdgeInsetsMake(64 + 35, 0, 49, 0);

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.showsVerticalScrollIndicator = NO;
    self.view.backgroundColor = SYCommonBgColor;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SYWholeCell class]) bundle:nil] forCellReuseIdentifier:ID];
}

- (void)setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    //自动改变透明度
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    
}


//加载新的数据
- (void)loadNewData
{
    [self.tableView.mj_footer endRefreshing];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"a"] = @"list";
//    params[@"c"] = @"data";
    params[@"type"] = @(self.type);
    self.params = params;

    [manager GET:@"http://s.budejie.com/topic/list/jingxuan/1/bs0315-iphone-4.2/0-20.json" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        [responseObject writeToFile:@"/Users/sunhaichao/Desktop/AD.plist" atomically:YES];
        
        if (self.params != params) return;
        
        self.maxtime = responseObject[@"info"][@"maxtime"];
      
        self.textItems = [SYTextItem mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        
        
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        
        self.page = 0;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.params != params) return;
        
        [self.tableView.mj_header endRefreshing];
        
    }];
    
}

// http://s.budejie.com/topic/tag-topic/64/hot/bs0315-iphone-4.2/0-20.json
- (void)loadMoreData
{
    
    [self.tableView.mj_header endRefreshing];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *paramas = [NSMutableDictionary dictionary];
//    paramas[@"a"] = @"list";
//    paramas[@"c"] = @"data";
    paramas[@"type"] = @(self.type);
    NSInteger page = self.page + 1;
    paramas[@"page"] = @(page);
    paramas[@"maxtime"] = self.maxtime;
    self.params = paramas;
    
    
    [manager GET:@"http://s.budejie.com/topic/list/jingxuan/1/bs0315-iphone-4.2/0-20.json" parameters:paramas progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (self.params != paramas) return;
        
        self.maxtime = responseObject[@"info"][@"maxtime"];
        
        NSArray *newTopics = [SYTextItem mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        
        [self.textItems addObjectsFromArray:newTopics];
        
        [self.tableView reloadData];
        
        [self.tableView.mj_footer endRefreshing];
        
        self.page = page;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.params != paramas) return;
        
        [self.tableView.mj_footer endRefreshing];
        
    }];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView.mj_footer.hidden = (self.textItems.count == 0);
    return self.textItems.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYWholeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textItems = self.textItems[indexPath.row];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYTextItem *textItem = self.textItems[indexPath.row];
    
    return textItem.cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end