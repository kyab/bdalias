#import <Foundation/Foundation.h>
#import "BDAlias.h"

void checkITunesLibraryPath();
int	setITunesLibraryLocationTo(const char *path);

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	BDAlias *alias1 = [BDAlias aliasWithPath:[[NSFileManager defaultManager] stringWithFileSystemRepresentation:argv[0] length:strlen(argv[0])]];
	BDAlias *alias2 = [BDAlias aliasWithPath:[[NSFileManager defaultManager] stringWithFileSystemRepresentation:argv[0] length:strlen(argv[0])]];
	assert([alias1 isEqual:alias2]);
    
	printf("success\n");
	
	printf("iTunes addition. cheking/setting iTunes Library Path...\n");
	
	checkITunesLibraryPath();
	setITunesLibraryLocationTo("/macbook/koji/Music/iTunes");
	
	[pool release];
    return 0;
}

//works well
void checkITunesLibraryPath(){
	
	NSString *pListPath = @"~/Library/Preferences/com.apple.iTunes.plist";
	NSDictionary *iTunesPList = [NSDictionary dictionaryWithContentsOfFile:[pListPath stringByExpandingTildeInPath]];
	
	NSData *pathData = [iTunesPList objectForKey:@"alis:1:iTunes Library Location"];
	if (pathData){
		BDAlias *locationAlias = [[BDAlias alloc] initWithData:pathData];
	
		NSString *libraryLocationPath = [locationAlias fullPath];
		if (libraryLocationPath){
			NSLog(@"iTunes Library Location is \"%@\"", libraryLocationPath);
		}else{
			NSLog(@"Could not resolve iTunes Library Location from Alias!!, maybe external Device is disconnected, \
				  or Network server is down..This may be same situation when yout itunes ask to select Library on launch.");
		}
	
	}else{
		
		//seems like com.apple.iTunes.plist don't have this key in case your library is default(~/Music/iTunes.)
		NSLog(@"music folder locations seems as defaults");
		
	}

}

//not enough yet..
int	setITunesLibraryLocationTo(const char *path){
	
	NSString *pListPath = @"~/Library/Preferences/com.apple.iTunes.plist";
	NSDictionary *iTunesPList = [NSDictionary dictionaryWithContentsOfFile:[pListPath stringByExpandingTildeInPath]];
	
	NSString *newLocationPath = [NSString stringWithUTF8String:path];
	BDAlias *alias = [BDAlias aliasWithPath:newLocationPath];
	if (alias == nil){
		NSLog(@"failed to set new location:%@. may be %@ is not accessible currently", newLocationPath, newLocationPath);
		return -1;
	}
	
	NSData *newLocationAliasData = [alias aliasData];
	if (newLocationAliasData == nil){
		NSLog(@"failed to set new location:%@. may be %@ is not accessible currently", newLocationPath, newLocationPath);
		return -2;
	}
	
	NSMutableDictionary *newPList = [[iTunesPList mutableCopy] autorelease];
	[newPList setObject:newLocationAliasData forKey:@"alis:1:iTunes Library Location"];
	[newPList writeToFile:[pListPath stringByExpandingTildeInPath] atomically:YES];
	
	//ok, here we've changed library path. but,,, this is not enough.
	
	//ok wee need more.  : pref:130:Preferences. but failed..
	NSData *preferencesData = [newPList objectForKey:@"pref:130:Preferences"];
	NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
	NSString *error;
	
	id preferences = [NSPropertyListSerialization
											 propertyListFromData:preferencesData
															   mutabilityOption: NSPropertyListImmutable
															   format:&format
															 errorDescription:&error];
	
	if (preferences ==nil ){
		NSLog(@"could not prase key pref:130:Preferences as property list..");
	}
	NSLog(@"%@", error);
	
	//try to save it. but currupted datas..
	[preferencesData writeToFile:@"/Users/koji/Desktop/foo.plist" atomically:YES];
	
	return 0;
}
	











































