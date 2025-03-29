#ifndef LINKED_TREE_H
#define LINKED_TREE_H


#include <stdint.h>

#define BLOCK 136 

typedef struct{
    uint8_t msg[BLOCK];
    node *next;
}node;

void increment(uint8_t data);
void decrement();
void view();


#endif