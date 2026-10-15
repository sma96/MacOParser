//
//  EarlyLoader.m
//  IntegrityKit
//
//  Created by 미니 on 10/14/26.
//

#import <Foundation/Foundation.h>
#import <IntegrityKit/IntegrityKit-Swift.h>

// __attribute__((constructor))를 사용하여 main() 실행되기 전에 함수를 실행시킬 수 있다.

void __attribute__((constructor)) integrity_check(void) {
    IntegrityChecker *checker = [[IntegrityChecker alloc] init];
    
    if (checker == nil) {
        exit(1);
    }
    if (checker.isTampered) {
        printf("tampered");
        exit(1);
    } else {
        printf("not tampered\n");
    }
}
