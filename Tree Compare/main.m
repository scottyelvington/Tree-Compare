//
//  main.m
//  Tree Compare
//
//  Created by Scott Yelvington on 6/27/18.
//  Copyright © 2018 Scott Yelvington. All rights reserved.
//

#import <Foundation/Foundation.h>

struct treeNode {
	
	int 				value;
	int 				count;
	
	struct treeNode 	**children;
};

struct listElement {
	
	//index, aPointer, bPointer
	NSUInteger		index;
	
	struct treeNode	*treeA,
					*treeB;
	
	struct listElement	*previous,
					*next;
};

struct linkedList {
	
	NSInteger			length;
	
	//previous struct, last struct
	struct listElement	*last;
};



bool areTreesIdentical(struct treeNode *candidateTreeA, struct treeNode *candidateTreeB) {
	
	struct treeNode	*treeA 		= candidateTreeA,
					*treeB 		= candidateTreeB;
	
	struct linkedList	list;
	
	struct listElement	*curElement,
					*newElement;
	
	NSInteger			depth		= 0,
					index		= 0;
	
	int 				elementSize	= sizeof(struct listElement);
	
	bool				match		= true;
	
	//add first list container
	curElement					= malloc(elementSize);
	curElement->previous			= NULL;
	
	
	//initialize the list struct
	list.last						= curElement;
	list.length					= 1;
	
	
	do {
		//test if the current tree's values and counts are the same,
		//if they're not, the trees are dissimilar and we don't want to proceed
		if (treeA->value != treeB->value 	||
		    treeA->count != treeB->count	) {
			
			match				= false;
			
			break;
		}
		
		//next, check if the current tree has more children to itterate through,
		//if so, we want to go downwards; if not, we want to go upwards
		if (treeA->count && index < treeA->count) {
			
			//save our progress at this depth
			curElement->index		= index;
			curElement->treeA		= treeA;
			curElement->treeB		= treeB;
			
			treeA				= treeA->children[index];
			treeB				= treeB->children[index];
			
			depth++;
			
			//check if we need to add a new element to list or not
			if (list.length == depth) {
				
				newElement		= malloc(elementSize);
				newElement->previous= curElement;
				
				curElement->next	= newElement;
				curElement		= newElement;
				
				//modify the list struct
				list.last			= newElement;
				list.length		+= 1;
			} else {
				
				//get next element
				newElement		= curElement->next;
				curElement		= newElement;
			}
			
			continue;
		}
		
		depth--;
		
		if (depth >= 0) {
			curElement 			= curElement->previous;
			treeA				= curElement->treeA;
			treeB				= curElement->treeB;
			index				= curElement->index+1;
		}
		
	} while (depth >= 0);
	
	newElement					= list.last;
	
	//add the free memory step here
	for (NSInteger i = list.length; i>0; i--) {
		
		curElement				= newElement->previous;
		
		free(newElement);
		
		newElement				= curElement;
	}
	
	return match;
}

struct treeNode* generateRandomTree (int maxChildren, int maxDepth) {
	
	struct treeNode	*node		= malloc(sizeof(struct treeNode));
	
	node->value					= arc4random();
	node->count					= (maxDepth > 0) ? arc4random()%maxChildren : 0;
	
	if (node->count) {
		
		node->children				= malloc(node->count * sizeof(struct treeNode *));
		
		for (int i = 0; i < node->count; i++) {
			
			node->children[i]		= generateRandomTree(maxChildren, maxDepth-1);
		}
	}
	
	return node;
}

void destroyRandomTree (struct treeNode *node) {
	
	if (node->count) {
		
		for (int i = 0; i < node->count; i++) {
			
			destroyRandomTree(node->children[i]);
		}
		
		free(node->children);
	}
	
	free(node);
}


int main(int argc, const char * argv[]) {
	
	//create randomized trees
	struct treeNode	*nodeA		= generateRandomTree(5, 5),
					*nodeB		= generateRandomTree(5, 5);
	
	//test the trees against eachother to produce a fail, and against themselves to produce a true
	bool 			firstResult	= areTreesIdentical(nodeA, nodeA),//same
					secondResult	= areTreesIdentical(nodeB, nodeB),//same
					thirdResult	= areTreesIdentical(nodeA, nodeB);//not same
	
	NSLog(firstResult ? @"The trees are the same" : @"The trees are not the same");
	NSLog(secondResult ? @"The trees are the same" : @"The trees are not the same");
	NSLog(thirdResult ? @"The trees are the same" : @"The trees are not the same");
	
	//remove trees from memory
	destroyRandomTree(nodeA);
	destroyRandomTree(nodeB);
		
	return 0;
}
