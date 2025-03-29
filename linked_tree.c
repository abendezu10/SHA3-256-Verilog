#include "linked_tree.h"

node *head;
int size = 0;

int main(void){
    
    head = NULL;
}

void increment(uint8_t data[]){
    node *temp1 = (node*)malloc(sizeof(node));
    memcpy(temp1->msg, data, strlen(data));
    
    if(size == 0){
        temp1->next = head;
        head = temp1;
        size++;
    }

    

}
void decrement();
void view();