#include <stdio.h>
#include "crypto_aead.h"

void print_testvectors(unsigned char* plaintext,  unsigned long long msglen,
                       unsigned char* ad,         unsigned long long adlen,
                       unsigned char* ciphertext, unsigned long long clen,
                       unsigned char* key,        unsigned char* iv)
{
     unsigned long i, success;

     printf("\n======================\nThe test vectors: \n");
     printf("\nLength of plaintext:       %llu bytes;\nLength of associated data: %llu bytes; \n", msglen, adlen);

     printf("\nThe key is:            ");  for (i = 0; i < 16; i++) printf("%x%x",key[i]>>4, key[i] & 15);
     printf("\nThe iv is:             ");  for (i = 0; i < 16; i++) printf("%x%x",iv[i]>>4, iv[i] & 15);

	 printf("\nThe plaintext is:      ");  for (i = 0; i < msglen; i++) printf("%x%x",plaintext[i]>>4, plaintext[i] & 15);
     printf("\nThe associated data is ");  for (i = 0; i < adlen; i++)  printf("%x%x",ad[i]>>4, ad[i] & 15);

     printf("\n\nNow perform encryption ....\n");
     crypto_aead_encrypt(ciphertext, &clen, plaintext, msglen, ad, adlen, 0, iv, key);

     printf("\nThe ciphertext is:     ");  for (i = 0; i < msglen; i++) printf("%x%x",ciphertext[i]>>4, ciphertext[i] & 15);
     printf("\nThe tag is:            ");  for (i = 0; i < 16; i++)     printf("%x%x",ciphertext[i+msglen]>>4, ciphertext[i+msglen] & 15);

     printf("\n\nNow perform decryption ....\n");
     for (i = 0; i < msglen; i++)  plaintext[i] = 0;
     success = crypto_aead_decrypt(plaintext, &msglen, 0, ciphertext, clen, ad, adlen, iv, key);
     if (success == 0) printf("\nThe verification is successful in decryption");
     else printf("\nThe verification failed in decryption");
     printf("\nThe plaintext is:      "); for (i = 0; i < msglen; i++) printf("%x%x",plaintext[i]>>4, plaintext[i] & 15);
     printf("\nThe ciphertext is:     "); for (i = 0; i < clen-16; i++) printf("%x%x",ciphertext[i]>>4,  ciphertext[i] & 15);
     printf("\n\n\n");
}

int main()
{
     unsigned char plaintext[4096];
     unsigned char ad[4096];
     unsigned char ciphertext[4096];
     unsigned char key[16];
     unsigned char iv[16];
     unsigned char mac[16];
     unsigned long long  msglen, adlen, clen;    // msg, adlen, clen in bytes.
     unsigned char maclen = 16;
     unsigned int  success;
     unsigned long i;

     //===============================================================
     msglen =  0;
     adlen  =  0;
     for (i = 0; i < 16; i++)  key[i] = 0;
     for (i = 0; i < 16; i++)  iv[i]  = 0;

     for (i = 0; i < adlen;  i++)  ad[i] = 0;
     for (i = 0; i < msglen; i++)  plaintext[i]  = 0;

     print_testvectors(plaintext, msglen, ad, adlen, ciphertext, clen, key, iv);

     //===============================================================
     msglen =  1;
     adlen  =  0;
     for (i = 0; i < 16; i++)  key[i] = 0;
     for (i = 0; i < 16; i++)  iv[i]  = 0;

     for (i = 0; i < adlen;  i++)  ad[i] = 0;
     for (i = 0; i < msglen; i++)  plaintext[i]  = 1;

     print_testvectors(plaintext, msglen, ad, adlen, ciphertext, clen, key, iv);

     //===============================================================
     msglen =  0;
     adlen  =  1;
     for (i = 0; i < 16; i++)  key[i] = 0;
     for (i = 0; i < 16; i++)  iv[i]  = 0;

     for (i = 0; i < adlen;  i++)  ad[i] = 1;
     for (i = 0; i < msglen; i++)  plaintext[i]  = 0;

     print_testvectors(plaintext, msglen, ad, adlen, ciphertext, clen, key, iv);

     //===============================================================
     msglen =  1;
     adlen  =  1;
     for (i = 0; i < 16; i++)  key[i] = 0;
     for (i = 0; i < 16; i++)  iv[i]  = 0;
     key[0] = 1;

     for (i = 0; i < adlen;  i++)  ad[i] = 0;
     for (i = 0; i < msglen; i++)  plaintext[i]  = 0;

     print_testvectors(plaintext, msglen, ad, adlen, ciphertext, clen, key, iv);


     //===============================================================
     msglen =  1;
     adlen  =  1;
     for (i = 0; i < 16; i++)  key[i] = 0;
     for (i = 0; i < 16; i++)  iv[i]  = 0;
     iv[0] = 1;

     for (i = 0; i < adlen;  i++)  ad[i] = 0;
     for (i = 0; i < msglen; i++)  plaintext[i]  = 0;

     print_testvectors(plaintext, msglen, ad, adlen, ciphertext, clen, key, iv);

     //===============================================================
     msglen =  16;
     adlen  =  16;
     for (i = 0; i < 16; i++)  key[i] = 1;
     for (i = 0; i < 16; i++)  iv[i]  = 1;

     for (i = 0; i < adlen;  i++)  ad[i] = 1;
     for (i = 0; i < msglen; i++)  plaintext[i]  = 1;

     print_testvectors(plaintext, msglen, ad, adlen, ciphertext, clen, key, iv);

     //===============================================================
     msglen =  16;
     adlen  =  16;
     for (i = 0; i < 16; i++)  key[i] = i;
     for (i = 0; i < 16; i++)  iv[i]  = 3*i;

     for (i = 0; i < adlen;  i++)  ad[i] = 1;
     for (i = 0; i < msglen; i++)  plaintext[i]  = 1;

     print_testvectors(plaintext, msglen, ad, adlen, ciphertext, clen, key, iv);


     //===============================================================
     msglen =  64+9;
     adlen  =  32+7;
     for (i = 0; i < 16; i++)  key[i] = i;
     for (i = 0; i < 16; i++)  iv[i]  = i*3;

     for (i = 0; i < adlen;  i++)  ad[i] = (i*5)%256;
     for (i = 0; i < msglen; i++)  plaintext[i]  = (i*7)%256;

     print_testvectors(plaintext, msglen, ad, adlen, ciphertext, clen, key, iv);

     //===============================================================
     msglen =  1024+7;
     adlen  =  512+2;
     for (i = 0; i < 16; i++)  key[i] = i;
     for (i = 0; i < 16; i++)  iv[i]  = i*3;

     for (i = 0; i < adlen;  i++)  ad[i] = (i*5)%256;
     for (i = 0; i < msglen; i++)  plaintext[i]  = (i*7)%256;

     print_testvectors(plaintext, msglen, ad, adlen, ciphertext, clen, key, iv);

	 return 0;
}
