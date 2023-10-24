@ extern void DisplayVertices (float* vertices, int n_vertices, const t_screen* scr);
@ r0 -> vertices
@ r1 -> n_vertices
@ r2 -> scr

@typedef struct {
@  unsigned int* pixels;      // 0
@  int stride;                // 4
@  int w, h;                  // 8, 12
@} t_screen;

  .global DisplayVertices

DisplayVertices:

  stmdb   sp!,{r4,r5,r6,r7,r8,r9,r10,r11,r12,r14}
  
  ldr     r3,[r2,#4]          @ scr->stride
  ldr     r4,[r2,#8]          @ scr->w
  mov     r4,r4,asr#1         @ scr->w >> 1
  ldr     r5,[r2,#12]         @ scr->h
  mov     r5,r5,asr#1         @ scr->h >> 1
  ldr     r12,[r2,#0]         @ scr->pixels

  mov     r6,#0               @ i = 0    
for_loop:
  cmp     r6,r1               @ i < n_vertices
  bge     end_loop
  
  flds    s0,[r0,#0]          @ vertices[i * 3 + 0]
  ftosis  s1,s0               @ s1 = (int) s0
  fsts    s1,[sp,#-4]
  ldr     r8,[sp,#-4]         @ (int) vertices[i * 3 + 0]
  add     r8,r4,r8            @ xp = (scr->w >> 1) + (int) vertices[i * 3 + 0]
  
  flds    s2,[r0,#4]          @ vertices[i * 3 + 1]
  ftosis  s3,s2               @ s3 = (int) s2
  fsts    s3,[sp,#-8]
  ldr     r9,[sp,#-8]         @ (int) vertices[i * 3 + 1]
  add     r9,r5,r9            @ yp = (scr->h >> 1) + (int) vertices[i * 3 + 0]
    
  mla     r9,r9,r3,r8         @ yp * src->stride + xp  
  
  add     r0,r0,#12           @ vertices = i*3
  
  mov     r10,#0xff
  and     r10,r6,r10          @ i & 0xff
  mov     r11,#0x7f00
  orr     r11,r11,#0x7f0000
  orr     r11,r10,r11         @ (i & 0xff) | 0x7f7f00
  str     r11,[r12,r9,lsl#2]        @ src->pixel[xp + yp * scr->stride] = (i & 0xff) | 0x7f7f00
 
  add     r6,r6,#1            @ i++
  b       for_loop
end_loop:

  ldmia   sp!,{r4,r5,r6,r7,r8,r9,r10,r11,r12,r14}

  bx      lr


/*
{
  int i;
  for(i = 0; i < n_vertices; i++) {
      int xp = (scr->w >> 1) + (int)vertices[i * 3 + 0];
      int yp = (scr->h >> 1) + (int)vertices[i * 3 + 1];
      scr->pixels [xp + yp * scr->stride] = (i & 0xff) | 0x7f7f00;
  } 
}
*/
