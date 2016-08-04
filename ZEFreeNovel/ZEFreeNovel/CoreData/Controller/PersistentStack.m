//
//  PersistentStack.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/2.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "PersistentStack.h"

@interface PersistentStack ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;
@property (nonatomic, strong) NSURL *modelURL;
@property (nonatomic, strong) NSURL *storeURL;

@end

@implementation PersistentStack

+ (instancetype)stack {
    static PersistentStack *_stack = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _stack = [[PersistentStack alloc]init];
    });
    return _stack;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupManagedObjectContexts];
    }
    return self;
}

- (void)setupManagedObjectContexts {
    self.context = [self setupManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
    self.context.undoManager = [[NSUndoManager alloc]init];
    
    self.backgroundContext = [self setupManagedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.backgroundContext.undoManager = nil;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      NSManagedObjectContext *moc = self.context;
                                                      if (note.object != moc) {
                                                          [moc performBlock:^{
                                                              [moc mergeChangesFromContextDidSaveNotification:note];
                                                          }];
                                                      }
                                                  }];
}

- (NSManagedObjectContext *)setupManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:concurrencyType];
    context.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
    NSError *error;
    [context.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                     configuration:nil
                                                               URL:self.storeURL
                                                           options:nil
                                                             error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
        NSLog(@"rm \"%@\"", self.storeURL.path);
    }
    return context;
}

- (NSManagedObjectModel*)managedObjectModel {
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}
- (NSURL*)storeURL {
    NSURL* documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                       inDomain:NSUserDomainMask
                                                              appropriateForURL:nil
                                                                         create:YES
                                                                          error:NULL];
    return [documentsDirectory URLByAppendingPathComponent:@"db.sqlite"];
}

- (NSURL*)modelURL {
    return [[NSBundle mainBundle] URLForResource:@"ZEFreeNovel" withExtension:@"momd"];
}

@end
