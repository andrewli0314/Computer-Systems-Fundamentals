////////////////////////////////////////////////////////////////////////
// COMP1521 21T3 --- Assignment 2: `chicken', a simple file archiver
// <https://www.cse.unsw.edu.au/~cs1521/21T3/assignments/ass2/index.html>
//
// Written by YOUR-NAME-HERE (z5555555) on INSERT-DATE-HERE.
//
// 2021-11-08   v1.1    Team COMP1521 <cs1521 at cse.unsw.edu.au>

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include "chicken.h"


// ADD ANY extra #defines HERE
#include <string.h>
#include <dirent.h>

// ADD YOUR FUNCTION PROTOTYPES HERE
int getPerValue(char *permissions);
// print the files & directories stored in egg_pathname (subset 0)
//
// if long_listing is non-zero then file/directory permissions, formats & sizes are also printed (subset 0)

void list_egg(char *egg_pathname, int long_listing) {

    FILE *filestream = fopen(egg_pathname, "r");
    while (1) {
        int magicNumber = getc(filestream);
        if (magicNumber == -1) {
            break;
        }
        int eggletFormat = getc(filestream);
        char permissions[11];
        permissions[10] = '\0';
        int i = 0;
        while(i<10){
            permissions[i++] = getc(filestream);
        }
        int pathnameLength;
        pathnameLength = getc(filestream);
        int l = getc(filestream) << 8;
        pathnameLength = pathnameLength + l;
        char *pathname = malloc(pathnameLength + 1);
        pathname[pathnameLength] = '\0';
        i = 0;
        while(i < pathnameLength)
            pathname[i++] = getc(filestream);
        int64_t contentLength = 0;
        int64_t byte;
        for (i = 0; i < 6; i++) {
            byte = getc(filestream);
            byte = byte << (8 * i);
            contentLength = byte + contentLength;
        }
        int64_t j = 0;
        while (j < contentLength) {
            getc(filestream);
            j++;
        }
        if (long_listing)
            printf("%s  %c  %5lu  %s\n", permissions, eggletFormat, contentLength, pathname);
        else
            printf("%s\n", pathname);
        getc(filestream);
    }
    fclose(filestream);
}

// check the files & directories stored in egg_pathname (subset 1)
//
// prints the files & directories stored in egg_pathname with a message
// either, indicating the hash byte is correct, or
// indicating the hash byte is incorrect, what the incorrect value is and the correct value would be
void check_egg(char *egg_pathname) {
    FILE *filestream = fopen(egg_pathname, "r+");
    while (filestream != NULL) {
        int magicNumber = getc(filestream);
        if (magicNumber == -1)
            return;
        if (magicNumber != 0x63) {
            fprintf(stderr, "error: incorrect first egglet byte: 0x%x should be 0x63\n", magicNumber);
            exit(1);
        }
        uint8_t hash = 0;
        hash = egglet_hash(hash, magicNumber);
        int i = 0;
        while(i < 11){
            int tmp = getc(filestream);
            hash = egglet_hash(hash, tmp);
            i++;
        }
        int pathnameLength;
        pathnameLength = getc(filestream);
        hash = egglet_hash(hash, pathnameLength);
        int64_t byte = getc(filestream);
        hash = egglet_hash(hash, byte);
        pathnameLength = pathnameLength + (byte << 8);
        char *pathname = malloc(pathnameLength + 1);
        pathname[pathnameLength] = '\0';
        i = 0;
        while(i<pathnameLength){
            pathname[i] = getc(filestream);
            hash = egglet_hash(hash, pathname[i]);
            i++;
        }
        int64_t contentLength = 0;
        for (i = 0; i < 6; i++) {
            byte = 0;
            byte = getc(filestream);
            hash = egglet_hash(hash, byte);
            byte = byte << (8 * i);
            contentLength = byte + contentLength;
        }
        int64_t j = 0;
        int temp;
        while (j < contentLength) {
            temp = getc(filestream);
            hash = egglet_hash(hash, temp);
            j++;
        }
        uint8_t fileHash = getc(filestream);
        if (hash == fileHash)
            printf("%s - correct hash\n", pathname);
        else
            printf("%s - incorrect hash 0x%x should be 0x%x\n", pathname, hash, fileHash);
    }
    fclose(filestream);
}


// extract the files/directories stored in egg_pathname (subset 2 & 3)

void extract_egg(char *egg_pathname) {

    FILE *filestream = fopen(egg_pathname, "r");
    while (1) {
        int magicNumber = getc(filestream);
        if (magicNumber == -1) {
            break;
        }
        int eggletFormat = getc(filestream);
        char permissions[11];
        permissions[10] = '\0';
        int i = 0;
        while(i<10){
            permissions[i++] = getc(filestream);
        }
        int value = getPerValue(permissions);
        int pathnameLength;
        pathnameLength = getc(filestream);
        int l = getc(filestream) << 8;
        pathnameLength = pathnameLength + l;
        char *pathname = malloc(pathnameLength + 1);
        pathname[pathnameLength] = '\0';
        i = 0;
        while(i < pathnameLength)
            pathname[i++] = getc(filestream);
        FILE *output_stream = fopen(pathname, "w+");
        int64_t contentLength = 0;
        int64_t byte;
        for (i = 0; i < 6; i++) {
            byte = getc(filestream);
            byte = byte << (8 * i);
            contentLength = byte + contentLength;
        }
        int64_t j = 0;
        while (j < contentLength) {
            fputc(getc(filestream), output_stream);
            j++;
        }
        close(output_stream);
        chmod(pathname, value);
        printf("Extracting: %s\n", pathname);
        getc(filestream);
    }
    fclose(filestream);
}


// create egg_pathname containing the files or directories specified in pathnames (subset 3)
//
// if append is zero egg_pathname should be over-written if it exists
// if append is non-zero egglets should be instead appended to egg_pathname if it exists
//
// format specifies the egglet format to use, it must be one EGGLET_FMT_6,EGGLET_FMT_7 or EGGLET_FMT_8

void create_egg(char *egg_pathname, int append, int format,
                int n_pathnames, char *pathnames[n_pathnames]) {
}


// ADD YOUR EXTRA FUNCTIONS HERE

int getPerValue(char *permissions) {
    int index = 1;
    int value = 0;
    for (int i = 0; i < 3; i++) {
        if (permissions[index] == 'r') {
            value = value + 4;
        } else if (permissions[index] == 'w') {
            value = value + 2;
        } else if (permissions[index] == 'x') {
            value = value + 1;
        }
        index++;
    }
    value = value * 8;
    for (int i = 0; i < 3; i++) {
        if (permissions[index] == 'r') {
            value = value + 4;
        } else if (permissions[index] == 'w') {
            value = value + 2;
        } else if (permissions[index] == 'x') {
            value = value + 1;
        }
        index++;
    }
    value = value * 8;
    for (int i = 0; i < 3; i++) {
        if (permissions[index] == 'r') {
            value = value + 4;
        } else if (permissions[index] == 'w') {
            value = value + 2;
        } else if (permissions[index] == 'x') {
            value = value + 1;
        }
        index++;
    }
    return value;
}