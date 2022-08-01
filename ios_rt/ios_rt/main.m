#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "../../utest.h"

int main(int argc, char * argv[]) {
    NSString* NsInputFileName, *NsInputFileFullName, *NsConfigFileName, *NsConfigFileFullName, *NsOutputFileName, *NsOutputFileFullName;
    char InputFileName[256], ConfigFileName[256], OutputFileName[256];
    unsigned long strLen;
    int j=0;
        
    NSString * NsDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"path:   %@",NsDocuments);
    NSLog(@"paths:   %@",NSHomeDirectory());

    //char infile[128]="BasketballDrive_1920x1080_50.yuv";
    char outfile[128]="out.yuv";
    char infile[128]="MarketPlace_1920x1080_60fps_10bit_420.yuv";
    char configfile[128]="encoder_ra.cfg";
    char* uavs3e_argv[7];
    int uavs3e_argc = 7;
    
    NsInputFileName = [[NSString alloc]initWithCString:(const char *) (infile) encoding:NSUTF8StringEncoding];
    NsInputFileFullName = [NSString stringWithFormat:@"%@/%@", NsDocuments, NsInputFileName];
    strLen = [NsInputFileFullName length];
    [NsInputFileFullName getCString:InputFileName maxLength:strLen+1 encoding:NSUTF8StringEncoding];
    
    NsOutputFileName = [[NSString alloc]initWithCString:(const char *) (outfile) encoding:NSUTF8StringEncoding];
    NsOutputFileFullName = [NSString stringWithFormat:@"%@/%@", NsDocuments, NsOutputFileName];
    strLen = [NsOutputFileFullName length];
    [NsOutputFileFullName getCString:OutputFileName maxLength:strLen+1 encoding:NSUTF8StringEncoding];
    
    NsConfigFileName = [[NSString alloc]initWithCString:(const char *) (configfile) encoding:NSUTF8StringEncoding];
    NsConfigFileFullName = [NSString stringWithFormat:@"%@/%@", NsDocuments, NsConfigFileName];
    strLen = [NsConfigFileFullName length];
    [NsConfigFileFullName getCString:ConfigFileName maxLength:strLen+1 encoding:NSUTF8StringEncoding];
    //printf("stream: %s\n", ConfigFileName);
    printf("stream: %s\n", InputFileName);
        
    uavs3e_argv[j++] = "uavs3e";
    uavs3e_argv[j++] = "-f";
    uavs3e_argv[j++] = ConfigFileName;
    uavs3e_argv[j++] = "-p";
    uavs3e_argv[j++] = "InputFile";
    uavs3e_argv[j++] = "=";
    uavs3e_argv[j++] = InputFileName;
    

    uavs3e_code_rt(uavs3e_argc, uavs3e_argv);

    return 0;
}
