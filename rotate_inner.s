@ extern void RotateVertices (float* vert_out, float* vert_in, int num_vertices, 
@                             float* matrix3x3);

@ r0 -> float* vert_out
@ r1 -> float* vert_in
@ r2 -> int num_vertices
@ r3 -> float* matrix3x3

.global RotateVertices

RotateVertices:

  @ Read values from Matrix
  flds    s3, [r3,#0]          @ matrix_3x3[0]
  flds    s4, [r3,#4]          @ matrix_3x3[1]
  flds    s5, [r3,#8]          @ matrix_3x3[2]
  flds    s6, [r3,#12]         @ matrix_3x3[3]
  flds    s7, [r3,#16]         @ matrix_3x3[4]
  flds    s8, [r3,#20]         @ matrix_3x3[5]
  flds    s9, [r3,#24]         @ matrix_3x3[6]
  flds    s10,[r3,#28]         @ matrix_3x3[7]
  flds    s11,[r3,#32]         @ matrix_3x3[8]

rotate_loop:
  cmp     r2,#0
  ble     rotate_done
  
  @Read values from vertex pointer
  flds    s0,[r1,#0]          @ float vx = *vert_in
  flds    s1,[r1,#4]          @ float vy = *vert_in
  flds    s2,[r1,#8]          @ float vz = *vert_in
  add     r1,r1,#12           @ vert_in++
  
  @ Calculate new vertices
  fmuls   s12,s0,s3           @ x = vx * matrix3x3[0]
  fmuls   s14,s0,s9           @ z = vx * matrix3x3[6]
  fmuls   s13,s0,s6           @ y = vx * matrix3x3[3]
  
  fmacs   s12,s1,s4           @ x = x + vy * matrix3x3[1]
  fmacs   s12,s2,s5           @ x = x + vz * matrix3x3[2]
  
  fmacs   s13,s1,s7           @ y = y + vy * matrix3x3[4]
  fmacs   s13,s2,s8           @ y = y + vz * matrix3x3[5]
  
  fmacs   s14,s1,s10          @ z = z + vy * matrix3x3[7]
  fmacs   s14,s2,s11          @ z = z + vz * matrix3x3[8]
  
  @Write new vertices in pointer
  fsts    s12,[r0,#0]         @ *vert_out = x
  fsts    s13,[r0,#4]         @ *vert_out = y
  fsts    s14,[r0,#8]         @ *vert_out = z
  add     r0,r0,#12           @ vert_out++
  
  sub     r2,r2,#1            @ num_vertices--

  b     rotate_loop
rotate_done:
  bx    lr



/*

while(num_vertices > 0) {
    float vx = *vert_in++;
    float vy = *vert_in++;
    float vz = *vert_in++;

    float x = vx * matrix3x3[0] + vy * matrix3x3[1] + vz * matrix3x3[2];
    float y = vx * matrix3x3[3] + vy * matrix3x3[4] + vz * matrix3x3[5];
    float z = vx * matrix3x3[6] + vy * matrix3x3[7] + vz * matrix3x3[8];

    *vert_out++ = x;
    *vert_out++ = y;
    *vert_out++ = z;

    num_vertices--;
  }

*/

