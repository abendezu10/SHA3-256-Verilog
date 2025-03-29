#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "linked_tree.h"

#define BLOCK 136 

// each block should be 1088 bits or 136 bytes

void message_to_padded(char *msg[]);

int main(int argc, char *argv[]){

    // command "msg" or "Hello, World" (12 bytes)
    // 01101000 01100101 01101100 01101100 01101111 00101100 00100000 01110111 01101111 01110010 01101100 01100100 00100001 00001010
    char msg[] = "The quick brown fox jumps over the lazy dog. SHA-3 is a cryptographic hash function standardized by NIST in FIPS 202.";

    //code when the string is above 136 bytes
    size_t msg_len = strlen(msg);

    uint8_t *pad_msg = (uint8_t *)malloc(BLOCK); //creates a block of 136 bytes

    if(msg_len > BLOCK){
      
    }else{
        memset(pad_msg, 0, BLOCK);
        memcpy(pad_msg, msg, msg_len);

        pad_msg[msg_len] = 0x06;
        pad_msg[BLOCK - 1] = 0x80;
    }



    free(pad_msg);
    return 0;
}