//
//  TableViewController.m
//  TableViewDemo
//
//  Created by hailiangwang on 2/6/15.
//  Copyright (c) 2015 com.whl.test. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *editButton;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation TableViewController

@synthesize deleteButton,addButton,cancelButton,editButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"TableViewDemo";
//    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.dataArray = [NSMutableArray new];
    
    //下拉刷新
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor redColor];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [self.refreshControl addTarget:self action:@selector(refreshViewControlEventValueChanged) forControlEvents:UIControlEventValueChanged];
    
    NSString *itemFormatString = NSLocalizedString(@"Item %d", @"Format string for item");
    for (unsigned int itemNumber = 1; itemNumber <= 12; itemNumber++)
    {
        NSString *itemName = [NSString stringWithFormat:itemFormatString, itemNumber];
        [self.dataArray addObject:itemName];
    }
    deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    deleteButton.tintColor = [UIColor redColor];
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    
    [self updateButtonsToMatchTableState];
}

//下拉刷新
- (void)refreshViewControlEventValueChanged{
    [self performSelector:@selector(reloadTableViewData) withObject:nil afterDelay:2.0];
}

- (void)reloadTableViewData{
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateDeleteButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateButtonsToMatchTableState];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure a cell to show the corresponding string from the array.
    static NSString *SimpleTableIdentifier = @"SimlpeTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:SimpleTableIdentifier];
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    NSLog(@"self frame with is %f",cell.bounds.size.width);
    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Action methods

- (IBAction)editAction:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender
{
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            [self.dataArray removeObjectsAtIndexes:indicesOfItemsToDelete];
            
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            [self.dataArray removeAllObjects];
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
    }
}

- (IBAction)deleteAction:(id)sender
{
    NSString *actionTitle;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove this item?", @"");
    }
    else
    {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove these items?", @"");
    }
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    [actionSheet showInView:self.view];
}

- (IBAction)addAction:(id)sender
{
    [self.tableView beginUpdates];
    
    [self.dataArray addObject:@"New Item"];
    
    NSIndexPath *indexPathOfNewItem = [NSIndexPath indexPathForRow:(self.dataArray.count - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPathOfNewItem]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:indexPathOfNewItem
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    
    [self updateButtonsToMatchTableState];
}


#pragma mark - Updating button state

- (void)updateButtonsToMatchTableState
{
    if (self.tableView.editing)
    {
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        
        [self updateDeleteButtonTitle];
        
        self.navigationItem.leftBarButtonItem = self.deleteButton;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = self.addButton;
        
        if (self.dataArray.count > 0)
        {
            self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
}

- (void)updateDeleteButtonTitle
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == self.dataArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"Delete All", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
