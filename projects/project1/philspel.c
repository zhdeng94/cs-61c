/*
 * Include the provided hash table library.
 */
#include "hashtable.h"

/*
 * Include the header file.
 */
#include "philspel.h"

/*
 * Standard IO and file routines.
 */
#include <stdio.h>

/*
 * General utility routines (including malloc()).
 */
#include <stdlib.h>

/*
 * Character utility routines.
 */
#include <ctype.h>

/*
 * String utility routines.
 */
#include <string.h>

/*
 * This hash table stores the dictionary.
 */
HashTable *dictionary;

void checkWord(char *buffer, int pos) {
  buffer[pos] = '\0';
  char *str1 = malloc(sizeof(char) * (pos + 1)); // store word like "Hello"
  char *str2 = malloc(sizeof(char) * (pos + 1)); // store word with all lowercase
  strcpy(str1, buffer);
  strcpy(str2, buffer);
  int i = 1;
  for (i = 1; i < pos; i++) {
    if (str1[i] >= 'A' && str1[i] <= 'Z') {
      str1[i] = str1[i] + ('a' - 'A');
    }
  }
  for (i = 0; i < pos; i++) {
    if (str2[i] >= 'A' && str2[i] <= 'Z') {
      str2[i] = str2[i] + ('a' - 'A');
    }
  }
  if (findData(dictionary, (void*)buffer) != NULL) {
    fprintf(stdout, "%s", buffer);
  } else if (findData(dictionary, (void*)str1) != NULL) {
    fprintf(stdout, "%s", buffer);
  } else if (findData(dictionary, (void*)str2) != NULL) {
    fprintf(stdout, "%s", buffer);
  } else {
    fprintf(stdout, "%s [sic]", buffer);
  }
  free(str1);
  free(str2);
}

/*
 * The MAIN routine.  You can safely print debugging information
 * to standard error (stderr) as shown and it will be ignored in 
 * the grading process.
 */
int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "Specify a dictionary\n");
    return 0;
  }
  /*
   * Allocate a hash table to store the dictionary.
   */
  fprintf(stderr, "Creating hashtable\n");
  dictionary = createHashTable(2255, &stringHash, &stringEquals);

  fprintf(stderr, "Loading dictionary %s\n", argv[1]);
  readDictionary(argv[1]);
  fprintf(stderr, "Dictionary loaded\n");

  fprintf(stderr, "Processing stdin\n");
  processInput();

  /*
   * The MAIN function in C should always return 0 as a way of telling
   * whatever program invoked this that everything went OK.
   */
  return 0;
}

/*
 * This should hash a string to a bucket index.  Void *s can be safely cast
 * to a char * (null terminated string) and is already done for you here 
 * for convenience.
 */
unsigned int stringHash(void *s) {
  char *string = (char *)s;
  const unsigned int BASE = 31;
  unsigned int res = 0;
  int i = 0;
  for (i = 0; i < strlen(string); i++) {
    res = (res * BASE + string[i]) % dictionary->size;
  }
  return res;
}

/*
 * This should return a nonzero value if the two strings are identical 
 * (case sensitive comparison) and 0 otherwise.
 */
int stringEquals(void *s1, void *s2) {
  char *string1 = (char *)s1;
  char *string2 = (char *)s2;
  return !strcmp(string1, string2);
}

/*
 * This function should read in every word from the dictionary and
 * store it in the hash table.  You should first open the file specified,
 * then read the words one at a time and insert them into the dictionary.
 * Once the file is read in completely, return.  You will need to allocate
 * (using malloc()) space for each word.  As described in the spec, you
 * can initially assume that no word is longer than 60 characters.  However,
 * for the final 20% of your grade, you cannot assumed that words have a bounded
 * length.  You CANNOT assume that the specified file exists.  If the file does
 * NOT exist, you should print some message to standard error and call exit(1)
 * to cleanly exit the program.
 *
 * Since the format is one word at a time, with new lines in between,
 * you can safely use fscanf() to read in the strings until you want to handle
 * arbitrarily long dictionary chacaters.
 */
void readDictionary(char *dictName) {
  FILE *fp;
  fp = fopen(dictName, "r");
  if (fp == NULL) {
    fprintf(stderr, "Cannot open %s!\n", dictName);
    exit(1);
  }

  char buffer[100];
  while (fscanf(fp, "%s", buffer) == 1) {
    int len = strlen(buffer);
    char *key = malloc(sizeof(char) * (len + 1));
    strcpy(key, buffer);
    insertData(dictionary, (void*)key, (void*)key);
  }
  fclose(fp);
}

/*
 * This should process standard input (stdin) and copy it to standard
 * output (stdout) as specified in the spec (e.g., if a standard 
 * dictionary was used and the string "this is a taest of  this-proGram" 
 * was given to stdin, the output to stdout should be 
 * "this is a teast [sic] of  this-proGram").  All words should be checked
 * against the dictionary as they are input, then with all but the first
 * letter converted to lowercase, and finally with all letters converted
 * to lowercase.  Only if all 3 cases are not in the dictionary should it
 * be reported as not found by appending " [sic]" after the error.
 *
 * Since we care about preserving whitespace and pass through all non alphabet
 * characters untouched, scanf() is probably insufficent (since it only considers
 * whitespace as breaking strings), meaning you will probably have
 * to get characters from stdin one at a time.
 *
 * Do note that even under the initial assumption that no word is longer than 60
 * characters, you may still encounter strings of non-alphabetic characters (e.g.,
 * numbers and punctuation) which are longer than 60 characters. Again, for the 
 * final 20% of your grade, you cannot assume words have a bounded length.
 */
void processInput() {
  int size = 50;
  char *buffer = malloc(sizeof(char) * size);
  int pos = 0;
  while (1) {
    int c = fgetc(stdin);
    if (feof(stdin)) {
      if (pos > 0) {
        checkWord(buffer, pos);
      }
      break;
    }
    if (!(c >= 'a' && c <= 'z') && !(c >= 'A' && c <= 'Z')) {
      if (pos > 0) {
        checkWord(buffer, pos);
        pos = 0;
      }
      fprintf(stdout, "%c", c);
    } else {
      if (pos == size - 1) {
        char *newBuffer = malloc(sizeof(char) * size * 2);
        size *= 2;
        buffer[pos] = '\0';
        strcpy(newBuffer, buffer);
        free(buffer);
        buffer = newBuffer;
      }
      buffer[pos++] = c;
    }
  }
  free(buffer);
}
