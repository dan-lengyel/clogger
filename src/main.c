#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/inotify.h>
#include <limits.h>
#include <unistd.h>
#include <signal.h>
#include <pthread.h>

#include "zlog.h"

#define MAX_EVENTS 1024 /*Max. number of events to process at one go*/
#define LEN_NAME 1024 /*Assuming length of the filename won't exceed 16 bytes*/
#define EVENT_SIZE  ( sizeof (struct inotify_event) ) /*size of one event*/
#define BUF_LEN     ( MAX_EVENTS * ( EVENT_SIZE + LEN_NAME )) /*buffer to store the data of events*/

static pthread_t inotify_pthread;
static int fd, wd;

static int zlog_rc;
static zlog_category_t *c;
static char zlog_conf[PATH_MAX];
static char zlog_folder[PATH_MAX];

// Clean up and exit on SIGINT
void sig_handler(int sig){
    zlog_info(c, "Cleaning up and exiting");
    inotify_rm_watch( fd, wd );
    close( fd );
	zlog_fini();
    exit(0);
}
 
void get_event () {
    while(1){
        char buffer[BUF_LEN];
        int length, i = 0;
     
        length = read( (int)fd, buffer, BUF_LEN );  
        if ( length < 0 ) {
            zlog_error(c, "read" );
        }  
      
        while ( i < length ) {
            struct inotify_event *event = ( struct inotify_event * ) &buffer[ i ];
            if ( event->len ) {
                zlog_info(c, "Reloading zlog configuration file");
                zlog_reload(zlog_conf);
                i += EVENT_SIZE + event->len;
            }
        }
    }
}

int main() {
    // Cleanup on SIGINT
    signal(SIGINT, sig_handler);

    // Get location of configuration file(s)
    if (getcwd(zlog_conf, sizeof(zlog_conf)) != NULL) {
        printf("Current working dir: %s\n", zlog_conf);
    } else {
        printf("getcwd() error");
        return 1;
    }
    strcpy(zlog_folder, zlog_conf);
    strcat(zlog_folder, "/conf/");
    strcat(zlog_conf, "/conf/zlog.conf");
    printf("Zlog folder location: %s\n", zlog_folder);
    printf("Zlog conf location: %s\n", zlog_conf);

    // Initialize zlog
	zlog_rc = zlog_init(zlog_conf);
	if (zlog_rc) {
		printf("Failed to initialize zlog\n");
		return -1;
	}

	c = zlog_get_category("logs");
	if (!c) {
		printf("Failed to get category\n");
		zlog_fini();
		return -2;
	}

    // Initialize inotify to check for config changes
    fd = inotify_init();
    if ( fd < 0 ) {
        zlog_error(c, "Couldn't initialize inotify");
    }
  
    wd = inotify_add_watch(fd, zlog_folder, IN_CREATE | IN_MODIFY | IN_DELETE); 
    if (wd == -1) {
        zlog_error(c, "Couldn't add watch to %s\n", zlog_folder);
    } else {
        zlog_info(c, "Watching:: %s\n", zlog_folder);
    }

    // Imagine main program loop here
    // Watch for changes in cfg directory. If the zlog config is modified, zlog_reload will be called.
    int ret;
    ret = pthread_create(&inotify_pthread, NULL, (void*)get_event, NULL);
	if (ret < 0) {
		zlog_error(c, "can't create inotify thread");
		exit(EXIT_FAILURE);
	}
    while(1){
        zlog_error(c, "This is a zlog error message");
        zlog_info(c, "This is a zlog info message");
        zlog_debug(c, "This is a zlog debug message");
        sleep(1);
    }

    return 0;
}