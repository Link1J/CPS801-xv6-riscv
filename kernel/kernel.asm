
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	45013103          	ld	sp,1104(sp) # 8000a450 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdae1f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	1c8020ef          	jal	800022c2 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00012517          	auipc	a0,0x12
    80000158:	35c50513          	addi	a0,a0,860 # 800124b0 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00012497          	auipc	s1,0x12
    80000164:	35048493          	addi	s1,s1,848 # 800124b0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00012917          	auipc	s2,0x12
    8000016c:	3e090913          	addi	s2,s2,992 # 80012548 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	7d1010ef          	jal	80002154 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	58f010ef          	jal	80001f1c <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00012717          	auipc	a4,0x12
    800001a4:	31070713          	addi	a4,a4,784 # 800124b0 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	0a6020ef          	jal	80002278 <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	00012517          	auipc	a0,0x12
    800001ee:	2c650513          	addi	a0,a0,710 # 800124b0 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00012717          	auipc	a4,0x12
    80000218:	32f72a23          	sw	a5,820(a4) # 80012548 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00012517          	auipc	a0,0x12
    8000022e:	28650513          	addi	a0,a0,646 # 800124b0 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	00012517          	auipc	a0,0x12
    80000282:	23250513          	addi	a0,a0,562 # 800124b0 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	06c020ef          	jal	8000230c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	00012517          	auipc	a0,0x12
    800002a8:	20c50513          	addi	a0,a0,524 # 800124b0 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	00012717          	auipc	a4,0x12
    800002c6:	1ee70713          	addi	a4,a4,494 # 800124b0 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	00012797          	auipc	a5,0x12
    800002ec:	1c878793          	addi	a5,a5,456 # 800124b0 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	00012797          	auipc	a5,0x12
    8000031a:	2327a783          	lw	a5,562(a5) # 80012548 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	00012717          	auipc	a4,0x12
    80000330:	18470713          	addi	a4,a4,388 # 800124b0 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	00012497          	auipc	s1,0x12
    80000340:	17448493          	addi	s1,s1,372 # 800124b0 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	00012717          	auipc	a4,0x12
    80000382:	13270713          	addi	a4,a4,306 # 800124b0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00012717          	auipc	a4,0x12
    80000398:	1af72e23          	sw	a5,444(a4) # 80012550 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	00012797          	auipc	a5,0x12
    800003b6:	0fe78793          	addi	a5,a5,254 # 800124b0 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00012797          	auipc	a5,0x12
    800003da:	16c7ab23          	sw	a2,374(a5) # 8001254c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00012517          	auipc	a0,0x12
    800003e2:	16a50513          	addi	a0,a0,362 # 80012548 <cons+0x98>
    800003e6:	383010ef          	jal	80001f68 <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	00012517          	auipc	a0,0x12
    80000400:	0b450513          	addi	a0,a0,180 # 800124b0 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00022797          	auipc	a5,0x22
    80000410:	43c78793          	addi	a5,a5,1084 # 80022848 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	39a60613          	addi	a2,a2,922 # 800077e0 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	00012797          	auipc	a5,0x12
    800004e4:	0907a783          	lw	a5,144(a5) # 80012570 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	00012517          	auipc	a0,0x12
    80000530:	02c50513          	addi	a0,a0,44 # 80012558 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	0f4b8b93          	addi	s7,s7,244 # 800077e0 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	00012517          	auipc	a0,0x12
    8000078a:	dd250513          	addi	a0,a0,-558 # 80012558 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	00012797          	auipc	a5,0x12
    800007a4:	dc07a823          	sw	zero,-560(a5) # 80012570 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	0000a717          	auipc	a4,0xa
    800007c8:	caf72623          	sw	a5,-852(a4) # 8000a470 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	00012497          	auipc	s1,0x12
    800007dc:	d8048493          	addi	s1,s1,-640 # 80012558 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	00012517          	auipc	a0,0x12
    80000844:	d3850513          	addi	a0,a0,-712 # 80012578 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	0000a797          	auipc	a5,0xa
    80000868:	c0c7a783          	lw	a5,-1012(a5) # 8000a470 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	0000a797          	auipc	a5,0xa
    8000089e:	bde7b783          	ld	a5,-1058(a5) # 8000a478 <uart_tx_r>
    800008a2:	0000a717          	auipc	a4,0xa
    800008a6:	bde73703          	ld	a4,-1058(a4) # 8000a480 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	00012a97          	auipc	s5,0x12
    800008cc:	cb0a8a93          	addi	s5,s5,-848 # 80012578 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	0000a497          	auipc	s1,0xa
    800008d4:	ba848493          	addi	s1,s1,-1112 # 8000a478 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	0000a997          	auipc	s3,0xa
    800008e0:	ba498993          	addi	s3,s3,-1116 # 8000a480 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	66a010ef          	jal	80001f68 <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	00012517          	auipc	a0,0x12
    80000950:	c2c50513          	addi	a0,a0,-980 # 80012578 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	0000a797          	auipc	a5,0xa
    8000095c:	b187a783          	lw	a5,-1256(a5) # 8000a470 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	0000a717          	auipc	a4,0xa
    80000966:	b1e73703          	ld	a4,-1250(a4) # 8000a480 <uart_tx_w>
    8000096a:	0000a797          	auipc	a5,0xa
    8000096e:	b0e7b783          	ld	a5,-1266(a5) # 8000a478 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	00012997          	auipc	s3,0x12
    8000097a:	c0298993          	addi	s3,s3,-1022 # 80012578 <uart_tx_lock>
    8000097e:	0000a497          	auipc	s1,0xa
    80000982:	afa48493          	addi	s1,s1,-1286 # 8000a478 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	0000a917          	auipc	s2,0xa
    8000098a:	afa90913          	addi	s2,s2,-1286 # 8000a480 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	586010ef          	jal	80001f1c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	bd048493          	addi	s1,s1,-1072 # 80012578 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	0000a797          	auipc	a5,0xa
    800009c0:	ace7b223          	sd	a4,-1340(a5) # 8000a480 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	00012497          	auipc	s1,0x12
    80000a24:	b5848493          	addi	s1,s1,-1192 # 80012578 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00023797          	auipc	a5,0x23
    80000a5a:	f8a78793          	addi	a5,a5,-118 # 800239e0 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	00012917          	auipc	s2,0x12
    80000a76:	b3e90913          	addi	s2,s2,-1218 # 800125b0 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	00012517          	auipc	a0,0x12
    80000b04:	ab050513          	addi	a0,a0,-1360 # 800125b0 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00023517          	auipc	a0,0x23
    80000b14:	ed050513          	addi	a0,a0,-304 # 800239e0 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	00012497          	auipc	s1,0x12
    80000b32:	a8248493          	addi	s1,s1,-1406 # 800125b0 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00012517          	auipc	a0,0x12
    80000b46:	a6e50513          	addi	a0,a0,-1426 # 800125b0 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	00012517          	auipc	a0,0x12
    80000b6a:	a4a50513          	addi	a0,a0,-1462 # 800125b0 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	485000ef          	jal	800018c4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ca6:	0310000f          	fence	rw,w
    80000caa:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb621>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00009717          	auipc	a4,0x9
    80000e72:	61a70713          	addi	a4,a4,1562 # 8000a488 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	0ed010ef          	jal	80002784 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	07d040ef          	jal	80005718 <plicinithart>
  }

  scheduler();        
    80000ea0:	67f000ef          	jal	80001d1e <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	123000ef          	jal	800017fe <procinit>
    trapinit();      // trap vectors
    80000ee0:	081010ef          	jal	80002760 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	0a1010ef          	jal	80002784 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	017040ef          	jal	800056fe <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	02d040ef          	jal	80005718 <plicinithart>
    binit();         // buffer cache
    80000ef0:	7db010ef          	jal	80002eca <binit>
    iinit();         // inode table
    80000ef4:	5cc020ef          	jal	800034c0 <iinit>
    fileinit();      // file table
    80000ef8:	378030ef          	jal	80004270 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	10d040ef          	jal	80005808 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	453000ef          	jal	80001b52 <userinit>
    __sync_synchronize();
    80000f04:	0330000f          	fence	rw,rw
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00009717          	auipc	a4,0x9
    80000f0e:	56f72f23          	sw	a5,1406(a4) # 8000a488 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00009797          	auipc	a5,0x9
    80000f22:	5727b783          	ld	a5,1394(a5) # 8000a490 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb617>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00009797          	auipc	a5,0x9
    800011ae:	2ea7b323          	sd	a0,742(a5) # 8000a490 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	00011497          	auipc	s1,0x11
    80001780:	28448493          	addi	s1,s1,644 # 80012a00 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	ff4df937          	lui	s2,0xff4df
    8000178a:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bafdd>
    8000178e:	0936                	slli	s2,s2,0xd
    80001790:	6f590913          	addi	s2,s2,1781
    80001794:	0936                	slli	s2,s2,0xd
    80001796:	bd390913          	addi	s2,s2,-1069
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	7a790913          	addi	s2,s2,1959
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00017a97          	auipc	s5,0x17
    800017ac:	e58a8a93          	addi	s5,s5,-424 # 80018600 <tickslock>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	8591                	srai	a1,a1,0x4
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	17048493          	addi	s1,s1,368
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	a0650513          	addi	a0,a0,-1530 # 800071f8 <etext+0x1f8>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9ee58593          	addi	a1,a1,-1554 # 80007200 <etext+0x200>
    8000181a:	00011517          	auipc	a0,0x11
    8000181e:	db650513          	addi	a0,a0,-586 # 800125d0 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9e258593          	addi	a1,a1,-1566 # 80007208 <etext+0x208>
    8000182e:	00011517          	auipc	a0,0x11
    80001832:	dba50513          	addi	a0,a0,-582 # 800125e8 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	00011497          	auipc	s1,0x11
    8000183e:	1c648493          	addi	s1,s1,454 # 80012a00 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9d6b0b13          	addi	s6,s6,-1578 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	ff4df937          	lui	s2,0xff4df
    80001850:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bafdd>
    80001854:	0936                	slli	s2,s2,0xd
    80001856:	6f590913          	addi	s2,s2,1781
    8000185a:	0936                	slli	s2,s2,0xd
    8000185c:	bd390913          	addi	s2,s2,-1069
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	7a790913          	addi	s2,s2,1959
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00017a17          	auipc	s4,0x17
    80001872:	d92a0a13          	addi	s4,s4,-622 # 80018600 <tickslock>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	8791                	srai	a5,a5,0x4
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	17048493          	addi	s1,s1,368
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
  }
}
    800018a0:	70e2                	ld	ra,56(sp)
    800018a2:	7442                	ld	s0,48(sp)
    800018a4:	74a2                	ld	s1,40(sp)
    800018a6:	7902                	ld	s2,32(sp)
    800018a8:	69e2                	ld	s3,24(sp)
    800018aa:	6a42                	ld	s4,16(sp)
    800018ac:	6aa2                	ld	s5,8(sp)
    800018ae:	6b02                	ld	s6,0(sp)
    800018b0:	6121                	addi	sp,sp,64
    800018b2:	8082                	ret

00000000800018b4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ba:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d0:	00011517          	auipc	a0,0x11
    800018d4:	d3050513          	addi	a0,a0,-720 # 80012600 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
  push_off();
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	00011717          	auipc	a4,0x11
    800018f8:	cdc70713          	addi	a4,a4,-804 # 800125d0 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>

  if (first) {
    80001920:	00009797          	auipc	a5,0x9
    80001924:	ae07a783          	lw	a5,-1312(a5) # 8000a400 <first.2>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	673000ef          	jal	8000279c <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	31d010ef          	jal	80003454 <fsinit>
    first = 0;
    8000193c:	00009797          	auipc	a5,0x9
    80001940:	ac07a223          	sw	zero,-1340(a5) # 8000a400 <first.2>
    __sync_synchronize();
    80001944:	0330000f          	fence	rw,rw
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
{
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001956:	00011917          	auipc	s2,0x11
    8000195a:	c7a90913          	addi	s2,s2,-902 # 800125d0 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00009797          	auipc	a5,0x9
    80001968:	aa078793          	addi	a5,a5,-1376 # 8000a404 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
}
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <proc_pagetable>:
{
    80001988:	1101                	addi	sp,sp,-32
    8000198a:	ec06                	sd	ra,24(sp)
    8000198c:	e822                	sd	s0,16(sp)
    8000198e:	e426                	sd	s1,8(sp)
    80001990:	e04a                	sd	s2,0(sp)
    80001992:	1000                	addi	s0,sp,32
    80001994:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001996:	8e1ff0ef          	jal	80001276 <uvmcreate>
    8000199a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000199c:	cd05                	beqz	a0,800019d4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199e:	4729                	li	a4,10
    800019a0:	00004697          	auipc	a3,0x4
    800019a4:	66068693          	addi	a3,a3,1632 # 80006000 <_trampoline>
    800019a8:	6605                	lui	a2,0x1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	e62ff0ef          	jal	80001014 <mappages>
    800019b6:	02054663          	bltz	a0,800019e2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ba:	4719                	li	a4,6
    800019bc:	05893683          	ld	a3,88(s2)
    800019c0:	6605                	lui	a2,0x1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	e48ff0ef          	jal	80001014 <mappages>
    800019d0:	00054f63          	bltz	a0,800019ee <proc_pagetable+0x66>
}
    800019d4:	8526                	mv	a0,s1
    800019d6:	60e2                	ld	ra,24(sp)
    800019d8:	6442                	ld	s0,16(sp)
    800019da:	64a2                	ld	s1,8(sp)
    800019dc:	6902                	ld	s2,0(sp)
    800019de:	6105                	addi	sp,sp,32
    800019e0:	8082                	ret
    uvmfree(pagetable, 0);
    800019e2:	4581                	li	a1,0
    800019e4:	8526                	mv	a0,s1
    800019e6:	a5fff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019ea:	4481                	li	s1,0
    800019ec:	b7e5                	j	800019d4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	040005b7          	lui	a1,0x4000
    800019f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	05b2                	slli	a1,a1,0xc
    800019fa:	8526                	mv	a0,s1
    800019fc:	fbeff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a00:	4581                	li	a1,0
    80001a02:	8526                	mv	a0,s1
    80001a04:	a41ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a08:	4481                	li	s1,0
    80001a0a:	b7e9                	j	800019d4 <proc_pagetable+0x4c>

0000000080001a0c <proc_freepagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	f92ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a2c:	4681                	li	a3,0
    80001a2e:	4605                	li	a2,1
    80001a30:	020005b7          	lui	a1,0x2000
    80001a34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a36:	05b6                	slli	a1,a1,0xd
    80001a38:	8526                	mv	a0,s1
    80001a3a:	f80ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3e:	85ca                	mv	a1,s2
    80001a40:	8526                	mv	a0,s1
    80001a42:	a03ff0ef          	jal	80001444 <uvmfree>
}
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6902                	ld	s2,0(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <freeproc>:
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
    80001a5c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5e:	6d28                	ld	a0,88(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a66:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a6a:	68a8                	ld	a0,80(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	64ac                	ld	a1,72(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a74:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a78:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a7c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a80:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a84:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a88:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a8c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a90:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a94:	0004ac23          	sw	zero,24(s1)
}
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <allocproc>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aae:	00011497          	auipc	s1,0x11
    80001ab2:	f5248493          	addi	s1,s1,-174 # 80012a00 <proc>
    80001ab6:	00017917          	auipc	s2,0x17
    80001aba:	b4a90913          	addi	s2,s2,-1206 # 80018600 <tickslock>
    acquire(&p->lock);
    80001abe:	8526                	mv	a0,s1
    80001ac0:	934ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ac4:	4c9c                	lw	a5,24(s1)
    80001ac6:	cb91                	beqz	a5,80001ada <allocproc+0x38>
      release(&p->lock);
    80001ac8:	8526                	mv	a0,s1
    80001aca:	9c2ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ace:	17048493          	addi	s1,s1,368
    80001ad2:	ff2496e3          	bne	s1,s2,80001abe <allocproc+0x1c>
  return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	a0b1                	j	80001b24 <allocproc+0x82>
  p->pid = allocpid();
    80001ada:	e71ff0ef          	jal	8000194a <allocpid>
    80001ade:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae0:	4785                	li	a5,1
    80001ae2:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae4:	840ff0ef          	jal	80000b24 <kalloc>
    80001ae8:	892a                	mv	s2,a0
    80001aea:	eca8                	sd	a0,88(s1)
    80001aec:	c139                	beqz	a0,80001b32 <allocproc+0x90>
  p->pagetable = proc_pagetable(p);
    80001aee:	8526                	mv	a0,s1
    80001af0:	e99ff0ef          	jal	80001988 <proc_pagetable>
    80001af4:	892a                	mv	s2,a0
    80001af6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001af8:	c529                	beqz	a0,80001b42 <allocproc+0xa0>
  memset(&p->context, 0, sizeof(p->context));
    80001afa:	07000613          	li	a2,112
    80001afe:	4581                	li	a1,0
    80001b00:	06048513          	addi	a0,s1,96
    80001b04:	9c4ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b08:	00000797          	auipc	a5,0x0
    80001b0c:	e0878793          	addi	a5,a5,-504 # 80001910 <forkret>
    80001b10:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b12:	60bc                	ld	a5,64(s1)
    80001b14:	6705                	lui	a4,0x1
    80001b16:	97ba                	add	a5,a5,a4
    80001b18:	f4bc                	sd	a5,104(s1)
  p->priority = 2;  // Default priority
    80001b1a:	4789                	li	a5,2
    80001b1c:	16f4a423          	sw	a5,360(s1)
  p->burst = 0; 
    80001b20:	1604a623          	sw	zero,364(s1)
}
    80001b24:	8526                	mv	a0,s1
    80001b26:	60e2                	ld	ra,24(sp)
    80001b28:	6442                	ld	s0,16(sp)
    80001b2a:	64a2                	ld	s1,8(sp)
    80001b2c:	6902                	ld	s2,0(sp)
    80001b2e:	6105                	addi	sp,sp,32
    80001b30:	8082                	ret
    freeproc(p);
    80001b32:	8526                	mv	a0,s1
    80001b34:	f1fff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b38:	8526                	mv	a0,s1
    80001b3a:	952ff0ef          	jal	80000c8c <release>
    return 0;
    80001b3e:	84ca                	mv	s1,s2
    80001b40:	b7d5                	j	80001b24 <allocproc+0x82>
    freeproc(p);
    80001b42:	8526                	mv	a0,s1
    80001b44:	f0fff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b48:	8526                	mv	a0,s1
    80001b4a:	942ff0ef          	jal	80000c8c <release>
    return 0;
    80001b4e:	84ca                	mv	s1,s2
    80001b50:	bfd1                	j	80001b24 <allocproc+0x82>

0000000080001b52 <userinit>:
{
    80001b52:	1101                	addi	sp,sp,-32
    80001b54:	ec06                	sd	ra,24(sp)
    80001b56:	e822                	sd	s0,16(sp)
    80001b58:	e426                	sd	s1,8(sp)
    80001b5a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b5c:	f47ff0ef          	jal	80001aa2 <allocproc>
    80001b60:	84aa                	mv	s1,a0
  initproc = p;
    80001b62:	00009797          	auipc	a5,0x9
    80001b66:	92a7bb23          	sd	a0,-1738(a5) # 8000a498 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b6a:	03400613          	li	a2,52
    80001b6e:	00009597          	auipc	a1,0x9
    80001b72:	8a258593          	addi	a1,a1,-1886 # 8000a410 <initcode>
    80001b76:	6928                	ld	a0,80(a0)
    80001b78:	f24ff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b7c:	6785                	lui	a5,0x1
    80001b7e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b80:	6cb8                	ld	a4,88(s1)
    80001b82:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b86:	6cb8                	ld	a4,88(s1)
    80001b88:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b8a:	4641                	li	a2,16
    80001b8c:	00005597          	auipc	a1,0x5
    80001b90:	69458593          	addi	a1,a1,1684 # 80007220 <etext+0x220>
    80001b94:	15848513          	addi	a0,s1,344
    80001b98:	a6eff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001b9c:	00005517          	auipc	a0,0x5
    80001ba0:	69450513          	addi	a0,a0,1684 # 80007230 <etext+0x230>
    80001ba4:	1be020ef          	jal	80003d62 <namei>
    80001ba8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bac:	478d                	li	a5,3
    80001bae:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	8daff0ef          	jal	80000c8c <release>
}
    80001bb6:	60e2                	ld	ra,24(sp)
    80001bb8:	6442                	ld	s0,16(sp)
    80001bba:	64a2                	ld	s1,8(sp)
    80001bbc:	6105                	addi	sp,sp,32
    80001bbe:	8082                	ret

0000000080001bc0 <growproc>:
{
    80001bc0:	1101                	addi	sp,sp,-32
    80001bc2:	ec06                	sd	ra,24(sp)
    80001bc4:	e822                	sd	s0,16(sp)
    80001bc6:	e426                	sd	s1,8(sp)
    80001bc8:	e04a                	sd	s2,0(sp)
    80001bca:	1000                	addi	s0,sp,32
    80001bcc:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bce:	d13ff0ef          	jal	800018e0 <myproc>
    80001bd2:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bd4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bd6:	01204c63          	bgtz	s2,80001bee <growproc+0x2e>
  } else if(n < 0){
    80001bda:	02094463          	bltz	s2,80001c02 <growproc+0x42>
  p->sz = sz;
    80001bde:	e4ac                	sd	a1,72(s1)
  return 0;
    80001be0:	4501                	li	a0,0
}
    80001be2:	60e2                	ld	ra,24(sp)
    80001be4:	6442                	ld	s0,16(sp)
    80001be6:	64a2                	ld	s1,8(sp)
    80001be8:	6902                	ld	s2,0(sp)
    80001bea:	6105                	addi	sp,sp,32
    80001bec:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bee:	4691                	li	a3,4
    80001bf0:	00b90633          	add	a2,s2,a1
    80001bf4:	6928                	ld	a0,80(a0)
    80001bf6:	f48ff0ef          	jal	8000133e <uvmalloc>
    80001bfa:	85aa                	mv	a1,a0
    80001bfc:	f16d                	bnez	a0,80001bde <growproc+0x1e>
      return -1;
    80001bfe:	557d                	li	a0,-1
    80001c00:	b7cd                	j	80001be2 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c02:	00b90633          	add	a2,s2,a1
    80001c06:	6928                	ld	a0,80(a0)
    80001c08:	ef2ff0ef          	jal	800012fa <uvmdealloc>
    80001c0c:	85aa                	mv	a1,a0
    80001c0e:	bfc1                	j	80001bde <growproc+0x1e>

0000000080001c10 <fork>:
{
    80001c10:	7139                	addi	sp,sp,-64
    80001c12:	fc06                	sd	ra,56(sp)
    80001c14:	f822                	sd	s0,48(sp)
    80001c16:	f04a                	sd	s2,32(sp)
    80001c18:	e456                	sd	s5,8(sp)
    80001c1a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c1c:	cc5ff0ef          	jal	800018e0 <myproc>
    80001c20:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c22:	e81ff0ef          	jal	80001aa2 <allocproc>
    80001c26:	0e050a63          	beqz	a0,80001d1a <fork+0x10a>
    80001c2a:	e852                	sd	s4,16(sp)
    80001c2c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c2e:	048ab603          	ld	a2,72(s5)
    80001c32:	692c                	ld	a1,80(a0)
    80001c34:	050ab503          	ld	a0,80(s5)
    80001c38:	83fff0ef          	jal	80001476 <uvmcopy>
    80001c3c:	04054a63          	bltz	a0,80001c90 <fork+0x80>
    80001c40:	f426                	sd	s1,40(sp)
    80001c42:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c44:	048ab783          	ld	a5,72(s5)
    80001c48:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c4c:	058ab683          	ld	a3,88(s5)
    80001c50:	87b6                	mv	a5,a3
    80001c52:	058a3703          	ld	a4,88(s4)
    80001c56:	12068693          	addi	a3,a3,288
    80001c5a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c5e:	6788                	ld	a0,8(a5)
    80001c60:	6b8c                	ld	a1,16(a5)
    80001c62:	6f90                	ld	a2,24(a5)
    80001c64:	01073023          	sd	a6,0(a4)
    80001c68:	e708                	sd	a0,8(a4)
    80001c6a:	eb0c                	sd	a1,16(a4)
    80001c6c:	ef10                	sd	a2,24(a4)
    80001c6e:	02078793          	addi	a5,a5,32
    80001c72:	02070713          	addi	a4,a4,32
    80001c76:	fed792e3          	bne	a5,a3,80001c5a <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c7a:	058a3783          	ld	a5,88(s4)
    80001c7e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c82:	0d0a8493          	addi	s1,s5,208
    80001c86:	0d0a0913          	addi	s2,s4,208
    80001c8a:	150a8993          	addi	s3,s5,336
    80001c8e:	a831                	j	80001caa <fork+0x9a>
    freeproc(np);
    80001c90:	8552                	mv	a0,s4
    80001c92:	dc1ff0ef          	jal	80001a52 <freeproc>
    release(&np->lock);
    80001c96:	8552                	mv	a0,s4
    80001c98:	ff5fe0ef          	jal	80000c8c <release>
    return -1;
    80001c9c:	597d                	li	s2,-1
    80001c9e:	6a42                	ld	s4,16(sp)
    80001ca0:	a0b5                	j	80001d0c <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001ca2:	04a1                	addi	s1,s1,8
    80001ca4:	0921                	addi	s2,s2,8
    80001ca6:	01348963          	beq	s1,s3,80001cb8 <fork+0xa8>
    if(p->ofile[i])
    80001caa:	6088                	ld	a0,0(s1)
    80001cac:	d97d                	beqz	a0,80001ca2 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cae:	644020ef          	jal	800042f2 <filedup>
    80001cb2:	00a93023          	sd	a0,0(s2)
    80001cb6:	b7f5                	j	80001ca2 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cb8:	150ab503          	ld	a0,336(s5)
    80001cbc:	197010ef          	jal	80003652 <idup>
    80001cc0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cc4:	4641                	li	a2,16
    80001cc6:	158a8593          	addi	a1,s5,344
    80001cca:	158a0513          	addi	a0,s4,344
    80001cce:	938ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cd2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cd6:	8552                	mv	a0,s4
    80001cd8:	fb5fe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cdc:	00011497          	auipc	s1,0x11
    80001ce0:	90c48493          	addi	s1,s1,-1780 # 800125e8 <wait_lock>
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	f0ffe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001cea:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	f9dfe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001cf4:	8552                	mv	a0,s4
    80001cf6:	efffe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001cfa:	478d                	li	a5,3
    80001cfc:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d00:	8552                	mv	a0,s4
    80001d02:	f8bfe0ef          	jal	80000c8c <release>
  return pid;
    80001d06:	74a2                	ld	s1,40(sp)
    80001d08:	69e2                	ld	s3,24(sp)
    80001d0a:	6a42                	ld	s4,16(sp)
}
    80001d0c:	854a                	mv	a0,s2
    80001d0e:	70e2                	ld	ra,56(sp)
    80001d10:	7442                	ld	s0,48(sp)
    80001d12:	7902                	ld	s2,32(sp)
    80001d14:	6aa2                	ld	s5,8(sp)
    80001d16:	6121                	addi	sp,sp,64
    80001d18:	8082                	ret
    return -1;
    80001d1a:	597d                	li	s2,-1
    80001d1c:	bfc5                	j	80001d0c <fork+0xfc>

0000000080001d1e <scheduler>:
{
    80001d1e:	711d                	addi	sp,sp,-96
    80001d20:	ec86                	sd	ra,88(sp)
    80001d22:	e8a2                	sd	s0,80(sp)
    80001d24:	e4a6                	sd	s1,72(sp)
    80001d26:	e0ca                	sd	s2,64(sp)
    80001d28:	fc4e                	sd	s3,56(sp)
    80001d2a:	f852                	sd	s4,48(sp)
    80001d2c:	f456                	sd	s5,40(sp)
    80001d2e:	f05a                	sd	s6,32(sp)
    80001d30:	ec5e                	sd	s7,24(sp)
    80001d32:	e862                	sd	s8,16(sp)
    80001d34:	e466                	sd	s9,8(sp)
    80001d36:	e06a                	sd	s10,0(sp)
    80001d38:	1080                	addi	s0,sp,96
    80001d3a:	8792                	mv	a5,tp
  int id = r_tp();
    80001d3c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d3e:	00779b93          	slli	s7,a5,0x7
    80001d42:	00011717          	auipc	a4,0x11
    80001d46:	88e70713          	addi	a4,a4,-1906 # 800125d0 <pid_lock>
    80001d4a:	975e                	add	a4,a4,s7
    80001d4c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d50:	00011717          	auipc	a4,0x11
    80001d54:	8b870713          	addi	a4,a4,-1864 # 80012608 <cpus+0x8>
    80001d58:	9bba                	add	s7,s7,a4
    int highest_priority = 4;
    80001d5a:	4b11                	li	s6,4
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d5c:	00017997          	auipc	s3,0x17
    80001d60:	8a498993          	addi	s3,s3,-1884 # 80018600 <tickslock>
        c->proc = p;
    80001d64:	079e                	slli	a5,a5,0x7
    80001d66:	00011a97          	auipc	s5,0x11
    80001d6a:	86aa8a93          	addi	s5,s5,-1942 # 800125d0 <pid_lock>
    80001d6e:	9abe                	add	s5,s5,a5
    80001d70:	a075                	j	80001e1c <scheduler+0xfe>
      if(p->state == RUNNABLE && p->priority < highest_priority) {
    80001d72:	00070a1b          	sext.w	s4,a4
      release(&p->lock);
    80001d76:	8526                	mv	a0,s1
    80001d78:	f15fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d7c:	17048493          	addi	s1,s1,368
    80001d80:	03348063          	beq	s1,s3,80001da0 <scheduler+0x82>
      acquire(&p->lock);
    80001d84:	8526                	mv	a0,s1
    80001d86:	e6ffe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE && p->priority < highest_priority) {
    80001d8a:	4c9c                	lw	a5,24(s1)
    80001d8c:	ff2795e3          	bne	a5,s2,80001d76 <scheduler+0x58>
    80001d90:	1684a783          	lw	a5,360(s1)
    80001d94:	873e                	mv	a4,a5
    80001d96:	2781                	sext.w	a5,a5
    80001d98:	fcfa5de3          	bge	s4,a5,80001d72 <scheduler+0x54>
    80001d9c:	8752                	mv	a4,s4
    80001d9e:	bfd1                	j	80001d72 <scheduler+0x54>
    int found = 0;
    80001da0:	4c81                	li	s9,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001da2:	00011497          	auipc	s1,0x11
    80001da6:	c5e48493          	addi	s1,s1,-930 # 80012a00 <proc>
        start = ticks; 
    80001daa:	00008c17          	auipc	s8,0x8
    80001dae:	6f6c0c13          	addi	s8,s8,1782 # 8000a4a0 <ticks>
        found = 1;
    80001db2:	4d05                	li	s10,1
    80001db4:	a801                	j	80001dc4 <scheduler+0xa6>
      release(&p->lock);
    80001db6:	8526                	mv	a0,s1
    80001db8:	ed5fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dbc:	17048493          	addi	s1,s1,368
    80001dc0:	05348463          	beq	s1,s3,80001e08 <scheduler+0xea>
      acquire(&p->lock);
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	e2ffe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE && p->priority == highest_priority) {
    80001dca:	4c9c                	lw	a5,24(s1)
    80001dcc:	ff2795e3          	bne	a5,s2,80001db6 <scheduler+0x98>
    80001dd0:	1684a783          	lw	a5,360(s1)
    80001dd4:	ff4791e3          	bne	a5,s4,80001db6 <scheduler+0x98>
        p->state = RUNNING;
    80001dd8:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001ddc:	029ab823          	sd	s1,48(s5)
        start = ticks; 
    80001de0:	000c2c83          	lw	s9,0(s8)
        swtch(&c->context, &p->context);
    80001de4:	06048593          	addi	a1,s1,96
    80001de8:	855e                	mv	a0,s7
    80001dea:	10d000ef          	jal	800026f6 <swtch>
        c->proc = 0; // Process done running
    80001dee:	020ab823          	sd	zero,48(s5)
        p->burst += (end - start); 
    80001df2:	000c2783          	lw	a5,0(s8)
    80001df6:	419787bb          	subw	a5,a5,s9
    80001dfa:	16c4a703          	lw	a4,364(s1)
    80001dfe:	9fb9                	addw	a5,a5,a4
    80001e00:	16f4a623          	sw	a5,364(s1)
        found = 1;
    80001e04:	8cea                	mv	s9,s10
    80001e06:	bf45                	j	80001db6 <scheduler+0x98>
    if(found == 0) {
    80001e08:	000c9b63          	bnez	s9,80001e1e <scheduler+0x100>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e0c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e10:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e14:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001e18:	10500073          	wfi
      if(p->state == RUNNABLE && p->priority < highest_priority) {
    80001e1c:	490d                	li	s2,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e1e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e22:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e26:	10079073          	csrw	sstatus,a5
    int highest_priority = 4;
    80001e2a:	8a5a                	mv	s4,s6
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e2c:	00011497          	auipc	s1,0x11
    80001e30:	bd448493          	addi	s1,s1,-1068 # 80012a00 <proc>
    80001e34:	bf81                	j	80001d84 <scheduler+0x66>

0000000080001e36 <sched>:
{
    80001e36:	7179                	addi	sp,sp,-48
    80001e38:	f406                	sd	ra,40(sp)
    80001e3a:	f022                	sd	s0,32(sp)
    80001e3c:	ec26                	sd	s1,24(sp)
    80001e3e:	e84a                	sd	s2,16(sp)
    80001e40:	e44e                	sd	s3,8(sp)
    80001e42:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e44:	a9dff0ef          	jal	800018e0 <myproc>
    80001e48:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e4a:	d41fe0ef          	jal	80000b8a <holding>
    80001e4e:	c92d                	beqz	a0,80001ec0 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e50:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e52:	2781                	sext.w	a5,a5
    80001e54:	079e                	slli	a5,a5,0x7
    80001e56:	00010717          	auipc	a4,0x10
    80001e5a:	77a70713          	addi	a4,a4,1914 # 800125d0 <pid_lock>
    80001e5e:	97ba                	add	a5,a5,a4
    80001e60:	0a87a703          	lw	a4,168(a5)
    80001e64:	4785                	li	a5,1
    80001e66:	06f71363          	bne	a4,a5,80001ecc <sched+0x96>
  if(p->state == RUNNING)
    80001e6a:	4c98                	lw	a4,24(s1)
    80001e6c:	4791                	li	a5,4
    80001e6e:	06f70563          	beq	a4,a5,80001ed8 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e72:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e76:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e78:	e7b5                	bnez	a5,80001ee4 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e7a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e7c:	00010917          	auipc	s2,0x10
    80001e80:	75490913          	addi	s2,s2,1876 # 800125d0 <pid_lock>
    80001e84:	2781                	sext.w	a5,a5
    80001e86:	079e                	slli	a5,a5,0x7
    80001e88:	97ca                	add	a5,a5,s2
    80001e8a:	0ac7a983          	lw	s3,172(a5)
    80001e8e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e90:	2781                	sext.w	a5,a5
    80001e92:	079e                	slli	a5,a5,0x7
    80001e94:	00010597          	auipc	a1,0x10
    80001e98:	77458593          	addi	a1,a1,1908 # 80012608 <cpus+0x8>
    80001e9c:	95be                	add	a1,a1,a5
    80001e9e:	06048513          	addi	a0,s1,96
    80001ea2:	055000ef          	jal	800026f6 <swtch>
    80001ea6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ea8:	2781                	sext.w	a5,a5
    80001eaa:	079e                	slli	a5,a5,0x7
    80001eac:	993e                	add	s2,s2,a5
    80001eae:	0b392623          	sw	s3,172(s2)
}
    80001eb2:	70a2                	ld	ra,40(sp)
    80001eb4:	7402                	ld	s0,32(sp)
    80001eb6:	64e2                	ld	s1,24(sp)
    80001eb8:	6942                	ld	s2,16(sp)
    80001eba:	69a2                	ld	s3,8(sp)
    80001ebc:	6145                	addi	sp,sp,48
    80001ebe:	8082                	ret
    panic("sched p->lock");
    80001ec0:	00005517          	auipc	a0,0x5
    80001ec4:	37850513          	addi	a0,a0,888 # 80007238 <etext+0x238>
    80001ec8:	8cdfe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001ecc:	00005517          	auipc	a0,0x5
    80001ed0:	37c50513          	addi	a0,a0,892 # 80007248 <etext+0x248>
    80001ed4:	8c1fe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001ed8:	00005517          	auipc	a0,0x5
    80001edc:	38050513          	addi	a0,a0,896 # 80007258 <etext+0x258>
    80001ee0:	8b5fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001ee4:	00005517          	auipc	a0,0x5
    80001ee8:	38450513          	addi	a0,a0,900 # 80007268 <etext+0x268>
    80001eec:	8a9fe0ef          	jal	80000794 <panic>

0000000080001ef0 <yield>:
{
    80001ef0:	1101                	addi	sp,sp,-32
    80001ef2:	ec06                	sd	ra,24(sp)
    80001ef4:	e822                	sd	s0,16(sp)
    80001ef6:	e426                	sd	s1,8(sp)
    80001ef8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001efa:	9e7ff0ef          	jal	800018e0 <myproc>
    80001efe:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f00:	cf5fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001f04:	478d                	li	a5,3
    80001f06:	cc9c                	sw	a5,24(s1)
  sched();
    80001f08:	f2fff0ef          	jal	80001e36 <sched>
  release(&p->lock);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	d7ffe0ef          	jal	80000c8c <release>
}
    80001f12:	60e2                	ld	ra,24(sp)
    80001f14:	6442                	ld	s0,16(sp)
    80001f16:	64a2                	ld	s1,8(sp)
    80001f18:	6105                	addi	sp,sp,32
    80001f1a:	8082                	ret

0000000080001f1c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f1c:	7179                	addi	sp,sp,-48
    80001f1e:	f406                	sd	ra,40(sp)
    80001f20:	f022                	sd	s0,32(sp)
    80001f22:	ec26                	sd	s1,24(sp)
    80001f24:	e84a                	sd	s2,16(sp)
    80001f26:	e44e                	sd	s3,8(sp)
    80001f28:	1800                	addi	s0,sp,48
    80001f2a:	89aa                	mv	s3,a0
    80001f2c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f2e:	9b3ff0ef          	jal	800018e0 <myproc>
    80001f32:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f34:	cc1fe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001f38:	854a                	mv	a0,s2
    80001f3a:	d53fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001f3e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f42:	4789                	li	a5,2
    80001f44:	cc9c                	sw	a5,24(s1)

  sched();
    80001f46:	ef1ff0ef          	jal	80001e36 <sched>

  // Tidy up.
  p->chan = 0;
    80001f4a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f4e:	8526                	mv	a0,s1
    80001f50:	d3dfe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001f54:	854a                	mv	a0,s2
    80001f56:	c9ffe0ef          	jal	80000bf4 <acquire>
}
    80001f5a:	70a2                	ld	ra,40(sp)
    80001f5c:	7402                	ld	s0,32(sp)
    80001f5e:	64e2                	ld	s1,24(sp)
    80001f60:	6942                	ld	s2,16(sp)
    80001f62:	69a2                	ld	s3,8(sp)
    80001f64:	6145                	addi	sp,sp,48
    80001f66:	8082                	ret

0000000080001f68 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f68:	7139                	addi	sp,sp,-64
    80001f6a:	fc06                	sd	ra,56(sp)
    80001f6c:	f822                	sd	s0,48(sp)
    80001f6e:	f426                	sd	s1,40(sp)
    80001f70:	f04a                	sd	s2,32(sp)
    80001f72:	ec4e                	sd	s3,24(sp)
    80001f74:	e852                	sd	s4,16(sp)
    80001f76:	e456                	sd	s5,8(sp)
    80001f78:	0080                	addi	s0,sp,64
    80001f7a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f7c:	00011497          	auipc	s1,0x11
    80001f80:	a8448493          	addi	s1,s1,-1404 # 80012a00 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f84:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f86:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f88:	00016917          	auipc	s2,0x16
    80001f8c:	67890913          	addi	s2,s2,1656 # 80018600 <tickslock>
    80001f90:	a801                	j	80001fa0 <wakeup+0x38>
      }
      release(&p->lock);
    80001f92:	8526                	mv	a0,s1
    80001f94:	cf9fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f98:	17048493          	addi	s1,s1,368
    80001f9c:	03248263          	beq	s1,s2,80001fc0 <wakeup+0x58>
    if(p != myproc()){
    80001fa0:	941ff0ef          	jal	800018e0 <myproc>
    80001fa4:	fea48ae3          	beq	s1,a0,80001f98 <wakeup+0x30>
      acquire(&p->lock);
    80001fa8:	8526                	mv	a0,s1
    80001faa:	c4bfe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001fae:	4c9c                	lw	a5,24(s1)
    80001fb0:	ff3791e3          	bne	a5,s3,80001f92 <wakeup+0x2a>
    80001fb4:	709c                	ld	a5,32(s1)
    80001fb6:	fd479ee3          	bne	a5,s4,80001f92 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fba:	0154ac23          	sw	s5,24(s1)
    80001fbe:	bfd1                	j	80001f92 <wakeup+0x2a>
    }
  }
}
    80001fc0:	70e2                	ld	ra,56(sp)
    80001fc2:	7442                	ld	s0,48(sp)
    80001fc4:	74a2                	ld	s1,40(sp)
    80001fc6:	7902                	ld	s2,32(sp)
    80001fc8:	69e2                	ld	s3,24(sp)
    80001fca:	6a42                	ld	s4,16(sp)
    80001fcc:	6aa2                	ld	s5,8(sp)
    80001fce:	6121                	addi	sp,sp,64
    80001fd0:	8082                	ret

0000000080001fd2 <reparent>:
{
    80001fd2:	7179                	addi	sp,sp,-48
    80001fd4:	f406                	sd	ra,40(sp)
    80001fd6:	f022                	sd	s0,32(sp)
    80001fd8:	ec26                	sd	s1,24(sp)
    80001fda:	e84a                	sd	s2,16(sp)
    80001fdc:	e44e                	sd	s3,8(sp)
    80001fde:	e052                	sd	s4,0(sp)
    80001fe0:	1800                	addi	s0,sp,48
    80001fe2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fe4:	00011497          	auipc	s1,0x11
    80001fe8:	a1c48493          	addi	s1,s1,-1508 # 80012a00 <proc>
      pp->parent = initproc;
    80001fec:	00008a17          	auipc	s4,0x8
    80001ff0:	4aca0a13          	addi	s4,s4,1196 # 8000a498 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ff4:	00016997          	auipc	s3,0x16
    80001ff8:	60c98993          	addi	s3,s3,1548 # 80018600 <tickslock>
    80001ffc:	a029                	j	80002006 <reparent+0x34>
    80001ffe:	17048493          	addi	s1,s1,368
    80002002:	01348b63          	beq	s1,s3,80002018 <reparent+0x46>
    if(pp->parent == p){
    80002006:	7c9c                	ld	a5,56(s1)
    80002008:	ff279be3          	bne	a5,s2,80001ffe <reparent+0x2c>
      pp->parent = initproc;
    8000200c:	000a3503          	ld	a0,0(s4)
    80002010:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002012:	f57ff0ef          	jal	80001f68 <wakeup>
    80002016:	b7e5                	j	80001ffe <reparent+0x2c>
}
    80002018:	70a2                	ld	ra,40(sp)
    8000201a:	7402                	ld	s0,32(sp)
    8000201c:	64e2                	ld	s1,24(sp)
    8000201e:	6942                	ld	s2,16(sp)
    80002020:	69a2                	ld	s3,8(sp)
    80002022:	6a02                	ld	s4,0(sp)
    80002024:	6145                	addi	sp,sp,48
    80002026:	8082                	ret

0000000080002028 <exit>:
{
    80002028:	7179                	addi	sp,sp,-48
    8000202a:	f406                	sd	ra,40(sp)
    8000202c:	f022                	sd	s0,32(sp)
    8000202e:	ec26                	sd	s1,24(sp)
    80002030:	e84a                	sd	s2,16(sp)
    80002032:	e44e                	sd	s3,8(sp)
    80002034:	e052                	sd	s4,0(sp)
    80002036:	1800                	addi	s0,sp,48
    80002038:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000203a:	8a7ff0ef          	jal	800018e0 <myproc>
    8000203e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002040:	00008797          	auipc	a5,0x8
    80002044:	4587b783          	ld	a5,1112(a5) # 8000a498 <initproc>
    80002048:	0d050493          	addi	s1,a0,208
    8000204c:	15050913          	addi	s2,a0,336
    80002050:	00a79f63          	bne	a5,a0,8000206e <exit+0x46>
    panic("init exiting");
    80002054:	00005517          	auipc	a0,0x5
    80002058:	22c50513          	addi	a0,a0,556 # 80007280 <etext+0x280>
    8000205c:	f38fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80002060:	2d8020ef          	jal	80004338 <fileclose>
      p->ofile[fd] = 0;
    80002064:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002068:	04a1                	addi	s1,s1,8
    8000206a:	01248563          	beq	s1,s2,80002074 <exit+0x4c>
    if(p->ofile[fd]){
    8000206e:	6088                	ld	a0,0(s1)
    80002070:	f965                	bnez	a0,80002060 <exit+0x38>
    80002072:	bfdd                	j	80002068 <exit+0x40>
  begin_op();
    80002074:	6ab010ef          	jal	80003f1e <begin_op>
  iput(p->cwd);
    80002078:	1509b503          	ld	a0,336(s3)
    8000207c:	78e010ef          	jal	8000380a <iput>
  end_op();
    80002080:	709010ef          	jal	80003f88 <end_op>
  p->cwd = 0;
    80002084:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002088:	00010497          	auipc	s1,0x10
    8000208c:	56048493          	addi	s1,s1,1376 # 800125e8 <wait_lock>
    80002090:	8526                	mv	a0,s1
    80002092:	b63fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002096:	854e                	mv	a0,s3
    80002098:	f3bff0ef          	jal	80001fd2 <reparent>
  wakeup(p->parent);
    8000209c:	0389b503          	ld	a0,56(s3)
    800020a0:	ec9ff0ef          	jal	80001f68 <wakeup>
  acquire(&p->lock);
    800020a4:	854e                	mv	a0,s3
    800020a6:	b4ffe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    800020aa:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020ae:	4795                	li	a5,5
    800020b0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020b4:	8526                	mv	a0,s1
    800020b6:	bd7fe0ef          	jal	80000c8c <release>
  sched();
    800020ba:	d7dff0ef          	jal	80001e36 <sched>
  panic("zombie exit");
    800020be:	00005517          	auipc	a0,0x5
    800020c2:	1d250513          	addi	a0,a0,466 # 80007290 <etext+0x290>
    800020c6:	ecefe0ef          	jal	80000794 <panic>

00000000800020ca <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800020ca:	7179                	addi	sp,sp,-48
    800020cc:	f406                	sd	ra,40(sp)
    800020ce:	f022                	sd	s0,32(sp)
    800020d0:	ec26                	sd	s1,24(sp)
    800020d2:	e84a                	sd	s2,16(sp)
    800020d4:	e44e                	sd	s3,8(sp)
    800020d6:	1800                	addi	s0,sp,48
    800020d8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020da:	00011497          	auipc	s1,0x11
    800020de:	92648493          	addi	s1,s1,-1754 # 80012a00 <proc>
    800020e2:	00016997          	auipc	s3,0x16
    800020e6:	51e98993          	addi	s3,s3,1310 # 80018600 <tickslock>
    acquire(&p->lock);
    800020ea:	8526                	mv	a0,s1
    800020ec:	b09fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    800020f0:	589c                	lw	a5,48(s1)
    800020f2:	01278b63          	beq	a5,s2,80002108 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020f6:	8526                	mv	a0,s1
    800020f8:	b95fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020fc:	17048493          	addi	s1,s1,368
    80002100:	ff3495e3          	bne	s1,s3,800020ea <kill+0x20>
  }
  return -1;
    80002104:	557d                	li	a0,-1
    80002106:	a819                	j	8000211c <kill+0x52>
      p->killed = 1;
    80002108:	4785                	li	a5,1
    8000210a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000210c:	4c98                	lw	a4,24(s1)
    8000210e:	4789                	li	a5,2
    80002110:	00f70d63          	beq	a4,a5,8000212a <kill+0x60>
      release(&p->lock);
    80002114:	8526                	mv	a0,s1
    80002116:	b77fe0ef          	jal	80000c8c <release>
      return 0;
    8000211a:	4501                	li	a0,0
}
    8000211c:	70a2                	ld	ra,40(sp)
    8000211e:	7402                	ld	s0,32(sp)
    80002120:	64e2                	ld	s1,24(sp)
    80002122:	6942                	ld	s2,16(sp)
    80002124:	69a2                	ld	s3,8(sp)
    80002126:	6145                	addi	sp,sp,48
    80002128:	8082                	ret
        p->state = RUNNABLE;
    8000212a:	478d                	li	a5,3
    8000212c:	cc9c                	sw	a5,24(s1)
    8000212e:	b7dd                	j	80002114 <kill+0x4a>

0000000080002130 <setkilled>:

void
setkilled(struct proc *p)
{
    80002130:	1101                	addi	sp,sp,-32
    80002132:	ec06                	sd	ra,24(sp)
    80002134:	e822                	sd	s0,16(sp)
    80002136:	e426                	sd	s1,8(sp)
    80002138:	1000                	addi	s0,sp,32
    8000213a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000213c:	ab9fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    80002140:	4785                	li	a5,1
    80002142:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002144:	8526                	mv	a0,s1
    80002146:	b47fe0ef          	jal	80000c8c <release>
}
    8000214a:	60e2                	ld	ra,24(sp)
    8000214c:	6442                	ld	s0,16(sp)
    8000214e:	64a2                	ld	s1,8(sp)
    80002150:	6105                	addi	sp,sp,32
    80002152:	8082                	ret

0000000080002154 <killed>:

int
killed(struct proc *p)
{
    80002154:	1101                	addi	sp,sp,-32
    80002156:	ec06                	sd	ra,24(sp)
    80002158:	e822                	sd	s0,16(sp)
    8000215a:	e426                	sd	s1,8(sp)
    8000215c:	e04a                	sd	s2,0(sp)
    8000215e:	1000                	addi	s0,sp,32
    80002160:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002162:	a93fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002166:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000216a:	8526                	mv	a0,s1
    8000216c:	b21fe0ef          	jal	80000c8c <release>
  return k;
}
    80002170:	854a                	mv	a0,s2
    80002172:	60e2                	ld	ra,24(sp)
    80002174:	6442                	ld	s0,16(sp)
    80002176:	64a2                	ld	s1,8(sp)
    80002178:	6902                	ld	s2,0(sp)
    8000217a:	6105                	addi	sp,sp,32
    8000217c:	8082                	ret

000000008000217e <wait>:
{
    8000217e:	715d                	addi	sp,sp,-80
    80002180:	e486                	sd	ra,72(sp)
    80002182:	e0a2                	sd	s0,64(sp)
    80002184:	fc26                	sd	s1,56(sp)
    80002186:	f84a                	sd	s2,48(sp)
    80002188:	f44e                	sd	s3,40(sp)
    8000218a:	f052                	sd	s4,32(sp)
    8000218c:	ec56                	sd	s5,24(sp)
    8000218e:	e85a                	sd	s6,16(sp)
    80002190:	e45e                	sd	s7,8(sp)
    80002192:	e062                	sd	s8,0(sp)
    80002194:	0880                	addi	s0,sp,80
    80002196:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002198:	f48ff0ef          	jal	800018e0 <myproc>
    8000219c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000219e:	00010517          	auipc	a0,0x10
    800021a2:	44a50513          	addi	a0,a0,1098 # 800125e8 <wait_lock>
    800021a6:	a4ffe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    800021aa:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800021ac:	4a15                	li	s4,5
        havekids = 1;
    800021ae:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b0:	00016997          	auipc	s3,0x16
    800021b4:	45098993          	addi	s3,s3,1104 # 80018600 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021b8:	00010c17          	auipc	s8,0x10
    800021bc:	430c0c13          	addi	s8,s8,1072 # 800125e8 <wait_lock>
    800021c0:	a871                	j	8000225c <wait+0xde>
          pid = pp->pid;
    800021c2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021c6:	000b0c63          	beqz	s6,800021de <wait+0x60>
    800021ca:	4691                	li	a3,4
    800021cc:	02c48613          	addi	a2,s1,44
    800021d0:	85da                	mv	a1,s6
    800021d2:	05093503          	ld	a0,80(s2)
    800021d6:	b7cff0ef          	jal	80001552 <copyout>
    800021da:	02054b63          	bltz	a0,80002210 <wait+0x92>
          freeproc(pp);
    800021de:	8526                	mv	a0,s1
    800021e0:	873ff0ef          	jal	80001a52 <freeproc>
          release(&pp->lock);
    800021e4:	8526                	mv	a0,s1
    800021e6:	aa7fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    800021ea:	00010517          	auipc	a0,0x10
    800021ee:	3fe50513          	addi	a0,a0,1022 # 800125e8 <wait_lock>
    800021f2:	a9bfe0ef          	jal	80000c8c <release>
}
    800021f6:	854e                	mv	a0,s3
    800021f8:	60a6                	ld	ra,72(sp)
    800021fa:	6406                	ld	s0,64(sp)
    800021fc:	74e2                	ld	s1,56(sp)
    800021fe:	7942                	ld	s2,48(sp)
    80002200:	79a2                	ld	s3,40(sp)
    80002202:	7a02                	ld	s4,32(sp)
    80002204:	6ae2                	ld	s5,24(sp)
    80002206:	6b42                	ld	s6,16(sp)
    80002208:	6ba2                	ld	s7,8(sp)
    8000220a:	6c02                	ld	s8,0(sp)
    8000220c:	6161                	addi	sp,sp,80
    8000220e:	8082                	ret
            release(&pp->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	a7bfe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    80002216:	00010517          	auipc	a0,0x10
    8000221a:	3d250513          	addi	a0,a0,978 # 800125e8 <wait_lock>
    8000221e:	a6ffe0ef          	jal	80000c8c <release>
            return -1;
    80002222:	59fd                	li	s3,-1
    80002224:	bfc9                	j	800021f6 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002226:	17048493          	addi	s1,s1,368
    8000222a:	03348063          	beq	s1,s3,8000224a <wait+0xcc>
      if(pp->parent == p){
    8000222e:	7c9c                	ld	a5,56(s1)
    80002230:	ff279be3          	bne	a5,s2,80002226 <wait+0xa8>
        acquire(&pp->lock);
    80002234:	8526                	mv	a0,s1
    80002236:	9bffe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    8000223a:	4c9c                	lw	a5,24(s1)
    8000223c:	f94783e3          	beq	a5,s4,800021c2 <wait+0x44>
        release(&pp->lock);
    80002240:	8526                	mv	a0,s1
    80002242:	a4bfe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002246:	8756                	mv	a4,s5
    80002248:	bff9                	j	80002226 <wait+0xa8>
    if(!havekids || killed(p)){
    8000224a:	cf19                	beqz	a4,80002268 <wait+0xea>
    8000224c:	854a                	mv	a0,s2
    8000224e:	f07ff0ef          	jal	80002154 <killed>
    80002252:	e919                	bnez	a0,80002268 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002254:	85e2                	mv	a1,s8
    80002256:	854a                	mv	a0,s2
    80002258:	cc5ff0ef          	jal	80001f1c <sleep>
    havekids = 0;
    8000225c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000225e:	00010497          	auipc	s1,0x10
    80002262:	7a248493          	addi	s1,s1,1954 # 80012a00 <proc>
    80002266:	b7e1                	j	8000222e <wait+0xb0>
      release(&wait_lock);
    80002268:	00010517          	auipc	a0,0x10
    8000226c:	38050513          	addi	a0,a0,896 # 800125e8 <wait_lock>
    80002270:	a1dfe0ef          	jal	80000c8c <release>
      return -1;
    80002274:	59fd                	li	s3,-1
    80002276:	b741                	j	800021f6 <wait+0x78>

0000000080002278 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002278:	7179                	addi	sp,sp,-48
    8000227a:	f406                	sd	ra,40(sp)
    8000227c:	f022                	sd	s0,32(sp)
    8000227e:	ec26                	sd	s1,24(sp)
    80002280:	e84a                	sd	s2,16(sp)
    80002282:	e44e                	sd	s3,8(sp)
    80002284:	e052                	sd	s4,0(sp)
    80002286:	1800                	addi	s0,sp,48
    80002288:	84aa                	mv	s1,a0
    8000228a:	892e                	mv	s2,a1
    8000228c:	89b2                	mv	s3,a2
    8000228e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002290:	e50ff0ef          	jal	800018e0 <myproc>
  if(user_dst){
    80002294:	cc99                	beqz	s1,800022b2 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002296:	86d2                	mv	a3,s4
    80002298:	864e                	mv	a2,s3
    8000229a:	85ca                	mv	a1,s2
    8000229c:	6928                	ld	a0,80(a0)
    8000229e:	ab4ff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022a2:	70a2                	ld	ra,40(sp)
    800022a4:	7402                	ld	s0,32(sp)
    800022a6:	64e2                	ld	s1,24(sp)
    800022a8:	6942                	ld	s2,16(sp)
    800022aa:	69a2                	ld	s3,8(sp)
    800022ac:	6a02                	ld	s4,0(sp)
    800022ae:	6145                	addi	sp,sp,48
    800022b0:	8082                	ret
    memmove((char *)dst, src, len);
    800022b2:	000a061b          	sext.w	a2,s4
    800022b6:	85ce                	mv	a1,s3
    800022b8:	854a                	mv	a0,s2
    800022ba:	a6bfe0ef          	jal	80000d24 <memmove>
    return 0;
    800022be:	8526                	mv	a0,s1
    800022c0:	b7cd                	j	800022a2 <either_copyout+0x2a>

00000000800022c2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022c2:	7179                	addi	sp,sp,-48
    800022c4:	f406                	sd	ra,40(sp)
    800022c6:	f022                	sd	s0,32(sp)
    800022c8:	ec26                	sd	s1,24(sp)
    800022ca:	e84a                	sd	s2,16(sp)
    800022cc:	e44e                	sd	s3,8(sp)
    800022ce:	e052                	sd	s4,0(sp)
    800022d0:	1800                	addi	s0,sp,48
    800022d2:	892a                	mv	s2,a0
    800022d4:	84ae                	mv	s1,a1
    800022d6:	89b2                	mv	s3,a2
    800022d8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022da:	e06ff0ef          	jal	800018e0 <myproc>
  if(user_src){
    800022de:	cc99                	beqz	s1,800022fc <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022e0:	86d2                	mv	a3,s4
    800022e2:	864e                	mv	a2,s3
    800022e4:	85ca                	mv	a1,s2
    800022e6:	6928                	ld	a0,80(a0)
    800022e8:	b40ff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022ec:	70a2                	ld	ra,40(sp)
    800022ee:	7402                	ld	s0,32(sp)
    800022f0:	64e2                	ld	s1,24(sp)
    800022f2:	6942                	ld	s2,16(sp)
    800022f4:	69a2                	ld	s3,8(sp)
    800022f6:	6a02                	ld	s4,0(sp)
    800022f8:	6145                	addi	sp,sp,48
    800022fa:	8082                	ret
    memmove(dst, (char*)src, len);
    800022fc:	000a061b          	sext.w	a2,s4
    80002300:	85ce                	mv	a1,s3
    80002302:	854a                	mv	a0,s2
    80002304:	a21fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002308:	8526                	mv	a0,s1
    8000230a:	b7cd                	j	800022ec <either_copyin+0x2a>

000000008000230c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000230c:	715d                	addi	sp,sp,-80
    8000230e:	e486                	sd	ra,72(sp)
    80002310:	e0a2                	sd	s0,64(sp)
    80002312:	fc26                	sd	s1,56(sp)
    80002314:	f84a                	sd	s2,48(sp)
    80002316:	f44e                	sd	s3,40(sp)
    80002318:	f052                	sd	s4,32(sp)
    8000231a:	ec56                	sd	s5,24(sp)
    8000231c:	e85a                	sd	s6,16(sp)
    8000231e:	e45e                	sd	s7,8(sp)
    80002320:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002322:	00005517          	auipc	a0,0x5
    80002326:	d5650513          	addi	a0,a0,-682 # 80007078 <etext+0x78>
    8000232a:	998fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000232e:	00011497          	auipc	s1,0x11
    80002332:	82a48493          	addi	s1,s1,-2006 # 80012b58 <proc+0x158>
    80002336:	00016917          	auipc	s2,0x16
    8000233a:	42290913          	addi	s2,s2,1058 # 80018758 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000233e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002340:	00005997          	auipc	s3,0x5
    80002344:	f6098993          	addi	s3,s3,-160 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002348:	00005a97          	auipc	s5,0x5
    8000234c:	f60a8a93          	addi	s5,s5,-160 # 800072a8 <etext+0x2a8>
    printf("\n");
    80002350:	00005a17          	auipc	s4,0x5
    80002354:	d28a0a13          	addi	s4,s4,-728 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002358:	00005b97          	auipc	s7,0x5
    8000235c:	4a0b8b93          	addi	s7,s7,1184 # 800077f8 <states.1>
    80002360:	a829                	j	8000237a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002362:	ed86a583          	lw	a1,-296(a3)
    80002366:	8556                	mv	a0,s5
    80002368:	95afe0ef          	jal	800004c2 <printf>
    printf("\n");
    8000236c:	8552                	mv	a0,s4
    8000236e:	954fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002372:	17048493          	addi	s1,s1,368
    80002376:	03248263          	beq	s1,s2,8000239a <procdump+0x8e>
    if(p->state == UNUSED)
    8000237a:	86a6                	mv	a3,s1
    8000237c:	ec04a783          	lw	a5,-320(s1)
    80002380:	dbed                	beqz	a5,80002372 <procdump+0x66>
      state = "???";
    80002382:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002384:	fcfb6fe3          	bltu	s6,a5,80002362 <procdump+0x56>
    80002388:	02079713          	slli	a4,a5,0x20
    8000238c:	01d75793          	srli	a5,a4,0x1d
    80002390:	97de                	add	a5,a5,s7
    80002392:	6390                	ld	a2,0(a5)
    80002394:	f679                	bnez	a2,80002362 <procdump+0x56>
      state = "???";
    80002396:	864e                	mv	a2,s3
    80002398:	b7e9                	j	80002362 <procdump+0x56>
  }
}
    8000239a:	60a6                	ld	ra,72(sp)
    8000239c:	6406                	ld	s0,64(sp)
    8000239e:	74e2                	ld	s1,56(sp)
    800023a0:	7942                	ld	s2,48(sp)
    800023a2:	79a2                	ld	s3,40(sp)
    800023a4:	7a02                	ld	s4,32(sp)
    800023a6:	6ae2                	ld	s5,24(sp)
    800023a8:	6b42                	ld	s6,16(sp)
    800023aa:	6ba2                	ld	s7,8(sp)
    800023ac:	6161                	addi	sp,sp,80
    800023ae:	8082                	ret

00000000800023b0 <atoi>:

int
atoi(const char *s)
{
    800023b0:	1141                	addi	sp,sp,-16
    800023b2:	e422                	sd	s0,8(sp)
    800023b4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    800023b6:	00054683          	lbu	a3,0(a0)
    800023ba:	fd06879b          	addiw	a5,a3,-48
    800023be:	0ff7f793          	zext.b	a5,a5
    800023c2:	4625                	li	a2,9
    800023c4:	02f66863          	bltu	a2,a5,800023f4 <atoi+0x44>
    800023c8:	872a                	mv	a4,a0
  n = 0;
    800023ca:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    800023cc:	0705                	addi	a4,a4,1
    800023ce:	0025179b          	slliw	a5,a0,0x2
    800023d2:	9fa9                	addw	a5,a5,a0
    800023d4:	0017979b          	slliw	a5,a5,0x1
    800023d8:	9fb5                	addw	a5,a5,a3
    800023da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    800023de:	00074683          	lbu	a3,0(a4)
    800023e2:	fd06879b          	addiw	a5,a3,-48
    800023e6:	0ff7f793          	zext.b	a5,a5
    800023ea:	fef671e3          	bgeu	a2,a5,800023cc <atoi+0x1c>
  return n;
}
    800023ee:	6422                	ld	s0,8(sp)
    800023f0:	0141                	addi	sp,sp,16
    800023f2:	8082                	ret
  n = 0;
    800023f4:	4501                	li	a0,0
    800023f6:	bfe5                	j	800023ee <atoi+0x3e>

00000000800023f8 <parsePIDs>:

int parsePIDs(char* args, int *pids)
{
    800023f8:	7159                	addi	sp,sp,-112
    800023fa:	f486                	sd	ra,104(sp)
    800023fc:	f0a2                	sd	s0,96(sp)
    800023fe:	e4ce                	sd	s3,72(sp)
    80002400:	e0d2                	sd	s4,64(sp)
    80002402:	f85a                	sd	s6,48(sp)
    80002404:	1880                	addi	s0,sp,112
    80002406:	8a2a                	mv	s4,a0
    80002408:	89ae                	mv	s3,a1
  int n = strlen(args);
    8000240a:	a2ffe0ef          	jal	80000e38 <strlen>
  char pidstr[10];
  int pidstrI = 0;
  int pidsI = 0;
    8000240e:	4b01                	li	s6,0
  for (int i = 0; i < n; i++){
    80002410:	00a04f63          	bgtz	a0,8000242e <parsePIDs+0x36>
    for (int j = 0; j < 10; j++) pidstr[j] = '\0';
    pidsI++;
    pidstrI = 0;
  }

  pids[pidsI] = -1;
    80002414:	0b0a                	slli	s6,s6,0x2
    80002416:	99da                	add	s3,s3,s6
    80002418:	57fd                	li	a5,-1
    8000241a:	00f9a023          	sw	a5,0(s3)
  return 0;
    8000241e:	4501                	li	a0,0
}
    80002420:	70a6                	ld	ra,104(sp)
    80002422:	7406                	ld	s0,96(sp)
    80002424:	69a6                	ld	s3,72(sp)
    80002426:	6a06                	ld	s4,64(sp)
    80002428:	7b42                	ld	s6,48(sp)
    8000242a:	6165                	addi	sp,sp,112
    8000242c:	8082                	ret
    8000242e:	eca6                	sd	s1,88(sp)
    80002430:	e8ca                	sd	s2,80(sp)
    80002432:	fc56                	sd	s5,56(sp)
    80002434:	f45e                	sd	s7,40(sp)
    80002436:	f062                	sd	s8,32(sp)
    80002438:	ec66                	sd	s9,24(sp)
    8000243a:	e86a                	sd	s10,16(sp)
    8000243c:	8aaa                	mv	s5,a0
    8000243e:	8cce                	mv	s9,s3
  for (int i = 0; i < n; i++){
    80002440:	4601                	li	a2,0
    while (args[i] != ',' && i < n) {
    80002442:	02c00b93          	li	s7,44
      pidstrI++;
    80002446:	4d05                	li	s10,1
      if (pidstrI >= 10) return -1;
    80002448:	4c29                	li	s8,10
    while (args[i] != ',' && i < n) {
    8000244a:	8932                	mv	s2,a2
    8000244c:	00ca07b3          	add	a5,s4,a2
    80002450:	0007c783          	lbu	a5,0(a5)
    80002454:	09778f63          	beq	a5,s7,800024f2 <parsePIDs+0xfa>
    80002458:	0b565663          	bge	a2,s5,80002504 <parsePIDs+0x10c>
      pidstr[pidstrI] = args[i];
    8000245c:	f8f40823          	sb	a5,-112(s0)
      if (pidstrI >= 10) return -1;
    80002460:	f9040493          	addi	s1,s0,-112
    80002464:	40ca863b          	subw	a2,s5,a2
      pidstr[pidstrI] = args[i];
    80002468:	8726                	mv	a4,s1
      pidstrI++;
    8000246a:	87ea                	mv	a5,s10
    while (args[i] != ',' && i < n) {
    8000246c:	012a06b3          	add	a3,s4,s2
    80002470:	0016c683          	lbu	a3,1(a3)
    80002474:	03768563          	beq	a3,s7,8000249e <parsePIDs+0xa6>
    80002478:	02c78263          	beq	a5,a2,8000249c <parsePIDs+0xa4>
      pidstr[pidstrI] = args[i];
    8000247c:	00d700a3          	sb	a3,1(a4)
      pidstrI++;
    80002480:	2785                	addiw	a5,a5,1
      if (pidstrI >= 10) return -1;
    80002482:	0905                	addi	s2,s2,1
    80002484:	0705                	addi	a4,a4,1
    80002486:	ff8793e3          	bne	a5,s8,8000246c <parsePIDs+0x74>
    8000248a:	557d                	li	a0,-1
    8000248c:	64e6                	ld	s1,88(sp)
    8000248e:	6946                	ld	s2,80(sp)
    80002490:	7ae2                	ld	s5,56(sp)
    80002492:	7ba2                	ld	s7,40(sp)
    80002494:	7c02                	ld	s8,32(sp)
    80002496:	6ce2                	ld	s9,24(sp)
    80002498:	6d42                	ld	s10,16(sp)
    8000249a:	b759                	j	80002420 <parsePIDs+0x28>
    8000249c:	87b2                	mv	a5,a2
    if (pidstrI == 0) return -1;
    8000249e:	c3a9                	beqz	a5,800024e0 <parsePIDs+0xe8>
    pidstr[pidstrI] = '\0';
    800024a0:	fa078793          	addi	a5,a5,-96
    800024a4:	97a2                	add	a5,a5,s0
    800024a6:	fe078823          	sb	zero,-16(a5)
    pids[pidsI] = atoi(pidstr);
    800024aa:	f9040513          	addi	a0,s0,-112
    800024ae:	f03ff0ef          	jal	800023b0 <atoi>
    800024b2:	00aca023          	sw	a0,0(s9)
    for (int j = 0; j < 10; j++) pidstr[j] = '\0';
    800024b6:	00a48793          	addi	a5,s1,10
    800024ba:	00048023          	sb	zero,0(s1)
    800024be:	0485                	addi	s1,s1,1
    800024c0:	fef49de3          	bne	s1,a5,800024ba <parsePIDs+0xc2>
    pidsI++;
    800024c4:	2b05                	addiw	s6,s6,1
  for (int i = 0; i < n; i++){
    800024c6:	0029061b          	addiw	a2,s2,2
    800024ca:	0c91                	addi	s9,s9,4
    800024cc:	f7564fe3          	blt	a2,s5,8000244a <parsePIDs+0x52>
    800024d0:	64e6                	ld	s1,88(sp)
    800024d2:	6946                	ld	s2,80(sp)
    800024d4:	7ae2                	ld	s5,56(sp)
    800024d6:	7ba2                	ld	s7,40(sp)
    800024d8:	7c02                	ld	s8,32(sp)
    800024da:	6ce2                	ld	s9,24(sp)
    800024dc:	6d42                	ld	s10,16(sp)
    800024de:	bf1d                	j	80002414 <parsePIDs+0x1c>
    if (pidstrI == 0) return -1;
    800024e0:	557d                	li	a0,-1
    800024e2:	64e6                	ld	s1,88(sp)
    800024e4:	6946                	ld	s2,80(sp)
    800024e6:	7ae2                	ld	s5,56(sp)
    800024e8:	7ba2                	ld	s7,40(sp)
    800024ea:	7c02                	ld	s8,32(sp)
    800024ec:	6ce2                	ld	s9,24(sp)
    800024ee:	6d42                	ld	s10,16(sp)
    800024f0:	bf05                	j	80002420 <parsePIDs+0x28>
    800024f2:	557d                	li	a0,-1
    800024f4:	64e6                	ld	s1,88(sp)
    800024f6:	6946                	ld	s2,80(sp)
    800024f8:	7ae2                	ld	s5,56(sp)
    800024fa:	7ba2                	ld	s7,40(sp)
    800024fc:	7c02                	ld	s8,32(sp)
    800024fe:	6ce2                	ld	s9,24(sp)
    80002500:	6d42                	ld	s10,16(sp)
    80002502:	bf39                	j	80002420 <parsePIDs+0x28>
    80002504:	557d                	li	a0,-1
    80002506:	64e6                	ld	s1,88(sp)
    80002508:	6946                	ld	s2,80(sp)
    8000250a:	7ae2                	ld	s5,56(sp)
    8000250c:	7ba2                	ld	s7,40(sp)
    8000250e:	7c02                	ld	s8,32(sp)
    80002510:	6ce2                	ld	s9,24(sp)
    80002512:	6d42                	ld	s10,16(sp)
    80002514:	b731                	j	80002420 <parsePIDs+0x28>

0000000080002516 <ps>:

// Lists process data in detail
int
ps(int argc, char *flags[])
{
    80002516:	7149                	addi	sp,sp,-368
    80002518:	f686                	sd	ra,360(sp)
    8000251a:	f2a2                	sd	s0,352(sp)
    8000251c:	eea6                	sd	s1,344(sp)
    8000251e:	eaca                	sd	s2,336(sp)
    80002520:	e6ce                	sd	s3,328(sp)
    80002522:	e2d2                	sd	s4,320(sp)
    80002524:	fe56                	sd	s5,312(sp)
    80002526:	fa5a                	sd	s6,304(sp)
    80002528:	f65e                	sd	s7,296(sp)
    8000252a:	f262                	sd	s8,288(sp)
    8000252c:	ee66                	sd	s9,280(sp)
    8000252e:	ea6a                	sd	s10,272(sp)
    80002530:	e66e                	sd	s11,264(sp)
    80002532:	1a80                	addi	s0,sp,368
  int onlyRunningProcesses = 0;
  int longList = 0;

  int pidFilter = 0;
  int pids[NPROC];
  for (int i = 1; i < argc; i++)
    80002534:	4785                	li	a5,1
    80002536:	0ca7d063          	bge	a5,a0,800025f6 <ps+0xe0>
    8000253a:	8b2a                	mv	s6,a0
    8000253c:	8c2e                	mv	s8,a1
    8000253e:	4485                	li	s1,1
  int pidFilter = 0;
    80002540:	4b81                	li	s7,0
  int longList = 0;
    80002542:	4a81                	li	s5,0
  int onlyRunningProcesses = 0;
    80002544:	4981                	li	s3,0
  {
    if (strncmp("r", flags[i], 1) == 0) {
    80002546:	00005c97          	auipc	s9,0x5
    8000254a:	d7ac8c93          	addi	s9,s9,-646 # 800072c0 <etext+0x2c0>
      onlyRunningProcesses = 1;
    } else if (strncmp("-l", flags[i], 2) == 0){
    8000254e:	00005d17          	auipc	s10,0x5
    80002552:	d7ad0d13          	addi	s10,s10,-646 # 800072c8 <etext+0x2c8>
    80002556:	a821                	j	8000256e <ps+0x58>
    80002558:	4609                	li	a2,2
    8000255a:	00093583          	ld	a1,0(s2)
    8000255e:	856a                	mv	a0,s10
    80002560:	835fe0ef          	jal	80000d94 <strncmp>
    80002564:	e115                	bnez	a0,80002588 <ps+0x72>
      longList = 1;
    80002566:	4a85                	li	s5,1
  for (int i = 1; i < argc; i++)
    80002568:	2485                	addiw	s1,s1,1
    8000256a:	0564d363          	bge	s1,s6,800025b0 <ps+0x9a>
    if (strncmp("r", flags[i], 1) == 0) {
    8000256e:	00349a13          	slli	s4,s1,0x3
    80002572:	014c0933          	add	s2,s8,s4
    80002576:	4605                	li	a2,1
    80002578:	00093583          	ld	a1,0(s2)
    8000257c:	8566                	mv	a0,s9
    8000257e:	817fe0ef          	jal	80000d94 <strncmp>
    80002582:	f979                	bnez	a0,80002558 <ps+0x42>
      onlyRunningProcesses = 1;
    80002584:	4985                	li	s3,1
    80002586:	b7cd                	j	80002568 <ps+0x52>
    } else if (strncmp("-p", flags[i], 2) == 0) {
    80002588:	4609                	li	a2,2
    8000258a:	00093583          	ld	a1,0(s2)
    8000258e:	00005517          	auipc	a0,0x5
    80002592:	d4250513          	addi	a0,a0,-702 # 800072d0 <etext+0x2d0>
    80002596:	ffefe0ef          	jal	80000d94 <strncmp>
    8000259a:	f579                	bnez	a0,80002568 <ps+0x52>
      i++;
    8000259c:	2485                	addiw	s1,s1,1
      if (parsePIDs(flags[i], pids) == 0) {
    8000259e:	e9040593          	addi	a1,s0,-368
    800025a2:	00893503          	ld	a0,8(s2)
    800025a6:	e53ff0ef          	jal	800023f8 <parsePIDs>
    800025aa:	fd5d                	bnez	a0,80002568 <ps+0x52>
        pidFilter = 1;
    800025ac:	4b85                	li	s7,1
    800025ae:	bf6d                	j	80002568 <ps+0x52>
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  if (longList) {
    800025b0:	040a8563          	beqz	s5,800025fa <ps+0xe4>
    printf("PID\tPPID\tAddr\t\tState\tSize\tCmd\n");
    800025b4:	00005517          	auipc	a0,0x5
    800025b8:	d2450513          	addi	a0,a0,-732 # 800072d8 <etext+0x2d8>
    800025bc:	f07fd0ef          	jal	800004c2 <printf>
  } else {
    printf("PID\tCmd\n");
  }
  for(p = proc; p < &proc[NPROC]; p++){
    800025c0:	00010497          	auipc	s1,0x10
    800025c4:	59848493          	addi	s1,s1,1432 # 80012b58 <proc+0x158>
    800025c8:	00016a17          	auipc	s4,0x16
    800025cc:	190a0a13          	addi	s4,s4,400 # 80018758 <bcache+0x140>
    if (p->state == UNUSED) continue;
    if (p->state != RUNNING && onlyRunningProcesses) continue;
    800025d0:	4b11                	li	s6,4
      }

      if (!validPid) continue;
    }

    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025d2:	00005d17          	auipc	s10,0x5
    800025d6:	226d0d13          	addi	s10,s10,550 # 800077f8 <states.1>
      if (p->parent == NULL) ppid = 0;
      else ppid = p->parent->pid;

      printf("%d\t%d\t%ld\t%s\t%ld\t%s\n", p->pid, ppid, p->kstack, state, p->sz, p->name);
    } else {
      printf("%d\t%s\n", p->pid, p->name);
    800025da:	00005d97          	auipc	s11,0x5
    800025de:	d46d8d93          	addi	s11,s11,-698 # 80007320 <etext+0x320>
      printf("%d\t%d\t%ld\t%s\t%ld\t%s\n", p->pid, ppid, p->kstack, state, p->sz, p->name);
    800025e2:	00005c17          	auipc	s8,0x5
    800025e6:	d26c0c13          	addi	s8,s8,-730 # 80007308 <etext+0x308>
      state = "UNKNOWN";
    800025ea:	00005c97          	auipc	s9,0x5
    800025ee:	ccec8c93          	addi	s9,s9,-818 # 800072b8 <etext+0x2b8>
      for (int i = 0; pids[i] != -1; i++){
    800025f2:	597d                	li	s2,-1
    800025f4:	a099                	j	8000263a <ps+0x124>
  int pidFilter = 0;
    800025f6:	4b81                	li	s7,0
  int onlyRunningProcesses = 0;
    800025f8:	4981                	li	s3,0
    printf("PID\tCmd\n");
    800025fa:	00005517          	auipc	a0,0x5
    800025fe:	cfe50513          	addi	a0,a0,-770 # 800072f8 <etext+0x2f8>
    80002602:	ec1fd0ef          	jal	800004c2 <printf>
    80002606:	4a81                	li	s5,0
    80002608:	bf65                	j	800025c0 <ps+0xaa>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000260a:	4695                	li	a3,5
      state = "UNKNOWN";
    8000260c:	8766                	mv	a4,s9
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000260e:	06f6f063          	bgeu	a3,a5,8000266e <ps+0x158>
    if (longList) {
    80002612:	060a8e63          	beqz	s5,8000268e <ps+0x178>
      if (p->parent == NULL) ppid = 0;
    80002616:	ee083783          	ld	a5,-288(a6)
    8000261a:	4601                	li	a2,0
    8000261c:	c391                	beqz	a5,80002620 <ps+0x10a>
      else ppid = p->parent->pid;
    8000261e:	5b90                	lw	a2,48(a5)
      printf("%d\t%d\t%ld\t%s\t%ld\t%s\n", p->pid, ppid, p->kstack, state, p->sz, p->name);
    80002620:	ef083783          	ld	a5,-272(a6)
    80002624:	ee883683          	ld	a3,-280(a6)
    80002628:	ed882583          	lw	a1,-296(a6)
    8000262c:	8562                	mv	a0,s8
    8000262e:	e95fd0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002632:	17048493          	addi	s1,s1,368
    80002636:	07448c63          	beq	s1,s4,800026ae <ps+0x198>
    if (p->state == UNUSED) continue;
    8000263a:	8826                	mv	a6,s1
    8000263c:	ec04a783          	lw	a5,-320(s1)
    80002640:	dbed                	beqz	a5,80002632 <ps+0x11c>
    if (p->state != RUNNING && onlyRunningProcesses) continue;
    80002642:	05678d63          	beq	a5,s6,8000269c <ps+0x186>
    80002646:	fe0996e3          	bnez	s3,80002632 <ps+0x11c>
    if (pidFilter){
    8000264a:	fc0b80e3          	beqz	s7,8000260a <ps+0xf4>
      for (int i = 0; pids[i] != -1; i++){
    8000264e:	e9042703          	lw	a4,-368(s0)
    80002652:	ff2700e3          	beq	a4,s2,80002632 <ps+0x11c>
        if (p->pid == pids[i]){
    80002656:	ed882603          	lw	a2,-296(a6)
    8000265a:	e9440693          	addi	a3,s0,-364
    8000265e:	fae606e3          	beq	a2,a4,8000260a <ps+0xf4>
      for (int i = 0; pids[i] != -1; i++){
    80002662:	0691                	addi	a3,a3,4
    80002664:	ffc6a703          	lw	a4,-4(a3)
    80002668:	ff271be3          	bne	a4,s2,8000265e <ps+0x148>
    8000266c:	b7d9                	j	80002632 <ps+0x11c>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000266e:	02079713          	slli	a4,a5,0x20
    80002672:	01d75793          	srli	a5,a4,0x1d
    80002676:	00005717          	auipc	a4,0x5
    8000267a:	18270713          	addi	a4,a4,386 # 800077f8 <states.1>
    8000267e:	97ba                	add	a5,a5,a4
    80002680:	7b98                	ld	a4,48(a5)
    80002682:	fb41                	bnez	a4,80002612 <ps+0xfc>
      state = "UNKNOWN";
    80002684:	00005717          	auipc	a4,0x5
    80002688:	c3470713          	addi	a4,a4,-972 # 800072b8 <etext+0x2b8>
    8000268c:	b759                	j	80002612 <ps+0xfc>
      printf("%d\t%s\n", p->pid, p->name);
    8000268e:	8642                	mv	a2,a6
    80002690:	ed882583          	lw	a1,-296(a6)
    80002694:	856e                	mv	a0,s11
    80002696:	e2dfd0ef          	jal	800004c2 <printf>
    8000269a:	bf61                	j	80002632 <ps+0x11c>
    if (pidFilter){
    8000269c:	fa0b99e3          	bnez	s7,8000264e <ps+0x138>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026a0:	02079713          	slli	a4,a5,0x20
    800026a4:	01d75793          	srli	a5,a4,0x1d
    800026a8:	97ea                	add	a5,a5,s10
    800026aa:	7b98                	ld	a4,48(a5)
    800026ac:	b79d                	j	80002612 <ps+0xfc>
    }
  }

  return 1;
}
    800026ae:	4505                	li	a0,1
    800026b0:	70b6                	ld	ra,360(sp)
    800026b2:	7416                	ld	s0,352(sp)
    800026b4:	64f6                	ld	s1,344(sp)
    800026b6:	6956                	ld	s2,336(sp)
    800026b8:	69b6                	ld	s3,328(sp)
    800026ba:	6a16                	ld	s4,320(sp)
    800026bc:	7af2                	ld	s5,312(sp)
    800026be:	7b52                	ld	s6,304(sp)
    800026c0:	7bb2                	ld	s7,296(sp)
    800026c2:	7c12                	ld	s8,288(sp)
    800026c4:	6cf2                	ld	s9,280(sp)
    800026c6:	6d52                	ld	s10,272(sp)
    800026c8:	6db2                	ld	s11,264(sp)
    800026ca:	6175                	addi	sp,sp,368
    800026cc:	8082                	ret

00000000800026ce <set_priority>:




void set_priority(int new_priority) {
    800026ce:	1101                	addi	sp,sp,-32
    800026d0:	ec06                	sd	ra,24(sp)
    800026d2:	e822                	sd	s0,16(sp)
    800026d4:	e426                	sd	s1,8(sp)
    800026d6:	1000                	addi	s0,sp,32
    800026d8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026da:	a06ff0ef          	jal	800018e0 <myproc>
  if (new_priority >= 0 && new_priority <= 4) {
    800026de:	0004871b          	sext.w	a4,s1
    800026e2:	4791                	li	a5,4
    800026e4:	00e7e463          	bltu	a5,a4,800026ec <set_priority+0x1e>
    p->priority = new_priority;
    800026e8:	16952423          	sw	s1,360(a0)
  }
    800026ec:	60e2                	ld	ra,24(sp)
    800026ee:	6442                	ld	s0,16(sp)
    800026f0:	64a2                	ld	s1,8(sp)
    800026f2:	6105                	addi	sp,sp,32
    800026f4:	8082                	ret

00000000800026f6 <swtch>:
    800026f6:	00153023          	sd	ra,0(a0)
    800026fa:	00253423          	sd	sp,8(a0)
    800026fe:	e900                	sd	s0,16(a0)
    80002700:	ed04                	sd	s1,24(a0)
    80002702:	03253023          	sd	s2,32(a0)
    80002706:	03353423          	sd	s3,40(a0)
    8000270a:	03453823          	sd	s4,48(a0)
    8000270e:	03553c23          	sd	s5,56(a0)
    80002712:	05653023          	sd	s6,64(a0)
    80002716:	05753423          	sd	s7,72(a0)
    8000271a:	05853823          	sd	s8,80(a0)
    8000271e:	05953c23          	sd	s9,88(a0)
    80002722:	07a53023          	sd	s10,96(a0)
    80002726:	07b53423          	sd	s11,104(a0)
    8000272a:	0005b083          	ld	ra,0(a1)
    8000272e:	0085b103          	ld	sp,8(a1)
    80002732:	6980                	ld	s0,16(a1)
    80002734:	6d84                	ld	s1,24(a1)
    80002736:	0205b903          	ld	s2,32(a1)
    8000273a:	0285b983          	ld	s3,40(a1)
    8000273e:	0305ba03          	ld	s4,48(a1)
    80002742:	0385ba83          	ld	s5,56(a1)
    80002746:	0405bb03          	ld	s6,64(a1)
    8000274a:	0485bb83          	ld	s7,72(a1)
    8000274e:	0505bc03          	ld	s8,80(a1)
    80002752:	0585bc83          	ld	s9,88(a1)
    80002756:	0605bd03          	ld	s10,96(a1)
    8000275a:	0685bd83          	ld	s11,104(a1)
    8000275e:	8082                	ret

0000000080002760 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002760:	1141                	addi	sp,sp,-16
    80002762:	e406                	sd	ra,8(sp)
    80002764:	e022                	sd	s0,0(sp)
    80002766:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002768:	00005597          	auipc	a1,0x5
    8000276c:	bf058593          	addi	a1,a1,-1040 # 80007358 <etext+0x358>
    80002770:	00016517          	auipc	a0,0x16
    80002774:	e9050513          	addi	a0,a0,-368 # 80018600 <tickslock>
    80002778:	bfcfe0ef          	jal	80000b74 <initlock>
}
    8000277c:	60a2                	ld	ra,8(sp)
    8000277e:	6402                	ld	s0,0(sp)
    80002780:	0141                	addi	sp,sp,16
    80002782:	8082                	ret

0000000080002784 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002784:	1141                	addi	sp,sp,-16
    80002786:	e422                	sd	s0,8(sp)
    80002788:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000278a:	00003797          	auipc	a5,0x3
    8000278e:	f1678793          	addi	a5,a5,-234 # 800056a0 <kernelvec>
    80002792:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002796:	6422                	ld	s0,8(sp)
    80002798:	0141                	addi	sp,sp,16
    8000279a:	8082                	ret

000000008000279c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000279c:	1141                	addi	sp,sp,-16
    8000279e:	e406                	sd	ra,8(sp)
    800027a0:	e022                	sd	s0,0(sp)
    800027a2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027a4:	93cff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027a8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027ac:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027ae:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800027b2:	00004697          	auipc	a3,0x4
    800027b6:	84e68693          	addi	a3,a3,-1970 # 80006000 <_trampoline>
    800027ba:	00004717          	auipc	a4,0x4
    800027be:	84670713          	addi	a4,a4,-1978 # 80006000 <_trampoline>
    800027c2:	8f15                	sub	a4,a4,a3
    800027c4:	040007b7          	lui	a5,0x4000
    800027c8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800027ca:	07b2                	slli	a5,a5,0xc
    800027cc:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027ce:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027d2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027d4:	18002673          	csrr	a2,satp
    800027d8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027da:	6d30                	ld	a2,88(a0)
    800027dc:	6138                	ld	a4,64(a0)
    800027de:	6585                	lui	a1,0x1
    800027e0:	972e                	add	a4,a4,a1
    800027e2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027e4:	6d38                	ld	a4,88(a0)
    800027e6:	00000617          	auipc	a2,0x0
    800027ea:	11060613          	addi	a2,a2,272 # 800028f6 <usertrap>
    800027ee:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027f0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027f2:	8612                	mv	a2,tp
    800027f4:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f6:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027fa:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027fe:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002802:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002806:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002808:	6f18                	ld	a4,24(a4)
    8000280a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000280e:	6928                	ld	a0,80(a0)
    80002810:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002812:	00004717          	auipc	a4,0x4
    80002816:	88a70713          	addi	a4,a4,-1910 # 8000609c <userret>
    8000281a:	8f15                	sub	a4,a4,a3
    8000281c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000281e:	577d                	li	a4,-1
    80002820:	177e                	slli	a4,a4,0x3f
    80002822:	8d59                	or	a0,a0,a4
    80002824:	9782                	jalr	a5
}
    80002826:	60a2                	ld	ra,8(sp)
    80002828:	6402                	ld	s0,0(sp)
    8000282a:	0141                	addi	sp,sp,16
    8000282c:	8082                	ret

000000008000282e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000282e:	1101                	addi	sp,sp,-32
    80002830:	ec06                	sd	ra,24(sp)
    80002832:	e822                	sd	s0,16(sp)
    80002834:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002836:	87eff0ef          	jal	800018b4 <cpuid>
    8000283a:	cd11                	beqz	a0,80002856 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000283c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002840:	000f4737          	lui	a4,0xf4
    80002844:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002848:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000284a:	14d79073          	csrw	stimecmp,a5
}
    8000284e:	60e2                	ld	ra,24(sp)
    80002850:	6442                	ld	s0,16(sp)
    80002852:	6105                	addi	sp,sp,32
    80002854:	8082                	ret
    80002856:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002858:	00016497          	auipc	s1,0x16
    8000285c:	da848493          	addi	s1,s1,-600 # 80018600 <tickslock>
    80002860:	8526                	mv	a0,s1
    80002862:	b92fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002866:	00008517          	auipc	a0,0x8
    8000286a:	c3a50513          	addi	a0,a0,-966 # 8000a4a0 <ticks>
    8000286e:	411c                	lw	a5,0(a0)
    80002870:	2785                	addiw	a5,a5,1
    80002872:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002874:	ef4ff0ef          	jal	80001f68 <wakeup>
    release(&tickslock);
    80002878:	8526                	mv	a0,s1
    8000287a:	c12fe0ef          	jal	80000c8c <release>
    8000287e:	64a2                	ld	s1,8(sp)
    80002880:	bf75                	j	8000283c <clockintr+0xe>

0000000080002882 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002882:	1101                	addi	sp,sp,-32
    80002884:	ec06                	sd	ra,24(sp)
    80002886:	e822                	sd	s0,16(sp)
    80002888:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000288a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000288e:	57fd                	li	a5,-1
    80002890:	17fe                	slli	a5,a5,0x3f
    80002892:	07a5                	addi	a5,a5,9
    80002894:	00f70c63          	beq	a4,a5,800028ac <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002898:	57fd                	li	a5,-1
    8000289a:	17fe                	slli	a5,a5,0x3f
    8000289c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000289e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800028a0:	04f70763          	beq	a4,a5,800028ee <devintr+0x6c>
  }
}
    800028a4:	60e2                	ld	ra,24(sp)
    800028a6:	6442                	ld	s0,16(sp)
    800028a8:	6105                	addi	sp,sp,32
    800028aa:	8082                	ret
    800028ac:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800028ae:	69f020ef          	jal	8000574c <plic_claim>
    800028b2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028b4:	47a9                	li	a5,10
    800028b6:	00f50963          	beq	a0,a5,800028c8 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800028ba:	4785                	li	a5,1
    800028bc:	00f50963          	beq	a0,a5,800028ce <devintr+0x4c>
    return 1;
    800028c0:	4505                	li	a0,1
    } else if(irq){
    800028c2:	e889                	bnez	s1,800028d4 <devintr+0x52>
    800028c4:	64a2                	ld	s1,8(sp)
    800028c6:	bff9                	j	800028a4 <devintr+0x22>
      uartintr();
    800028c8:	93efe0ef          	jal	80000a06 <uartintr>
    if(irq)
    800028cc:	a819                	j	800028e2 <devintr+0x60>
      virtio_disk_intr();
    800028ce:	344030ef          	jal	80005c12 <virtio_disk_intr>
    if(irq)
    800028d2:	a801                	j	800028e2 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800028d4:	85a6                	mv	a1,s1
    800028d6:	00005517          	auipc	a0,0x5
    800028da:	a8a50513          	addi	a0,a0,-1398 # 80007360 <etext+0x360>
    800028de:	be5fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800028e2:	8526                	mv	a0,s1
    800028e4:	689020ef          	jal	8000576c <plic_complete>
    return 1;
    800028e8:	4505                	li	a0,1
    800028ea:	64a2                	ld	s1,8(sp)
    800028ec:	bf65                	j	800028a4 <devintr+0x22>
    clockintr();
    800028ee:	f41ff0ef          	jal	8000282e <clockintr>
    return 2;
    800028f2:	4509                	li	a0,2
    800028f4:	bf45                	j	800028a4 <devintr+0x22>

00000000800028f6 <usertrap>:
{
    800028f6:	1101                	addi	sp,sp,-32
    800028f8:	ec06                	sd	ra,24(sp)
    800028fa:	e822                	sd	s0,16(sp)
    800028fc:	e426                	sd	s1,8(sp)
    800028fe:	e04a                	sd	s2,0(sp)
    80002900:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002902:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002906:	1007f793          	andi	a5,a5,256
    8000290a:	ef85                	bnez	a5,80002942 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000290c:	00003797          	auipc	a5,0x3
    80002910:	d9478793          	addi	a5,a5,-620 # 800056a0 <kernelvec>
    80002914:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002918:	fc9fe0ef          	jal	800018e0 <myproc>
    8000291c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000291e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002920:	14102773          	csrr	a4,sepc
    80002924:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002926:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000292a:	47a1                	li	a5,8
    8000292c:	02f70163          	beq	a4,a5,8000294e <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002930:	f53ff0ef          	jal	80002882 <devintr>
    80002934:	892a                	mv	s2,a0
    80002936:	c135                	beqz	a0,8000299a <usertrap+0xa4>
  if(killed(p))
    80002938:	8526                	mv	a0,s1
    8000293a:	81bff0ef          	jal	80002154 <killed>
    8000293e:	cd1d                	beqz	a0,8000297c <usertrap+0x86>
    80002940:	a81d                	j	80002976 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80002942:	00005517          	auipc	a0,0x5
    80002946:	a3e50513          	addi	a0,a0,-1474 # 80007380 <etext+0x380>
    8000294a:	e4bfd0ef          	jal	80000794 <panic>
    if(killed(p))
    8000294e:	807ff0ef          	jal	80002154 <killed>
    80002952:	e121                	bnez	a0,80002992 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80002954:	6cb8                	ld	a4,88(s1)
    80002956:	6f1c                	ld	a5,24(a4)
    80002958:	0791                	addi	a5,a5,4
    8000295a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000295c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002960:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002964:	10079073          	csrw	sstatus,a5
    syscall();
    80002968:	248000ef          	jal	80002bb0 <syscall>
  if(killed(p))
    8000296c:	8526                	mv	a0,s1
    8000296e:	fe6ff0ef          	jal	80002154 <killed>
    80002972:	c901                	beqz	a0,80002982 <usertrap+0x8c>
    80002974:	4901                	li	s2,0
    exit(-1);
    80002976:	557d                	li	a0,-1
    80002978:	eb0ff0ef          	jal	80002028 <exit>
  if(which_dev == 2)
    8000297c:	4789                	li	a5,2
    8000297e:	04f90563          	beq	s2,a5,800029c8 <usertrap+0xd2>
  usertrapret();
    80002982:	e1bff0ef          	jal	8000279c <usertrapret>
}
    80002986:	60e2                	ld	ra,24(sp)
    80002988:	6442                	ld	s0,16(sp)
    8000298a:	64a2                	ld	s1,8(sp)
    8000298c:	6902                	ld	s2,0(sp)
    8000298e:	6105                	addi	sp,sp,32
    80002990:	8082                	ret
      exit(-1);
    80002992:	557d                	li	a0,-1
    80002994:	e94ff0ef          	jal	80002028 <exit>
    80002998:	bf75                	j	80002954 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000299a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000299e:	5890                	lw	a2,48(s1)
    800029a0:	00005517          	auipc	a0,0x5
    800029a4:	a0050513          	addi	a0,a0,-1536 # 800073a0 <etext+0x3a0>
    800029a8:	b1bfd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ac:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029b0:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800029b4:	00005517          	auipc	a0,0x5
    800029b8:	a1c50513          	addi	a0,a0,-1508 # 800073d0 <etext+0x3d0>
    800029bc:	b07fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    800029c0:	8526                	mv	a0,s1
    800029c2:	f6eff0ef          	jal	80002130 <setkilled>
    800029c6:	b75d                	j	8000296c <usertrap+0x76>
    yield();
    800029c8:	d28ff0ef          	jal	80001ef0 <yield>
    800029cc:	bf5d                	j	80002982 <usertrap+0x8c>

00000000800029ce <kerneltrap>:
{
    800029ce:	7179                	addi	sp,sp,-48
    800029d0:	f406                	sd	ra,40(sp)
    800029d2:	f022                	sd	s0,32(sp)
    800029d4:	ec26                	sd	s1,24(sp)
    800029d6:	e84a                	sd	s2,16(sp)
    800029d8:	e44e                	sd	s3,8(sp)
    800029da:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029dc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029e4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029e8:	1004f793          	andi	a5,s1,256
    800029ec:	c795                	beqz	a5,80002a18 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029f2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029f4:	eb85                	bnez	a5,80002a24 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800029f6:	e8dff0ef          	jal	80002882 <devintr>
    800029fa:	c91d                	beqz	a0,80002a30 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800029fc:	4789                	li	a5,2
    800029fe:	04f50a63          	beq	a0,a5,80002a52 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a02:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a06:	10049073          	csrw	sstatus,s1
}
    80002a0a:	70a2                	ld	ra,40(sp)
    80002a0c:	7402                	ld	s0,32(sp)
    80002a0e:	64e2                	ld	s1,24(sp)
    80002a10:	6942                	ld	s2,16(sp)
    80002a12:	69a2                	ld	s3,8(sp)
    80002a14:	6145                	addi	sp,sp,48
    80002a16:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a18:	00005517          	auipc	a0,0x5
    80002a1c:	9e050513          	addi	a0,a0,-1568 # 800073f8 <etext+0x3f8>
    80002a20:	d75fd0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a24:	00005517          	auipc	a0,0x5
    80002a28:	9fc50513          	addi	a0,a0,-1540 # 80007420 <etext+0x420>
    80002a2c:	d69fd0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a30:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a34:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002a38:	85ce                	mv	a1,s3
    80002a3a:	00005517          	auipc	a0,0x5
    80002a3e:	a0650513          	addi	a0,a0,-1530 # 80007440 <etext+0x440>
    80002a42:	a81fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002a46:	00005517          	auipc	a0,0x5
    80002a4a:	a2250513          	addi	a0,a0,-1502 # 80007468 <etext+0x468>
    80002a4e:	d47fd0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002a52:	e8ffe0ef          	jal	800018e0 <myproc>
    80002a56:	d555                	beqz	a0,80002a02 <kerneltrap+0x34>
    yield();
    80002a58:	c98ff0ef          	jal	80001ef0 <yield>
    80002a5c:	b75d                	j	80002a02 <kerneltrap+0x34>

0000000080002a5e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a5e:	1101                	addi	sp,sp,-32
    80002a60:	ec06                	sd	ra,24(sp)
    80002a62:	e822                	sd	s0,16(sp)
    80002a64:	e426                	sd	s1,8(sp)
    80002a66:	1000                	addi	s0,sp,32
    80002a68:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a6a:	e77fe0ef          	jal	800018e0 <myproc>
  switch (n) {
    80002a6e:	4795                	li	a5,5
    80002a70:	0497e163          	bltu	a5,s1,80002ab2 <argraw+0x54>
    80002a74:	048a                	slli	s1,s1,0x2
    80002a76:	00005717          	auipc	a4,0x5
    80002a7a:	de270713          	addi	a4,a4,-542 # 80007858 <states.0+0x30>
    80002a7e:	94ba                	add	s1,s1,a4
    80002a80:	409c                	lw	a5,0(s1)
    80002a82:	97ba                	add	a5,a5,a4
    80002a84:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a86:	6d3c                	ld	a5,88(a0)
    80002a88:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a8a:	60e2                	ld	ra,24(sp)
    80002a8c:	6442                	ld	s0,16(sp)
    80002a8e:	64a2                	ld	s1,8(sp)
    80002a90:	6105                	addi	sp,sp,32
    80002a92:	8082                	ret
    return p->trapframe->a1;
    80002a94:	6d3c                	ld	a5,88(a0)
    80002a96:	7fa8                	ld	a0,120(a5)
    80002a98:	bfcd                	j	80002a8a <argraw+0x2c>
    return p->trapframe->a2;
    80002a9a:	6d3c                	ld	a5,88(a0)
    80002a9c:	63c8                	ld	a0,128(a5)
    80002a9e:	b7f5                	j	80002a8a <argraw+0x2c>
    return p->trapframe->a3;
    80002aa0:	6d3c                	ld	a5,88(a0)
    80002aa2:	67c8                	ld	a0,136(a5)
    80002aa4:	b7dd                	j	80002a8a <argraw+0x2c>
    return p->trapframe->a4;
    80002aa6:	6d3c                	ld	a5,88(a0)
    80002aa8:	6bc8                	ld	a0,144(a5)
    80002aaa:	b7c5                	j	80002a8a <argraw+0x2c>
    return p->trapframe->a5;
    80002aac:	6d3c                	ld	a5,88(a0)
    80002aae:	6fc8                	ld	a0,152(a5)
    80002ab0:	bfe9                	j	80002a8a <argraw+0x2c>
  panic("argraw");
    80002ab2:	00005517          	auipc	a0,0x5
    80002ab6:	9c650513          	addi	a0,a0,-1594 # 80007478 <etext+0x478>
    80002aba:	cdbfd0ef          	jal	80000794 <panic>

0000000080002abe <fetchaddr>:
{
    80002abe:	1101                	addi	sp,sp,-32
    80002ac0:	ec06                	sd	ra,24(sp)
    80002ac2:	e822                	sd	s0,16(sp)
    80002ac4:	e426                	sd	s1,8(sp)
    80002ac6:	e04a                	sd	s2,0(sp)
    80002ac8:	1000                	addi	s0,sp,32
    80002aca:	84aa                	mv	s1,a0
    80002acc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ace:	e13fe0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ad2:	653c                	ld	a5,72(a0)
    80002ad4:	02f4f663          	bgeu	s1,a5,80002b00 <fetchaddr+0x42>
    80002ad8:	00848713          	addi	a4,s1,8
    80002adc:	02e7e463          	bltu	a5,a4,80002b04 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ae0:	46a1                	li	a3,8
    80002ae2:	8626                	mv	a2,s1
    80002ae4:	85ca                	mv	a1,s2
    80002ae6:	6928                	ld	a0,80(a0)
    80002ae8:	b41fe0ef          	jal	80001628 <copyin>
    80002aec:	00a03533          	snez	a0,a0
    80002af0:	40a00533          	neg	a0,a0
}
    80002af4:	60e2                	ld	ra,24(sp)
    80002af6:	6442                	ld	s0,16(sp)
    80002af8:	64a2                	ld	s1,8(sp)
    80002afa:	6902                	ld	s2,0(sp)
    80002afc:	6105                	addi	sp,sp,32
    80002afe:	8082                	ret
    return -1;
    80002b00:	557d                	li	a0,-1
    80002b02:	bfcd                	j	80002af4 <fetchaddr+0x36>
    80002b04:	557d                	li	a0,-1
    80002b06:	b7fd                	j	80002af4 <fetchaddr+0x36>

0000000080002b08 <fetchstr>:
{
    80002b08:	7179                	addi	sp,sp,-48
    80002b0a:	f406                	sd	ra,40(sp)
    80002b0c:	f022                	sd	s0,32(sp)
    80002b0e:	ec26                	sd	s1,24(sp)
    80002b10:	e84a                	sd	s2,16(sp)
    80002b12:	e44e                	sd	s3,8(sp)
    80002b14:	1800                	addi	s0,sp,48
    80002b16:	892a                	mv	s2,a0
    80002b18:	84ae                	mv	s1,a1
    80002b1a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b1c:	dc5fe0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b20:	86ce                	mv	a3,s3
    80002b22:	864a                	mv	a2,s2
    80002b24:	85a6                	mv	a1,s1
    80002b26:	6928                	ld	a0,80(a0)
    80002b28:	b87fe0ef          	jal	800016ae <copyinstr>
    80002b2c:	00054c63          	bltz	a0,80002b44 <fetchstr+0x3c>
  return strlen(buf);
    80002b30:	8526                	mv	a0,s1
    80002b32:	b06fe0ef          	jal	80000e38 <strlen>
}
    80002b36:	70a2                	ld	ra,40(sp)
    80002b38:	7402                	ld	s0,32(sp)
    80002b3a:	64e2                	ld	s1,24(sp)
    80002b3c:	6942                	ld	s2,16(sp)
    80002b3e:	69a2                	ld	s3,8(sp)
    80002b40:	6145                	addi	sp,sp,48
    80002b42:	8082                	ret
    return -1;
    80002b44:	557d                	li	a0,-1
    80002b46:	bfc5                	j	80002b36 <fetchstr+0x2e>

0000000080002b48 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b48:	1101                	addi	sp,sp,-32
    80002b4a:	ec06                	sd	ra,24(sp)
    80002b4c:	e822                	sd	s0,16(sp)
    80002b4e:	e426                	sd	s1,8(sp)
    80002b50:	1000                	addi	s0,sp,32
    80002b52:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b54:	f0bff0ef          	jal	80002a5e <argraw>
    80002b58:	c088                	sw	a0,0(s1)
}
    80002b5a:	60e2                	ld	ra,24(sp)
    80002b5c:	6442                	ld	s0,16(sp)
    80002b5e:	64a2                	ld	s1,8(sp)
    80002b60:	6105                	addi	sp,sp,32
    80002b62:	8082                	ret

0000000080002b64 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b64:	1101                	addi	sp,sp,-32
    80002b66:	ec06                	sd	ra,24(sp)
    80002b68:	e822                	sd	s0,16(sp)
    80002b6a:	e426                	sd	s1,8(sp)
    80002b6c:	1000                	addi	s0,sp,32
    80002b6e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b70:	eefff0ef          	jal	80002a5e <argraw>
    80002b74:	e088                	sd	a0,0(s1)
}
    80002b76:	60e2                	ld	ra,24(sp)
    80002b78:	6442                	ld	s0,16(sp)
    80002b7a:	64a2                	ld	s1,8(sp)
    80002b7c:	6105                	addi	sp,sp,32
    80002b7e:	8082                	ret

0000000080002b80 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b80:	7179                	addi	sp,sp,-48
    80002b82:	f406                	sd	ra,40(sp)
    80002b84:	f022                	sd	s0,32(sp)
    80002b86:	ec26                	sd	s1,24(sp)
    80002b88:	e84a                	sd	s2,16(sp)
    80002b8a:	1800                	addi	s0,sp,48
    80002b8c:	84ae                	mv	s1,a1
    80002b8e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b90:	fd840593          	addi	a1,s0,-40
    80002b94:	fd1ff0ef          	jal	80002b64 <argaddr>
  return fetchstr(addr, buf, max);
    80002b98:	864a                	mv	a2,s2
    80002b9a:	85a6                	mv	a1,s1
    80002b9c:	fd843503          	ld	a0,-40(s0)
    80002ba0:	f69ff0ef          	jal	80002b08 <fetchstr>
}
    80002ba4:	70a2                	ld	ra,40(sp)
    80002ba6:	7402                	ld	s0,32(sp)
    80002ba8:	64e2                	ld	s1,24(sp)
    80002baa:	6942                	ld	s2,16(sp)
    80002bac:	6145                	addi	sp,sp,48
    80002bae:	8082                	ret

0000000080002bb0 <syscall>:
[SYS_getburst]  sys_getburst
};

void
syscall(void)
{
    80002bb0:	1101                	addi	sp,sp,-32
    80002bb2:	ec06                	sd	ra,24(sp)
    80002bb4:	e822                	sd	s0,16(sp)
    80002bb6:	e426                	sd	s1,8(sp)
    80002bb8:	e04a                	sd	s2,0(sp)
    80002bba:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bbc:	d25fe0ef          	jal	800018e0 <myproc>
    80002bc0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002bc2:	05853903          	ld	s2,88(a0)
    80002bc6:	0a893783          	ld	a5,168(s2)
    80002bca:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bce:	37fd                	addiw	a5,a5,-1
    80002bd0:	475d                	li	a4,23
    80002bd2:	00f76f63          	bltu	a4,a5,80002bf0 <syscall+0x40>
    80002bd6:	00369713          	slli	a4,a3,0x3
    80002bda:	00005797          	auipc	a5,0x5
    80002bde:	c9678793          	addi	a5,a5,-874 # 80007870 <syscalls>
    80002be2:	97ba                	add	a5,a5,a4
    80002be4:	639c                	ld	a5,0(a5)
    80002be6:	c789                	beqz	a5,80002bf0 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002be8:	9782                	jalr	a5
    80002bea:	06a93823          	sd	a0,112(s2)
    80002bee:	a829                	j	80002c08 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bf0:	15848613          	addi	a2,s1,344
    80002bf4:	588c                	lw	a1,48(s1)
    80002bf6:	00005517          	auipc	a0,0x5
    80002bfa:	88a50513          	addi	a0,a0,-1910 # 80007480 <etext+0x480>
    80002bfe:	8c5fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c02:	6cbc                	ld	a5,88(s1)
    80002c04:	577d                	li	a4,-1
    80002c06:	fbb8                	sd	a4,112(a5)
  }
}
    80002c08:	60e2                	ld	ra,24(sp)
    80002c0a:	6442                	ld	s0,16(sp)
    80002c0c:	64a2                	ld	s1,8(sp)
    80002c0e:	6902                	ld	s2,0(sp)
    80002c10:	6105                	addi	sp,sp,32
    80002c12:	8082                	ret

0000000080002c14 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c14:	1101                	addi	sp,sp,-32
    80002c16:	ec06                	sd	ra,24(sp)
    80002c18:	e822                	sd	s0,16(sp)
    80002c1a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c1c:	fec40593          	addi	a1,s0,-20
    80002c20:	4501                	li	a0,0
    80002c22:	f27ff0ef          	jal	80002b48 <argint>
  exit(n);
    80002c26:	fec42503          	lw	a0,-20(s0)
    80002c2a:	bfeff0ef          	jal	80002028 <exit>
  return 0;  // not reached
}
    80002c2e:	4501                	li	a0,0
    80002c30:	60e2                	ld	ra,24(sp)
    80002c32:	6442                	ld	s0,16(sp)
    80002c34:	6105                	addi	sp,sp,32
    80002c36:	8082                	ret

0000000080002c38 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c38:	1141                	addi	sp,sp,-16
    80002c3a:	e406                	sd	ra,8(sp)
    80002c3c:	e022                	sd	s0,0(sp)
    80002c3e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c40:	ca1fe0ef          	jal	800018e0 <myproc>
}
    80002c44:	5908                	lw	a0,48(a0)
    80002c46:	60a2                	ld	ra,8(sp)
    80002c48:	6402                	ld	s0,0(sp)
    80002c4a:	0141                	addi	sp,sp,16
    80002c4c:	8082                	ret

0000000080002c4e <sys_getburst>:

uint64
sys_getburst(void){
    80002c4e:	1141                	addi	sp,sp,-16
    80002c50:	e406                	sd	ra,8(sp)
    80002c52:	e022                	sd	s0,0(sp)
    80002c54:	0800                	addi	s0,sp,16
  return myproc()->burst;
    80002c56:	c8bfe0ef          	jal	800018e0 <myproc>
}
    80002c5a:	16c52503          	lw	a0,364(a0)
    80002c5e:	60a2                	ld	ra,8(sp)
    80002c60:	6402                	ld	s0,0(sp)
    80002c62:	0141                	addi	sp,sp,16
    80002c64:	8082                	ret

0000000080002c66 <sys_fork>:
uint64
sys_fork(void)
{
    80002c66:	1141                	addi	sp,sp,-16
    80002c68:	e406                	sd	ra,8(sp)
    80002c6a:	e022                	sd	s0,0(sp)
    80002c6c:	0800                	addi	s0,sp,16
  return fork();
    80002c6e:	fa3fe0ef          	jal	80001c10 <fork>
}
    80002c72:	60a2                	ld	ra,8(sp)
    80002c74:	6402                	ld	s0,0(sp)
    80002c76:	0141                	addi	sp,sp,16
    80002c78:	8082                	ret

0000000080002c7a <sys_wait>:

uint64
sys_wait(void)
{
    80002c7a:	1101                	addi	sp,sp,-32
    80002c7c:	ec06                	sd	ra,24(sp)
    80002c7e:	e822                	sd	s0,16(sp)
    80002c80:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c82:	fe840593          	addi	a1,s0,-24
    80002c86:	4501                	li	a0,0
    80002c88:	eddff0ef          	jal	80002b64 <argaddr>
  return wait(p);
    80002c8c:	fe843503          	ld	a0,-24(s0)
    80002c90:	ceeff0ef          	jal	8000217e <wait>
}
    80002c94:	60e2                	ld	ra,24(sp)
    80002c96:	6442                	ld	s0,16(sp)
    80002c98:	6105                	addi	sp,sp,32
    80002c9a:	8082                	ret

0000000080002c9c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c9c:	7179                	addi	sp,sp,-48
    80002c9e:	f406                	sd	ra,40(sp)
    80002ca0:	f022                	sd	s0,32(sp)
    80002ca2:	ec26                	sd	s1,24(sp)
    80002ca4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ca6:	fdc40593          	addi	a1,s0,-36
    80002caa:	4501                	li	a0,0
    80002cac:	e9dff0ef          	jal	80002b48 <argint>
  addr = myproc()->sz;
    80002cb0:	c31fe0ef          	jal	800018e0 <myproc>
    80002cb4:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002cb6:	fdc42503          	lw	a0,-36(s0)
    80002cba:	f07fe0ef          	jal	80001bc0 <growproc>
    80002cbe:	00054863          	bltz	a0,80002cce <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002cc2:	8526                	mv	a0,s1
    80002cc4:	70a2                	ld	ra,40(sp)
    80002cc6:	7402                	ld	s0,32(sp)
    80002cc8:	64e2                	ld	s1,24(sp)
    80002cca:	6145                	addi	sp,sp,48
    80002ccc:	8082                	ret
    return -1;
    80002cce:	54fd                	li	s1,-1
    80002cd0:	bfcd                	j	80002cc2 <sys_sbrk+0x26>

0000000080002cd2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cd2:	7139                	addi	sp,sp,-64
    80002cd4:	fc06                	sd	ra,56(sp)
    80002cd6:	f822                	sd	s0,48(sp)
    80002cd8:	f04a                	sd	s2,32(sp)
    80002cda:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cdc:	fcc40593          	addi	a1,s0,-52
    80002ce0:	4501                	li	a0,0
    80002ce2:	e67ff0ef          	jal	80002b48 <argint>
  if(n < 0)
    80002ce6:	fcc42783          	lw	a5,-52(s0)
    80002cea:	0607c763          	bltz	a5,80002d58 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002cee:	00016517          	auipc	a0,0x16
    80002cf2:	91250513          	addi	a0,a0,-1774 # 80018600 <tickslock>
    80002cf6:	efffd0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002cfa:	00007917          	auipc	s2,0x7
    80002cfe:	7a692903          	lw	s2,1958(s2) # 8000a4a0 <ticks>
  while(ticks - ticks0 < n){
    80002d02:	fcc42783          	lw	a5,-52(s0)
    80002d06:	cf8d                	beqz	a5,80002d40 <sys_sleep+0x6e>
    80002d08:	f426                	sd	s1,40(sp)
    80002d0a:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d0c:	00016997          	auipc	s3,0x16
    80002d10:	8f498993          	addi	s3,s3,-1804 # 80018600 <tickslock>
    80002d14:	00007497          	auipc	s1,0x7
    80002d18:	78c48493          	addi	s1,s1,1932 # 8000a4a0 <ticks>
    if(killed(myproc())){
    80002d1c:	bc5fe0ef          	jal	800018e0 <myproc>
    80002d20:	c34ff0ef          	jal	80002154 <killed>
    80002d24:	ed0d                	bnez	a0,80002d5e <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002d26:	85ce                	mv	a1,s3
    80002d28:	8526                	mv	a0,s1
    80002d2a:	9f2ff0ef          	jal	80001f1c <sleep>
  while(ticks - ticks0 < n){
    80002d2e:	409c                	lw	a5,0(s1)
    80002d30:	412787bb          	subw	a5,a5,s2
    80002d34:	fcc42703          	lw	a4,-52(s0)
    80002d38:	fee7e2e3          	bltu	a5,a4,80002d1c <sys_sleep+0x4a>
    80002d3c:	74a2                	ld	s1,40(sp)
    80002d3e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d40:	00016517          	auipc	a0,0x16
    80002d44:	8c050513          	addi	a0,a0,-1856 # 80018600 <tickslock>
    80002d48:	f45fd0ef          	jal	80000c8c <release>
  return 0;
    80002d4c:	4501                	li	a0,0
}
    80002d4e:	70e2                	ld	ra,56(sp)
    80002d50:	7442                	ld	s0,48(sp)
    80002d52:	7902                	ld	s2,32(sp)
    80002d54:	6121                	addi	sp,sp,64
    80002d56:	8082                	ret
    n = 0;
    80002d58:	fc042623          	sw	zero,-52(s0)
    80002d5c:	bf49                	j	80002cee <sys_sleep+0x1c>
      release(&tickslock);
    80002d5e:	00016517          	auipc	a0,0x16
    80002d62:	8a250513          	addi	a0,a0,-1886 # 80018600 <tickslock>
    80002d66:	f27fd0ef          	jal	80000c8c <release>
      return -1;
    80002d6a:	557d                	li	a0,-1
    80002d6c:	74a2                	ld	s1,40(sp)
    80002d6e:	69e2                	ld	s3,24(sp)
    80002d70:	bff9                	j	80002d4e <sys_sleep+0x7c>

0000000080002d72 <sys_kill>:

uint64
sys_kill(void)
{
    80002d72:	1101                	addi	sp,sp,-32
    80002d74:	ec06                	sd	ra,24(sp)
    80002d76:	e822                	sd	s0,16(sp)
    80002d78:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d7a:	fec40593          	addi	a1,s0,-20
    80002d7e:	4501                	li	a0,0
    80002d80:	dc9ff0ef          	jal	80002b48 <argint>
  return kill(pid);
    80002d84:	fec42503          	lw	a0,-20(s0)
    80002d88:	b42ff0ef          	jal	800020ca <kill>
}
    80002d8c:	60e2                	ld	ra,24(sp)
    80002d8e:	6442                	ld	s0,16(sp)
    80002d90:	6105                	addi	sp,sp,32
    80002d92:	8082                	ret

0000000080002d94 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d94:	1101                	addi	sp,sp,-32
    80002d96:	ec06                	sd	ra,24(sp)
    80002d98:	e822                	sd	s0,16(sp)
    80002d9a:	e426                	sd	s1,8(sp)
    80002d9c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d9e:	00016517          	auipc	a0,0x16
    80002da2:	86250513          	addi	a0,a0,-1950 # 80018600 <tickslock>
    80002da6:	e4ffd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002daa:	00007497          	auipc	s1,0x7
    80002dae:	6f64a483          	lw	s1,1782(s1) # 8000a4a0 <ticks>
  release(&tickslock);
    80002db2:	00016517          	auipc	a0,0x16
    80002db6:	84e50513          	addi	a0,a0,-1970 # 80018600 <tickslock>
    80002dba:	ed3fd0ef          	jal	80000c8c <release>
  return xticks;
}
    80002dbe:	02049513          	slli	a0,s1,0x20
    80002dc2:	9101                	srli	a0,a0,0x20
    80002dc4:	60e2                	ld	ra,24(sp)
    80002dc6:	6442                	ld	s0,16(sp)
    80002dc8:	64a2                	ld	s1,8(sp)
    80002dca:	6105                	addi	sp,sp,32
    80002dcc:	8082                	ret

0000000080002dce <sys_ps>:

uint64
sys_ps(void)
{
    80002dce:	714d                	addi	sp,sp,-336
    80002dd0:	e686                	sd	ra,328(sp)
    80002dd2:	e2a2                	sd	s0,320(sp)
    80002dd4:	fe26                	sd	s1,312(sp)
    80002dd6:	fa4a                	sd	s2,304(sp)
    80002dd8:	f64e                	sd	s3,296(sp)
    80002dda:	f252                	sd	s4,288(sp)
    80002ddc:	0a80                	addi	s0,sp,336
  char *argv[MAXARG];
  int i, argc;
  uint64 uargv, uarg;

  argint(0, &argc);
    80002dde:	ecc40593          	addi	a1,s0,-308
    80002de2:	4501                	li	a0,0
    80002de4:	d65ff0ef          	jal	80002b48 <argint>
  argaddr(1, &uargv);
    80002de8:	ec040593          	addi	a1,s0,-320
    80002dec:	4505                	li	a0,1
    80002dee:	d77ff0ef          	jal	80002b64 <argaddr>
  memset(argv, 0, sizeof(argv));
    80002df2:	10000613          	li	a2,256
    80002df6:	4581                	li	a1,0
    80002df8:	ed040513          	addi	a0,s0,-304
    80002dfc:	ecdfd0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80002e00:	ed040493          	addi	s1,s0,-304
  memset(argv, 0, sizeof(argv));
    80002e04:	89a6                	mv	s3,s1
    80002e06:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80002e08:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80002e0c:	00391513          	slli	a0,s2,0x3
    80002e10:	eb840593          	addi	a1,s0,-328
    80002e14:	ec043783          	ld	a5,-320(s0)
    80002e18:	953e                	add	a0,a0,a5
    80002e1a:	ca5ff0ef          	jal	80002abe <fetchaddr>
    80002e1e:	02054663          	bltz	a0,80002e4a <sys_ps+0x7c>
      goto bad;
    }
    if(uarg == 0){
    80002e22:	eb843783          	ld	a5,-328(s0)
    80002e26:	cf8d                	beqz	a5,80002e60 <sys_ps+0x92>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80002e28:	cfdfd0ef          	jal	80000b24 <kalloc>
    80002e2c:	85aa                	mv	a1,a0
    80002e2e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80002e32:	cd01                	beqz	a0,80002e4a <sys_ps+0x7c>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80002e34:	6605                	lui	a2,0x1
    80002e36:	eb843503          	ld	a0,-328(s0)
    80002e3a:	ccfff0ef          	jal	80002b08 <fetchstr>
    80002e3e:	00054663          	bltz	a0,80002e4a <sys_ps+0x7c>
    if(i >= NELEM(argv)){
    80002e42:	0905                	addi	s2,s2,1
    80002e44:	09a1                	addi	s3,s3,8
    80002e46:	fd4913e3          	bne	s2,s4,80002e0c <sys_ps+0x3e>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80002e4a:	fd040913          	addi	s2,s0,-48
    80002e4e:	6088                	ld	a0,0(s1)
    80002e50:	c131                	beqz	a0,80002e94 <sys_ps+0xc6>
    kfree(argv[i]);
    80002e52:	bf1fd0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80002e56:	04a1                	addi	s1,s1,8
    80002e58:	ff249be3          	bne	s1,s2,80002e4e <sys_ps+0x80>
  return -1;
    80002e5c:	557d                	li	a0,-1
    80002e5e:	a825                	j	80002e96 <sys_ps+0xc8>
      argv[i] = 0;
    80002e60:	0009079b          	sext.w	a5,s2
    80002e64:	078e                	slli	a5,a5,0x3
    80002e66:	fd078793          	addi	a5,a5,-48
    80002e6a:	97a2                	add	a5,a5,s0
    80002e6c:	f007b023          	sd	zero,-256(a5)
  int ret = ps(argc, argv);
    80002e70:	ed040593          	addi	a1,s0,-304
    80002e74:	ecc42503          	lw	a0,-308(s0)
    80002e78:	e9eff0ef          	jal	80002516 <ps>
    80002e7c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80002e7e:	fd040993          	addi	s3,s0,-48
    80002e82:	6088                	ld	a0,0(s1)
    80002e84:	c511                	beqz	a0,80002e90 <sys_ps+0xc2>
    kfree(argv[i]);
    80002e86:	bbdfd0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80002e8a:	04a1                	addi	s1,s1,8
    80002e8c:	ff349be3          	bne	s1,s3,80002e82 <sys_ps+0xb4>
  return ret;
    80002e90:	854a                	mv	a0,s2
    80002e92:	a011                	j	80002e96 <sys_ps+0xc8>
  return -1;
    80002e94:	557d                	li	a0,-1
}
    80002e96:	60b6                	ld	ra,328(sp)
    80002e98:	6416                	ld	s0,320(sp)
    80002e9a:	74f2                	ld	s1,312(sp)
    80002e9c:	7952                	ld	s2,304(sp)
    80002e9e:	79b2                	ld	s3,296(sp)
    80002ea0:	7a12                	ld	s4,288(sp)
    80002ea2:	6171                	addi	sp,sp,336
    80002ea4:	8082                	ret

0000000080002ea6 <sys_set_priority>:


uint64
sys_set_priority(void) {
    80002ea6:	1101                	addi	sp,sp,-32
    80002ea8:	ec06                	sd	ra,24(sp)
    80002eaa:	e822                	sd	s0,16(sp)
    80002eac:	1000                	addi	s0,sp,32
  int priority;
  
  // Directly check the result of argraw() instead of relying on return value
  argint(0, &priority); 
    80002eae:	fec40593          	addi	a1,s0,-20
    80002eb2:	4501                	li	a0,0
    80002eb4:	c95ff0ef          	jal	80002b48 <argint>
  set_priority(priority);  // Set the process priority
    80002eb8:	fec42503          	lw	a0,-20(s0)
    80002ebc:	813ff0ef          	jal	800026ce <set_priority>
  return 0;
    80002ec0:	4501                	li	a0,0
    80002ec2:	60e2                	ld	ra,24(sp)
    80002ec4:	6442                	ld	s0,16(sp)
    80002ec6:	6105                	addi	sp,sp,32
    80002ec8:	8082                	ret

0000000080002eca <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002eca:	7179                	addi	sp,sp,-48
    80002ecc:	f406                	sd	ra,40(sp)
    80002ece:	f022                	sd	s0,32(sp)
    80002ed0:	ec26                	sd	s1,24(sp)
    80002ed2:	e84a                	sd	s2,16(sp)
    80002ed4:	e44e                	sd	s3,8(sp)
    80002ed6:	e052                	sd	s4,0(sp)
    80002ed8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002eda:	00004597          	auipc	a1,0x4
    80002ede:	5c658593          	addi	a1,a1,1478 # 800074a0 <etext+0x4a0>
    80002ee2:	00015517          	auipc	a0,0x15
    80002ee6:	73650513          	addi	a0,a0,1846 # 80018618 <bcache>
    80002eea:	c8bfd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002eee:	0001d797          	auipc	a5,0x1d
    80002ef2:	72a78793          	addi	a5,a5,1834 # 80020618 <bcache+0x8000>
    80002ef6:	0001e717          	auipc	a4,0x1e
    80002efa:	98a70713          	addi	a4,a4,-1654 # 80020880 <bcache+0x8268>
    80002efe:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f02:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f06:	00015497          	auipc	s1,0x15
    80002f0a:	72a48493          	addi	s1,s1,1834 # 80018630 <bcache+0x18>
    b->next = bcache.head.next;
    80002f0e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f10:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f12:	00004a17          	auipc	s4,0x4
    80002f16:	596a0a13          	addi	s4,s4,1430 # 800074a8 <etext+0x4a8>
    b->next = bcache.head.next;
    80002f1a:	2b893783          	ld	a5,696(s2)
    80002f1e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f20:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f24:	85d2                	mv	a1,s4
    80002f26:	01048513          	addi	a0,s1,16
    80002f2a:	248010ef          	jal	80004172 <initsleeplock>
    bcache.head.next->prev = b;
    80002f2e:	2b893783          	ld	a5,696(s2)
    80002f32:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f34:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f38:	45848493          	addi	s1,s1,1112
    80002f3c:	fd349fe3          	bne	s1,s3,80002f1a <binit+0x50>
  }
}
    80002f40:	70a2                	ld	ra,40(sp)
    80002f42:	7402                	ld	s0,32(sp)
    80002f44:	64e2                	ld	s1,24(sp)
    80002f46:	6942                	ld	s2,16(sp)
    80002f48:	69a2                	ld	s3,8(sp)
    80002f4a:	6a02                	ld	s4,0(sp)
    80002f4c:	6145                	addi	sp,sp,48
    80002f4e:	8082                	ret

0000000080002f50 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f50:	7179                	addi	sp,sp,-48
    80002f52:	f406                	sd	ra,40(sp)
    80002f54:	f022                	sd	s0,32(sp)
    80002f56:	ec26                	sd	s1,24(sp)
    80002f58:	e84a                	sd	s2,16(sp)
    80002f5a:	e44e                	sd	s3,8(sp)
    80002f5c:	1800                	addi	s0,sp,48
    80002f5e:	892a                	mv	s2,a0
    80002f60:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f62:	00015517          	auipc	a0,0x15
    80002f66:	6b650513          	addi	a0,a0,1718 # 80018618 <bcache>
    80002f6a:	c8bfd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f6e:	0001e497          	auipc	s1,0x1e
    80002f72:	9624b483          	ld	s1,-1694(s1) # 800208d0 <bcache+0x82b8>
    80002f76:	0001e797          	auipc	a5,0x1e
    80002f7a:	90a78793          	addi	a5,a5,-1782 # 80020880 <bcache+0x8268>
    80002f7e:	02f48b63          	beq	s1,a5,80002fb4 <bread+0x64>
    80002f82:	873e                	mv	a4,a5
    80002f84:	a021                	j	80002f8c <bread+0x3c>
    80002f86:	68a4                	ld	s1,80(s1)
    80002f88:	02e48663          	beq	s1,a4,80002fb4 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002f8c:	449c                	lw	a5,8(s1)
    80002f8e:	ff279ce3          	bne	a5,s2,80002f86 <bread+0x36>
    80002f92:	44dc                	lw	a5,12(s1)
    80002f94:	ff3799e3          	bne	a5,s3,80002f86 <bread+0x36>
      b->refcnt++;
    80002f98:	40bc                	lw	a5,64(s1)
    80002f9a:	2785                	addiw	a5,a5,1
    80002f9c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f9e:	00015517          	auipc	a0,0x15
    80002fa2:	67a50513          	addi	a0,a0,1658 # 80018618 <bcache>
    80002fa6:	ce7fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002faa:	01048513          	addi	a0,s1,16
    80002fae:	1fa010ef          	jal	800041a8 <acquiresleep>
      return b;
    80002fb2:	a889                	j	80003004 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fb4:	0001e497          	auipc	s1,0x1e
    80002fb8:	9144b483          	ld	s1,-1772(s1) # 800208c8 <bcache+0x82b0>
    80002fbc:	0001e797          	auipc	a5,0x1e
    80002fc0:	8c478793          	addi	a5,a5,-1852 # 80020880 <bcache+0x8268>
    80002fc4:	00f48863          	beq	s1,a5,80002fd4 <bread+0x84>
    80002fc8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fca:	40bc                	lw	a5,64(s1)
    80002fcc:	cb91                	beqz	a5,80002fe0 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fce:	64a4                	ld	s1,72(s1)
    80002fd0:	fee49de3          	bne	s1,a4,80002fca <bread+0x7a>
  panic("bget: no buffers");
    80002fd4:	00004517          	auipc	a0,0x4
    80002fd8:	4dc50513          	addi	a0,a0,1244 # 800074b0 <etext+0x4b0>
    80002fdc:	fb8fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002fe0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fe4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fe8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fec:	4785                	li	a5,1
    80002fee:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ff0:	00015517          	auipc	a0,0x15
    80002ff4:	62850513          	addi	a0,a0,1576 # 80018618 <bcache>
    80002ff8:	c95fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002ffc:	01048513          	addi	a0,s1,16
    80003000:	1a8010ef          	jal	800041a8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003004:	409c                	lw	a5,0(s1)
    80003006:	cb89                	beqz	a5,80003018 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003008:	8526                	mv	a0,s1
    8000300a:	70a2                	ld	ra,40(sp)
    8000300c:	7402                	ld	s0,32(sp)
    8000300e:	64e2                	ld	s1,24(sp)
    80003010:	6942                	ld	s2,16(sp)
    80003012:	69a2                	ld	s3,8(sp)
    80003014:	6145                	addi	sp,sp,48
    80003016:	8082                	ret
    virtio_disk_rw(b, 0);
    80003018:	4581                	li	a1,0
    8000301a:	8526                	mv	a0,s1
    8000301c:	1e5020ef          	jal	80005a00 <virtio_disk_rw>
    b->valid = 1;
    80003020:	4785                	li	a5,1
    80003022:	c09c                	sw	a5,0(s1)
  return b;
    80003024:	b7d5                	j	80003008 <bread+0xb8>

0000000080003026 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003026:	1101                	addi	sp,sp,-32
    80003028:	ec06                	sd	ra,24(sp)
    8000302a:	e822                	sd	s0,16(sp)
    8000302c:	e426                	sd	s1,8(sp)
    8000302e:	1000                	addi	s0,sp,32
    80003030:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003032:	0541                	addi	a0,a0,16
    80003034:	1f2010ef          	jal	80004226 <holdingsleep>
    80003038:	c911                	beqz	a0,8000304c <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000303a:	4585                	li	a1,1
    8000303c:	8526                	mv	a0,s1
    8000303e:	1c3020ef          	jal	80005a00 <virtio_disk_rw>
}
    80003042:	60e2                	ld	ra,24(sp)
    80003044:	6442                	ld	s0,16(sp)
    80003046:	64a2                	ld	s1,8(sp)
    80003048:	6105                	addi	sp,sp,32
    8000304a:	8082                	ret
    panic("bwrite");
    8000304c:	00004517          	auipc	a0,0x4
    80003050:	47c50513          	addi	a0,a0,1148 # 800074c8 <etext+0x4c8>
    80003054:	f40fd0ef          	jal	80000794 <panic>

0000000080003058 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003058:	1101                	addi	sp,sp,-32
    8000305a:	ec06                	sd	ra,24(sp)
    8000305c:	e822                	sd	s0,16(sp)
    8000305e:	e426                	sd	s1,8(sp)
    80003060:	e04a                	sd	s2,0(sp)
    80003062:	1000                	addi	s0,sp,32
    80003064:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003066:	01050913          	addi	s2,a0,16
    8000306a:	854a                	mv	a0,s2
    8000306c:	1ba010ef          	jal	80004226 <holdingsleep>
    80003070:	c135                	beqz	a0,800030d4 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80003072:	854a                	mv	a0,s2
    80003074:	17a010ef          	jal	800041ee <releasesleep>

  acquire(&bcache.lock);
    80003078:	00015517          	auipc	a0,0x15
    8000307c:	5a050513          	addi	a0,a0,1440 # 80018618 <bcache>
    80003080:	b75fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80003084:	40bc                	lw	a5,64(s1)
    80003086:	37fd                	addiw	a5,a5,-1
    80003088:	0007871b          	sext.w	a4,a5
    8000308c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000308e:	e71d                	bnez	a4,800030bc <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003090:	68b8                	ld	a4,80(s1)
    80003092:	64bc                	ld	a5,72(s1)
    80003094:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003096:	68b8                	ld	a4,80(s1)
    80003098:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000309a:	0001d797          	auipc	a5,0x1d
    8000309e:	57e78793          	addi	a5,a5,1406 # 80020618 <bcache+0x8000>
    800030a2:	2b87b703          	ld	a4,696(a5)
    800030a6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030a8:	0001d717          	auipc	a4,0x1d
    800030ac:	7d870713          	addi	a4,a4,2008 # 80020880 <bcache+0x8268>
    800030b0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030b2:	2b87b703          	ld	a4,696(a5)
    800030b6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030b8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030bc:	00015517          	auipc	a0,0x15
    800030c0:	55c50513          	addi	a0,a0,1372 # 80018618 <bcache>
    800030c4:	bc9fd0ef          	jal	80000c8c <release>
}
    800030c8:	60e2                	ld	ra,24(sp)
    800030ca:	6442                	ld	s0,16(sp)
    800030cc:	64a2                	ld	s1,8(sp)
    800030ce:	6902                	ld	s2,0(sp)
    800030d0:	6105                	addi	sp,sp,32
    800030d2:	8082                	ret
    panic("brelse");
    800030d4:	00004517          	auipc	a0,0x4
    800030d8:	3fc50513          	addi	a0,a0,1020 # 800074d0 <etext+0x4d0>
    800030dc:	eb8fd0ef          	jal	80000794 <panic>

00000000800030e0 <bpin>:

void
bpin(struct buf *b) {
    800030e0:	1101                	addi	sp,sp,-32
    800030e2:	ec06                	sd	ra,24(sp)
    800030e4:	e822                	sd	s0,16(sp)
    800030e6:	e426                	sd	s1,8(sp)
    800030e8:	1000                	addi	s0,sp,32
    800030ea:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030ec:	00015517          	auipc	a0,0x15
    800030f0:	52c50513          	addi	a0,a0,1324 # 80018618 <bcache>
    800030f4:	b01fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    800030f8:	40bc                	lw	a5,64(s1)
    800030fa:	2785                	addiw	a5,a5,1
    800030fc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030fe:	00015517          	auipc	a0,0x15
    80003102:	51a50513          	addi	a0,a0,1306 # 80018618 <bcache>
    80003106:	b87fd0ef          	jal	80000c8c <release>
}
    8000310a:	60e2                	ld	ra,24(sp)
    8000310c:	6442                	ld	s0,16(sp)
    8000310e:	64a2                	ld	s1,8(sp)
    80003110:	6105                	addi	sp,sp,32
    80003112:	8082                	ret

0000000080003114 <bunpin>:

void
bunpin(struct buf *b) {
    80003114:	1101                	addi	sp,sp,-32
    80003116:	ec06                	sd	ra,24(sp)
    80003118:	e822                	sd	s0,16(sp)
    8000311a:	e426                	sd	s1,8(sp)
    8000311c:	1000                	addi	s0,sp,32
    8000311e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003120:	00015517          	auipc	a0,0x15
    80003124:	4f850513          	addi	a0,a0,1272 # 80018618 <bcache>
    80003128:	acdfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    8000312c:	40bc                	lw	a5,64(s1)
    8000312e:	37fd                	addiw	a5,a5,-1
    80003130:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003132:	00015517          	auipc	a0,0x15
    80003136:	4e650513          	addi	a0,a0,1254 # 80018618 <bcache>
    8000313a:	b53fd0ef          	jal	80000c8c <release>
}
    8000313e:	60e2                	ld	ra,24(sp)
    80003140:	6442                	ld	s0,16(sp)
    80003142:	64a2                	ld	s1,8(sp)
    80003144:	6105                	addi	sp,sp,32
    80003146:	8082                	ret

0000000080003148 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003148:	1101                	addi	sp,sp,-32
    8000314a:	ec06                	sd	ra,24(sp)
    8000314c:	e822                	sd	s0,16(sp)
    8000314e:	e426                	sd	s1,8(sp)
    80003150:	e04a                	sd	s2,0(sp)
    80003152:	1000                	addi	s0,sp,32
    80003154:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003156:	00d5d59b          	srliw	a1,a1,0xd
    8000315a:	0001e797          	auipc	a5,0x1e
    8000315e:	b9a7a783          	lw	a5,-1126(a5) # 80020cf4 <sb+0x1c>
    80003162:	9dbd                	addw	a1,a1,a5
    80003164:	dedff0ef          	jal	80002f50 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003168:	0074f713          	andi	a4,s1,7
    8000316c:	4785                	li	a5,1
    8000316e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003172:	14ce                	slli	s1,s1,0x33
    80003174:	90d9                	srli	s1,s1,0x36
    80003176:	00950733          	add	a4,a0,s1
    8000317a:	05874703          	lbu	a4,88(a4)
    8000317e:	00e7f6b3          	and	a3,a5,a4
    80003182:	c29d                	beqz	a3,800031a8 <bfree+0x60>
    80003184:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003186:	94aa                	add	s1,s1,a0
    80003188:	fff7c793          	not	a5,a5
    8000318c:	8f7d                	and	a4,a4,a5
    8000318e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003192:	711000ef          	jal	800040a2 <log_write>
  brelse(bp);
    80003196:	854a                	mv	a0,s2
    80003198:	ec1ff0ef          	jal	80003058 <brelse>
}
    8000319c:	60e2                	ld	ra,24(sp)
    8000319e:	6442                	ld	s0,16(sp)
    800031a0:	64a2                	ld	s1,8(sp)
    800031a2:	6902                	ld	s2,0(sp)
    800031a4:	6105                	addi	sp,sp,32
    800031a6:	8082                	ret
    panic("freeing free block");
    800031a8:	00004517          	auipc	a0,0x4
    800031ac:	33050513          	addi	a0,a0,816 # 800074d8 <etext+0x4d8>
    800031b0:	de4fd0ef          	jal	80000794 <panic>

00000000800031b4 <balloc>:
{
    800031b4:	711d                	addi	sp,sp,-96
    800031b6:	ec86                	sd	ra,88(sp)
    800031b8:	e8a2                	sd	s0,80(sp)
    800031ba:	e4a6                	sd	s1,72(sp)
    800031bc:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031be:	0001e797          	auipc	a5,0x1e
    800031c2:	b1e7a783          	lw	a5,-1250(a5) # 80020cdc <sb+0x4>
    800031c6:	0e078f63          	beqz	a5,800032c4 <balloc+0x110>
    800031ca:	e0ca                	sd	s2,64(sp)
    800031cc:	fc4e                	sd	s3,56(sp)
    800031ce:	f852                	sd	s4,48(sp)
    800031d0:	f456                	sd	s5,40(sp)
    800031d2:	f05a                	sd	s6,32(sp)
    800031d4:	ec5e                	sd	s7,24(sp)
    800031d6:	e862                	sd	s8,16(sp)
    800031d8:	e466                	sd	s9,8(sp)
    800031da:	8baa                	mv	s7,a0
    800031dc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031de:	0001eb17          	auipc	s6,0x1e
    800031e2:	afab0b13          	addi	s6,s6,-1286 # 80020cd8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031e6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031e8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031ea:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031ec:	6c89                	lui	s9,0x2
    800031ee:	a0b5                	j	8000325a <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031f0:	97ca                	add	a5,a5,s2
    800031f2:	8e55                	or	a2,a2,a3
    800031f4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031f8:	854a                	mv	a0,s2
    800031fa:	6a9000ef          	jal	800040a2 <log_write>
        brelse(bp);
    800031fe:	854a                	mv	a0,s2
    80003200:	e59ff0ef          	jal	80003058 <brelse>
  bp = bread(dev, bno);
    80003204:	85a6                	mv	a1,s1
    80003206:	855e                	mv	a0,s7
    80003208:	d49ff0ef          	jal	80002f50 <bread>
    8000320c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000320e:	40000613          	li	a2,1024
    80003212:	4581                	li	a1,0
    80003214:	05850513          	addi	a0,a0,88
    80003218:	ab1fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    8000321c:	854a                	mv	a0,s2
    8000321e:	685000ef          	jal	800040a2 <log_write>
  brelse(bp);
    80003222:	854a                	mv	a0,s2
    80003224:	e35ff0ef          	jal	80003058 <brelse>
}
    80003228:	6906                	ld	s2,64(sp)
    8000322a:	79e2                	ld	s3,56(sp)
    8000322c:	7a42                	ld	s4,48(sp)
    8000322e:	7aa2                	ld	s5,40(sp)
    80003230:	7b02                	ld	s6,32(sp)
    80003232:	6be2                	ld	s7,24(sp)
    80003234:	6c42                	ld	s8,16(sp)
    80003236:	6ca2                	ld	s9,8(sp)
}
    80003238:	8526                	mv	a0,s1
    8000323a:	60e6                	ld	ra,88(sp)
    8000323c:	6446                	ld	s0,80(sp)
    8000323e:	64a6                	ld	s1,72(sp)
    80003240:	6125                	addi	sp,sp,96
    80003242:	8082                	ret
    brelse(bp);
    80003244:	854a                	mv	a0,s2
    80003246:	e13ff0ef          	jal	80003058 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000324a:	015c87bb          	addw	a5,s9,s5
    8000324e:	00078a9b          	sext.w	s5,a5
    80003252:	004b2703          	lw	a4,4(s6)
    80003256:	04eaff63          	bgeu	s5,a4,800032b4 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    8000325a:	41fad79b          	sraiw	a5,s5,0x1f
    8000325e:	0137d79b          	srliw	a5,a5,0x13
    80003262:	015787bb          	addw	a5,a5,s5
    80003266:	40d7d79b          	sraiw	a5,a5,0xd
    8000326a:	01cb2583          	lw	a1,28(s6)
    8000326e:	9dbd                	addw	a1,a1,a5
    80003270:	855e                	mv	a0,s7
    80003272:	cdfff0ef          	jal	80002f50 <bread>
    80003276:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003278:	004b2503          	lw	a0,4(s6)
    8000327c:	000a849b          	sext.w	s1,s5
    80003280:	8762                	mv	a4,s8
    80003282:	fca4f1e3          	bgeu	s1,a0,80003244 <balloc+0x90>
      m = 1 << (bi % 8);
    80003286:	00777693          	andi	a3,a4,7
    8000328a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000328e:	41f7579b          	sraiw	a5,a4,0x1f
    80003292:	01d7d79b          	srliw	a5,a5,0x1d
    80003296:	9fb9                	addw	a5,a5,a4
    80003298:	4037d79b          	sraiw	a5,a5,0x3
    8000329c:	00f90633          	add	a2,s2,a5
    800032a0:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800032a4:	00c6f5b3          	and	a1,a3,a2
    800032a8:	d5a1                	beqz	a1,800031f0 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032aa:	2705                	addiw	a4,a4,1
    800032ac:	2485                	addiw	s1,s1,1
    800032ae:	fd471ae3          	bne	a4,s4,80003282 <balloc+0xce>
    800032b2:	bf49                	j	80003244 <balloc+0x90>
    800032b4:	6906                	ld	s2,64(sp)
    800032b6:	79e2                	ld	s3,56(sp)
    800032b8:	7a42                	ld	s4,48(sp)
    800032ba:	7aa2                	ld	s5,40(sp)
    800032bc:	7b02                	ld	s6,32(sp)
    800032be:	6be2                	ld	s7,24(sp)
    800032c0:	6c42                	ld	s8,16(sp)
    800032c2:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800032c4:	00004517          	auipc	a0,0x4
    800032c8:	22c50513          	addi	a0,a0,556 # 800074f0 <etext+0x4f0>
    800032cc:	9f6fd0ef          	jal	800004c2 <printf>
  return 0;
    800032d0:	4481                	li	s1,0
    800032d2:	b79d                	j	80003238 <balloc+0x84>

00000000800032d4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032d4:	7179                	addi	sp,sp,-48
    800032d6:	f406                	sd	ra,40(sp)
    800032d8:	f022                	sd	s0,32(sp)
    800032da:	ec26                	sd	s1,24(sp)
    800032dc:	e84a                	sd	s2,16(sp)
    800032de:	e44e                	sd	s3,8(sp)
    800032e0:	1800                	addi	s0,sp,48
    800032e2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032e4:	47ad                	li	a5,11
    800032e6:	02b7e663          	bltu	a5,a1,80003312 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800032ea:	02059793          	slli	a5,a1,0x20
    800032ee:	01e7d593          	srli	a1,a5,0x1e
    800032f2:	00b504b3          	add	s1,a0,a1
    800032f6:	0504a903          	lw	s2,80(s1)
    800032fa:	06091a63          	bnez	s2,8000336e <bmap+0x9a>
      addr = balloc(ip->dev);
    800032fe:	4108                	lw	a0,0(a0)
    80003300:	eb5ff0ef          	jal	800031b4 <balloc>
    80003304:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003308:	06090363          	beqz	s2,8000336e <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000330c:	0524a823          	sw	s2,80(s1)
    80003310:	a8b9                	j	8000336e <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003312:	ff45849b          	addiw	s1,a1,-12
    80003316:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000331a:	0ff00793          	li	a5,255
    8000331e:	06e7ee63          	bltu	a5,a4,8000339a <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003322:	08052903          	lw	s2,128(a0)
    80003326:	00091d63          	bnez	s2,80003340 <bmap+0x6c>
      addr = balloc(ip->dev);
    8000332a:	4108                	lw	a0,0(a0)
    8000332c:	e89ff0ef          	jal	800031b4 <balloc>
    80003330:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003334:	02090d63          	beqz	s2,8000336e <bmap+0x9a>
    80003338:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000333a:	0929a023          	sw	s2,128(s3)
    8000333e:	a011                	j	80003342 <bmap+0x6e>
    80003340:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003342:	85ca                	mv	a1,s2
    80003344:	0009a503          	lw	a0,0(s3)
    80003348:	c09ff0ef          	jal	80002f50 <bread>
    8000334c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000334e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003352:	02049713          	slli	a4,s1,0x20
    80003356:	01e75593          	srli	a1,a4,0x1e
    8000335a:	00b784b3          	add	s1,a5,a1
    8000335e:	0004a903          	lw	s2,0(s1)
    80003362:	00090e63          	beqz	s2,8000337e <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003366:	8552                	mv	a0,s4
    80003368:	cf1ff0ef          	jal	80003058 <brelse>
    return addr;
    8000336c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000336e:	854a                	mv	a0,s2
    80003370:	70a2                	ld	ra,40(sp)
    80003372:	7402                	ld	s0,32(sp)
    80003374:	64e2                	ld	s1,24(sp)
    80003376:	6942                	ld	s2,16(sp)
    80003378:	69a2                	ld	s3,8(sp)
    8000337a:	6145                	addi	sp,sp,48
    8000337c:	8082                	ret
      addr = balloc(ip->dev);
    8000337e:	0009a503          	lw	a0,0(s3)
    80003382:	e33ff0ef          	jal	800031b4 <balloc>
    80003386:	0005091b          	sext.w	s2,a0
      if(addr){
    8000338a:	fc090ee3          	beqz	s2,80003366 <bmap+0x92>
        a[bn] = addr;
    8000338e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003392:	8552                	mv	a0,s4
    80003394:	50f000ef          	jal	800040a2 <log_write>
    80003398:	b7f9                	j	80003366 <bmap+0x92>
    8000339a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000339c:	00004517          	auipc	a0,0x4
    800033a0:	16c50513          	addi	a0,a0,364 # 80007508 <etext+0x508>
    800033a4:	bf0fd0ef          	jal	80000794 <panic>

00000000800033a8 <iget>:
{
    800033a8:	7179                	addi	sp,sp,-48
    800033aa:	f406                	sd	ra,40(sp)
    800033ac:	f022                	sd	s0,32(sp)
    800033ae:	ec26                	sd	s1,24(sp)
    800033b0:	e84a                	sd	s2,16(sp)
    800033b2:	e44e                	sd	s3,8(sp)
    800033b4:	e052                	sd	s4,0(sp)
    800033b6:	1800                	addi	s0,sp,48
    800033b8:	89aa                	mv	s3,a0
    800033ba:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033bc:	0001e517          	auipc	a0,0x1e
    800033c0:	93c50513          	addi	a0,a0,-1732 # 80020cf8 <itable>
    800033c4:	831fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    800033c8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033ca:	0001e497          	auipc	s1,0x1e
    800033ce:	94648493          	addi	s1,s1,-1722 # 80020d10 <itable+0x18>
    800033d2:	0001f697          	auipc	a3,0x1f
    800033d6:	3ce68693          	addi	a3,a3,974 # 800227a0 <log>
    800033da:	a039                	j	800033e8 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033dc:	02090963          	beqz	s2,8000340e <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033e0:	08848493          	addi	s1,s1,136
    800033e4:	02d48863          	beq	s1,a3,80003414 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033e8:	449c                	lw	a5,8(s1)
    800033ea:	fef059e3          	blez	a5,800033dc <iget+0x34>
    800033ee:	4098                	lw	a4,0(s1)
    800033f0:	ff3716e3          	bne	a4,s3,800033dc <iget+0x34>
    800033f4:	40d8                	lw	a4,4(s1)
    800033f6:	ff4713e3          	bne	a4,s4,800033dc <iget+0x34>
      ip->ref++;
    800033fa:	2785                	addiw	a5,a5,1
    800033fc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033fe:	0001e517          	auipc	a0,0x1e
    80003402:	8fa50513          	addi	a0,a0,-1798 # 80020cf8 <itable>
    80003406:	887fd0ef          	jal	80000c8c <release>
      return ip;
    8000340a:	8926                	mv	s2,s1
    8000340c:	a02d                	j	80003436 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000340e:	fbe9                	bnez	a5,800033e0 <iget+0x38>
      empty = ip;
    80003410:	8926                	mv	s2,s1
    80003412:	b7f9                	j	800033e0 <iget+0x38>
  if(empty == 0)
    80003414:	02090a63          	beqz	s2,80003448 <iget+0xa0>
  ip->dev = dev;
    80003418:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000341c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003420:	4785                	li	a5,1
    80003422:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003426:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000342a:	0001e517          	auipc	a0,0x1e
    8000342e:	8ce50513          	addi	a0,a0,-1842 # 80020cf8 <itable>
    80003432:	85bfd0ef          	jal	80000c8c <release>
}
    80003436:	854a                	mv	a0,s2
    80003438:	70a2                	ld	ra,40(sp)
    8000343a:	7402                	ld	s0,32(sp)
    8000343c:	64e2                	ld	s1,24(sp)
    8000343e:	6942                	ld	s2,16(sp)
    80003440:	69a2                	ld	s3,8(sp)
    80003442:	6a02                	ld	s4,0(sp)
    80003444:	6145                	addi	sp,sp,48
    80003446:	8082                	ret
    panic("iget: no inodes");
    80003448:	00004517          	auipc	a0,0x4
    8000344c:	0d850513          	addi	a0,a0,216 # 80007520 <etext+0x520>
    80003450:	b44fd0ef          	jal	80000794 <panic>

0000000080003454 <fsinit>:
fsinit(int dev) {
    80003454:	7179                	addi	sp,sp,-48
    80003456:	f406                	sd	ra,40(sp)
    80003458:	f022                	sd	s0,32(sp)
    8000345a:	ec26                	sd	s1,24(sp)
    8000345c:	e84a                	sd	s2,16(sp)
    8000345e:	e44e                	sd	s3,8(sp)
    80003460:	1800                	addi	s0,sp,48
    80003462:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003464:	4585                	li	a1,1
    80003466:	aebff0ef          	jal	80002f50 <bread>
    8000346a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000346c:	0001e997          	auipc	s3,0x1e
    80003470:	86c98993          	addi	s3,s3,-1940 # 80020cd8 <sb>
    80003474:	02000613          	li	a2,32
    80003478:	05850593          	addi	a1,a0,88
    8000347c:	854e                	mv	a0,s3
    8000347e:	8a7fd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80003482:	8526                	mv	a0,s1
    80003484:	bd5ff0ef          	jal	80003058 <brelse>
  if(sb.magic != FSMAGIC)
    80003488:	0009a703          	lw	a4,0(s3)
    8000348c:	102037b7          	lui	a5,0x10203
    80003490:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003494:	02f71063          	bne	a4,a5,800034b4 <fsinit+0x60>
  initlog(dev, &sb);
    80003498:	0001e597          	auipc	a1,0x1e
    8000349c:	84058593          	addi	a1,a1,-1984 # 80020cd8 <sb>
    800034a0:	854a                	mv	a0,s2
    800034a2:	1f9000ef          	jal	80003e9a <initlog>
}
    800034a6:	70a2                	ld	ra,40(sp)
    800034a8:	7402                	ld	s0,32(sp)
    800034aa:	64e2                	ld	s1,24(sp)
    800034ac:	6942                	ld	s2,16(sp)
    800034ae:	69a2                	ld	s3,8(sp)
    800034b0:	6145                	addi	sp,sp,48
    800034b2:	8082                	ret
    panic("invalid file system");
    800034b4:	00004517          	auipc	a0,0x4
    800034b8:	07c50513          	addi	a0,a0,124 # 80007530 <etext+0x530>
    800034bc:	ad8fd0ef          	jal	80000794 <panic>

00000000800034c0 <iinit>:
{
    800034c0:	7179                	addi	sp,sp,-48
    800034c2:	f406                	sd	ra,40(sp)
    800034c4:	f022                	sd	s0,32(sp)
    800034c6:	ec26                	sd	s1,24(sp)
    800034c8:	e84a                	sd	s2,16(sp)
    800034ca:	e44e                	sd	s3,8(sp)
    800034cc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034ce:	00004597          	auipc	a1,0x4
    800034d2:	07a58593          	addi	a1,a1,122 # 80007548 <etext+0x548>
    800034d6:	0001e517          	auipc	a0,0x1e
    800034da:	82250513          	addi	a0,a0,-2014 # 80020cf8 <itable>
    800034de:	e96fd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034e2:	0001e497          	auipc	s1,0x1e
    800034e6:	83e48493          	addi	s1,s1,-1986 # 80020d20 <itable+0x28>
    800034ea:	0001f997          	auipc	s3,0x1f
    800034ee:	2c698993          	addi	s3,s3,710 # 800227b0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034f2:	00004917          	auipc	s2,0x4
    800034f6:	05e90913          	addi	s2,s2,94 # 80007550 <etext+0x550>
    800034fa:	85ca                	mv	a1,s2
    800034fc:	8526                	mv	a0,s1
    800034fe:	475000ef          	jal	80004172 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003502:	08848493          	addi	s1,s1,136
    80003506:	ff349ae3          	bne	s1,s3,800034fa <iinit+0x3a>
}
    8000350a:	70a2                	ld	ra,40(sp)
    8000350c:	7402                	ld	s0,32(sp)
    8000350e:	64e2                	ld	s1,24(sp)
    80003510:	6942                	ld	s2,16(sp)
    80003512:	69a2                	ld	s3,8(sp)
    80003514:	6145                	addi	sp,sp,48
    80003516:	8082                	ret

0000000080003518 <ialloc>:
{
    80003518:	7139                	addi	sp,sp,-64
    8000351a:	fc06                	sd	ra,56(sp)
    8000351c:	f822                	sd	s0,48(sp)
    8000351e:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003520:	0001d717          	auipc	a4,0x1d
    80003524:	7c472703          	lw	a4,1988(a4) # 80020ce4 <sb+0xc>
    80003528:	4785                	li	a5,1
    8000352a:	06e7f063          	bgeu	a5,a4,8000358a <ialloc+0x72>
    8000352e:	f426                	sd	s1,40(sp)
    80003530:	f04a                	sd	s2,32(sp)
    80003532:	ec4e                	sd	s3,24(sp)
    80003534:	e852                	sd	s4,16(sp)
    80003536:	e456                	sd	s5,8(sp)
    80003538:	e05a                	sd	s6,0(sp)
    8000353a:	8aaa                	mv	s5,a0
    8000353c:	8b2e                	mv	s6,a1
    8000353e:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003540:	0001da17          	auipc	s4,0x1d
    80003544:	798a0a13          	addi	s4,s4,1944 # 80020cd8 <sb>
    80003548:	00495593          	srli	a1,s2,0x4
    8000354c:	018a2783          	lw	a5,24(s4)
    80003550:	9dbd                	addw	a1,a1,a5
    80003552:	8556                	mv	a0,s5
    80003554:	9fdff0ef          	jal	80002f50 <bread>
    80003558:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000355a:	05850993          	addi	s3,a0,88
    8000355e:	00f97793          	andi	a5,s2,15
    80003562:	079a                	slli	a5,a5,0x6
    80003564:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003566:	00099783          	lh	a5,0(s3)
    8000356a:	cb9d                	beqz	a5,800035a0 <ialloc+0x88>
    brelse(bp);
    8000356c:	aedff0ef          	jal	80003058 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003570:	0905                	addi	s2,s2,1
    80003572:	00ca2703          	lw	a4,12(s4)
    80003576:	0009079b          	sext.w	a5,s2
    8000357a:	fce7e7e3          	bltu	a5,a4,80003548 <ialloc+0x30>
    8000357e:	74a2                	ld	s1,40(sp)
    80003580:	7902                	ld	s2,32(sp)
    80003582:	69e2                	ld	s3,24(sp)
    80003584:	6a42                	ld	s4,16(sp)
    80003586:	6aa2                	ld	s5,8(sp)
    80003588:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000358a:	00004517          	auipc	a0,0x4
    8000358e:	fce50513          	addi	a0,a0,-50 # 80007558 <etext+0x558>
    80003592:	f31fc0ef          	jal	800004c2 <printf>
  return 0;
    80003596:	4501                	li	a0,0
}
    80003598:	70e2                	ld	ra,56(sp)
    8000359a:	7442                	ld	s0,48(sp)
    8000359c:	6121                	addi	sp,sp,64
    8000359e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035a0:	04000613          	li	a2,64
    800035a4:	4581                	li	a1,0
    800035a6:	854e                	mv	a0,s3
    800035a8:	f20fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800035ac:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035b0:	8526                	mv	a0,s1
    800035b2:	2f1000ef          	jal	800040a2 <log_write>
      brelse(bp);
    800035b6:	8526                	mv	a0,s1
    800035b8:	aa1ff0ef          	jal	80003058 <brelse>
      return iget(dev, inum);
    800035bc:	0009059b          	sext.w	a1,s2
    800035c0:	8556                	mv	a0,s5
    800035c2:	de7ff0ef          	jal	800033a8 <iget>
    800035c6:	74a2                	ld	s1,40(sp)
    800035c8:	7902                	ld	s2,32(sp)
    800035ca:	69e2                	ld	s3,24(sp)
    800035cc:	6a42                	ld	s4,16(sp)
    800035ce:	6aa2                	ld	s5,8(sp)
    800035d0:	6b02                	ld	s6,0(sp)
    800035d2:	b7d9                	j	80003598 <ialloc+0x80>

00000000800035d4 <iupdate>:
{
    800035d4:	1101                	addi	sp,sp,-32
    800035d6:	ec06                	sd	ra,24(sp)
    800035d8:	e822                	sd	s0,16(sp)
    800035da:	e426                	sd	s1,8(sp)
    800035dc:	e04a                	sd	s2,0(sp)
    800035de:	1000                	addi	s0,sp,32
    800035e0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035e2:	415c                	lw	a5,4(a0)
    800035e4:	0047d79b          	srliw	a5,a5,0x4
    800035e8:	0001d597          	auipc	a1,0x1d
    800035ec:	7085a583          	lw	a1,1800(a1) # 80020cf0 <sb+0x18>
    800035f0:	9dbd                	addw	a1,a1,a5
    800035f2:	4108                	lw	a0,0(a0)
    800035f4:	95dff0ef          	jal	80002f50 <bread>
    800035f8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035fa:	05850793          	addi	a5,a0,88
    800035fe:	40d8                	lw	a4,4(s1)
    80003600:	8b3d                	andi	a4,a4,15
    80003602:	071a                	slli	a4,a4,0x6
    80003604:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003606:	04449703          	lh	a4,68(s1)
    8000360a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000360e:	04649703          	lh	a4,70(s1)
    80003612:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003616:	04849703          	lh	a4,72(s1)
    8000361a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000361e:	04a49703          	lh	a4,74(s1)
    80003622:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003626:	44f8                	lw	a4,76(s1)
    80003628:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000362a:	03400613          	li	a2,52
    8000362e:	05048593          	addi	a1,s1,80
    80003632:	00c78513          	addi	a0,a5,12
    80003636:	eeefd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    8000363a:	854a                	mv	a0,s2
    8000363c:	267000ef          	jal	800040a2 <log_write>
  brelse(bp);
    80003640:	854a                	mv	a0,s2
    80003642:	a17ff0ef          	jal	80003058 <brelse>
}
    80003646:	60e2                	ld	ra,24(sp)
    80003648:	6442                	ld	s0,16(sp)
    8000364a:	64a2                	ld	s1,8(sp)
    8000364c:	6902                	ld	s2,0(sp)
    8000364e:	6105                	addi	sp,sp,32
    80003650:	8082                	ret

0000000080003652 <idup>:
{
    80003652:	1101                	addi	sp,sp,-32
    80003654:	ec06                	sd	ra,24(sp)
    80003656:	e822                	sd	s0,16(sp)
    80003658:	e426                	sd	s1,8(sp)
    8000365a:	1000                	addi	s0,sp,32
    8000365c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000365e:	0001d517          	auipc	a0,0x1d
    80003662:	69a50513          	addi	a0,a0,1690 # 80020cf8 <itable>
    80003666:	d8efd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    8000366a:	449c                	lw	a5,8(s1)
    8000366c:	2785                	addiw	a5,a5,1
    8000366e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003670:	0001d517          	auipc	a0,0x1d
    80003674:	68850513          	addi	a0,a0,1672 # 80020cf8 <itable>
    80003678:	e14fd0ef          	jal	80000c8c <release>
}
    8000367c:	8526                	mv	a0,s1
    8000367e:	60e2                	ld	ra,24(sp)
    80003680:	6442                	ld	s0,16(sp)
    80003682:	64a2                	ld	s1,8(sp)
    80003684:	6105                	addi	sp,sp,32
    80003686:	8082                	ret

0000000080003688 <ilock>:
{
    80003688:	1101                	addi	sp,sp,-32
    8000368a:	ec06                	sd	ra,24(sp)
    8000368c:	e822                	sd	s0,16(sp)
    8000368e:	e426                	sd	s1,8(sp)
    80003690:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003692:	cd19                	beqz	a0,800036b0 <ilock+0x28>
    80003694:	84aa                	mv	s1,a0
    80003696:	451c                	lw	a5,8(a0)
    80003698:	00f05c63          	blez	a5,800036b0 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000369c:	0541                	addi	a0,a0,16
    8000369e:	30b000ef          	jal	800041a8 <acquiresleep>
  if(ip->valid == 0){
    800036a2:	40bc                	lw	a5,64(s1)
    800036a4:	cf89                	beqz	a5,800036be <ilock+0x36>
}
    800036a6:	60e2                	ld	ra,24(sp)
    800036a8:	6442                	ld	s0,16(sp)
    800036aa:	64a2                	ld	s1,8(sp)
    800036ac:	6105                	addi	sp,sp,32
    800036ae:	8082                	ret
    800036b0:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800036b2:	00004517          	auipc	a0,0x4
    800036b6:	ebe50513          	addi	a0,a0,-322 # 80007570 <etext+0x570>
    800036ba:	8dafd0ef          	jal	80000794 <panic>
    800036be:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036c0:	40dc                	lw	a5,4(s1)
    800036c2:	0047d79b          	srliw	a5,a5,0x4
    800036c6:	0001d597          	auipc	a1,0x1d
    800036ca:	62a5a583          	lw	a1,1578(a1) # 80020cf0 <sb+0x18>
    800036ce:	9dbd                	addw	a1,a1,a5
    800036d0:	4088                	lw	a0,0(s1)
    800036d2:	87fff0ef          	jal	80002f50 <bread>
    800036d6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036d8:	05850593          	addi	a1,a0,88
    800036dc:	40dc                	lw	a5,4(s1)
    800036de:	8bbd                	andi	a5,a5,15
    800036e0:	079a                	slli	a5,a5,0x6
    800036e2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036e4:	00059783          	lh	a5,0(a1)
    800036e8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036ec:	00259783          	lh	a5,2(a1)
    800036f0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036f4:	00459783          	lh	a5,4(a1)
    800036f8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036fc:	00659783          	lh	a5,6(a1)
    80003700:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003704:	459c                	lw	a5,8(a1)
    80003706:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003708:	03400613          	li	a2,52
    8000370c:	05b1                	addi	a1,a1,12
    8000370e:	05048513          	addi	a0,s1,80
    80003712:	e12fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003716:	854a                	mv	a0,s2
    80003718:	941ff0ef          	jal	80003058 <brelse>
    ip->valid = 1;
    8000371c:	4785                	li	a5,1
    8000371e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003720:	04449783          	lh	a5,68(s1)
    80003724:	c399                	beqz	a5,8000372a <ilock+0xa2>
    80003726:	6902                	ld	s2,0(sp)
    80003728:	bfbd                	j	800036a6 <ilock+0x1e>
      panic("ilock: no type");
    8000372a:	00004517          	auipc	a0,0x4
    8000372e:	e4e50513          	addi	a0,a0,-434 # 80007578 <etext+0x578>
    80003732:	862fd0ef          	jal	80000794 <panic>

0000000080003736 <iunlock>:
{
    80003736:	1101                	addi	sp,sp,-32
    80003738:	ec06                	sd	ra,24(sp)
    8000373a:	e822                	sd	s0,16(sp)
    8000373c:	e426                	sd	s1,8(sp)
    8000373e:	e04a                	sd	s2,0(sp)
    80003740:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003742:	c505                	beqz	a0,8000376a <iunlock+0x34>
    80003744:	84aa                	mv	s1,a0
    80003746:	01050913          	addi	s2,a0,16
    8000374a:	854a                	mv	a0,s2
    8000374c:	2db000ef          	jal	80004226 <holdingsleep>
    80003750:	cd09                	beqz	a0,8000376a <iunlock+0x34>
    80003752:	449c                	lw	a5,8(s1)
    80003754:	00f05b63          	blez	a5,8000376a <iunlock+0x34>
  releasesleep(&ip->lock);
    80003758:	854a                	mv	a0,s2
    8000375a:	295000ef          	jal	800041ee <releasesleep>
}
    8000375e:	60e2                	ld	ra,24(sp)
    80003760:	6442                	ld	s0,16(sp)
    80003762:	64a2                	ld	s1,8(sp)
    80003764:	6902                	ld	s2,0(sp)
    80003766:	6105                	addi	sp,sp,32
    80003768:	8082                	ret
    panic("iunlock");
    8000376a:	00004517          	auipc	a0,0x4
    8000376e:	e1e50513          	addi	a0,a0,-482 # 80007588 <etext+0x588>
    80003772:	822fd0ef          	jal	80000794 <panic>

0000000080003776 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003776:	7179                	addi	sp,sp,-48
    80003778:	f406                	sd	ra,40(sp)
    8000377a:	f022                	sd	s0,32(sp)
    8000377c:	ec26                	sd	s1,24(sp)
    8000377e:	e84a                	sd	s2,16(sp)
    80003780:	e44e                	sd	s3,8(sp)
    80003782:	1800                	addi	s0,sp,48
    80003784:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003786:	05050493          	addi	s1,a0,80
    8000378a:	08050913          	addi	s2,a0,128
    8000378e:	a021                	j	80003796 <itrunc+0x20>
    80003790:	0491                	addi	s1,s1,4
    80003792:	01248b63          	beq	s1,s2,800037a8 <itrunc+0x32>
    if(ip->addrs[i]){
    80003796:	408c                	lw	a1,0(s1)
    80003798:	dde5                	beqz	a1,80003790 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000379a:	0009a503          	lw	a0,0(s3)
    8000379e:	9abff0ef          	jal	80003148 <bfree>
      ip->addrs[i] = 0;
    800037a2:	0004a023          	sw	zero,0(s1)
    800037a6:	b7ed                	j	80003790 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037a8:	0809a583          	lw	a1,128(s3)
    800037ac:	ed89                	bnez	a1,800037c6 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037ae:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037b2:	854e                	mv	a0,s3
    800037b4:	e21ff0ef          	jal	800035d4 <iupdate>
}
    800037b8:	70a2                	ld	ra,40(sp)
    800037ba:	7402                	ld	s0,32(sp)
    800037bc:	64e2                	ld	s1,24(sp)
    800037be:	6942                	ld	s2,16(sp)
    800037c0:	69a2                	ld	s3,8(sp)
    800037c2:	6145                	addi	sp,sp,48
    800037c4:	8082                	ret
    800037c6:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037c8:	0009a503          	lw	a0,0(s3)
    800037cc:	f84ff0ef          	jal	80002f50 <bread>
    800037d0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037d2:	05850493          	addi	s1,a0,88
    800037d6:	45850913          	addi	s2,a0,1112
    800037da:	a021                	j	800037e2 <itrunc+0x6c>
    800037dc:	0491                	addi	s1,s1,4
    800037de:	01248963          	beq	s1,s2,800037f0 <itrunc+0x7a>
      if(a[j])
    800037e2:	408c                	lw	a1,0(s1)
    800037e4:	dde5                	beqz	a1,800037dc <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800037e6:	0009a503          	lw	a0,0(s3)
    800037ea:	95fff0ef          	jal	80003148 <bfree>
    800037ee:	b7fd                	j	800037dc <itrunc+0x66>
    brelse(bp);
    800037f0:	8552                	mv	a0,s4
    800037f2:	867ff0ef          	jal	80003058 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037f6:	0809a583          	lw	a1,128(s3)
    800037fa:	0009a503          	lw	a0,0(s3)
    800037fe:	94bff0ef          	jal	80003148 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003802:	0809a023          	sw	zero,128(s3)
    80003806:	6a02                	ld	s4,0(sp)
    80003808:	b75d                	j	800037ae <itrunc+0x38>

000000008000380a <iput>:
{
    8000380a:	1101                	addi	sp,sp,-32
    8000380c:	ec06                	sd	ra,24(sp)
    8000380e:	e822                	sd	s0,16(sp)
    80003810:	e426                	sd	s1,8(sp)
    80003812:	1000                	addi	s0,sp,32
    80003814:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003816:	0001d517          	auipc	a0,0x1d
    8000381a:	4e250513          	addi	a0,a0,1250 # 80020cf8 <itable>
    8000381e:	bd6fd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003822:	4498                	lw	a4,8(s1)
    80003824:	4785                	li	a5,1
    80003826:	02f70063          	beq	a4,a5,80003846 <iput+0x3c>
  ip->ref--;
    8000382a:	449c                	lw	a5,8(s1)
    8000382c:	37fd                	addiw	a5,a5,-1
    8000382e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003830:	0001d517          	auipc	a0,0x1d
    80003834:	4c850513          	addi	a0,a0,1224 # 80020cf8 <itable>
    80003838:	c54fd0ef          	jal	80000c8c <release>
}
    8000383c:	60e2                	ld	ra,24(sp)
    8000383e:	6442                	ld	s0,16(sp)
    80003840:	64a2                	ld	s1,8(sp)
    80003842:	6105                	addi	sp,sp,32
    80003844:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003846:	40bc                	lw	a5,64(s1)
    80003848:	d3ed                	beqz	a5,8000382a <iput+0x20>
    8000384a:	04a49783          	lh	a5,74(s1)
    8000384e:	fff1                	bnez	a5,8000382a <iput+0x20>
    80003850:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003852:	01048913          	addi	s2,s1,16
    80003856:	854a                	mv	a0,s2
    80003858:	151000ef          	jal	800041a8 <acquiresleep>
    release(&itable.lock);
    8000385c:	0001d517          	auipc	a0,0x1d
    80003860:	49c50513          	addi	a0,a0,1180 # 80020cf8 <itable>
    80003864:	c28fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    80003868:	8526                	mv	a0,s1
    8000386a:	f0dff0ef          	jal	80003776 <itrunc>
    ip->type = 0;
    8000386e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003872:	8526                	mv	a0,s1
    80003874:	d61ff0ef          	jal	800035d4 <iupdate>
    ip->valid = 0;
    80003878:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000387c:	854a                	mv	a0,s2
    8000387e:	171000ef          	jal	800041ee <releasesleep>
    acquire(&itable.lock);
    80003882:	0001d517          	auipc	a0,0x1d
    80003886:	47650513          	addi	a0,a0,1142 # 80020cf8 <itable>
    8000388a:	b6afd0ef          	jal	80000bf4 <acquire>
    8000388e:	6902                	ld	s2,0(sp)
    80003890:	bf69                	j	8000382a <iput+0x20>

0000000080003892 <iunlockput>:
{
    80003892:	1101                	addi	sp,sp,-32
    80003894:	ec06                	sd	ra,24(sp)
    80003896:	e822                	sd	s0,16(sp)
    80003898:	e426                	sd	s1,8(sp)
    8000389a:	1000                	addi	s0,sp,32
    8000389c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000389e:	e99ff0ef          	jal	80003736 <iunlock>
  iput(ip);
    800038a2:	8526                	mv	a0,s1
    800038a4:	f67ff0ef          	jal	8000380a <iput>
}
    800038a8:	60e2                	ld	ra,24(sp)
    800038aa:	6442                	ld	s0,16(sp)
    800038ac:	64a2                	ld	s1,8(sp)
    800038ae:	6105                	addi	sp,sp,32
    800038b0:	8082                	ret

00000000800038b2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038b2:	1141                	addi	sp,sp,-16
    800038b4:	e422                	sd	s0,8(sp)
    800038b6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038b8:	411c                	lw	a5,0(a0)
    800038ba:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038bc:	415c                	lw	a5,4(a0)
    800038be:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038c0:	04451783          	lh	a5,68(a0)
    800038c4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038c8:	04a51783          	lh	a5,74(a0)
    800038cc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800038d0:	04c56783          	lwu	a5,76(a0)
    800038d4:	e99c                	sd	a5,16(a1)
}
    800038d6:	6422                	ld	s0,8(sp)
    800038d8:	0141                	addi	sp,sp,16
    800038da:	8082                	ret

00000000800038dc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038dc:	457c                	lw	a5,76(a0)
    800038de:	0ed7eb63          	bltu	a5,a3,800039d4 <readi+0xf8>
{
    800038e2:	7159                	addi	sp,sp,-112
    800038e4:	f486                	sd	ra,104(sp)
    800038e6:	f0a2                	sd	s0,96(sp)
    800038e8:	eca6                	sd	s1,88(sp)
    800038ea:	e0d2                	sd	s4,64(sp)
    800038ec:	fc56                	sd	s5,56(sp)
    800038ee:	f85a                	sd	s6,48(sp)
    800038f0:	f45e                	sd	s7,40(sp)
    800038f2:	1880                	addi	s0,sp,112
    800038f4:	8b2a                	mv	s6,a0
    800038f6:	8bae                	mv	s7,a1
    800038f8:	8a32                	mv	s4,a2
    800038fa:	84b6                	mv	s1,a3
    800038fc:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800038fe:	9f35                	addw	a4,a4,a3
    return 0;
    80003900:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003902:	0cd76063          	bltu	a4,a3,800039c2 <readi+0xe6>
    80003906:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003908:	00e7f463          	bgeu	a5,a4,80003910 <readi+0x34>
    n = ip->size - off;
    8000390c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003910:	080a8f63          	beqz	s5,800039ae <readi+0xd2>
    80003914:	e8ca                	sd	s2,80(sp)
    80003916:	f062                	sd	s8,32(sp)
    80003918:	ec66                	sd	s9,24(sp)
    8000391a:	e86a                	sd	s10,16(sp)
    8000391c:	e46e                	sd	s11,8(sp)
    8000391e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003920:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003924:	5c7d                	li	s8,-1
    80003926:	a80d                	j	80003958 <readi+0x7c>
    80003928:	020d1d93          	slli	s11,s10,0x20
    8000392c:	020ddd93          	srli	s11,s11,0x20
    80003930:	05890613          	addi	a2,s2,88
    80003934:	86ee                	mv	a3,s11
    80003936:	963a                	add	a2,a2,a4
    80003938:	85d2                	mv	a1,s4
    8000393a:	855e                	mv	a0,s7
    8000393c:	93dfe0ef          	jal	80002278 <either_copyout>
    80003940:	05850763          	beq	a0,s8,8000398e <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003944:	854a                	mv	a0,s2
    80003946:	f12ff0ef          	jal	80003058 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000394a:	013d09bb          	addw	s3,s10,s3
    8000394e:	009d04bb          	addw	s1,s10,s1
    80003952:	9a6e                	add	s4,s4,s11
    80003954:	0559f763          	bgeu	s3,s5,800039a2 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003958:	00a4d59b          	srliw	a1,s1,0xa
    8000395c:	855a                	mv	a0,s6
    8000395e:	977ff0ef          	jal	800032d4 <bmap>
    80003962:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003966:	c5b1                	beqz	a1,800039b2 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003968:	000b2503          	lw	a0,0(s6)
    8000396c:	de4ff0ef          	jal	80002f50 <bread>
    80003970:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003972:	3ff4f713          	andi	a4,s1,1023
    80003976:	40ec87bb          	subw	a5,s9,a4
    8000397a:	413a86bb          	subw	a3,s5,s3
    8000397e:	8d3e                	mv	s10,a5
    80003980:	2781                	sext.w	a5,a5
    80003982:	0006861b          	sext.w	a2,a3
    80003986:	faf671e3          	bgeu	a2,a5,80003928 <readi+0x4c>
    8000398a:	8d36                	mv	s10,a3
    8000398c:	bf71                	j	80003928 <readi+0x4c>
      brelse(bp);
    8000398e:	854a                	mv	a0,s2
    80003990:	ec8ff0ef          	jal	80003058 <brelse>
      tot = -1;
    80003994:	59fd                	li	s3,-1
      break;
    80003996:	6946                	ld	s2,80(sp)
    80003998:	7c02                	ld	s8,32(sp)
    8000399a:	6ce2                	ld	s9,24(sp)
    8000399c:	6d42                	ld	s10,16(sp)
    8000399e:	6da2                	ld	s11,8(sp)
    800039a0:	a831                	j	800039bc <readi+0xe0>
    800039a2:	6946                	ld	s2,80(sp)
    800039a4:	7c02                	ld	s8,32(sp)
    800039a6:	6ce2                	ld	s9,24(sp)
    800039a8:	6d42                	ld	s10,16(sp)
    800039aa:	6da2                	ld	s11,8(sp)
    800039ac:	a801                	j	800039bc <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039ae:	89d6                	mv	s3,s5
    800039b0:	a031                	j	800039bc <readi+0xe0>
    800039b2:	6946                	ld	s2,80(sp)
    800039b4:	7c02                	ld	s8,32(sp)
    800039b6:	6ce2                	ld	s9,24(sp)
    800039b8:	6d42                	ld	s10,16(sp)
    800039ba:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800039bc:	0009851b          	sext.w	a0,s3
    800039c0:	69a6                	ld	s3,72(sp)
}
    800039c2:	70a6                	ld	ra,104(sp)
    800039c4:	7406                	ld	s0,96(sp)
    800039c6:	64e6                	ld	s1,88(sp)
    800039c8:	6a06                	ld	s4,64(sp)
    800039ca:	7ae2                	ld	s5,56(sp)
    800039cc:	7b42                	ld	s6,48(sp)
    800039ce:	7ba2                	ld	s7,40(sp)
    800039d0:	6165                	addi	sp,sp,112
    800039d2:	8082                	ret
    return 0;
    800039d4:	4501                	li	a0,0
}
    800039d6:	8082                	ret

00000000800039d8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039d8:	457c                	lw	a5,76(a0)
    800039da:	10d7e063          	bltu	a5,a3,80003ada <writei+0x102>
{
    800039de:	7159                	addi	sp,sp,-112
    800039e0:	f486                	sd	ra,104(sp)
    800039e2:	f0a2                	sd	s0,96(sp)
    800039e4:	e8ca                	sd	s2,80(sp)
    800039e6:	e0d2                	sd	s4,64(sp)
    800039e8:	fc56                	sd	s5,56(sp)
    800039ea:	f85a                	sd	s6,48(sp)
    800039ec:	f45e                	sd	s7,40(sp)
    800039ee:	1880                	addi	s0,sp,112
    800039f0:	8aaa                	mv	s5,a0
    800039f2:	8bae                	mv	s7,a1
    800039f4:	8a32                	mv	s4,a2
    800039f6:	8936                	mv	s2,a3
    800039f8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039fa:	00e687bb          	addw	a5,a3,a4
    800039fe:	0ed7e063          	bltu	a5,a3,80003ade <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a02:	00043737          	lui	a4,0x43
    80003a06:	0cf76e63          	bltu	a4,a5,80003ae2 <writei+0x10a>
    80003a0a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a0c:	0a0b0f63          	beqz	s6,80003aca <writei+0xf2>
    80003a10:	eca6                	sd	s1,88(sp)
    80003a12:	f062                	sd	s8,32(sp)
    80003a14:	ec66                	sd	s9,24(sp)
    80003a16:	e86a                	sd	s10,16(sp)
    80003a18:	e46e                	sd	s11,8(sp)
    80003a1a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a1c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a20:	5c7d                	li	s8,-1
    80003a22:	a825                	j	80003a5a <writei+0x82>
    80003a24:	020d1d93          	slli	s11,s10,0x20
    80003a28:	020ddd93          	srli	s11,s11,0x20
    80003a2c:	05848513          	addi	a0,s1,88
    80003a30:	86ee                	mv	a3,s11
    80003a32:	8652                	mv	a2,s4
    80003a34:	85de                	mv	a1,s7
    80003a36:	953a                	add	a0,a0,a4
    80003a38:	88bfe0ef          	jal	800022c2 <either_copyin>
    80003a3c:	05850a63          	beq	a0,s8,80003a90 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a40:	8526                	mv	a0,s1
    80003a42:	660000ef          	jal	800040a2 <log_write>
    brelse(bp);
    80003a46:	8526                	mv	a0,s1
    80003a48:	e10ff0ef          	jal	80003058 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a4c:	013d09bb          	addw	s3,s10,s3
    80003a50:	012d093b          	addw	s2,s10,s2
    80003a54:	9a6e                	add	s4,s4,s11
    80003a56:	0569f063          	bgeu	s3,s6,80003a96 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003a5a:	00a9559b          	srliw	a1,s2,0xa
    80003a5e:	8556                	mv	a0,s5
    80003a60:	875ff0ef          	jal	800032d4 <bmap>
    80003a64:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a68:	c59d                	beqz	a1,80003a96 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003a6a:	000aa503          	lw	a0,0(s5)
    80003a6e:	ce2ff0ef          	jal	80002f50 <bread>
    80003a72:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a74:	3ff97713          	andi	a4,s2,1023
    80003a78:	40ec87bb          	subw	a5,s9,a4
    80003a7c:	413b06bb          	subw	a3,s6,s3
    80003a80:	8d3e                	mv	s10,a5
    80003a82:	2781                	sext.w	a5,a5
    80003a84:	0006861b          	sext.w	a2,a3
    80003a88:	f8f67ee3          	bgeu	a2,a5,80003a24 <writei+0x4c>
    80003a8c:	8d36                	mv	s10,a3
    80003a8e:	bf59                	j	80003a24 <writei+0x4c>
      brelse(bp);
    80003a90:	8526                	mv	a0,s1
    80003a92:	dc6ff0ef          	jal	80003058 <brelse>
  }

  if(off > ip->size)
    80003a96:	04caa783          	lw	a5,76(s5)
    80003a9a:	0327fa63          	bgeu	a5,s2,80003ace <writei+0xf6>
    ip->size = off;
    80003a9e:	052aa623          	sw	s2,76(s5)
    80003aa2:	64e6                	ld	s1,88(sp)
    80003aa4:	7c02                	ld	s8,32(sp)
    80003aa6:	6ce2                	ld	s9,24(sp)
    80003aa8:	6d42                	ld	s10,16(sp)
    80003aaa:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003aac:	8556                	mv	a0,s5
    80003aae:	b27ff0ef          	jal	800035d4 <iupdate>

  return tot;
    80003ab2:	0009851b          	sext.w	a0,s3
    80003ab6:	69a6                	ld	s3,72(sp)
}
    80003ab8:	70a6                	ld	ra,104(sp)
    80003aba:	7406                	ld	s0,96(sp)
    80003abc:	6946                	ld	s2,80(sp)
    80003abe:	6a06                	ld	s4,64(sp)
    80003ac0:	7ae2                	ld	s5,56(sp)
    80003ac2:	7b42                	ld	s6,48(sp)
    80003ac4:	7ba2                	ld	s7,40(sp)
    80003ac6:	6165                	addi	sp,sp,112
    80003ac8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aca:	89da                	mv	s3,s6
    80003acc:	b7c5                	j	80003aac <writei+0xd4>
    80003ace:	64e6                	ld	s1,88(sp)
    80003ad0:	7c02                	ld	s8,32(sp)
    80003ad2:	6ce2                	ld	s9,24(sp)
    80003ad4:	6d42                	ld	s10,16(sp)
    80003ad6:	6da2                	ld	s11,8(sp)
    80003ad8:	bfd1                	j	80003aac <writei+0xd4>
    return -1;
    80003ada:	557d                	li	a0,-1
}
    80003adc:	8082                	ret
    return -1;
    80003ade:	557d                	li	a0,-1
    80003ae0:	bfe1                	j	80003ab8 <writei+0xe0>
    return -1;
    80003ae2:	557d                	li	a0,-1
    80003ae4:	bfd1                	j	80003ab8 <writei+0xe0>

0000000080003ae6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ae6:	1141                	addi	sp,sp,-16
    80003ae8:	e406                	sd	ra,8(sp)
    80003aea:	e022                	sd	s0,0(sp)
    80003aec:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003aee:	4639                	li	a2,14
    80003af0:	aa4fd0ef          	jal	80000d94 <strncmp>
}
    80003af4:	60a2                	ld	ra,8(sp)
    80003af6:	6402                	ld	s0,0(sp)
    80003af8:	0141                	addi	sp,sp,16
    80003afa:	8082                	ret

0000000080003afc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003afc:	7139                	addi	sp,sp,-64
    80003afe:	fc06                	sd	ra,56(sp)
    80003b00:	f822                	sd	s0,48(sp)
    80003b02:	f426                	sd	s1,40(sp)
    80003b04:	f04a                	sd	s2,32(sp)
    80003b06:	ec4e                	sd	s3,24(sp)
    80003b08:	e852                	sd	s4,16(sp)
    80003b0a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b0c:	04451703          	lh	a4,68(a0)
    80003b10:	4785                	li	a5,1
    80003b12:	00f71a63          	bne	a4,a5,80003b26 <dirlookup+0x2a>
    80003b16:	892a                	mv	s2,a0
    80003b18:	89ae                	mv	s3,a1
    80003b1a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b1c:	457c                	lw	a5,76(a0)
    80003b1e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b20:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b22:	e39d                	bnez	a5,80003b48 <dirlookup+0x4c>
    80003b24:	a095                	j	80003b88 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003b26:	00004517          	auipc	a0,0x4
    80003b2a:	a6a50513          	addi	a0,a0,-1430 # 80007590 <etext+0x590>
    80003b2e:	c67fc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    80003b32:	00004517          	auipc	a0,0x4
    80003b36:	a7650513          	addi	a0,a0,-1418 # 800075a8 <etext+0x5a8>
    80003b3a:	c5bfc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b3e:	24c1                	addiw	s1,s1,16
    80003b40:	04c92783          	lw	a5,76(s2)
    80003b44:	04f4f163          	bgeu	s1,a5,80003b86 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b48:	4741                	li	a4,16
    80003b4a:	86a6                	mv	a3,s1
    80003b4c:	fc040613          	addi	a2,s0,-64
    80003b50:	4581                	li	a1,0
    80003b52:	854a                	mv	a0,s2
    80003b54:	d89ff0ef          	jal	800038dc <readi>
    80003b58:	47c1                	li	a5,16
    80003b5a:	fcf51ce3          	bne	a0,a5,80003b32 <dirlookup+0x36>
    if(de.inum == 0)
    80003b5e:	fc045783          	lhu	a5,-64(s0)
    80003b62:	dff1                	beqz	a5,80003b3e <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003b64:	fc240593          	addi	a1,s0,-62
    80003b68:	854e                	mv	a0,s3
    80003b6a:	f7dff0ef          	jal	80003ae6 <namecmp>
    80003b6e:	f961                	bnez	a0,80003b3e <dirlookup+0x42>
      if(poff)
    80003b70:	000a0463          	beqz	s4,80003b78 <dirlookup+0x7c>
        *poff = off;
    80003b74:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003b78:	fc045583          	lhu	a1,-64(s0)
    80003b7c:	00092503          	lw	a0,0(s2)
    80003b80:	829ff0ef          	jal	800033a8 <iget>
    80003b84:	a011                	j	80003b88 <dirlookup+0x8c>
  return 0;
    80003b86:	4501                	li	a0,0
}
    80003b88:	70e2                	ld	ra,56(sp)
    80003b8a:	7442                	ld	s0,48(sp)
    80003b8c:	74a2                	ld	s1,40(sp)
    80003b8e:	7902                	ld	s2,32(sp)
    80003b90:	69e2                	ld	s3,24(sp)
    80003b92:	6a42                	ld	s4,16(sp)
    80003b94:	6121                	addi	sp,sp,64
    80003b96:	8082                	ret

0000000080003b98 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b98:	711d                	addi	sp,sp,-96
    80003b9a:	ec86                	sd	ra,88(sp)
    80003b9c:	e8a2                	sd	s0,80(sp)
    80003b9e:	e4a6                	sd	s1,72(sp)
    80003ba0:	e0ca                	sd	s2,64(sp)
    80003ba2:	fc4e                	sd	s3,56(sp)
    80003ba4:	f852                	sd	s4,48(sp)
    80003ba6:	f456                	sd	s5,40(sp)
    80003ba8:	f05a                	sd	s6,32(sp)
    80003baa:	ec5e                	sd	s7,24(sp)
    80003bac:	e862                	sd	s8,16(sp)
    80003bae:	e466                	sd	s9,8(sp)
    80003bb0:	1080                	addi	s0,sp,96
    80003bb2:	84aa                	mv	s1,a0
    80003bb4:	8b2e                	mv	s6,a1
    80003bb6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003bb8:	00054703          	lbu	a4,0(a0)
    80003bbc:	02f00793          	li	a5,47
    80003bc0:	00f70e63          	beq	a4,a5,80003bdc <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003bc4:	d1dfd0ef          	jal	800018e0 <myproc>
    80003bc8:	15053503          	ld	a0,336(a0)
    80003bcc:	a87ff0ef          	jal	80003652 <idup>
    80003bd0:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003bd2:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003bd6:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003bd8:	4b85                	li	s7,1
    80003bda:	a871                	j	80003c76 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003bdc:	4585                	li	a1,1
    80003bde:	4505                	li	a0,1
    80003be0:	fc8ff0ef          	jal	800033a8 <iget>
    80003be4:	8a2a                	mv	s4,a0
    80003be6:	b7f5                	j	80003bd2 <namex+0x3a>
      iunlockput(ip);
    80003be8:	8552                	mv	a0,s4
    80003bea:	ca9ff0ef          	jal	80003892 <iunlockput>
      return 0;
    80003bee:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003bf0:	8552                	mv	a0,s4
    80003bf2:	60e6                	ld	ra,88(sp)
    80003bf4:	6446                	ld	s0,80(sp)
    80003bf6:	64a6                	ld	s1,72(sp)
    80003bf8:	6906                	ld	s2,64(sp)
    80003bfa:	79e2                	ld	s3,56(sp)
    80003bfc:	7a42                	ld	s4,48(sp)
    80003bfe:	7aa2                	ld	s5,40(sp)
    80003c00:	7b02                	ld	s6,32(sp)
    80003c02:	6be2                	ld	s7,24(sp)
    80003c04:	6c42                	ld	s8,16(sp)
    80003c06:	6ca2                	ld	s9,8(sp)
    80003c08:	6125                	addi	sp,sp,96
    80003c0a:	8082                	ret
      iunlock(ip);
    80003c0c:	8552                	mv	a0,s4
    80003c0e:	b29ff0ef          	jal	80003736 <iunlock>
      return ip;
    80003c12:	bff9                	j	80003bf0 <namex+0x58>
      iunlockput(ip);
    80003c14:	8552                	mv	a0,s4
    80003c16:	c7dff0ef          	jal	80003892 <iunlockput>
      return 0;
    80003c1a:	8a4e                	mv	s4,s3
    80003c1c:	bfd1                	j	80003bf0 <namex+0x58>
  len = path - s;
    80003c1e:	40998633          	sub	a2,s3,s1
    80003c22:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c26:	099c5063          	bge	s8,s9,80003ca6 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003c2a:	4639                	li	a2,14
    80003c2c:	85a6                	mv	a1,s1
    80003c2e:	8556                	mv	a0,s5
    80003c30:	8f4fd0ef          	jal	80000d24 <memmove>
    80003c34:	84ce                	mv	s1,s3
  while(*path == '/')
    80003c36:	0004c783          	lbu	a5,0(s1)
    80003c3a:	01279763          	bne	a5,s2,80003c48 <namex+0xb0>
    path++;
    80003c3e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c40:	0004c783          	lbu	a5,0(s1)
    80003c44:	ff278de3          	beq	a5,s2,80003c3e <namex+0xa6>
    ilock(ip);
    80003c48:	8552                	mv	a0,s4
    80003c4a:	a3fff0ef          	jal	80003688 <ilock>
    if(ip->type != T_DIR){
    80003c4e:	044a1783          	lh	a5,68(s4)
    80003c52:	f9779be3          	bne	a5,s7,80003be8 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003c56:	000b0563          	beqz	s6,80003c60 <namex+0xc8>
    80003c5a:	0004c783          	lbu	a5,0(s1)
    80003c5e:	d7dd                	beqz	a5,80003c0c <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c60:	4601                	li	a2,0
    80003c62:	85d6                	mv	a1,s5
    80003c64:	8552                	mv	a0,s4
    80003c66:	e97ff0ef          	jal	80003afc <dirlookup>
    80003c6a:	89aa                	mv	s3,a0
    80003c6c:	d545                	beqz	a0,80003c14 <namex+0x7c>
    iunlockput(ip);
    80003c6e:	8552                	mv	a0,s4
    80003c70:	c23ff0ef          	jal	80003892 <iunlockput>
    ip = next;
    80003c74:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003c76:	0004c783          	lbu	a5,0(s1)
    80003c7a:	01279763          	bne	a5,s2,80003c88 <namex+0xf0>
    path++;
    80003c7e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c80:	0004c783          	lbu	a5,0(s1)
    80003c84:	ff278de3          	beq	a5,s2,80003c7e <namex+0xe6>
  if(*path == 0)
    80003c88:	cb8d                	beqz	a5,80003cba <namex+0x122>
  while(*path != '/' && *path != 0)
    80003c8a:	0004c783          	lbu	a5,0(s1)
    80003c8e:	89a6                	mv	s3,s1
  len = path - s;
    80003c90:	4c81                	li	s9,0
    80003c92:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003c94:	01278963          	beq	a5,s2,80003ca6 <namex+0x10e>
    80003c98:	d3d9                	beqz	a5,80003c1e <namex+0x86>
    path++;
    80003c9a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003c9c:	0009c783          	lbu	a5,0(s3)
    80003ca0:	ff279ce3          	bne	a5,s2,80003c98 <namex+0x100>
    80003ca4:	bfad                	j	80003c1e <namex+0x86>
    memmove(name, s, len);
    80003ca6:	2601                	sext.w	a2,a2
    80003ca8:	85a6                	mv	a1,s1
    80003caa:	8556                	mv	a0,s5
    80003cac:	878fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003cb0:	9cd6                	add	s9,s9,s5
    80003cb2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003cb6:	84ce                	mv	s1,s3
    80003cb8:	bfbd                	j	80003c36 <namex+0x9e>
  if(nameiparent){
    80003cba:	f20b0be3          	beqz	s6,80003bf0 <namex+0x58>
    iput(ip);
    80003cbe:	8552                	mv	a0,s4
    80003cc0:	b4bff0ef          	jal	8000380a <iput>
    return 0;
    80003cc4:	4a01                	li	s4,0
    80003cc6:	b72d                	j	80003bf0 <namex+0x58>

0000000080003cc8 <dirlink>:
{
    80003cc8:	7139                	addi	sp,sp,-64
    80003cca:	fc06                	sd	ra,56(sp)
    80003ccc:	f822                	sd	s0,48(sp)
    80003cce:	f04a                	sd	s2,32(sp)
    80003cd0:	ec4e                	sd	s3,24(sp)
    80003cd2:	e852                	sd	s4,16(sp)
    80003cd4:	0080                	addi	s0,sp,64
    80003cd6:	892a                	mv	s2,a0
    80003cd8:	8a2e                	mv	s4,a1
    80003cda:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003cdc:	4601                	li	a2,0
    80003cde:	e1fff0ef          	jal	80003afc <dirlookup>
    80003ce2:	e535                	bnez	a0,80003d4e <dirlink+0x86>
    80003ce4:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ce6:	04c92483          	lw	s1,76(s2)
    80003cea:	c48d                	beqz	s1,80003d14 <dirlink+0x4c>
    80003cec:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cee:	4741                	li	a4,16
    80003cf0:	86a6                	mv	a3,s1
    80003cf2:	fc040613          	addi	a2,s0,-64
    80003cf6:	4581                	li	a1,0
    80003cf8:	854a                	mv	a0,s2
    80003cfa:	be3ff0ef          	jal	800038dc <readi>
    80003cfe:	47c1                	li	a5,16
    80003d00:	04f51b63          	bne	a0,a5,80003d56 <dirlink+0x8e>
    if(de.inum == 0)
    80003d04:	fc045783          	lhu	a5,-64(s0)
    80003d08:	c791                	beqz	a5,80003d14 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d0a:	24c1                	addiw	s1,s1,16
    80003d0c:	04c92783          	lw	a5,76(s2)
    80003d10:	fcf4efe3          	bltu	s1,a5,80003cee <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003d14:	4639                	li	a2,14
    80003d16:	85d2                	mv	a1,s4
    80003d18:	fc240513          	addi	a0,s0,-62
    80003d1c:	8aefd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003d20:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d24:	4741                	li	a4,16
    80003d26:	86a6                	mv	a3,s1
    80003d28:	fc040613          	addi	a2,s0,-64
    80003d2c:	4581                	li	a1,0
    80003d2e:	854a                	mv	a0,s2
    80003d30:	ca9ff0ef          	jal	800039d8 <writei>
    80003d34:	1541                	addi	a0,a0,-16
    80003d36:	00a03533          	snez	a0,a0
    80003d3a:	40a00533          	neg	a0,a0
    80003d3e:	74a2                	ld	s1,40(sp)
}
    80003d40:	70e2                	ld	ra,56(sp)
    80003d42:	7442                	ld	s0,48(sp)
    80003d44:	7902                	ld	s2,32(sp)
    80003d46:	69e2                	ld	s3,24(sp)
    80003d48:	6a42                	ld	s4,16(sp)
    80003d4a:	6121                	addi	sp,sp,64
    80003d4c:	8082                	ret
    iput(ip);
    80003d4e:	abdff0ef          	jal	8000380a <iput>
    return -1;
    80003d52:	557d                	li	a0,-1
    80003d54:	b7f5                	j	80003d40 <dirlink+0x78>
      panic("dirlink read");
    80003d56:	00004517          	auipc	a0,0x4
    80003d5a:	86250513          	addi	a0,a0,-1950 # 800075b8 <etext+0x5b8>
    80003d5e:	a37fc0ef          	jal	80000794 <panic>

0000000080003d62 <namei>:

struct inode*
namei(char *path)
{
    80003d62:	1101                	addi	sp,sp,-32
    80003d64:	ec06                	sd	ra,24(sp)
    80003d66:	e822                	sd	s0,16(sp)
    80003d68:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003d6a:	fe040613          	addi	a2,s0,-32
    80003d6e:	4581                	li	a1,0
    80003d70:	e29ff0ef          	jal	80003b98 <namex>
}
    80003d74:	60e2                	ld	ra,24(sp)
    80003d76:	6442                	ld	s0,16(sp)
    80003d78:	6105                	addi	sp,sp,32
    80003d7a:	8082                	ret

0000000080003d7c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003d7c:	1141                	addi	sp,sp,-16
    80003d7e:	e406                	sd	ra,8(sp)
    80003d80:	e022                	sd	s0,0(sp)
    80003d82:	0800                	addi	s0,sp,16
    80003d84:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003d86:	4585                	li	a1,1
    80003d88:	e11ff0ef          	jal	80003b98 <namex>
}
    80003d8c:	60a2                	ld	ra,8(sp)
    80003d8e:	6402                	ld	s0,0(sp)
    80003d90:	0141                	addi	sp,sp,16
    80003d92:	8082                	ret

0000000080003d94 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d94:	1101                	addi	sp,sp,-32
    80003d96:	ec06                	sd	ra,24(sp)
    80003d98:	e822                	sd	s0,16(sp)
    80003d9a:	e426                	sd	s1,8(sp)
    80003d9c:	e04a                	sd	s2,0(sp)
    80003d9e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003da0:	0001f917          	auipc	s2,0x1f
    80003da4:	a0090913          	addi	s2,s2,-1536 # 800227a0 <log>
    80003da8:	01892583          	lw	a1,24(s2)
    80003dac:	02892503          	lw	a0,40(s2)
    80003db0:	9a0ff0ef          	jal	80002f50 <bread>
    80003db4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003db6:	02c92603          	lw	a2,44(s2)
    80003dba:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003dbc:	00c05f63          	blez	a2,80003dda <write_head+0x46>
    80003dc0:	0001f717          	auipc	a4,0x1f
    80003dc4:	a1070713          	addi	a4,a4,-1520 # 800227d0 <log+0x30>
    80003dc8:	87aa                	mv	a5,a0
    80003dca:	060a                	slli	a2,a2,0x2
    80003dcc:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003dce:	4314                	lw	a3,0(a4)
    80003dd0:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003dd2:	0711                	addi	a4,a4,4
    80003dd4:	0791                	addi	a5,a5,4
    80003dd6:	fec79ce3          	bne	a5,a2,80003dce <write_head+0x3a>
  }
  bwrite(buf);
    80003dda:	8526                	mv	a0,s1
    80003ddc:	a4aff0ef          	jal	80003026 <bwrite>
  brelse(buf);
    80003de0:	8526                	mv	a0,s1
    80003de2:	a76ff0ef          	jal	80003058 <brelse>
}
    80003de6:	60e2                	ld	ra,24(sp)
    80003de8:	6442                	ld	s0,16(sp)
    80003dea:	64a2                	ld	s1,8(sp)
    80003dec:	6902                	ld	s2,0(sp)
    80003dee:	6105                	addi	sp,sp,32
    80003df0:	8082                	ret

0000000080003df2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003df2:	0001f797          	auipc	a5,0x1f
    80003df6:	9da7a783          	lw	a5,-1574(a5) # 800227cc <log+0x2c>
    80003dfa:	08f05f63          	blez	a5,80003e98 <install_trans+0xa6>
{
    80003dfe:	7139                	addi	sp,sp,-64
    80003e00:	fc06                	sd	ra,56(sp)
    80003e02:	f822                	sd	s0,48(sp)
    80003e04:	f426                	sd	s1,40(sp)
    80003e06:	f04a                	sd	s2,32(sp)
    80003e08:	ec4e                	sd	s3,24(sp)
    80003e0a:	e852                	sd	s4,16(sp)
    80003e0c:	e456                	sd	s5,8(sp)
    80003e0e:	e05a                	sd	s6,0(sp)
    80003e10:	0080                	addi	s0,sp,64
    80003e12:	8b2a                	mv	s6,a0
    80003e14:	0001fa97          	auipc	s5,0x1f
    80003e18:	9bca8a93          	addi	s5,s5,-1604 # 800227d0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e1c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e1e:	0001f997          	auipc	s3,0x1f
    80003e22:	98298993          	addi	s3,s3,-1662 # 800227a0 <log>
    80003e26:	a829                	j	80003e40 <install_trans+0x4e>
    brelse(lbuf);
    80003e28:	854a                	mv	a0,s2
    80003e2a:	a2eff0ef          	jal	80003058 <brelse>
    brelse(dbuf);
    80003e2e:	8526                	mv	a0,s1
    80003e30:	a28ff0ef          	jal	80003058 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e34:	2a05                	addiw	s4,s4,1
    80003e36:	0a91                	addi	s5,s5,4
    80003e38:	02c9a783          	lw	a5,44(s3)
    80003e3c:	04fa5463          	bge	s4,a5,80003e84 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e40:	0189a583          	lw	a1,24(s3)
    80003e44:	014585bb          	addw	a1,a1,s4
    80003e48:	2585                	addiw	a1,a1,1
    80003e4a:	0289a503          	lw	a0,40(s3)
    80003e4e:	902ff0ef          	jal	80002f50 <bread>
    80003e52:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003e54:	000aa583          	lw	a1,0(s5)
    80003e58:	0289a503          	lw	a0,40(s3)
    80003e5c:	8f4ff0ef          	jal	80002f50 <bread>
    80003e60:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003e62:	40000613          	li	a2,1024
    80003e66:	05890593          	addi	a1,s2,88
    80003e6a:	05850513          	addi	a0,a0,88
    80003e6e:	eb7fc0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003e72:	8526                	mv	a0,s1
    80003e74:	9b2ff0ef          	jal	80003026 <bwrite>
    if(recovering == 0)
    80003e78:	fa0b18e3          	bnez	s6,80003e28 <install_trans+0x36>
      bunpin(dbuf);
    80003e7c:	8526                	mv	a0,s1
    80003e7e:	a96ff0ef          	jal	80003114 <bunpin>
    80003e82:	b75d                	j	80003e28 <install_trans+0x36>
}
    80003e84:	70e2                	ld	ra,56(sp)
    80003e86:	7442                	ld	s0,48(sp)
    80003e88:	74a2                	ld	s1,40(sp)
    80003e8a:	7902                	ld	s2,32(sp)
    80003e8c:	69e2                	ld	s3,24(sp)
    80003e8e:	6a42                	ld	s4,16(sp)
    80003e90:	6aa2                	ld	s5,8(sp)
    80003e92:	6b02                	ld	s6,0(sp)
    80003e94:	6121                	addi	sp,sp,64
    80003e96:	8082                	ret
    80003e98:	8082                	ret

0000000080003e9a <initlog>:
{
    80003e9a:	7179                	addi	sp,sp,-48
    80003e9c:	f406                	sd	ra,40(sp)
    80003e9e:	f022                	sd	s0,32(sp)
    80003ea0:	ec26                	sd	s1,24(sp)
    80003ea2:	e84a                	sd	s2,16(sp)
    80003ea4:	e44e                	sd	s3,8(sp)
    80003ea6:	1800                	addi	s0,sp,48
    80003ea8:	892a                	mv	s2,a0
    80003eaa:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003eac:	0001f497          	auipc	s1,0x1f
    80003eb0:	8f448493          	addi	s1,s1,-1804 # 800227a0 <log>
    80003eb4:	00003597          	auipc	a1,0x3
    80003eb8:	71458593          	addi	a1,a1,1812 # 800075c8 <etext+0x5c8>
    80003ebc:	8526                	mv	a0,s1
    80003ebe:	cb7fc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003ec2:	0149a583          	lw	a1,20(s3)
    80003ec6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003ec8:	0109a783          	lw	a5,16(s3)
    80003ecc:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003ece:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ed2:	854a                	mv	a0,s2
    80003ed4:	87cff0ef          	jal	80002f50 <bread>
  log.lh.n = lh->n;
    80003ed8:	4d30                	lw	a2,88(a0)
    80003eda:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003edc:	00c05f63          	blez	a2,80003efa <initlog+0x60>
    80003ee0:	87aa                	mv	a5,a0
    80003ee2:	0001f717          	auipc	a4,0x1f
    80003ee6:	8ee70713          	addi	a4,a4,-1810 # 800227d0 <log+0x30>
    80003eea:	060a                	slli	a2,a2,0x2
    80003eec:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003eee:	4ff4                	lw	a3,92(a5)
    80003ef0:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ef2:	0791                	addi	a5,a5,4
    80003ef4:	0711                	addi	a4,a4,4
    80003ef6:	fec79ce3          	bne	a5,a2,80003eee <initlog+0x54>
  brelse(buf);
    80003efa:	95eff0ef          	jal	80003058 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003efe:	4505                	li	a0,1
    80003f00:	ef3ff0ef          	jal	80003df2 <install_trans>
  log.lh.n = 0;
    80003f04:	0001f797          	auipc	a5,0x1f
    80003f08:	8c07a423          	sw	zero,-1848(a5) # 800227cc <log+0x2c>
  write_head(); // clear the log
    80003f0c:	e89ff0ef          	jal	80003d94 <write_head>
}
    80003f10:	70a2                	ld	ra,40(sp)
    80003f12:	7402                	ld	s0,32(sp)
    80003f14:	64e2                	ld	s1,24(sp)
    80003f16:	6942                	ld	s2,16(sp)
    80003f18:	69a2                	ld	s3,8(sp)
    80003f1a:	6145                	addi	sp,sp,48
    80003f1c:	8082                	ret

0000000080003f1e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003f1e:	1101                	addi	sp,sp,-32
    80003f20:	ec06                	sd	ra,24(sp)
    80003f22:	e822                	sd	s0,16(sp)
    80003f24:	e426                	sd	s1,8(sp)
    80003f26:	e04a                	sd	s2,0(sp)
    80003f28:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f2a:	0001f517          	auipc	a0,0x1f
    80003f2e:	87650513          	addi	a0,a0,-1930 # 800227a0 <log>
    80003f32:	cc3fc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003f36:	0001f497          	auipc	s1,0x1f
    80003f3a:	86a48493          	addi	s1,s1,-1942 # 800227a0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f3e:	4979                	li	s2,30
    80003f40:	a029                	j	80003f4a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003f42:	85a6                	mv	a1,s1
    80003f44:	8526                	mv	a0,s1
    80003f46:	fd7fd0ef          	jal	80001f1c <sleep>
    if(log.committing){
    80003f4a:	50dc                	lw	a5,36(s1)
    80003f4c:	fbfd                	bnez	a5,80003f42 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f4e:	5098                	lw	a4,32(s1)
    80003f50:	2705                	addiw	a4,a4,1
    80003f52:	0027179b          	slliw	a5,a4,0x2
    80003f56:	9fb9                	addw	a5,a5,a4
    80003f58:	0017979b          	slliw	a5,a5,0x1
    80003f5c:	54d4                	lw	a3,44(s1)
    80003f5e:	9fb5                	addw	a5,a5,a3
    80003f60:	00f95763          	bge	s2,a5,80003f6e <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003f64:	85a6                	mv	a1,s1
    80003f66:	8526                	mv	a0,s1
    80003f68:	fb5fd0ef          	jal	80001f1c <sleep>
    80003f6c:	bff9                	j	80003f4a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003f6e:	0001f517          	auipc	a0,0x1f
    80003f72:	83250513          	addi	a0,a0,-1998 # 800227a0 <log>
    80003f76:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003f78:	d15fc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003f7c:	60e2                	ld	ra,24(sp)
    80003f7e:	6442                	ld	s0,16(sp)
    80003f80:	64a2                	ld	s1,8(sp)
    80003f82:	6902                	ld	s2,0(sp)
    80003f84:	6105                	addi	sp,sp,32
    80003f86:	8082                	ret

0000000080003f88 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f88:	7139                	addi	sp,sp,-64
    80003f8a:	fc06                	sd	ra,56(sp)
    80003f8c:	f822                	sd	s0,48(sp)
    80003f8e:	f426                	sd	s1,40(sp)
    80003f90:	f04a                	sd	s2,32(sp)
    80003f92:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f94:	0001f497          	auipc	s1,0x1f
    80003f98:	80c48493          	addi	s1,s1,-2036 # 800227a0 <log>
    80003f9c:	8526                	mv	a0,s1
    80003f9e:	c57fc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003fa2:	509c                	lw	a5,32(s1)
    80003fa4:	37fd                	addiw	a5,a5,-1
    80003fa6:	0007891b          	sext.w	s2,a5
    80003faa:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003fac:	50dc                	lw	a5,36(s1)
    80003fae:	ef9d                	bnez	a5,80003fec <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003fb0:	04091763          	bnez	s2,80003ffe <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003fb4:	0001e497          	auipc	s1,0x1e
    80003fb8:	7ec48493          	addi	s1,s1,2028 # 800227a0 <log>
    80003fbc:	4785                	li	a5,1
    80003fbe:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003fc0:	8526                	mv	a0,s1
    80003fc2:	ccbfc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003fc6:	54dc                	lw	a5,44(s1)
    80003fc8:	04f04b63          	bgtz	a5,8000401e <end_op+0x96>
    acquire(&log.lock);
    80003fcc:	0001e497          	auipc	s1,0x1e
    80003fd0:	7d448493          	addi	s1,s1,2004 # 800227a0 <log>
    80003fd4:	8526                	mv	a0,s1
    80003fd6:	c1ffc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003fda:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003fde:	8526                	mv	a0,s1
    80003fe0:	f89fd0ef          	jal	80001f68 <wakeup>
    release(&log.lock);
    80003fe4:	8526                	mv	a0,s1
    80003fe6:	ca7fc0ef          	jal	80000c8c <release>
}
    80003fea:	a025                	j	80004012 <end_op+0x8a>
    80003fec:	ec4e                	sd	s3,24(sp)
    80003fee:	e852                	sd	s4,16(sp)
    80003ff0:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003ff2:	00003517          	auipc	a0,0x3
    80003ff6:	5de50513          	addi	a0,a0,1502 # 800075d0 <etext+0x5d0>
    80003ffa:	f9afc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003ffe:	0001e497          	auipc	s1,0x1e
    80004002:	7a248493          	addi	s1,s1,1954 # 800227a0 <log>
    80004006:	8526                	mv	a0,s1
    80004008:	f61fd0ef          	jal	80001f68 <wakeup>
  release(&log.lock);
    8000400c:	8526                	mv	a0,s1
    8000400e:	c7ffc0ef          	jal	80000c8c <release>
}
    80004012:	70e2                	ld	ra,56(sp)
    80004014:	7442                	ld	s0,48(sp)
    80004016:	74a2                	ld	s1,40(sp)
    80004018:	7902                	ld	s2,32(sp)
    8000401a:	6121                	addi	sp,sp,64
    8000401c:	8082                	ret
    8000401e:	ec4e                	sd	s3,24(sp)
    80004020:	e852                	sd	s4,16(sp)
    80004022:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004024:	0001ea97          	auipc	s5,0x1e
    80004028:	7aca8a93          	addi	s5,s5,1964 # 800227d0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000402c:	0001ea17          	auipc	s4,0x1e
    80004030:	774a0a13          	addi	s4,s4,1908 # 800227a0 <log>
    80004034:	018a2583          	lw	a1,24(s4)
    80004038:	012585bb          	addw	a1,a1,s2
    8000403c:	2585                	addiw	a1,a1,1
    8000403e:	028a2503          	lw	a0,40(s4)
    80004042:	f0ffe0ef          	jal	80002f50 <bread>
    80004046:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004048:	000aa583          	lw	a1,0(s5)
    8000404c:	028a2503          	lw	a0,40(s4)
    80004050:	f01fe0ef          	jal	80002f50 <bread>
    80004054:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004056:	40000613          	li	a2,1024
    8000405a:	05850593          	addi	a1,a0,88
    8000405e:	05848513          	addi	a0,s1,88
    80004062:	cc3fc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80004066:	8526                	mv	a0,s1
    80004068:	fbffe0ef          	jal	80003026 <bwrite>
    brelse(from);
    8000406c:	854e                	mv	a0,s3
    8000406e:	febfe0ef          	jal	80003058 <brelse>
    brelse(to);
    80004072:	8526                	mv	a0,s1
    80004074:	fe5fe0ef          	jal	80003058 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004078:	2905                	addiw	s2,s2,1
    8000407a:	0a91                	addi	s5,s5,4
    8000407c:	02ca2783          	lw	a5,44(s4)
    80004080:	faf94ae3          	blt	s2,a5,80004034 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004084:	d11ff0ef          	jal	80003d94 <write_head>
    install_trans(0); // Now install writes to home locations
    80004088:	4501                	li	a0,0
    8000408a:	d69ff0ef          	jal	80003df2 <install_trans>
    log.lh.n = 0;
    8000408e:	0001e797          	auipc	a5,0x1e
    80004092:	7207af23          	sw	zero,1854(a5) # 800227cc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004096:	cffff0ef          	jal	80003d94 <write_head>
    8000409a:	69e2                	ld	s3,24(sp)
    8000409c:	6a42                	ld	s4,16(sp)
    8000409e:	6aa2                	ld	s5,8(sp)
    800040a0:	b735                	j	80003fcc <end_op+0x44>

00000000800040a2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800040a2:	1101                	addi	sp,sp,-32
    800040a4:	ec06                	sd	ra,24(sp)
    800040a6:	e822                	sd	s0,16(sp)
    800040a8:	e426                	sd	s1,8(sp)
    800040aa:	e04a                	sd	s2,0(sp)
    800040ac:	1000                	addi	s0,sp,32
    800040ae:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800040b0:	0001e917          	auipc	s2,0x1e
    800040b4:	6f090913          	addi	s2,s2,1776 # 800227a0 <log>
    800040b8:	854a                	mv	a0,s2
    800040ba:	b3bfc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800040be:	02c92603          	lw	a2,44(s2)
    800040c2:	47f5                	li	a5,29
    800040c4:	06c7c363          	blt	a5,a2,8000412a <log_write+0x88>
    800040c8:	0001e797          	auipc	a5,0x1e
    800040cc:	6f47a783          	lw	a5,1780(a5) # 800227bc <log+0x1c>
    800040d0:	37fd                	addiw	a5,a5,-1
    800040d2:	04f65c63          	bge	a2,a5,8000412a <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800040d6:	0001e797          	auipc	a5,0x1e
    800040da:	6ea7a783          	lw	a5,1770(a5) # 800227c0 <log+0x20>
    800040de:	04f05c63          	blez	a5,80004136 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800040e2:	4781                	li	a5,0
    800040e4:	04c05f63          	blez	a2,80004142 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800040e8:	44cc                	lw	a1,12(s1)
    800040ea:	0001e717          	auipc	a4,0x1e
    800040ee:	6e670713          	addi	a4,a4,1766 # 800227d0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800040f2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800040f4:	4314                	lw	a3,0(a4)
    800040f6:	04b68663          	beq	a3,a1,80004142 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    800040fa:	2785                	addiw	a5,a5,1
    800040fc:	0711                	addi	a4,a4,4
    800040fe:	fef61be3          	bne	a2,a5,800040f4 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004102:	0621                	addi	a2,a2,8
    80004104:	060a                	slli	a2,a2,0x2
    80004106:	0001e797          	auipc	a5,0x1e
    8000410a:	69a78793          	addi	a5,a5,1690 # 800227a0 <log>
    8000410e:	97b2                	add	a5,a5,a2
    80004110:	44d8                	lw	a4,12(s1)
    80004112:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004114:	8526                	mv	a0,s1
    80004116:	fcbfe0ef          	jal	800030e0 <bpin>
    log.lh.n++;
    8000411a:	0001e717          	auipc	a4,0x1e
    8000411e:	68670713          	addi	a4,a4,1670 # 800227a0 <log>
    80004122:	575c                	lw	a5,44(a4)
    80004124:	2785                	addiw	a5,a5,1
    80004126:	d75c                	sw	a5,44(a4)
    80004128:	a80d                	j	8000415a <log_write+0xb8>
    panic("too big a transaction");
    8000412a:	00003517          	auipc	a0,0x3
    8000412e:	4b650513          	addi	a0,a0,1206 # 800075e0 <etext+0x5e0>
    80004132:	e62fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80004136:	00003517          	auipc	a0,0x3
    8000413a:	4c250513          	addi	a0,a0,1218 # 800075f8 <etext+0x5f8>
    8000413e:	e56fc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80004142:	00878693          	addi	a3,a5,8
    80004146:	068a                	slli	a3,a3,0x2
    80004148:	0001e717          	auipc	a4,0x1e
    8000414c:	65870713          	addi	a4,a4,1624 # 800227a0 <log>
    80004150:	9736                	add	a4,a4,a3
    80004152:	44d4                	lw	a3,12(s1)
    80004154:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004156:	faf60fe3          	beq	a2,a5,80004114 <log_write+0x72>
  }
  release(&log.lock);
    8000415a:	0001e517          	auipc	a0,0x1e
    8000415e:	64650513          	addi	a0,a0,1606 # 800227a0 <log>
    80004162:	b2bfc0ef          	jal	80000c8c <release>
}
    80004166:	60e2                	ld	ra,24(sp)
    80004168:	6442                	ld	s0,16(sp)
    8000416a:	64a2                	ld	s1,8(sp)
    8000416c:	6902                	ld	s2,0(sp)
    8000416e:	6105                	addi	sp,sp,32
    80004170:	8082                	ret

0000000080004172 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004172:	1101                	addi	sp,sp,-32
    80004174:	ec06                	sd	ra,24(sp)
    80004176:	e822                	sd	s0,16(sp)
    80004178:	e426                	sd	s1,8(sp)
    8000417a:	e04a                	sd	s2,0(sp)
    8000417c:	1000                	addi	s0,sp,32
    8000417e:	84aa                	mv	s1,a0
    80004180:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004182:	00003597          	auipc	a1,0x3
    80004186:	49658593          	addi	a1,a1,1174 # 80007618 <etext+0x618>
    8000418a:	0521                	addi	a0,a0,8
    8000418c:	9e9fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80004190:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004194:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004198:	0204a423          	sw	zero,40(s1)
}
    8000419c:	60e2                	ld	ra,24(sp)
    8000419e:	6442                	ld	s0,16(sp)
    800041a0:	64a2                	ld	s1,8(sp)
    800041a2:	6902                	ld	s2,0(sp)
    800041a4:	6105                	addi	sp,sp,32
    800041a6:	8082                	ret

00000000800041a8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800041a8:	1101                	addi	sp,sp,-32
    800041aa:	ec06                	sd	ra,24(sp)
    800041ac:	e822                	sd	s0,16(sp)
    800041ae:	e426                	sd	s1,8(sp)
    800041b0:	e04a                	sd	s2,0(sp)
    800041b2:	1000                	addi	s0,sp,32
    800041b4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041b6:	00850913          	addi	s2,a0,8
    800041ba:	854a                	mv	a0,s2
    800041bc:	a39fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    800041c0:	409c                	lw	a5,0(s1)
    800041c2:	c799                	beqz	a5,800041d0 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800041c4:	85ca                	mv	a1,s2
    800041c6:	8526                	mv	a0,s1
    800041c8:	d55fd0ef          	jal	80001f1c <sleep>
  while (lk->locked) {
    800041cc:	409c                	lw	a5,0(s1)
    800041ce:	fbfd                	bnez	a5,800041c4 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800041d0:	4785                	li	a5,1
    800041d2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800041d4:	f0cfd0ef          	jal	800018e0 <myproc>
    800041d8:	591c                	lw	a5,48(a0)
    800041da:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800041dc:	854a                	mv	a0,s2
    800041de:	aaffc0ef          	jal	80000c8c <release>
}
    800041e2:	60e2                	ld	ra,24(sp)
    800041e4:	6442                	ld	s0,16(sp)
    800041e6:	64a2                	ld	s1,8(sp)
    800041e8:	6902                	ld	s2,0(sp)
    800041ea:	6105                	addi	sp,sp,32
    800041ec:	8082                	ret

00000000800041ee <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800041ee:	1101                	addi	sp,sp,-32
    800041f0:	ec06                	sd	ra,24(sp)
    800041f2:	e822                	sd	s0,16(sp)
    800041f4:	e426                	sd	s1,8(sp)
    800041f6:	e04a                	sd	s2,0(sp)
    800041f8:	1000                	addi	s0,sp,32
    800041fa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041fc:	00850913          	addi	s2,a0,8
    80004200:	854a                	mv	a0,s2
    80004202:	9f3fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80004206:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000420a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000420e:	8526                	mv	a0,s1
    80004210:	d59fd0ef          	jal	80001f68 <wakeup>
  release(&lk->lk);
    80004214:	854a                	mv	a0,s2
    80004216:	a77fc0ef          	jal	80000c8c <release>
}
    8000421a:	60e2                	ld	ra,24(sp)
    8000421c:	6442                	ld	s0,16(sp)
    8000421e:	64a2                	ld	s1,8(sp)
    80004220:	6902                	ld	s2,0(sp)
    80004222:	6105                	addi	sp,sp,32
    80004224:	8082                	ret

0000000080004226 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004226:	7179                	addi	sp,sp,-48
    80004228:	f406                	sd	ra,40(sp)
    8000422a:	f022                	sd	s0,32(sp)
    8000422c:	ec26                	sd	s1,24(sp)
    8000422e:	e84a                	sd	s2,16(sp)
    80004230:	1800                	addi	s0,sp,48
    80004232:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004234:	00850913          	addi	s2,a0,8
    80004238:	854a                	mv	a0,s2
    8000423a:	9bbfc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000423e:	409c                	lw	a5,0(s1)
    80004240:	ef81                	bnez	a5,80004258 <holdingsleep+0x32>
    80004242:	4481                	li	s1,0
  release(&lk->lk);
    80004244:	854a                	mv	a0,s2
    80004246:	a47fc0ef          	jal	80000c8c <release>
  return r;
}
    8000424a:	8526                	mv	a0,s1
    8000424c:	70a2                	ld	ra,40(sp)
    8000424e:	7402                	ld	s0,32(sp)
    80004250:	64e2                	ld	s1,24(sp)
    80004252:	6942                	ld	s2,16(sp)
    80004254:	6145                	addi	sp,sp,48
    80004256:	8082                	ret
    80004258:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000425a:	0284a983          	lw	s3,40(s1)
    8000425e:	e82fd0ef          	jal	800018e0 <myproc>
    80004262:	5904                	lw	s1,48(a0)
    80004264:	413484b3          	sub	s1,s1,s3
    80004268:	0014b493          	seqz	s1,s1
    8000426c:	69a2                	ld	s3,8(sp)
    8000426e:	bfd9                	j	80004244 <holdingsleep+0x1e>

0000000080004270 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004270:	1141                	addi	sp,sp,-16
    80004272:	e406                	sd	ra,8(sp)
    80004274:	e022                	sd	s0,0(sp)
    80004276:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004278:	00003597          	auipc	a1,0x3
    8000427c:	3b058593          	addi	a1,a1,944 # 80007628 <etext+0x628>
    80004280:	0001e517          	auipc	a0,0x1e
    80004284:	66850513          	addi	a0,a0,1640 # 800228e8 <ftable>
    80004288:	8edfc0ef          	jal	80000b74 <initlock>
}
    8000428c:	60a2                	ld	ra,8(sp)
    8000428e:	6402                	ld	s0,0(sp)
    80004290:	0141                	addi	sp,sp,16
    80004292:	8082                	ret

0000000080004294 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004294:	1101                	addi	sp,sp,-32
    80004296:	ec06                	sd	ra,24(sp)
    80004298:	e822                	sd	s0,16(sp)
    8000429a:	e426                	sd	s1,8(sp)
    8000429c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000429e:	0001e517          	auipc	a0,0x1e
    800042a2:	64a50513          	addi	a0,a0,1610 # 800228e8 <ftable>
    800042a6:	94ffc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800042aa:	0001e497          	auipc	s1,0x1e
    800042ae:	65648493          	addi	s1,s1,1622 # 80022900 <ftable+0x18>
    800042b2:	0001f717          	auipc	a4,0x1f
    800042b6:	5ee70713          	addi	a4,a4,1518 # 800238a0 <disk>
    if(f->ref == 0){
    800042ba:	40dc                	lw	a5,4(s1)
    800042bc:	cf89                	beqz	a5,800042d6 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800042be:	02848493          	addi	s1,s1,40
    800042c2:	fee49ce3          	bne	s1,a4,800042ba <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042c6:	0001e517          	auipc	a0,0x1e
    800042ca:	62250513          	addi	a0,a0,1570 # 800228e8 <ftable>
    800042ce:	9bffc0ef          	jal	80000c8c <release>
  return 0;
    800042d2:	4481                	li	s1,0
    800042d4:	a809                	j	800042e6 <filealloc+0x52>
      f->ref = 1;
    800042d6:	4785                	li	a5,1
    800042d8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800042da:	0001e517          	auipc	a0,0x1e
    800042de:	60e50513          	addi	a0,a0,1550 # 800228e8 <ftable>
    800042e2:	9abfc0ef          	jal	80000c8c <release>
}
    800042e6:	8526                	mv	a0,s1
    800042e8:	60e2                	ld	ra,24(sp)
    800042ea:	6442                	ld	s0,16(sp)
    800042ec:	64a2                	ld	s1,8(sp)
    800042ee:	6105                	addi	sp,sp,32
    800042f0:	8082                	ret

00000000800042f2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800042f2:	1101                	addi	sp,sp,-32
    800042f4:	ec06                	sd	ra,24(sp)
    800042f6:	e822                	sd	s0,16(sp)
    800042f8:	e426                	sd	s1,8(sp)
    800042fa:	1000                	addi	s0,sp,32
    800042fc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800042fe:	0001e517          	auipc	a0,0x1e
    80004302:	5ea50513          	addi	a0,a0,1514 # 800228e8 <ftable>
    80004306:	8effc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    8000430a:	40dc                	lw	a5,4(s1)
    8000430c:	02f05063          	blez	a5,8000432c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004310:	2785                	addiw	a5,a5,1
    80004312:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004314:	0001e517          	auipc	a0,0x1e
    80004318:	5d450513          	addi	a0,a0,1492 # 800228e8 <ftable>
    8000431c:	971fc0ef          	jal	80000c8c <release>
  return f;
}
    80004320:	8526                	mv	a0,s1
    80004322:	60e2                	ld	ra,24(sp)
    80004324:	6442                	ld	s0,16(sp)
    80004326:	64a2                	ld	s1,8(sp)
    80004328:	6105                	addi	sp,sp,32
    8000432a:	8082                	ret
    panic("filedup");
    8000432c:	00003517          	auipc	a0,0x3
    80004330:	30450513          	addi	a0,a0,772 # 80007630 <etext+0x630>
    80004334:	c60fc0ef          	jal	80000794 <panic>

0000000080004338 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004338:	7139                	addi	sp,sp,-64
    8000433a:	fc06                	sd	ra,56(sp)
    8000433c:	f822                	sd	s0,48(sp)
    8000433e:	f426                	sd	s1,40(sp)
    80004340:	0080                	addi	s0,sp,64
    80004342:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004344:	0001e517          	auipc	a0,0x1e
    80004348:	5a450513          	addi	a0,a0,1444 # 800228e8 <ftable>
    8000434c:	8a9fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004350:	40dc                	lw	a5,4(s1)
    80004352:	04f05a63          	blez	a5,800043a6 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004356:	37fd                	addiw	a5,a5,-1
    80004358:	0007871b          	sext.w	a4,a5
    8000435c:	c0dc                	sw	a5,4(s1)
    8000435e:	04e04e63          	bgtz	a4,800043ba <fileclose+0x82>
    80004362:	f04a                	sd	s2,32(sp)
    80004364:	ec4e                	sd	s3,24(sp)
    80004366:	e852                	sd	s4,16(sp)
    80004368:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000436a:	0004a903          	lw	s2,0(s1)
    8000436e:	0094ca83          	lbu	s5,9(s1)
    80004372:	0104ba03          	ld	s4,16(s1)
    80004376:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000437a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000437e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004382:	0001e517          	auipc	a0,0x1e
    80004386:	56650513          	addi	a0,a0,1382 # 800228e8 <ftable>
    8000438a:	903fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    8000438e:	4785                	li	a5,1
    80004390:	04f90063          	beq	s2,a5,800043d0 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004394:	3979                	addiw	s2,s2,-2
    80004396:	4785                	li	a5,1
    80004398:	0527f563          	bgeu	a5,s2,800043e2 <fileclose+0xaa>
    8000439c:	7902                	ld	s2,32(sp)
    8000439e:	69e2                	ld	s3,24(sp)
    800043a0:	6a42                	ld	s4,16(sp)
    800043a2:	6aa2                	ld	s5,8(sp)
    800043a4:	a00d                	j	800043c6 <fileclose+0x8e>
    800043a6:	f04a                	sd	s2,32(sp)
    800043a8:	ec4e                	sd	s3,24(sp)
    800043aa:	e852                	sd	s4,16(sp)
    800043ac:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800043ae:	00003517          	auipc	a0,0x3
    800043b2:	28a50513          	addi	a0,a0,650 # 80007638 <etext+0x638>
    800043b6:	bdefc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    800043ba:	0001e517          	auipc	a0,0x1e
    800043be:	52e50513          	addi	a0,a0,1326 # 800228e8 <ftable>
    800043c2:	8cbfc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043c6:	70e2                	ld	ra,56(sp)
    800043c8:	7442                	ld	s0,48(sp)
    800043ca:	74a2                	ld	s1,40(sp)
    800043cc:	6121                	addi	sp,sp,64
    800043ce:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800043d0:	85d6                	mv	a1,s5
    800043d2:	8552                	mv	a0,s4
    800043d4:	336000ef          	jal	8000470a <pipeclose>
    800043d8:	7902                	ld	s2,32(sp)
    800043da:	69e2                	ld	s3,24(sp)
    800043dc:	6a42                	ld	s4,16(sp)
    800043de:	6aa2                	ld	s5,8(sp)
    800043e0:	b7dd                	j	800043c6 <fileclose+0x8e>
    begin_op();
    800043e2:	b3dff0ef          	jal	80003f1e <begin_op>
    iput(ff.ip);
    800043e6:	854e                	mv	a0,s3
    800043e8:	c22ff0ef          	jal	8000380a <iput>
    end_op();
    800043ec:	b9dff0ef          	jal	80003f88 <end_op>
    800043f0:	7902                	ld	s2,32(sp)
    800043f2:	69e2                	ld	s3,24(sp)
    800043f4:	6a42                	ld	s4,16(sp)
    800043f6:	6aa2                	ld	s5,8(sp)
    800043f8:	b7f9                	j	800043c6 <fileclose+0x8e>

00000000800043fa <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800043fa:	715d                	addi	sp,sp,-80
    800043fc:	e486                	sd	ra,72(sp)
    800043fe:	e0a2                	sd	s0,64(sp)
    80004400:	fc26                	sd	s1,56(sp)
    80004402:	f44e                	sd	s3,40(sp)
    80004404:	0880                	addi	s0,sp,80
    80004406:	84aa                	mv	s1,a0
    80004408:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000440a:	cd6fd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000440e:	409c                	lw	a5,0(s1)
    80004410:	37f9                	addiw	a5,a5,-2
    80004412:	4705                	li	a4,1
    80004414:	04f76063          	bltu	a4,a5,80004454 <filestat+0x5a>
    80004418:	f84a                	sd	s2,48(sp)
    8000441a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000441c:	6c88                	ld	a0,24(s1)
    8000441e:	a6aff0ef          	jal	80003688 <ilock>
    stati(f->ip, &st);
    80004422:	fb840593          	addi	a1,s0,-72
    80004426:	6c88                	ld	a0,24(s1)
    80004428:	c8aff0ef          	jal	800038b2 <stati>
    iunlock(f->ip);
    8000442c:	6c88                	ld	a0,24(s1)
    8000442e:	b08ff0ef          	jal	80003736 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004432:	46e1                	li	a3,24
    80004434:	fb840613          	addi	a2,s0,-72
    80004438:	85ce                	mv	a1,s3
    8000443a:	05093503          	ld	a0,80(s2)
    8000443e:	914fd0ef          	jal	80001552 <copyout>
    80004442:	41f5551b          	sraiw	a0,a0,0x1f
    80004446:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004448:	60a6                	ld	ra,72(sp)
    8000444a:	6406                	ld	s0,64(sp)
    8000444c:	74e2                	ld	s1,56(sp)
    8000444e:	79a2                	ld	s3,40(sp)
    80004450:	6161                	addi	sp,sp,80
    80004452:	8082                	ret
  return -1;
    80004454:	557d                	li	a0,-1
    80004456:	bfcd                	j	80004448 <filestat+0x4e>

0000000080004458 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004458:	7179                	addi	sp,sp,-48
    8000445a:	f406                	sd	ra,40(sp)
    8000445c:	f022                	sd	s0,32(sp)
    8000445e:	e84a                	sd	s2,16(sp)
    80004460:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004462:	00854783          	lbu	a5,8(a0)
    80004466:	cfd1                	beqz	a5,80004502 <fileread+0xaa>
    80004468:	ec26                	sd	s1,24(sp)
    8000446a:	e44e                	sd	s3,8(sp)
    8000446c:	84aa                	mv	s1,a0
    8000446e:	89ae                	mv	s3,a1
    80004470:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004472:	411c                	lw	a5,0(a0)
    80004474:	4705                	li	a4,1
    80004476:	04e78363          	beq	a5,a4,800044bc <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000447a:	470d                	li	a4,3
    8000447c:	04e78763          	beq	a5,a4,800044ca <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004480:	4709                	li	a4,2
    80004482:	06e79a63          	bne	a5,a4,800044f6 <fileread+0x9e>
    ilock(f->ip);
    80004486:	6d08                	ld	a0,24(a0)
    80004488:	a00ff0ef          	jal	80003688 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000448c:	874a                	mv	a4,s2
    8000448e:	5094                	lw	a3,32(s1)
    80004490:	864e                	mv	a2,s3
    80004492:	4585                	li	a1,1
    80004494:	6c88                	ld	a0,24(s1)
    80004496:	c46ff0ef          	jal	800038dc <readi>
    8000449a:	892a                	mv	s2,a0
    8000449c:	00a05563          	blez	a0,800044a6 <fileread+0x4e>
      f->off += r;
    800044a0:	509c                	lw	a5,32(s1)
    800044a2:	9fa9                	addw	a5,a5,a0
    800044a4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800044a6:	6c88                	ld	a0,24(s1)
    800044a8:	a8eff0ef          	jal	80003736 <iunlock>
    800044ac:	64e2                	ld	s1,24(sp)
    800044ae:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800044b0:	854a                	mv	a0,s2
    800044b2:	70a2                	ld	ra,40(sp)
    800044b4:	7402                	ld	s0,32(sp)
    800044b6:	6942                	ld	s2,16(sp)
    800044b8:	6145                	addi	sp,sp,48
    800044ba:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800044bc:	6908                	ld	a0,16(a0)
    800044be:	388000ef          	jal	80004846 <piperead>
    800044c2:	892a                	mv	s2,a0
    800044c4:	64e2                	ld	s1,24(sp)
    800044c6:	69a2                	ld	s3,8(sp)
    800044c8:	b7e5                	j	800044b0 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800044ca:	02451783          	lh	a5,36(a0)
    800044ce:	03079693          	slli	a3,a5,0x30
    800044d2:	92c1                	srli	a3,a3,0x30
    800044d4:	4725                	li	a4,9
    800044d6:	02d76863          	bltu	a4,a3,80004506 <fileread+0xae>
    800044da:	0792                	slli	a5,a5,0x4
    800044dc:	0001e717          	auipc	a4,0x1e
    800044e0:	36c70713          	addi	a4,a4,876 # 80022848 <devsw>
    800044e4:	97ba                	add	a5,a5,a4
    800044e6:	639c                	ld	a5,0(a5)
    800044e8:	c39d                	beqz	a5,8000450e <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800044ea:	4505                	li	a0,1
    800044ec:	9782                	jalr	a5
    800044ee:	892a                	mv	s2,a0
    800044f0:	64e2                	ld	s1,24(sp)
    800044f2:	69a2                	ld	s3,8(sp)
    800044f4:	bf75                	j	800044b0 <fileread+0x58>
    panic("fileread");
    800044f6:	00003517          	auipc	a0,0x3
    800044fa:	15250513          	addi	a0,a0,338 # 80007648 <etext+0x648>
    800044fe:	a96fc0ef          	jal	80000794 <panic>
    return -1;
    80004502:	597d                	li	s2,-1
    80004504:	b775                	j	800044b0 <fileread+0x58>
      return -1;
    80004506:	597d                	li	s2,-1
    80004508:	64e2                	ld	s1,24(sp)
    8000450a:	69a2                	ld	s3,8(sp)
    8000450c:	b755                	j	800044b0 <fileread+0x58>
    8000450e:	597d                	li	s2,-1
    80004510:	64e2                	ld	s1,24(sp)
    80004512:	69a2                	ld	s3,8(sp)
    80004514:	bf71                	j	800044b0 <fileread+0x58>

0000000080004516 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004516:	00954783          	lbu	a5,9(a0)
    8000451a:	10078b63          	beqz	a5,80004630 <filewrite+0x11a>
{
    8000451e:	715d                	addi	sp,sp,-80
    80004520:	e486                	sd	ra,72(sp)
    80004522:	e0a2                	sd	s0,64(sp)
    80004524:	f84a                	sd	s2,48(sp)
    80004526:	f052                	sd	s4,32(sp)
    80004528:	e85a                	sd	s6,16(sp)
    8000452a:	0880                	addi	s0,sp,80
    8000452c:	892a                	mv	s2,a0
    8000452e:	8b2e                	mv	s6,a1
    80004530:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004532:	411c                	lw	a5,0(a0)
    80004534:	4705                	li	a4,1
    80004536:	02e78763          	beq	a5,a4,80004564 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000453a:	470d                	li	a4,3
    8000453c:	02e78863          	beq	a5,a4,8000456c <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004540:	4709                	li	a4,2
    80004542:	0ce79c63          	bne	a5,a4,8000461a <filewrite+0x104>
    80004546:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004548:	0ac05863          	blez	a2,800045f8 <filewrite+0xe2>
    8000454c:	fc26                	sd	s1,56(sp)
    8000454e:	ec56                	sd	s5,24(sp)
    80004550:	e45e                	sd	s7,8(sp)
    80004552:	e062                	sd	s8,0(sp)
    int i = 0;
    80004554:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004556:	6b85                	lui	s7,0x1
    80004558:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000455c:	6c05                	lui	s8,0x1
    8000455e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004562:	a8b5                	j	800045de <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004564:	6908                	ld	a0,16(a0)
    80004566:	1fc000ef          	jal	80004762 <pipewrite>
    8000456a:	a04d                	j	8000460c <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000456c:	02451783          	lh	a5,36(a0)
    80004570:	03079693          	slli	a3,a5,0x30
    80004574:	92c1                	srli	a3,a3,0x30
    80004576:	4725                	li	a4,9
    80004578:	0ad76e63          	bltu	a4,a3,80004634 <filewrite+0x11e>
    8000457c:	0792                	slli	a5,a5,0x4
    8000457e:	0001e717          	auipc	a4,0x1e
    80004582:	2ca70713          	addi	a4,a4,714 # 80022848 <devsw>
    80004586:	97ba                	add	a5,a5,a4
    80004588:	679c                	ld	a5,8(a5)
    8000458a:	c7dd                	beqz	a5,80004638 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000458c:	4505                	li	a0,1
    8000458e:	9782                	jalr	a5
    80004590:	a8b5                	j	8000460c <filewrite+0xf6>
      if(n1 > max)
    80004592:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004596:	989ff0ef          	jal	80003f1e <begin_op>
      ilock(f->ip);
    8000459a:	01893503          	ld	a0,24(s2)
    8000459e:	8eaff0ef          	jal	80003688 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045a2:	8756                	mv	a4,s5
    800045a4:	02092683          	lw	a3,32(s2)
    800045a8:	01698633          	add	a2,s3,s6
    800045ac:	4585                	li	a1,1
    800045ae:	01893503          	ld	a0,24(s2)
    800045b2:	c26ff0ef          	jal	800039d8 <writei>
    800045b6:	84aa                	mv	s1,a0
    800045b8:	00a05763          	blez	a0,800045c6 <filewrite+0xb0>
        f->off += r;
    800045bc:	02092783          	lw	a5,32(s2)
    800045c0:	9fa9                	addw	a5,a5,a0
    800045c2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800045c6:	01893503          	ld	a0,24(s2)
    800045ca:	96cff0ef          	jal	80003736 <iunlock>
      end_op();
    800045ce:	9bbff0ef          	jal	80003f88 <end_op>

      if(r != n1){
    800045d2:	029a9563          	bne	s5,s1,800045fc <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800045d6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800045da:	0149da63          	bge	s3,s4,800045ee <filewrite+0xd8>
      int n1 = n - i;
    800045de:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800045e2:	0004879b          	sext.w	a5,s1
    800045e6:	fafbd6e3          	bge	s7,a5,80004592 <filewrite+0x7c>
    800045ea:	84e2                	mv	s1,s8
    800045ec:	b75d                	j	80004592 <filewrite+0x7c>
    800045ee:	74e2                	ld	s1,56(sp)
    800045f0:	6ae2                	ld	s5,24(sp)
    800045f2:	6ba2                	ld	s7,8(sp)
    800045f4:	6c02                	ld	s8,0(sp)
    800045f6:	a039                	j	80004604 <filewrite+0xee>
    int i = 0;
    800045f8:	4981                	li	s3,0
    800045fa:	a029                	j	80004604 <filewrite+0xee>
    800045fc:	74e2                	ld	s1,56(sp)
    800045fe:	6ae2                	ld	s5,24(sp)
    80004600:	6ba2                	ld	s7,8(sp)
    80004602:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004604:	033a1c63          	bne	s4,s3,8000463c <filewrite+0x126>
    80004608:	8552                	mv	a0,s4
    8000460a:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000460c:	60a6                	ld	ra,72(sp)
    8000460e:	6406                	ld	s0,64(sp)
    80004610:	7942                	ld	s2,48(sp)
    80004612:	7a02                	ld	s4,32(sp)
    80004614:	6b42                	ld	s6,16(sp)
    80004616:	6161                	addi	sp,sp,80
    80004618:	8082                	ret
    8000461a:	fc26                	sd	s1,56(sp)
    8000461c:	f44e                	sd	s3,40(sp)
    8000461e:	ec56                	sd	s5,24(sp)
    80004620:	e45e                	sd	s7,8(sp)
    80004622:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004624:	00003517          	auipc	a0,0x3
    80004628:	03450513          	addi	a0,a0,52 # 80007658 <etext+0x658>
    8000462c:	968fc0ef          	jal	80000794 <panic>
    return -1;
    80004630:	557d                	li	a0,-1
}
    80004632:	8082                	ret
      return -1;
    80004634:	557d                	li	a0,-1
    80004636:	bfd9                	j	8000460c <filewrite+0xf6>
    80004638:	557d                	li	a0,-1
    8000463a:	bfc9                	j	8000460c <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000463c:	557d                	li	a0,-1
    8000463e:	79a2                	ld	s3,40(sp)
    80004640:	b7f1                	j	8000460c <filewrite+0xf6>

0000000080004642 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004642:	7179                	addi	sp,sp,-48
    80004644:	f406                	sd	ra,40(sp)
    80004646:	f022                	sd	s0,32(sp)
    80004648:	ec26                	sd	s1,24(sp)
    8000464a:	e052                	sd	s4,0(sp)
    8000464c:	1800                	addi	s0,sp,48
    8000464e:	84aa                	mv	s1,a0
    80004650:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004652:	0005b023          	sd	zero,0(a1)
    80004656:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000465a:	c3bff0ef          	jal	80004294 <filealloc>
    8000465e:	e088                	sd	a0,0(s1)
    80004660:	c549                	beqz	a0,800046ea <pipealloc+0xa8>
    80004662:	c33ff0ef          	jal	80004294 <filealloc>
    80004666:	00aa3023          	sd	a0,0(s4)
    8000466a:	cd25                	beqz	a0,800046e2 <pipealloc+0xa0>
    8000466c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000466e:	cb6fc0ef          	jal	80000b24 <kalloc>
    80004672:	892a                	mv	s2,a0
    80004674:	c12d                	beqz	a0,800046d6 <pipealloc+0x94>
    80004676:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004678:	4985                	li	s3,1
    8000467a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000467e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004682:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004686:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000468a:	00003597          	auipc	a1,0x3
    8000468e:	fde58593          	addi	a1,a1,-34 # 80007668 <etext+0x668>
    80004692:	ce2fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    80004696:	609c                	ld	a5,0(s1)
    80004698:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000469c:	609c                	ld	a5,0(s1)
    8000469e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800046a2:	609c                	ld	a5,0(s1)
    800046a4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800046a8:	609c                	ld	a5,0(s1)
    800046aa:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800046ae:	000a3783          	ld	a5,0(s4)
    800046b2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800046b6:	000a3783          	ld	a5,0(s4)
    800046ba:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800046be:	000a3783          	ld	a5,0(s4)
    800046c2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800046c6:	000a3783          	ld	a5,0(s4)
    800046ca:	0127b823          	sd	s2,16(a5)
  return 0;
    800046ce:	4501                	li	a0,0
    800046d0:	6942                	ld	s2,16(sp)
    800046d2:	69a2                	ld	s3,8(sp)
    800046d4:	a01d                	j	800046fa <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800046d6:	6088                	ld	a0,0(s1)
    800046d8:	c119                	beqz	a0,800046de <pipealloc+0x9c>
    800046da:	6942                	ld	s2,16(sp)
    800046dc:	a029                	j	800046e6 <pipealloc+0xa4>
    800046de:	6942                	ld	s2,16(sp)
    800046e0:	a029                	j	800046ea <pipealloc+0xa8>
    800046e2:	6088                	ld	a0,0(s1)
    800046e4:	c10d                	beqz	a0,80004706 <pipealloc+0xc4>
    fileclose(*f0);
    800046e6:	c53ff0ef          	jal	80004338 <fileclose>
  if(*f1)
    800046ea:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800046ee:	557d                	li	a0,-1
  if(*f1)
    800046f0:	c789                	beqz	a5,800046fa <pipealloc+0xb8>
    fileclose(*f1);
    800046f2:	853e                	mv	a0,a5
    800046f4:	c45ff0ef          	jal	80004338 <fileclose>
  return -1;
    800046f8:	557d                	li	a0,-1
}
    800046fa:	70a2                	ld	ra,40(sp)
    800046fc:	7402                	ld	s0,32(sp)
    800046fe:	64e2                	ld	s1,24(sp)
    80004700:	6a02                	ld	s4,0(sp)
    80004702:	6145                	addi	sp,sp,48
    80004704:	8082                	ret
  return -1;
    80004706:	557d                	li	a0,-1
    80004708:	bfcd                	j	800046fa <pipealloc+0xb8>

000000008000470a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000470a:	1101                	addi	sp,sp,-32
    8000470c:	ec06                	sd	ra,24(sp)
    8000470e:	e822                	sd	s0,16(sp)
    80004710:	e426                	sd	s1,8(sp)
    80004712:	e04a                	sd	s2,0(sp)
    80004714:	1000                	addi	s0,sp,32
    80004716:	84aa                	mv	s1,a0
    80004718:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000471a:	cdafc0ef          	jal	80000bf4 <acquire>
  if(writable){
    8000471e:	02090763          	beqz	s2,8000474c <pipeclose+0x42>
    pi->writeopen = 0;
    80004722:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004726:	21848513          	addi	a0,s1,536
    8000472a:	83ffd0ef          	jal	80001f68 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000472e:	2204b783          	ld	a5,544(s1)
    80004732:	e785                	bnez	a5,8000475a <pipeclose+0x50>
    release(&pi->lock);
    80004734:	8526                	mv	a0,s1
    80004736:	d56fc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    8000473a:	8526                	mv	a0,s1
    8000473c:	b06fc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004740:	60e2                	ld	ra,24(sp)
    80004742:	6442                	ld	s0,16(sp)
    80004744:	64a2                	ld	s1,8(sp)
    80004746:	6902                	ld	s2,0(sp)
    80004748:	6105                	addi	sp,sp,32
    8000474a:	8082                	ret
    pi->readopen = 0;
    8000474c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004750:	21c48513          	addi	a0,s1,540
    80004754:	815fd0ef          	jal	80001f68 <wakeup>
    80004758:	bfd9                	j	8000472e <pipeclose+0x24>
    release(&pi->lock);
    8000475a:	8526                	mv	a0,s1
    8000475c:	d30fc0ef          	jal	80000c8c <release>
}
    80004760:	b7c5                	j	80004740 <pipeclose+0x36>

0000000080004762 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004762:	711d                	addi	sp,sp,-96
    80004764:	ec86                	sd	ra,88(sp)
    80004766:	e8a2                	sd	s0,80(sp)
    80004768:	e4a6                	sd	s1,72(sp)
    8000476a:	e0ca                	sd	s2,64(sp)
    8000476c:	fc4e                	sd	s3,56(sp)
    8000476e:	f852                	sd	s4,48(sp)
    80004770:	f456                	sd	s5,40(sp)
    80004772:	1080                	addi	s0,sp,96
    80004774:	84aa                	mv	s1,a0
    80004776:	8aae                	mv	s5,a1
    80004778:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000477a:	966fd0ef          	jal	800018e0 <myproc>
    8000477e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004780:	8526                	mv	a0,s1
    80004782:	c72fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    80004786:	0b405a63          	blez	s4,8000483a <pipewrite+0xd8>
    8000478a:	f05a                	sd	s6,32(sp)
    8000478c:	ec5e                	sd	s7,24(sp)
    8000478e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004790:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004792:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004794:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004798:	21c48b93          	addi	s7,s1,540
    8000479c:	a81d                	j	800047d2 <pipewrite+0x70>
      release(&pi->lock);
    8000479e:	8526                	mv	a0,s1
    800047a0:	cecfc0ef          	jal	80000c8c <release>
      return -1;
    800047a4:	597d                	li	s2,-1
    800047a6:	7b02                	ld	s6,32(sp)
    800047a8:	6be2                	ld	s7,24(sp)
    800047aa:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800047ac:	854a                	mv	a0,s2
    800047ae:	60e6                	ld	ra,88(sp)
    800047b0:	6446                	ld	s0,80(sp)
    800047b2:	64a6                	ld	s1,72(sp)
    800047b4:	6906                	ld	s2,64(sp)
    800047b6:	79e2                	ld	s3,56(sp)
    800047b8:	7a42                	ld	s4,48(sp)
    800047ba:	7aa2                	ld	s5,40(sp)
    800047bc:	6125                	addi	sp,sp,96
    800047be:	8082                	ret
      wakeup(&pi->nread);
    800047c0:	8562                	mv	a0,s8
    800047c2:	fa6fd0ef          	jal	80001f68 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800047c6:	85a6                	mv	a1,s1
    800047c8:	855e                	mv	a0,s7
    800047ca:	f52fd0ef          	jal	80001f1c <sleep>
  while(i < n){
    800047ce:	05495b63          	bge	s2,s4,80004824 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800047d2:	2204a783          	lw	a5,544(s1)
    800047d6:	d7e1                	beqz	a5,8000479e <pipewrite+0x3c>
    800047d8:	854e                	mv	a0,s3
    800047da:	97bfd0ef          	jal	80002154 <killed>
    800047de:	f161                	bnez	a0,8000479e <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800047e0:	2184a783          	lw	a5,536(s1)
    800047e4:	21c4a703          	lw	a4,540(s1)
    800047e8:	2007879b          	addiw	a5,a5,512
    800047ec:	fcf70ae3          	beq	a4,a5,800047c0 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800047f0:	4685                	li	a3,1
    800047f2:	01590633          	add	a2,s2,s5
    800047f6:	faf40593          	addi	a1,s0,-81
    800047fa:	0509b503          	ld	a0,80(s3)
    800047fe:	e2bfc0ef          	jal	80001628 <copyin>
    80004802:	03650e63          	beq	a0,s6,8000483e <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004806:	21c4a783          	lw	a5,540(s1)
    8000480a:	0017871b          	addiw	a4,a5,1
    8000480e:	20e4ae23          	sw	a4,540(s1)
    80004812:	1ff7f793          	andi	a5,a5,511
    80004816:	97a6                	add	a5,a5,s1
    80004818:	faf44703          	lbu	a4,-81(s0)
    8000481c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004820:	2905                	addiw	s2,s2,1
    80004822:	b775                	j	800047ce <pipewrite+0x6c>
    80004824:	7b02                	ld	s6,32(sp)
    80004826:	6be2                	ld	s7,24(sp)
    80004828:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000482a:	21848513          	addi	a0,s1,536
    8000482e:	f3afd0ef          	jal	80001f68 <wakeup>
  release(&pi->lock);
    80004832:	8526                	mv	a0,s1
    80004834:	c58fc0ef          	jal	80000c8c <release>
  return i;
    80004838:	bf95                	j	800047ac <pipewrite+0x4a>
  int i = 0;
    8000483a:	4901                	li	s2,0
    8000483c:	b7fd                	j	8000482a <pipewrite+0xc8>
    8000483e:	7b02                	ld	s6,32(sp)
    80004840:	6be2                	ld	s7,24(sp)
    80004842:	6c42                	ld	s8,16(sp)
    80004844:	b7dd                	j	8000482a <pipewrite+0xc8>

0000000080004846 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004846:	715d                	addi	sp,sp,-80
    80004848:	e486                	sd	ra,72(sp)
    8000484a:	e0a2                	sd	s0,64(sp)
    8000484c:	fc26                	sd	s1,56(sp)
    8000484e:	f84a                	sd	s2,48(sp)
    80004850:	f44e                	sd	s3,40(sp)
    80004852:	f052                	sd	s4,32(sp)
    80004854:	ec56                	sd	s5,24(sp)
    80004856:	0880                	addi	s0,sp,80
    80004858:	84aa                	mv	s1,a0
    8000485a:	892e                	mv	s2,a1
    8000485c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000485e:	882fd0ef          	jal	800018e0 <myproc>
    80004862:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004864:	8526                	mv	a0,s1
    80004866:	b8efc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000486a:	2184a703          	lw	a4,536(s1)
    8000486e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004872:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004876:	02f71563          	bne	a4,a5,800048a0 <piperead+0x5a>
    8000487a:	2244a783          	lw	a5,548(s1)
    8000487e:	cb85                	beqz	a5,800048ae <piperead+0x68>
    if(killed(pr)){
    80004880:	8552                	mv	a0,s4
    80004882:	8d3fd0ef          	jal	80002154 <killed>
    80004886:	ed19                	bnez	a0,800048a4 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004888:	85a6                	mv	a1,s1
    8000488a:	854e                	mv	a0,s3
    8000488c:	e90fd0ef          	jal	80001f1c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004890:	2184a703          	lw	a4,536(s1)
    80004894:	21c4a783          	lw	a5,540(s1)
    80004898:	fef701e3          	beq	a4,a5,8000487a <piperead+0x34>
    8000489c:	e85a                	sd	s6,16(sp)
    8000489e:	a809                	j	800048b0 <piperead+0x6a>
    800048a0:	e85a                	sd	s6,16(sp)
    800048a2:	a039                	j	800048b0 <piperead+0x6a>
      release(&pi->lock);
    800048a4:	8526                	mv	a0,s1
    800048a6:	be6fc0ef          	jal	80000c8c <release>
      return -1;
    800048aa:	59fd                	li	s3,-1
    800048ac:	a8b1                	j	80004908 <piperead+0xc2>
    800048ae:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048b0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800048b2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048b4:	05505263          	blez	s5,800048f8 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800048b8:	2184a783          	lw	a5,536(s1)
    800048bc:	21c4a703          	lw	a4,540(s1)
    800048c0:	02f70c63          	beq	a4,a5,800048f8 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800048c4:	0017871b          	addiw	a4,a5,1
    800048c8:	20e4ac23          	sw	a4,536(s1)
    800048cc:	1ff7f793          	andi	a5,a5,511
    800048d0:	97a6                	add	a5,a5,s1
    800048d2:	0187c783          	lbu	a5,24(a5)
    800048d6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800048da:	4685                	li	a3,1
    800048dc:	fbf40613          	addi	a2,s0,-65
    800048e0:	85ca                	mv	a1,s2
    800048e2:	050a3503          	ld	a0,80(s4)
    800048e6:	c6dfc0ef          	jal	80001552 <copyout>
    800048ea:	01650763          	beq	a0,s6,800048f8 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048ee:	2985                	addiw	s3,s3,1
    800048f0:	0905                	addi	s2,s2,1
    800048f2:	fd3a93e3          	bne	s5,s3,800048b8 <piperead+0x72>
    800048f6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800048f8:	21c48513          	addi	a0,s1,540
    800048fc:	e6cfd0ef          	jal	80001f68 <wakeup>
  release(&pi->lock);
    80004900:	8526                	mv	a0,s1
    80004902:	b8afc0ef          	jal	80000c8c <release>
    80004906:	6b42                	ld	s6,16(sp)
  return i;
}
    80004908:	854e                	mv	a0,s3
    8000490a:	60a6                	ld	ra,72(sp)
    8000490c:	6406                	ld	s0,64(sp)
    8000490e:	74e2                	ld	s1,56(sp)
    80004910:	7942                	ld	s2,48(sp)
    80004912:	79a2                	ld	s3,40(sp)
    80004914:	7a02                	ld	s4,32(sp)
    80004916:	6ae2                	ld	s5,24(sp)
    80004918:	6161                	addi	sp,sp,80
    8000491a:	8082                	ret

000000008000491c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000491c:	1141                	addi	sp,sp,-16
    8000491e:	e422                	sd	s0,8(sp)
    80004920:	0800                	addi	s0,sp,16
    80004922:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004924:	8905                	andi	a0,a0,1
    80004926:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004928:	8b89                	andi	a5,a5,2
    8000492a:	c399                	beqz	a5,80004930 <flags2perm+0x14>
      perm |= PTE_W;
    8000492c:	00456513          	ori	a0,a0,4
    return perm;
}
    80004930:	6422                	ld	s0,8(sp)
    80004932:	0141                	addi	sp,sp,16
    80004934:	8082                	ret

0000000080004936 <exec>:

int
exec(char *path, char **argv)
{
    80004936:	df010113          	addi	sp,sp,-528
    8000493a:	20113423          	sd	ra,520(sp)
    8000493e:	20813023          	sd	s0,512(sp)
    80004942:	ffa6                	sd	s1,504(sp)
    80004944:	fbca                	sd	s2,496(sp)
    80004946:	0c00                	addi	s0,sp,528
    80004948:	892a                	mv	s2,a0
    8000494a:	dea43c23          	sd	a0,-520(s0)
    8000494e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004952:	f8ffc0ef          	jal	800018e0 <myproc>
    80004956:	84aa                	mv	s1,a0

  begin_op();
    80004958:	dc6ff0ef          	jal	80003f1e <begin_op>

  if((ip = namei(path)) == 0){
    8000495c:	854a                	mv	a0,s2
    8000495e:	c04ff0ef          	jal	80003d62 <namei>
    80004962:	c931                	beqz	a0,800049b6 <exec+0x80>
    80004964:	f3d2                	sd	s4,480(sp)
    80004966:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004968:	d21fe0ef          	jal	80003688 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000496c:	04000713          	li	a4,64
    80004970:	4681                	li	a3,0
    80004972:	e5040613          	addi	a2,s0,-432
    80004976:	4581                	li	a1,0
    80004978:	8552                	mv	a0,s4
    8000497a:	f63fe0ef          	jal	800038dc <readi>
    8000497e:	04000793          	li	a5,64
    80004982:	00f51a63          	bne	a0,a5,80004996 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004986:	e5042703          	lw	a4,-432(s0)
    8000498a:	464c47b7          	lui	a5,0x464c4
    8000498e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004992:	02f70663          	beq	a4,a5,800049be <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004996:	8552                	mv	a0,s4
    80004998:	efbfe0ef          	jal	80003892 <iunlockput>
    end_op();
    8000499c:	decff0ef          	jal	80003f88 <end_op>
  }
  return -1;
    800049a0:	557d                	li	a0,-1
    800049a2:	7a1e                	ld	s4,480(sp)
}
    800049a4:	20813083          	ld	ra,520(sp)
    800049a8:	20013403          	ld	s0,512(sp)
    800049ac:	74fe                	ld	s1,504(sp)
    800049ae:	795e                	ld	s2,496(sp)
    800049b0:	21010113          	addi	sp,sp,528
    800049b4:	8082                	ret
    end_op();
    800049b6:	dd2ff0ef          	jal	80003f88 <end_op>
    return -1;
    800049ba:	557d                	li	a0,-1
    800049bc:	b7e5                	j	800049a4 <exec+0x6e>
    800049be:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800049c0:	8526                	mv	a0,s1
    800049c2:	fc7fc0ef          	jal	80001988 <proc_pagetable>
    800049c6:	8b2a                	mv	s6,a0
    800049c8:	2c050b63          	beqz	a0,80004c9e <exec+0x368>
    800049cc:	f7ce                	sd	s3,488(sp)
    800049ce:	efd6                	sd	s5,472(sp)
    800049d0:	e7de                	sd	s7,456(sp)
    800049d2:	e3e2                	sd	s8,448(sp)
    800049d4:	ff66                	sd	s9,440(sp)
    800049d6:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049d8:	e7042d03          	lw	s10,-400(s0)
    800049dc:	e8845783          	lhu	a5,-376(s0)
    800049e0:	12078963          	beqz	a5,80004b12 <exec+0x1dc>
    800049e4:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049e6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049e8:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800049ea:	6c85                	lui	s9,0x1
    800049ec:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800049f0:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800049f4:	6a85                	lui	s5,0x1
    800049f6:	a085                	j	80004a56 <exec+0x120>
      panic("loadseg: address should exist");
    800049f8:	00003517          	auipc	a0,0x3
    800049fc:	c7850513          	addi	a0,a0,-904 # 80007670 <etext+0x670>
    80004a00:	d95fb0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    80004a04:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004a06:	8726                	mv	a4,s1
    80004a08:	012c06bb          	addw	a3,s8,s2
    80004a0c:	4581                	li	a1,0
    80004a0e:	8552                	mv	a0,s4
    80004a10:	ecdfe0ef          	jal	800038dc <readi>
    80004a14:	2501                	sext.w	a0,a0
    80004a16:	24a49a63          	bne	s1,a0,80004c6a <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004a1a:	012a893b          	addw	s2,s5,s2
    80004a1e:	03397363          	bgeu	s2,s3,80004a44 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004a22:	02091593          	slli	a1,s2,0x20
    80004a26:	9181                	srli	a1,a1,0x20
    80004a28:	95de                	add	a1,a1,s7
    80004a2a:	855a                	mv	a0,s6
    80004a2c:	daafc0ef          	jal	80000fd6 <walkaddr>
    80004a30:	862a                	mv	a2,a0
    if(pa == 0)
    80004a32:	d179                	beqz	a0,800049f8 <exec+0xc2>
    if(sz - i < PGSIZE)
    80004a34:	412984bb          	subw	s1,s3,s2
    80004a38:	0004879b          	sext.w	a5,s1
    80004a3c:	fcfcf4e3          	bgeu	s9,a5,80004a04 <exec+0xce>
    80004a40:	84d6                	mv	s1,s5
    80004a42:	b7c9                	j	80004a04 <exec+0xce>
    sz = sz1;
    80004a44:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a48:	2d85                	addiw	s11,s11,1
    80004a4a:	038d0d1b          	addiw	s10,s10,56
    80004a4e:	e8845783          	lhu	a5,-376(s0)
    80004a52:	08fdd063          	bge	s11,a5,80004ad2 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a56:	2d01                	sext.w	s10,s10
    80004a58:	03800713          	li	a4,56
    80004a5c:	86ea                	mv	a3,s10
    80004a5e:	e1840613          	addi	a2,s0,-488
    80004a62:	4581                	li	a1,0
    80004a64:	8552                	mv	a0,s4
    80004a66:	e77fe0ef          	jal	800038dc <readi>
    80004a6a:	03800793          	li	a5,56
    80004a6e:	1cf51663          	bne	a0,a5,80004c3a <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004a72:	e1842783          	lw	a5,-488(s0)
    80004a76:	4705                	li	a4,1
    80004a78:	fce798e3          	bne	a5,a4,80004a48 <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004a7c:	e4043483          	ld	s1,-448(s0)
    80004a80:	e3843783          	ld	a5,-456(s0)
    80004a84:	1af4ef63          	bltu	s1,a5,80004c42 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a88:	e2843783          	ld	a5,-472(s0)
    80004a8c:	94be                	add	s1,s1,a5
    80004a8e:	1af4ee63          	bltu	s1,a5,80004c4a <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004a92:	df043703          	ld	a4,-528(s0)
    80004a96:	8ff9                	and	a5,a5,a4
    80004a98:	1a079d63          	bnez	a5,80004c52 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a9c:	e1c42503          	lw	a0,-484(s0)
    80004aa0:	e7dff0ef          	jal	8000491c <flags2perm>
    80004aa4:	86aa                	mv	a3,a0
    80004aa6:	8626                	mv	a2,s1
    80004aa8:	85ca                	mv	a1,s2
    80004aaa:	855a                	mv	a0,s6
    80004aac:	893fc0ef          	jal	8000133e <uvmalloc>
    80004ab0:	e0a43423          	sd	a0,-504(s0)
    80004ab4:	1a050363          	beqz	a0,80004c5a <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ab8:	e2843b83          	ld	s7,-472(s0)
    80004abc:	e2042c03          	lw	s8,-480(s0)
    80004ac0:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ac4:	00098463          	beqz	s3,80004acc <exec+0x196>
    80004ac8:	4901                	li	s2,0
    80004aca:	bfa1                	j	80004a22 <exec+0xec>
    sz = sz1;
    80004acc:	e0843903          	ld	s2,-504(s0)
    80004ad0:	bfa5                	j	80004a48 <exec+0x112>
    80004ad2:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004ad4:	8552                	mv	a0,s4
    80004ad6:	dbdfe0ef          	jal	80003892 <iunlockput>
  end_op();
    80004ada:	caeff0ef          	jal	80003f88 <end_op>
  p = myproc();
    80004ade:	e03fc0ef          	jal	800018e0 <myproc>
    80004ae2:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004ae4:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004ae8:	6985                	lui	s3,0x1
    80004aea:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004aec:	99ca                	add	s3,s3,s2
    80004aee:	77fd                	lui	a5,0xfffff
    80004af0:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004af4:	4691                	li	a3,4
    80004af6:	6609                	lui	a2,0x2
    80004af8:	964e                	add	a2,a2,s3
    80004afa:	85ce                	mv	a1,s3
    80004afc:	855a                	mv	a0,s6
    80004afe:	841fc0ef          	jal	8000133e <uvmalloc>
    80004b02:	892a                	mv	s2,a0
    80004b04:	e0a43423          	sd	a0,-504(s0)
    80004b08:	e519                	bnez	a0,80004b16 <exec+0x1e0>
  if(pagetable)
    80004b0a:	e1343423          	sd	s3,-504(s0)
    80004b0e:	4a01                	li	s4,0
    80004b10:	aab1                	j	80004c6c <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b12:	4901                	li	s2,0
    80004b14:	b7c1                	j	80004ad4 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004b16:	75f9                	lui	a1,0xffffe
    80004b18:	95aa                	add	a1,a1,a0
    80004b1a:	855a                	mv	a0,s6
    80004b1c:	a0dfc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004b20:	7bfd                	lui	s7,0xfffff
    80004b22:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004b24:	e0043783          	ld	a5,-512(s0)
    80004b28:	6388                	ld	a0,0(a5)
    80004b2a:	cd39                	beqz	a0,80004b88 <exec+0x252>
    80004b2c:	e9040993          	addi	s3,s0,-368
    80004b30:	f9040c13          	addi	s8,s0,-112
    80004b34:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004b36:	b02fc0ef          	jal	80000e38 <strlen>
    80004b3a:	0015079b          	addiw	a5,a0,1
    80004b3e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b42:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004b46:	11796e63          	bltu	s2,s7,80004c62 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b4a:	e0043d03          	ld	s10,-512(s0)
    80004b4e:	000d3a03          	ld	s4,0(s10)
    80004b52:	8552                	mv	a0,s4
    80004b54:	ae4fc0ef          	jal	80000e38 <strlen>
    80004b58:	0015069b          	addiw	a3,a0,1
    80004b5c:	8652                	mv	a2,s4
    80004b5e:	85ca                	mv	a1,s2
    80004b60:	855a                	mv	a0,s6
    80004b62:	9f1fc0ef          	jal	80001552 <copyout>
    80004b66:	10054063          	bltz	a0,80004c66 <exec+0x330>
    ustack[argc] = sp;
    80004b6a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004b6e:	0485                	addi	s1,s1,1
    80004b70:	008d0793          	addi	a5,s10,8
    80004b74:	e0f43023          	sd	a5,-512(s0)
    80004b78:	008d3503          	ld	a0,8(s10)
    80004b7c:	c909                	beqz	a0,80004b8e <exec+0x258>
    if(argc >= MAXARG)
    80004b7e:	09a1                	addi	s3,s3,8
    80004b80:	fb899be3          	bne	s3,s8,80004b36 <exec+0x200>
  ip = 0;
    80004b84:	4a01                	li	s4,0
    80004b86:	a0dd                	j	80004c6c <exec+0x336>
  sp = sz;
    80004b88:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004b8c:	4481                	li	s1,0
  ustack[argc] = 0;
    80004b8e:	00349793          	slli	a5,s1,0x3
    80004b92:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb5b0>
    80004b96:	97a2                	add	a5,a5,s0
    80004b98:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b9c:	00148693          	addi	a3,s1,1
    80004ba0:	068e                	slli	a3,a3,0x3
    80004ba2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ba6:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004baa:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004bae:	f5796ee3          	bltu	s2,s7,80004b0a <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004bb2:	e9040613          	addi	a2,s0,-368
    80004bb6:	85ca                	mv	a1,s2
    80004bb8:	855a                	mv	a0,s6
    80004bba:	999fc0ef          	jal	80001552 <copyout>
    80004bbe:	0e054263          	bltz	a0,80004ca2 <exec+0x36c>
  p->trapframe->a1 = sp;
    80004bc2:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004bc6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004bca:	df843783          	ld	a5,-520(s0)
    80004bce:	0007c703          	lbu	a4,0(a5)
    80004bd2:	cf11                	beqz	a4,80004bee <exec+0x2b8>
    80004bd4:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004bd6:	02f00693          	li	a3,47
    80004bda:	a039                	j	80004be8 <exec+0x2b2>
      last = s+1;
    80004bdc:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004be0:	0785                	addi	a5,a5,1
    80004be2:	fff7c703          	lbu	a4,-1(a5)
    80004be6:	c701                	beqz	a4,80004bee <exec+0x2b8>
    if(*s == '/')
    80004be8:	fed71ce3          	bne	a4,a3,80004be0 <exec+0x2aa>
    80004bec:	bfc5                	j	80004bdc <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004bee:	4641                	li	a2,16
    80004bf0:	df843583          	ld	a1,-520(s0)
    80004bf4:	158a8513          	addi	a0,s5,344
    80004bf8:	a0efc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004bfc:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004c00:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004c04:	e0843783          	ld	a5,-504(s0)
    80004c08:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004c0c:	058ab783          	ld	a5,88(s5)
    80004c10:	e6843703          	ld	a4,-408(s0)
    80004c14:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004c16:	058ab783          	ld	a5,88(s5)
    80004c1a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c1e:	85e6                	mv	a1,s9
    80004c20:	dedfc0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c24:	0004851b          	sext.w	a0,s1
    80004c28:	79be                	ld	s3,488(sp)
    80004c2a:	7a1e                	ld	s4,480(sp)
    80004c2c:	6afe                	ld	s5,472(sp)
    80004c2e:	6b5e                	ld	s6,464(sp)
    80004c30:	6bbe                	ld	s7,456(sp)
    80004c32:	6c1e                	ld	s8,448(sp)
    80004c34:	7cfa                	ld	s9,440(sp)
    80004c36:	7d5a                	ld	s10,432(sp)
    80004c38:	b3b5                	j	800049a4 <exec+0x6e>
    80004c3a:	e1243423          	sd	s2,-504(s0)
    80004c3e:	7dba                	ld	s11,424(sp)
    80004c40:	a035                	j	80004c6c <exec+0x336>
    80004c42:	e1243423          	sd	s2,-504(s0)
    80004c46:	7dba                	ld	s11,424(sp)
    80004c48:	a015                	j	80004c6c <exec+0x336>
    80004c4a:	e1243423          	sd	s2,-504(s0)
    80004c4e:	7dba                	ld	s11,424(sp)
    80004c50:	a831                	j	80004c6c <exec+0x336>
    80004c52:	e1243423          	sd	s2,-504(s0)
    80004c56:	7dba                	ld	s11,424(sp)
    80004c58:	a811                	j	80004c6c <exec+0x336>
    80004c5a:	e1243423          	sd	s2,-504(s0)
    80004c5e:	7dba                	ld	s11,424(sp)
    80004c60:	a031                	j	80004c6c <exec+0x336>
  ip = 0;
    80004c62:	4a01                	li	s4,0
    80004c64:	a021                	j	80004c6c <exec+0x336>
    80004c66:	4a01                	li	s4,0
  if(pagetable)
    80004c68:	a011                	j	80004c6c <exec+0x336>
    80004c6a:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004c6c:	e0843583          	ld	a1,-504(s0)
    80004c70:	855a                	mv	a0,s6
    80004c72:	d9bfc0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    80004c76:	557d                	li	a0,-1
  if(ip){
    80004c78:	000a1b63          	bnez	s4,80004c8e <exec+0x358>
    80004c7c:	79be                	ld	s3,488(sp)
    80004c7e:	7a1e                	ld	s4,480(sp)
    80004c80:	6afe                	ld	s5,472(sp)
    80004c82:	6b5e                	ld	s6,464(sp)
    80004c84:	6bbe                	ld	s7,456(sp)
    80004c86:	6c1e                	ld	s8,448(sp)
    80004c88:	7cfa                	ld	s9,440(sp)
    80004c8a:	7d5a                	ld	s10,432(sp)
    80004c8c:	bb21                	j	800049a4 <exec+0x6e>
    80004c8e:	79be                	ld	s3,488(sp)
    80004c90:	6afe                	ld	s5,472(sp)
    80004c92:	6b5e                	ld	s6,464(sp)
    80004c94:	6bbe                	ld	s7,456(sp)
    80004c96:	6c1e                	ld	s8,448(sp)
    80004c98:	7cfa                	ld	s9,440(sp)
    80004c9a:	7d5a                	ld	s10,432(sp)
    80004c9c:	b9ed                	j	80004996 <exec+0x60>
    80004c9e:	6b5e                	ld	s6,464(sp)
    80004ca0:	b9dd                	j	80004996 <exec+0x60>
  sz = sz1;
    80004ca2:	e0843983          	ld	s3,-504(s0)
    80004ca6:	b595                	j	80004b0a <exec+0x1d4>

0000000080004ca8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ca8:	7179                	addi	sp,sp,-48
    80004caa:	f406                	sd	ra,40(sp)
    80004cac:	f022                	sd	s0,32(sp)
    80004cae:	ec26                	sd	s1,24(sp)
    80004cb0:	e84a                	sd	s2,16(sp)
    80004cb2:	1800                	addi	s0,sp,48
    80004cb4:	892e                	mv	s2,a1
    80004cb6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004cb8:	fdc40593          	addi	a1,s0,-36
    80004cbc:	e8dfd0ef          	jal	80002b48 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004cc0:	fdc42703          	lw	a4,-36(s0)
    80004cc4:	47bd                	li	a5,15
    80004cc6:	02e7e963          	bltu	a5,a4,80004cf8 <argfd+0x50>
    80004cca:	c17fc0ef          	jal	800018e0 <myproc>
    80004cce:	fdc42703          	lw	a4,-36(s0)
    80004cd2:	01a70793          	addi	a5,a4,26
    80004cd6:	078e                	slli	a5,a5,0x3
    80004cd8:	953e                	add	a0,a0,a5
    80004cda:	611c                	ld	a5,0(a0)
    80004cdc:	c385                	beqz	a5,80004cfc <argfd+0x54>
    return -1;
  if(pfd)
    80004cde:	00090463          	beqz	s2,80004ce6 <argfd+0x3e>
    *pfd = fd;
    80004ce2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004ce6:	4501                	li	a0,0
  if(pf)
    80004ce8:	c091                	beqz	s1,80004cec <argfd+0x44>
    *pf = f;
    80004cea:	e09c                	sd	a5,0(s1)
}
    80004cec:	70a2                	ld	ra,40(sp)
    80004cee:	7402                	ld	s0,32(sp)
    80004cf0:	64e2                	ld	s1,24(sp)
    80004cf2:	6942                	ld	s2,16(sp)
    80004cf4:	6145                	addi	sp,sp,48
    80004cf6:	8082                	ret
    return -1;
    80004cf8:	557d                	li	a0,-1
    80004cfa:	bfcd                	j	80004cec <argfd+0x44>
    80004cfc:	557d                	li	a0,-1
    80004cfe:	b7fd                	j	80004cec <argfd+0x44>

0000000080004d00 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d00:	1101                	addi	sp,sp,-32
    80004d02:	ec06                	sd	ra,24(sp)
    80004d04:	e822                	sd	s0,16(sp)
    80004d06:	e426                	sd	s1,8(sp)
    80004d08:	1000                	addi	s0,sp,32
    80004d0a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d0c:	bd5fc0ef          	jal	800018e0 <myproc>
    80004d10:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004d12:	0d050793          	addi	a5,a0,208
    80004d16:	4501                	li	a0,0
    80004d18:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004d1a:	6398                	ld	a4,0(a5)
    80004d1c:	cb19                	beqz	a4,80004d32 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004d1e:	2505                	addiw	a0,a0,1
    80004d20:	07a1                	addi	a5,a5,8
    80004d22:	fed51ce3          	bne	a0,a3,80004d1a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d26:	557d                	li	a0,-1
}
    80004d28:	60e2                	ld	ra,24(sp)
    80004d2a:	6442                	ld	s0,16(sp)
    80004d2c:	64a2                	ld	s1,8(sp)
    80004d2e:	6105                	addi	sp,sp,32
    80004d30:	8082                	ret
      p->ofile[fd] = f;
    80004d32:	01a50793          	addi	a5,a0,26
    80004d36:	078e                	slli	a5,a5,0x3
    80004d38:	963e                	add	a2,a2,a5
    80004d3a:	e204                	sd	s1,0(a2)
      return fd;
    80004d3c:	b7f5                	j	80004d28 <fdalloc+0x28>

0000000080004d3e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004d3e:	715d                	addi	sp,sp,-80
    80004d40:	e486                	sd	ra,72(sp)
    80004d42:	e0a2                	sd	s0,64(sp)
    80004d44:	fc26                	sd	s1,56(sp)
    80004d46:	f84a                	sd	s2,48(sp)
    80004d48:	f44e                	sd	s3,40(sp)
    80004d4a:	ec56                	sd	s5,24(sp)
    80004d4c:	e85a                	sd	s6,16(sp)
    80004d4e:	0880                	addi	s0,sp,80
    80004d50:	8b2e                	mv	s6,a1
    80004d52:	89b2                	mv	s3,a2
    80004d54:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004d56:	fb040593          	addi	a1,s0,-80
    80004d5a:	822ff0ef          	jal	80003d7c <nameiparent>
    80004d5e:	84aa                	mv	s1,a0
    80004d60:	10050a63          	beqz	a0,80004e74 <create+0x136>
    return 0;

  ilock(dp);
    80004d64:	925fe0ef          	jal	80003688 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004d68:	4601                	li	a2,0
    80004d6a:	fb040593          	addi	a1,s0,-80
    80004d6e:	8526                	mv	a0,s1
    80004d70:	d8dfe0ef          	jal	80003afc <dirlookup>
    80004d74:	8aaa                	mv	s5,a0
    80004d76:	c129                	beqz	a0,80004db8 <create+0x7a>
    iunlockput(dp);
    80004d78:	8526                	mv	a0,s1
    80004d7a:	b19fe0ef          	jal	80003892 <iunlockput>
    ilock(ip);
    80004d7e:	8556                	mv	a0,s5
    80004d80:	909fe0ef          	jal	80003688 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d84:	4789                	li	a5,2
    80004d86:	02fb1463          	bne	s6,a5,80004dae <create+0x70>
    80004d8a:	044ad783          	lhu	a5,68(s5)
    80004d8e:	37f9                	addiw	a5,a5,-2
    80004d90:	17c2                	slli	a5,a5,0x30
    80004d92:	93c1                	srli	a5,a5,0x30
    80004d94:	4705                	li	a4,1
    80004d96:	00f76c63          	bltu	a4,a5,80004dae <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d9a:	8556                	mv	a0,s5
    80004d9c:	60a6                	ld	ra,72(sp)
    80004d9e:	6406                	ld	s0,64(sp)
    80004da0:	74e2                	ld	s1,56(sp)
    80004da2:	7942                	ld	s2,48(sp)
    80004da4:	79a2                	ld	s3,40(sp)
    80004da6:	6ae2                	ld	s5,24(sp)
    80004da8:	6b42                	ld	s6,16(sp)
    80004daa:	6161                	addi	sp,sp,80
    80004dac:	8082                	ret
    iunlockput(ip);
    80004dae:	8556                	mv	a0,s5
    80004db0:	ae3fe0ef          	jal	80003892 <iunlockput>
    return 0;
    80004db4:	4a81                	li	s5,0
    80004db6:	b7d5                	j	80004d9a <create+0x5c>
    80004db8:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004dba:	85da                	mv	a1,s6
    80004dbc:	4088                	lw	a0,0(s1)
    80004dbe:	f5afe0ef          	jal	80003518 <ialloc>
    80004dc2:	8a2a                	mv	s4,a0
    80004dc4:	cd15                	beqz	a0,80004e00 <create+0xc2>
  ilock(ip);
    80004dc6:	8c3fe0ef          	jal	80003688 <ilock>
  ip->major = major;
    80004dca:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004dce:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004dd2:	4905                	li	s2,1
    80004dd4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004dd8:	8552                	mv	a0,s4
    80004dda:	ffafe0ef          	jal	800035d4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004dde:	032b0763          	beq	s6,s2,80004e0c <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004de2:	004a2603          	lw	a2,4(s4)
    80004de6:	fb040593          	addi	a1,s0,-80
    80004dea:	8526                	mv	a0,s1
    80004dec:	eddfe0ef          	jal	80003cc8 <dirlink>
    80004df0:	06054563          	bltz	a0,80004e5a <create+0x11c>
  iunlockput(dp);
    80004df4:	8526                	mv	a0,s1
    80004df6:	a9dfe0ef          	jal	80003892 <iunlockput>
  return ip;
    80004dfa:	8ad2                	mv	s5,s4
    80004dfc:	7a02                	ld	s4,32(sp)
    80004dfe:	bf71                	j	80004d9a <create+0x5c>
    iunlockput(dp);
    80004e00:	8526                	mv	a0,s1
    80004e02:	a91fe0ef          	jal	80003892 <iunlockput>
    return 0;
    80004e06:	8ad2                	mv	s5,s4
    80004e08:	7a02                	ld	s4,32(sp)
    80004e0a:	bf41                	j	80004d9a <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e0c:	004a2603          	lw	a2,4(s4)
    80004e10:	00003597          	auipc	a1,0x3
    80004e14:	88058593          	addi	a1,a1,-1920 # 80007690 <etext+0x690>
    80004e18:	8552                	mv	a0,s4
    80004e1a:	eaffe0ef          	jal	80003cc8 <dirlink>
    80004e1e:	02054e63          	bltz	a0,80004e5a <create+0x11c>
    80004e22:	40d0                	lw	a2,4(s1)
    80004e24:	00003597          	auipc	a1,0x3
    80004e28:	87458593          	addi	a1,a1,-1932 # 80007698 <etext+0x698>
    80004e2c:	8552                	mv	a0,s4
    80004e2e:	e9bfe0ef          	jal	80003cc8 <dirlink>
    80004e32:	02054463          	bltz	a0,80004e5a <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e36:	004a2603          	lw	a2,4(s4)
    80004e3a:	fb040593          	addi	a1,s0,-80
    80004e3e:	8526                	mv	a0,s1
    80004e40:	e89fe0ef          	jal	80003cc8 <dirlink>
    80004e44:	00054b63          	bltz	a0,80004e5a <create+0x11c>
    dp->nlink++;  // for ".."
    80004e48:	04a4d783          	lhu	a5,74(s1)
    80004e4c:	2785                	addiw	a5,a5,1
    80004e4e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e52:	8526                	mv	a0,s1
    80004e54:	f80fe0ef          	jal	800035d4 <iupdate>
    80004e58:	bf71                	j	80004df4 <create+0xb6>
  ip->nlink = 0;
    80004e5a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004e5e:	8552                	mv	a0,s4
    80004e60:	f74fe0ef          	jal	800035d4 <iupdate>
  iunlockput(ip);
    80004e64:	8552                	mv	a0,s4
    80004e66:	a2dfe0ef          	jal	80003892 <iunlockput>
  iunlockput(dp);
    80004e6a:	8526                	mv	a0,s1
    80004e6c:	a27fe0ef          	jal	80003892 <iunlockput>
  return 0;
    80004e70:	7a02                	ld	s4,32(sp)
    80004e72:	b725                	j	80004d9a <create+0x5c>
    return 0;
    80004e74:	8aaa                	mv	s5,a0
    80004e76:	b715                	j	80004d9a <create+0x5c>

0000000080004e78 <sys_dup>:
{
    80004e78:	7179                	addi	sp,sp,-48
    80004e7a:	f406                	sd	ra,40(sp)
    80004e7c:	f022                	sd	s0,32(sp)
    80004e7e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004e80:	fd840613          	addi	a2,s0,-40
    80004e84:	4581                	li	a1,0
    80004e86:	4501                	li	a0,0
    80004e88:	e21ff0ef          	jal	80004ca8 <argfd>
    return -1;
    80004e8c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004e8e:	02054363          	bltz	a0,80004eb4 <sys_dup+0x3c>
    80004e92:	ec26                	sd	s1,24(sp)
    80004e94:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004e96:	fd843903          	ld	s2,-40(s0)
    80004e9a:	854a                	mv	a0,s2
    80004e9c:	e65ff0ef          	jal	80004d00 <fdalloc>
    80004ea0:	84aa                	mv	s1,a0
    return -1;
    80004ea2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004ea4:	00054d63          	bltz	a0,80004ebe <sys_dup+0x46>
  filedup(f);
    80004ea8:	854a                	mv	a0,s2
    80004eaa:	c48ff0ef          	jal	800042f2 <filedup>
  return fd;
    80004eae:	87a6                	mv	a5,s1
    80004eb0:	64e2                	ld	s1,24(sp)
    80004eb2:	6942                	ld	s2,16(sp)
}
    80004eb4:	853e                	mv	a0,a5
    80004eb6:	70a2                	ld	ra,40(sp)
    80004eb8:	7402                	ld	s0,32(sp)
    80004eba:	6145                	addi	sp,sp,48
    80004ebc:	8082                	ret
    80004ebe:	64e2                	ld	s1,24(sp)
    80004ec0:	6942                	ld	s2,16(sp)
    80004ec2:	bfcd                	j	80004eb4 <sys_dup+0x3c>

0000000080004ec4 <sys_read>:
{
    80004ec4:	7179                	addi	sp,sp,-48
    80004ec6:	f406                	sd	ra,40(sp)
    80004ec8:	f022                	sd	s0,32(sp)
    80004eca:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ecc:	fd840593          	addi	a1,s0,-40
    80004ed0:	4505                	li	a0,1
    80004ed2:	c93fd0ef          	jal	80002b64 <argaddr>
  argint(2, &n);
    80004ed6:	fe440593          	addi	a1,s0,-28
    80004eda:	4509                	li	a0,2
    80004edc:	c6dfd0ef          	jal	80002b48 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ee0:	fe840613          	addi	a2,s0,-24
    80004ee4:	4581                	li	a1,0
    80004ee6:	4501                	li	a0,0
    80004ee8:	dc1ff0ef          	jal	80004ca8 <argfd>
    80004eec:	87aa                	mv	a5,a0
    return -1;
    80004eee:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ef0:	0007ca63          	bltz	a5,80004f04 <sys_read+0x40>
  return fileread(f, p, n);
    80004ef4:	fe442603          	lw	a2,-28(s0)
    80004ef8:	fd843583          	ld	a1,-40(s0)
    80004efc:	fe843503          	ld	a0,-24(s0)
    80004f00:	d58ff0ef          	jal	80004458 <fileread>
}
    80004f04:	70a2                	ld	ra,40(sp)
    80004f06:	7402                	ld	s0,32(sp)
    80004f08:	6145                	addi	sp,sp,48
    80004f0a:	8082                	ret

0000000080004f0c <sys_write>:
{
    80004f0c:	7179                	addi	sp,sp,-48
    80004f0e:	f406                	sd	ra,40(sp)
    80004f10:	f022                	sd	s0,32(sp)
    80004f12:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f14:	fd840593          	addi	a1,s0,-40
    80004f18:	4505                	li	a0,1
    80004f1a:	c4bfd0ef          	jal	80002b64 <argaddr>
  argint(2, &n);
    80004f1e:	fe440593          	addi	a1,s0,-28
    80004f22:	4509                	li	a0,2
    80004f24:	c25fd0ef          	jal	80002b48 <argint>
  if(argfd(0, 0, &f) < 0)
    80004f28:	fe840613          	addi	a2,s0,-24
    80004f2c:	4581                	li	a1,0
    80004f2e:	4501                	li	a0,0
    80004f30:	d79ff0ef          	jal	80004ca8 <argfd>
    80004f34:	87aa                	mv	a5,a0
    return -1;
    80004f36:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f38:	0007ca63          	bltz	a5,80004f4c <sys_write+0x40>
  return filewrite(f, p, n);
    80004f3c:	fe442603          	lw	a2,-28(s0)
    80004f40:	fd843583          	ld	a1,-40(s0)
    80004f44:	fe843503          	ld	a0,-24(s0)
    80004f48:	dceff0ef          	jal	80004516 <filewrite>
}
    80004f4c:	70a2                	ld	ra,40(sp)
    80004f4e:	7402                	ld	s0,32(sp)
    80004f50:	6145                	addi	sp,sp,48
    80004f52:	8082                	ret

0000000080004f54 <sys_close>:
{
    80004f54:	1101                	addi	sp,sp,-32
    80004f56:	ec06                	sd	ra,24(sp)
    80004f58:	e822                	sd	s0,16(sp)
    80004f5a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004f5c:	fe040613          	addi	a2,s0,-32
    80004f60:	fec40593          	addi	a1,s0,-20
    80004f64:	4501                	li	a0,0
    80004f66:	d43ff0ef          	jal	80004ca8 <argfd>
    return -1;
    80004f6a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004f6c:	02054063          	bltz	a0,80004f8c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004f70:	971fc0ef          	jal	800018e0 <myproc>
    80004f74:	fec42783          	lw	a5,-20(s0)
    80004f78:	07e9                	addi	a5,a5,26
    80004f7a:	078e                	slli	a5,a5,0x3
    80004f7c:	953e                	add	a0,a0,a5
    80004f7e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f82:	fe043503          	ld	a0,-32(s0)
    80004f86:	bb2ff0ef          	jal	80004338 <fileclose>
  return 0;
    80004f8a:	4781                	li	a5,0
}
    80004f8c:	853e                	mv	a0,a5
    80004f8e:	60e2                	ld	ra,24(sp)
    80004f90:	6442                	ld	s0,16(sp)
    80004f92:	6105                	addi	sp,sp,32
    80004f94:	8082                	ret

0000000080004f96 <sys_fstat>:
{
    80004f96:	1101                	addi	sp,sp,-32
    80004f98:	ec06                	sd	ra,24(sp)
    80004f9a:	e822                	sd	s0,16(sp)
    80004f9c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f9e:	fe040593          	addi	a1,s0,-32
    80004fa2:	4505                	li	a0,1
    80004fa4:	bc1fd0ef          	jal	80002b64 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004fa8:	fe840613          	addi	a2,s0,-24
    80004fac:	4581                	li	a1,0
    80004fae:	4501                	li	a0,0
    80004fb0:	cf9ff0ef          	jal	80004ca8 <argfd>
    80004fb4:	87aa                	mv	a5,a0
    return -1;
    80004fb6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fb8:	0007c863          	bltz	a5,80004fc8 <sys_fstat+0x32>
  return filestat(f, st);
    80004fbc:	fe043583          	ld	a1,-32(s0)
    80004fc0:	fe843503          	ld	a0,-24(s0)
    80004fc4:	c36ff0ef          	jal	800043fa <filestat>
}
    80004fc8:	60e2                	ld	ra,24(sp)
    80004fca:	6442                	ld	s0,16(sp)
    80004fcc:	6105                	addi	sp,sp,32
    80004fce:	8082                	ret

0000000080004fd0 <sys_link>:
{
    80004fd0:	7169                	addi	sp,sp,-304
    80004fd2:	f606                	sd	ra,296(sp)
    80004fd4:	f222                	sd	s0,288(sp)
    80004fd6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fd8:	08000613          	li	a2,128
    80004fdc:	ed040593          	addi	a1,s0,-304
    80004fe0:	4501                	li	a0,0
    80004fe2:	b9ffd0ef          	jal	80002b80 <argstr>
    return -1;
    80004fe6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fe8:	0c054e63          	bltz	a0,800050c4 <sys_link+0xf4>
    80004fec:	08000613          	li	a2,128
    80004ff0:	f5040593          	addi	a1,s0,-176
    80004ff4:	4505                	li	a0,1
    80004ff6:	b8bfd0ef          	jal	80002b80 <argstr>
    return -1;
    80004ffa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ffc:	0c054463          	bltz	a0,800050c4 <sys_link+0xf4>
    80005000:	ee26                	sd	s1,280(sp)
  begin_op();
    80005002:	f1dfe0ef          	jal	80003f1e <begin_op>
  if((ip = namei(old)) == 0){
    80005006:	ed040513          	addi	a0,s0,-304
    8000500a:	d59fe0ef          	jal	80003d62 <namei>
    8000500e:	84aa                	mv	s1,a0
    80005010:	c53d                	beqz	a0,8000507e <sys_link+0xae>
  ilock(ip);
    80005012:	e76fe0ef          	jal	80003688 <ilock>
  if(ip->type == T_DIR){
    80005016:	04449703          	lh	a4,68(s1)
    8000501a:	4785                	li	a5,1
    8000501c:	06f70663          	beq	a4,a5,80005088 <sys_link+0xb8>
    80005020:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005022:	04a4d783          	lhu	a5,74(s1)
    80005026:	2785                	addiw	a5,a5,1
    80005028:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000502c:	8526                	mv	a0,s1
    8000502e:	da6fe0ef          	jal	800035d4 <iupdate>
  iunlock(ip);
    80005032:	8526                	mv	a0,s1
    80005034:	f02fe0ef          	jal	80003736 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005038:	fd040593          	addi	a1,s0,-48
    8000503c:	f5040513          	addi	a0,s0,-176
    80005040:	d3dfe0ef          	jal	80003d7c <nameiparent>
    80005044:	892a                	mv	s2,a0
    80005046:	cd21                	beqz	a0,8000509e <sys_link+0xce>
  ilock(dp);
    80005048:	e40fe0ef          	jal	80003688 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000504c:	00092703          	lw	a4,0(s2)
    80005050:	409c                	lw	a5,0(s1)
    80005052:	04f71363          	bne	a4,a5,80005098 <sys_link+0xc8>
    80005056:	40d0                	lw	a2,4(s1)
    80005058:	fd040593          	addi	a1,s0,-48
    8000505c:	854a                	mv	a0,s2
    8000505e:	c6bfe0ef          	jal	80003cc8 <dirlink>
    80005062:	02054b63          	bltz	a0,80005098 <sys_link+0xc8>
  iunlockput(dp);
    80005066:	854a                	mv	a0,s2
    80005068:	82bfe0ef          	jal	80003892 <iunlockput>
  iput(ip);
    8000506c:	8526                	mv	a0,s1
    8000506e:	f9cfe0ef          	jal	8000380a <iput>
  end_op();
    80005072:	f17fe0ef          	jal	80003f88 <end_op>
  return 0;
    80005076:	4781                	li	a5,0
    80005078:	64f2                	ld	s1,280(sp)
    8000507a:	6952                	ld	s2,272(sp)
    8000507c:	a0a1                	j	800050c4 <sys_link+0xf4>
    end_op();
    8000507e:	f0bfe0ef          	jal	80003f88 <end_op>
    return -1;
    80005082:	57fd                	li	a5,-1
    80005084:	64f2                	ld	s1,280(sp)
    80005086:	a83d                	j	800050c4 <sys_link+0xf4>
    iunlockput(ip);
    80005088:	8526                	mv	a0,s1
    8000508a:	809fe0ef          	jal	80003892 <iunlockput>
    end_op();
    8000508e:	efbfe0ef          	jal	80003f88 <end_op>
    return -1;
    80005092:	57fd                	li	a5,-1
    80005094:	64f2                	ld	s1,280(sp)
    80005096:	a03d                	j	800050c4 <sys_link+0xf4>
    iunlockput(dp);
    80005098:	854a                	mv	a0,s2
    8000509a:	ff8fe0ef          	jal	80003892 <iunlockput>
  ilock(ip);
    8000509e:	8526                	mv	a0,s1
    800050a0:	de8fe0ef          	jal	80003688 <ilock>
  ip->nlink--;
    800050a4:	04a4d783          	lhu	a5,74(s1)
    800050a8:	37fd                	addiw	a5,a5,-1
    800050aa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050ae:	8526                	mv	a0,s1
    800050b0:	d24fe0ef          	jal	800035d4 <iupdate>
  iunlockput(ip);
    800050b4:	8526                	mv	a0,s1
    800050b6:	fdcfe0ef          	jal	80003892 <iunlockput>
  end_op();
    800050ba:	ecffe0ef          	jal	80003f88 <end_op>
  return -1;
    800050be:	57fd                	li	a5,-1
    800050c0:	64f2                	ld	s1,280(sp)
    800050c2:	6952                	ld	s2,272(sp)
}
    800050c4:	853e                	mv	a0,a5
    800050c6:	70b2                	ld	ra,296(sp)
    800050c8:	7412                	ld	s0,288(sp)
    800050ca:	6155                	addi	sp,sp,304
    800050cc:	8082                	ret

00000000800050ce <sys_unlink>:
{
    800050ce:	7151                	addi	sp,sp,-240
    800050d0:	f586                	sd	ra,232(sp)
    800050d2:	f1a2                	sd	s0,224(sp)
    800050d4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800050d6:	08000613          	li	a2,128
    800050da:	f3040593          	addi	a1,s0,-208
    800050de:	4501                	li	a0,0
    800050e0:	aa1fd0ef          	jal	80002b80 <argstr>
    800050e4:	16054063          	bltz	a0,80005244 <sys_unlink+0x176>
    800050e8:	eda6                	sd	s1,216(sp)
  begin_op();
    800050ea:	e35fe0ef          	jal	80003f1e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800050ee:	fb040593          	addi	a1,s0,-80
    800050f2:	f3040513          	addi	a0,s0,-208
    800050f6:	c87fe0ef          	jal	80003d7c <nameiparent>
    800050fa:	84aa                	mv	s1,a0
    800050fc:	c945                	beqz	a0,800051ac <sys_unlink+0xde>
  ilock(dp);
    800050fe:	d8afe0ef          	jal	80003688 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005102:	00002597          	auipc	a1,0x2
    80005106:	58e58593          	addi	a1,a1,1422 # 80007690 <etext+0x690>
    8000510a:	fb040513          	addi	a0,s0,-80
    8000510e:	9d9fe0ef          	jal	80003ae6 <namecmp>
    80005112:	10050e63          	beqz	a0,8000522e <sys_unlink+0x160>
    80005116:	00002597          	auipc	a1,0x2
    8000511a:	58258593          	addi	a1,a1,1410 # 80007698 <etext+0x698>
    8000511e:	fb040513          	addi	a0,s0,-80
    80005122:	9c5fe0ef          	jal	80003ae6 <namecmp>
    80005126:	10050463          	beqz	a0,8000522e <sys_unlink+0x160>
    8000512a:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000512c:	f2c40613          	addi	a2,s0,-212
    80005130:	fb040593          	addi	a1,s0,-80
    80005134:	8526                	mv	a0,s1
    80005136:	9c7fe0ef          	jal	80003afc <dirlookup>
    8000513a:	892a                	mv	s2,a0
    8000513c:	0e050863          	beqz	a0,8000522c <sys_unlink+0x15e>
  ilock(ip);
    80005140:	d48fe0ef          	jal	80003688 <ilock>
  if(ip->nlink < 1)
    80005144:	04a91783          	lh	a5,74(s2)
    80005148:	06f05763          	blez	a5,800051b6 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000514c:	04491703          	lh	a4,68(s2)
    80005150:	4785                	li	a5,1
    80005152:	06f70963          	beq	a4,a5,800051c4 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005156:	4641                	li	a2,16
    80005158:	4581                	li	a1,0
    8000515a:	fc040513          	addi	a0,s0,-64
    8000515e:	b6bfb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005162:	4741                	li	a4,16
    80005164:	f2c42683          	lw	a3,-212(s0)
    80005168:	fc040613          	addi	a2,s0,-64
    8000516c:	4581                	li	a1,0
    8000516e:	8526                	mv	a0,s1
    80005170:	869fe0ef          	jal	800039d8 <writei>
    80005174:	47c1                	li	a5,16
    80005176:	08f51b63          	bne	a0,a5,8000520c <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000517a:	04491703          	lh	a4,68(s2)
    8000517e:	4785                	li	a5,1
    80005180:	08f70d63          	beq	a4,a5,8000521a <sys_unlink+0x14c>
  iunlockput(dp);
    80005184:	8526                	mv	a0,s1
    80005186:	f0cfe0ef          	jal	80003892 <iunlockput>
  ip->nlink--;
    8000518a:	04a95783          	lhu	a5,74(s2)
    8000518e:	37fd                	addiw	a5,a5,-1
    80005190:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005194:	854a                	mv	a0,s2
    80005196:	c3efe0ef          	jal	800035d4 <iupdate>
  iunlockput(ip);
    8000519a:	854a                	mv	a0,s2
    8000519c:	ef6fe0ef          	jal	80003892 <iunlockput>
  end_op();
    800051a0:	de9fe0ef          	jal	80003f88 <end_op>
  return 0;
    800051a4:	4501                	li	a0,0
    800051a6:	64ee                	ld	s1,216(sp)
    800051a8:	694e                	ld	s2,208(sp)
    800051aa:	a849                	j	8000523c <sys_unlink+0x16e>
    end_op();
    800051ac:	dddfe0ef          	jal	80003f88 <end_op>
    return -1;
    800051b0:	557d                	li	a0,-1
    800051b2:	64ee                	ld	s1,216(sp)
    800051b4:	a061                	j	8000523c <sys_unlink+0x16e>
    800051b6:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800051b8:	00002517          	auipc	a0,0x2
    800051bc:	4e850513          	addi	a0,a0,1256 # 800076a0 <etext+0x6a0>
    800051c0:	dd4fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051c4:	04c92703          	lw	a4,76(s2)
    800051c8:	02000793          	li	a5,32
    800051cc:	f8e7f5e3          	bgeu	a5,a4,80005156 <sys_unlink+0x88>
    800051d0:	e5ce                	sd	s3,200(sp)
    800051d2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051d6:	4741                	li	a4,16
    800051d8:	86ce                	mv	a3,s3
    800051da:	f1840613          	addi	a2,s0,-232
    800051de:	4581                	li	a1,0
    800051e0:	854a                	mv	a0,s2
    800051e2:	efafe0ef          	jal	800038dc <readi>
    800051e6:	47c1                	li	a5,16
    800051e8:	00f51c63          	bne	a0,a5,80005200 <sys_unlink+0x132>
    if(de.inum != 0)
    800051ec:	f1845783          	lhu	a5,-232(s0)
    800051f0:	efa1                	bnez	a5,80005248 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051f2:	29c1                	addiw	s3,s3,16
    800051f4:	04c92783          	lw	a5,76(s2)
    800051f8:	fcf9efe3          	bltu	s3,a5,800051d6 <sys_unlink+0x108>
    800051fc:	69ae                	ld	s3,200(sp)
    800051fe:	bfa1                	j	80005156 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005200:	00002517          	auipc	a0,0x2
    80005204:	4b850513          	addi	a0,a0,1208 # 800076b8 <etext+0x6b8>
    80005208:	d8cfb0ef          	jal	80000794 <panic>
    8000520c:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000520e:	00002517          	auipc	a0,0x2
    80005212:	4c250513          	addi	a0,a0,1218 # 800076d0 <etext+0x6d0>
    80005216:	d7efb0ef          	jal	80000794 <panic>
    dp->nlink--;
    8000521a:	04a4d783          	lhu	a5,74(s1)
    8000521e:	37fd                	addiw	a5,a5,-1
    80005220:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005224:	8526                	mv	a0,s1
    80005226:	baefe0ef          	jal	800035d4 <iupdate>
    8000522a:	bfa9                	j	80005184 <sys_unlink+0xb6>
    8000522c:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000522e:	8526                	mv	a0,s1
    80005230:	e62fe0ef          	jal	80003892 <iunlockput>
  end_op();
    80005234:	d55fe0ef          	jal	80003f88 <end_op>
  return -1;
    80005238:	557d                	li	a0,-1
    8000523a:	64ee                	ld	s1,216(sp)
}
    8000523c:	70ae                	ld	ra,232(sp)
    8000523e:	740e                	ld	s0,224(sp)
    80005240:	616d                	addi	sp,sp,240
    80005242:	8082                	ret
    return -1;
    80005244:	557d                	li	a0,-1
    80005246:	bfdd                	j	8000523c <sys_unlink+0x16e>
    iunlockput(ip);
    80005248:	854a                	mv	a0,s2
    8000524a:	e48fe0ef          	jal	80003892 <iunlockput>
    goto bad;
    8000524e:	694e                	ld	s2,208(sp)
    80005250:	69ae                	ld	s3,200(sp)
    80005252:	bff1                	j	8000522e <sys_unlink+0x160>

0000000080005254 <sys_open>:

uint64
sys_open(void)
{
    80005254:	7131                	addi	sp,sp,-192
    80005256:	fd06                	sd	ra,184(sp)
    80005258:	f922                	sd	s0,176(sp)
    8000525a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000525c:	f4c40593          	addi	a1,s0,-180
    80005260:	4505                	li	a0,1
    80005262:	8e7fd0ef          	jal	80002b48 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005266:	08000613          	li	a2,128
    8000526a:	f5040593          	addi	a1,s0,-176
    8000526e:	4501                	li	a0,0
    80005270:	911fd0ef          	jal	80002b80 <argstr>
    80005274:	87aa                	mv	a5,a0
    return -1;
    80005276:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005278:	0a07c263          	bltz	a5,8000531c <sys_open+0xc8>
    8000527c:	f526                	sd	s1,168(sp)

  begin_op();
    8000527e:	ca1fe0ef          	jal	80003f1e <begin_op>

  if(omode & O_CREATE){
    80005282:	f4c42783          	lw	a5,-180(s0)
    80005286:	2007f793          	andi	a5,a5,512
    8000528a:	c3d5                	beqz	a5,8000532e <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000528c:	4681                	li	a3,0
    8000528e:	4601                	li	a2,0
    80005290:	4589                	li	a1,2
    80005292:	f5040513          	addi	a0,s0,-176
    80005296:	aa9ff0ef          	jal	80004d3e <create>
    8000529a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000529c:	c541                	beqz	a0,80005324 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000529e:	04449703          	lh	a4,68(s1)
    800052a2:	478d                	li	a5,3
    800052a4:	00f71763          	bne	a4,a5,800052b2 <sys_open+0x5e>
    800052a8:	0464d703          	lhu	a4,70(s1)
    800052ac:	47a5                	li	a5,9
    800052ae:	0ae7ed63          	bltu	a5,a4,80005368 <sys_open+0x114>
    800052b2:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800052b4:	fe1fe0ef          	jal	80004294 <filealloc>
    800052b8:	892a                	mv	s2,a0
    800052ba:	c179                	beqz	a0,80005380 <sys_open+0x12c>
    800052bc:	ed4e                	sd	s3,152(sp)
    800052be:	a43ff0ef          	jal	80004d00 <fdalloc>
    800052c2:	89aa                	mv	s3,a0
    800052c4:	0a054a63          	bltz	a0,80005378 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800052c8:	04449703          	lh	a4,68(s1)
    800052cc:	478d                	li	a5,3
    800052ce:	0cf70263          	beq	a4,a5,80005392 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800052d2:	4789                	li	a5,2
    800052d4:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800052d8:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800052dc:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800052e0:	f4c42783          	lw	a5,-180(s0)
    800052e4:	0017c713          	xori	a4,a5,1
    800052e8:	8b05                	andi	a4,a4,1
    800052ea:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800052ee:	0037f713          	andi	a4,a5,3
    800052f2:	00e03733          	snez	a4,a4
    800052f6:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800052fa:	4007f793          	andi	a5,a5,1024
    800052fe:	c791                	beqz	a5,8000530a <sys_open+0xb6>
    80005300:	04449703          	lh	a4,68(s1)
    80005304:	4789                	li	a5,2
    80005306:	08f70d63          	beq	a4,a5,800053a0 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000530a:	8526                	mv	a0,s1
    8000530c:	c2afe0ef          	jal	80003736 <iunlock>
  end_op();
    80005310:	c79fe0ef          	jal	80003f88 <end_op>

  return fd;
    80005314:	854e                	mv	a0,s3
    80005316:	74aa                	ld	s1,168(sp)
    80005318:	790a                	ld	s2,160(sp)
    8000531a:	69ea                	ld	s3,152(sp)
}
    8000531c:	70ea                	ld	ra,184(sp)
    8000531e:	744a                	ld	s0,176(sp)
    80005320:	6129                	addi	sp,sp,192
    80005322:	8082                	ret
      end_op();
    80005324:	c65fe0ef          	jal	80003f88 <end_op>
      return -1;
    80005328:	557d                	li	a0,-1
    8000532a:	74aa                	ld	s1,168(sp)
    8000532c:	bfc5                	j	8000531c <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000532e:	f5040513          	addi	a0,s0,-176
    80005332:	a31fe0ef          	jal	80003d62 <namei>
    80005336:	84aa                	mv	s1,a0
    80005338:	c11d                	beqz	a0,8000535e <sys_open+0x10a>
    ilock(ip);
    8000533a:	b4efe0ef          	jal	80003688 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000533e:	04449703          	lh	a4,68(s1)
    80005342:	4785                	li	a5,1
    80005344:	f4f71de3          	bne	a4,a5,8000529e <sys_open+0x4a>
    80005348:	f4c42783          	lw	a5,-180(s0)
    8000534c:	d3bd                	beqz	a5,800052b2 <sys_open+0x5e>
      iunlockput(ip);
    8000534e:	8526                	mv	a0,s1
    80005350:	d42fe0ef          	jal	80003892 <iunlockput>
      end_op();
    80005354:	c35fe0ef          	jal	80003f88 <end_op>
      return -1;
    80005358:	557d                	li	a0,-1
    8000535a:	74aa                	ld	s1,168(sp)
    8000535c:	b7c1                	j	8000531c <sys_open+0xc8>
      end_op();
    8000535e:	c2bfe0ef          	jal	80003f88 <end_op>
      return -1;
    80005362:	557d                	li	a0,-1
    80005364:	74aa                	ld	s1,168(sp)
    80005366:	bf5d                	j	8000531c <sys_open+0xc8>
    iunlockput(ip);
    80005368:	8526                	mv	a0,s1
    8000536a:	d28fe0ef          	jal	80003892 <iunlockput>
    end_op();
    8000536e:	c1bfe0ef          	jal	80003f88 <end_op>
    return -1;
    80005372:	557d                	li	a0,-1
    80005374:	74aa                	ld	s1,168(sp)
    80005376:	b75d                	j	8000531c <sys_open+0xc8>
      fileclose(f);
    80005378:	854a                	mv	a0,s2
    8000537a:	fbffe0ef          	jal	80004338 <fileclose>
    8000537e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005380:	8526                	mv	a0,s1
    80005382:	d10fe0ef          	jal	80003892 <iunlockput>
    end_op();
    80005386:	c03fe0ef          	jal	80003f88 <end_op>
    return -1;
    8000538a:	557d                	li	a0,-1
    8000538c:	74aa                	ld	s1,168(sp)
    8000538e:	790a                	ld	s2,160(sp)
    80005390:	b771                	j	8000531c <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005392:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005396:	04649783          	lh	a5,70(s1)
    8000539a:	02f91223          	sh	a5,36(s2)
    8000539e:	bf3d                	j	800052dc <sys_open+0x88>
    itrunc(ip);
    800053a0:	8526                	mv	a0,s1
    800053a2:	bd4fe0ef          	jal	80003776 <itrunc>
    800053a6:	b795                	j	8000530a <sys_open+0xb6>

00000000800053a8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800053a8:	7175                	addi	sp,sp,-144
    800053aa:	e506                	sd	ra,136(sp)
    800053ac:	e122                	sd	s0,128(sp)
    800053ae:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800053b0:	b6ffe0ef          	jal	80003f1e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800053b4:	08000613          	li	a2,128
    800053b8:	f7040593          	addi	a1,s0,-144
    800053bc:	4501                	li	a0,0
    800053be:	fc2fd0ef          	jal	80002b80 <argstr>
    800053c2:	02054363          	bltz	a0,800053e8 <sys_mkdir+0x40>
    800053c6:	4681                	li	a3,0
    800053c8:	4601                	li	a2,0
    800053ca:	4585                	li	a1,1
    800053cc:	f7040513          	addi	a0,s0,-144
    800053d0:	96fff0ef          	jal	80004d3e <create>
    800053d4:	c911                	beqz	a0,800053e8 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053d6:	cbcfe0ef          	jal	80003892 <iunlockput>
  end_op();
    800053da:	baffe0ef          	jal	80003f88 <end_op>
  return 0;
    800053de:	4501                	li	a0,0
}
    800053e0:	60aa                	ld	ra,136(sp)
    800053e2:	640a                	ld	s0,128(sp)
    800053e4:	6149                	addi	sp,sp,144
    800053e6:	8082                	ret
    end_op();
    800053e8:	ba1fe0ef          	jal	80003f88 <end_op>
    return -1;
    800053ec:	557d                	li	a0,-1
    800053ee:	bfcd                	j	800053e0 <sys_mkdir+0x38>

00000000800053f0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800053f0:	7135                	addi	sp,sp,-160
    800053f2:	ed06                	sd	ra,152(sp)
    800053f4:	e922                	sd	s0,144(sp)
    800053f6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800053f8:	b27fe0ef          	jal	80003f1e <begin_op>
  argint(1, &major);
    800053fc:	f6c40593          	addi	a1,s0,-148
    80005400:	4505                	li	a0,1
    80005402:	f46fd0ef          	jal	80002b48 <argint>
  argint(2, &minor);
    80005406:	f6840593          	addi	a1,s0,-152
    8000540a:	4509                	li	a0,2
    8000540c:	f3cfd0ef          	jal	80002b48 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005410:	08000613          	li	a2,128
    80005414:	f7040593          	addi	a1,s0,-144
    80005418:	4501                	li	a0,0
    8000541a:	f66fd0ef          	jal	80002b80 <argstr>
    8000541e:	02054563          	bltz	a0,80005448 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005422:	f6841683          	lh	a3,-152(s0)
    80005426:	f6c41603          	lh	a2,-148(s0)
    8000542a:	458d                	li	a1,3
    8000542c:	f7040513          	addi	a0,s0,-144
    80005430:	90fff0ef          	jal	80004d3e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005434:	c911                	beqz	a0,80005448 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005436:	c5cfe0ef          	jal	80003892 <iunlockput>
  end_op();
    8000543a:	b4ffe0ef          	jal	80003f88 <end_op>
  return 0;
    8000543e:	4501                	li	a0,0
}
    80005440:	60ea                	ld	ra,152(sp)
    80005442:	644a                	ld	s0,144(sp)
    80005444:	610d                	addi	sp,sp,160
    80005446:	8082                	ret
    end_op();
    80005448:	b41fe0ef          	jal	80003f88 <end_op>
    return -1;
    8000544c:	557d                	li	a0,-1
    8000544e:	bfcd                	j	80005440 <sys_mknod+0x50>

0000000080005450 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005450:	7135                	addi	sp,sp,-160
    80005452:	ed06                	sd	ra,152(sp)
    80005454:	e922                	sd	s0,144(sp)
    80005456:	e14a                	sd	s2,128(sp)
    80005458:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000545a:	c86fc0ef          	jal	800018e0 <myproc>
    8000545e:	892a                	mv	s2,a0
  
  begin_op();
    80005460:	abffe0ef          	jal	80003f1e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005464:	08000613          	li	a2,128
    80005468:	f6040593          	addi	a1,s0,-160
    8000546c:	4501                	li	a0,0
    8000546e:	f12fd0ef          	jal	80002b80 <argstr>
    80005472:	04054363          	bltz	a0,800054b8 <sys_chdir+0x68>
    80005476:	e526                	sd	s1,136(sp)
    80005478:	f6040513          	addi	a0,s0,-160
    8000547c:	8e7fe0ef          	jal	80003d62 <namei>
    80005480:	84aa                	mv	s1,a0
    80005482:	c915                	beqz	a0,800054b6 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005484:	a04fe0ef          	jal	80003688 <ilock>
  if(ip->type != T_DIR){
    80005488:	04449703          	lh	a4,68(s1)
    8000548c:	4785                	li	a5,1
    8000548e:	02f71963          	bne	a4,a5,800054c0 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005492:	8526                	mv	a0,s1
    80005494:	aa2fe0ef          	jal	80003736 <iunlock>
  iput(p->cwd);
    80005498:	15093503          	ld	a0,336(s2)
    8000549c:	b6efe0ef          	jal	8000380a <iput>
  end_op();
    800054a0:	ae9fe0ef          	jal	80003f88 <end_op>
  p->cwd = ip;
    800054a4:	14993823          	sd	s1,336(s2)
  return 0;
    800054a8:	4501                	li	a0,0
    800054aa:	64aa                	ld	s1,136(sp)
}
    800054ac:	60ea                	ld	ra,152(sp)
    800054ae:	644a                	ld	s0,144(sp)
    800054b0:	690a                	ld	s2,128(sp)
    800054b2:	610d                	addi	sp,sp,160
    800054b4:	8082                	ret
    800054b6:	64aa                	ld	s1,136(sp)
    end_op();
    800054b8:	ad1fe0ef          	jal	80003f88 <end_op>
    return -1;
    800054bc:	557d                	li	a0,-1
    800054be:	b7fd                	j	800054ac <sys_chdir+0x5c>
    iunlockput(ip);
    800054c0:	8526                	mv	a0,s1
    800054c2:	bd0fe0ef          	jal	80003892 <iunlockput>
    end_op();
    800054c6:	ac3fe0ef          	jal	80003f88 <end_op>
    return -1;
    800054ca:	557d                	li	a0,-1
    800054cc:	64aa                	ld	s1,136(sp)
    800054ce:	bff9                	j	800054ac <sys_chdir+0x5c>

00000000800054d0 <sys_exec>:

uint64
sys_exec(void)
{
    800054d0:	7121                	addi	sp,sp,-448
    800054d2:	ff06                	sd	ra,440(sp)
    800054d4:	fb22                	sd	s0,432(sp)
    800054d6:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800054d8:	e4840593          	addi	a1,s0,-440
    800054dc:	4505                	li	a0,1
    800054de:	e86fd0ef          	jal	80002b64 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800054e2:	08000613          	li	a2,128
    800054e6:	f5040593          	addi	a1,s0,-176
    800054ea:	4501                	li	a0,0
    800054ec:	e94fd0ef          	jal	80002b80 <argstr>
    800054f0:	87aa                	mv	a5,a0
    return -1;
    800054f2:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800054f4:	0c07c463          	bltz	a5,800055bc <sys_exec+0xec>
    800054f8:	f726                	sd	s1,424(sp)
    800054fa:	f34a                	sd	s2,416(sp)
    800054fc:	ef4e                	sd	s3,408(sp)
    800054fe:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005500:	10000613          	li	a2,256
    80005504:	4581                	li	a1,0
    80005506:	e5040513          	addi	a0,s0,-432
    8000550a:	fbefb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000550e:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005512:	89a6                	mv	s3,s1
    80005514:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005516:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000551a:	00391513          	slli	a0,s2,0x3
    8000551e:	e4040593          	addi	a1,s0,-448
    80005522:	e4843783          	ld	a5,-440(s0)
    80005526:	953e                	add	a0,a0,a5
    80005528:	d96fd0ef          	jal	80002abe <fetchaddr>
    8000552c:	02054663          	bltz	a0,80005558 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005530:	e4043783          	ld	a5,-448(s0)
    80005534:	c3a9                	beqz	a5,80005576 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005536:	deefb0ef          	jal	80000b24 <kalloc>
    8000553a:	85aa                	mv	a1,a0
    8000553c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005540:	cd01                	beqz	a0,80005558 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005542:	6605                	lui	a2,0x1
    80005544:	e4043503          	ld	a0,-448(s0)
    80005548:	dc0fd0ef          	jal	80002b08 <fetchstr>
    8000554c:	00054663          	bltz	a0,80005558 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005550:	0905                	addi	s2,s2,1
    80005552:	09a1                	addi	s3,s3,8
    80005554:	fd4913e3          	bne	s2,s4,8000551a <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005558:	f5040913          	addi	s2,s0,-176
    8000555c:	6088                	ld	a0,0(s1)
    8000555e:	c931                	beqz	a0,800055b2 <sys_exec+0xe2>
    kfree(argv[i]);
    80005560:	ce2fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005564:	04a1                	addi	s1,s1,8
    80005566:	ff249be3          	bne	s1,s2,8000555c <sys_exec+0x8c>
  return -1;
    8000556a:	557d                	li	a0,-1
    8000556c:	74ba                	ld	s1,424(sp)
    8000556e:	791a                	ld	s2,416(sp)
    80005570:	69fa                	ld	s3,408(sp)
    80005572:	6a5a                	ld	s4,400(sp)
    80005574:	a0a1                	j	800055bc <sys_exec+0xec>
      argv[i] = 0;
    80005576:	0009079b          	sext.w	a5,s2
    8000557a:	078e                	slli	a5,a5,0x3
    8000557c:	fd078793          	addi	a5,a5,-48
    80005580:	97a2                	add	a5,a5,s0
    80005582:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005586:	e5040593          	addi	a1,s0,-432
    8000558a:	f5040513          	addi	a0,s0,-176
    8000558e:	ba8ff0ef          	jal	80004936 <exec>
    80005592:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005594:	f5040993          	addi	s3,s0,-176
    80005598:	6088                	ld	a0,0(s1)
    8000559a:	c511                	beqz	a0,800055a6 <sys_exec+0xd6>
    kfree(argv[i]);
    8000559c:	ca6fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055a0:	04a1                	addi	s1,s1,8
    800055a2:	ff349be3          	bne	s1,s3,80005598 <sys_exec+0xc8>
  return ret;
    800055a6:	854a                	mv	a0,s2
    800055a8:	74ba                	ld	s1,424(sp)
    800055aa:	791a                	ld	s2,416(sp)
    800055ac:	69fa                	ld	s3,408(sp)
    800055ae:	6a5a                	ld	s4,400(sp)
    800055b0:	a031                	j	800055bc <sys_exec+0xec>
  return -1;
    800055b2:	557d                	li	a0,-1
    800055b4:	74ba                	ld	s1,424(sp)
    800055b6:	791a                	ld	s2,416(sp)
    800055b8:	69fa                	ld	s3,408(sp)
    800055ba:	6a5a                	ld	s4,400(sp)
}
    800055bc:	70fa                	ld	ra,440(sp)
    800055be:	745a                	ld	s0,432(sp)
    800055c0:	6139                	addi	sp,sp,448
    800055c2:	8082                	ret

00000000800055c4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800055c4:	7139                	addi	sp,sp,-64
    800055c6:	fc06                	sd	ra,56(sp)
    800055c8:	f822                	sd	s0,48(sp)
    800055ca:	f426                	sd	s1,40(sp)
    800055cc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800055ce:	b12fc0ef          	jal	800018e0 <myproc>
    800055d2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800055d4:	fd840593          	addi	a1,s0,-40
    800055d8:	4501                	li	a0,0
    800055da:	d8afd0ef          	jal	80002b64 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800055de:	fc840593          	addi	a1,s0,-56
    800055e2:	fd040513          	addi	a0,s0,-48
    800055e6:	85cff0ef          	jal	80004642 <pipealloc>
    return -1;
    800055ea:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800055ec:	0a054463          	bltz	a0,80005694 <sys_pipe+0xd0>
  fd0 = -1;
    800055f0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800055f4:	fd043503          	ld	a0,-48(s0)
    800055f8:	f08ff0ef          	jal	80004d00 <fdalloc>
    800055fc:	fca42223          	sw	a0,-60(s0)
    80005600:	08054163          	bltz	a0,80005682 <sys_pipe+0xbe>
    80005604:	fc843503          	ld	a0,-56(s0)
    80005608:	ef8ff0ef          	jal	80004d00 <fdalloc>
    8000560c:	fca42023          	sw	a0,-64(s0)
    80005610:	06054063          	bltz	a0,80005670 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005614:	4691                	li	a3,4
    80005616:	fc440613          	addi	a2,s0,-60
    8000561a:	fd843583          	ld	a1,-40(s0)
    8000561e:	68a8                	ld	a0,80(s1)
    80005620:	f33fb0ef          	jal	80001552 <copyout>
    80005624:	00054e63          	bltz	a0,80005640 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005628:	4691                	li	a3,4
    8000562a:	fc040613          	addi	a2,s0,-64
    8000562e:	fd843583          	ld	a1,-40(s0)
    80005632:	0591                	addi	a1,a1,4
    80005634:	68a8                	ld	a0,80(s1)
    80005636:	f1dfb0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000563a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000563c:	04055c63          	bgez	a0,80005694 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005640:	fc442783          	lw	a5,-60(s0)
    80005644:	07e9                	addi	a5,a5,26
    80005646:	078e                	slli	a5,a5,0x3
    80005648:	97a6                	add	a5,a5,s1
    8000564a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000564e:	fc042783          	lw	a5,-64(s0)
    80005652:	07e9                	addi	a5,a5,26
    80005654:	078e                	slli	a5,a5,0x3
    80005656:	94be                	add	s1,s1,a5
    80005658:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000565c:	fd043503          	ld	a0,-48(s0)
    80005660:	cd9fe0ef          	jal	80004338 <fileclose>
    fileclose(wf);
    80005664:	fc843503          	ld	a0,-56(s0)
    80005668:	cd1fe0ef          	jal	80004338 <fileclose>
    return -1;
    8000566c:	57fd                	li	a5,-1
    8000566e:	a01d                	j	80005694 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005670:	fc442783          	lw	a5,-60(s0)
    80005674:	0007c763          	bltz	a5,80005682 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005678:	07e9                	addi	a5,a5,26
    8000567a:	078e                	slli	a5,a5,0x3
    8000567c:	97a6                	add	a5,a5,s1
    8000567e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005682:	fd043503          	ld	a0,-48(s0)
    80005686:	cb3fe0ef          	jal	80004338 <fileclose>
    fileclose(wf);
    8000568a:	fc843503          	ld	a0,-56(s0)
    8000568e:	cabfe0ef          	jal	80004338 <fileclose>
    return -1;
    80005692:	57fd                	li	a5,-1
}
    80005694:	853e                	mv	a0,a5
    80005696:	70e2                	ld	ra,56(sp)
    80005698:	7442                	ld	s0,48(sp)
    8000569a:	74a2                	ld	s1,40(sp)
    8000569c:	6121                	addi	sp,sp,64
    8000569e:	8082                	ret

00000000800056a0 <kernelvec>:
    800056a0:	7111                	addi	sp,sp,-256
    800056a2:	e006                	sd	ra,0(sp)
    800056a4:	e40a                	sd	sp,8(sp)
    800056a6:	e80e                	sd	gp,16(sp)
    800056a8:	ec12                	sd	tp,24(sp)
    800056aa:	f016                	sd	t0,32(sp)
    800056ac:	f41a                	sd	t1,40(sp)
    800056ae:	f81e                	sd	t2,48(sp)
    800056b0:	e4aa                	sd	a0,72(sp)
    800056b2:	e8ae                	sd	a1,80(sp)
    800056b4:	ecb2                	sd	a2,88(sp)
    800056b6:	f0b6                	sd	a3,96(sp)
    800056b8:	f4ba                	sd	a4,104(sp)
    800056ba:	f8be                	sd	a5,112(sp)
    800056bc:	fcc2                	sd	a6,120(sp)
    800056be:	e146                	sd	a7,128(sp)
    800056c0:	edf2                	sd	t3,216(sp)
    800056c2:	f1f6                	sd	t4,224(sp)
    800056c4:	f5fa                	sd	t5,232(sp)
    800056c6:	f9fe                	sd	t6,240(sp)
    800056c8:	b06fd0ef          	jal	800029ce <kerneltrap>
    800056cc:	6082                	ld	ra,0(sp)
    800056ce:	6122                	ld	sp,8(sp)
    800056d0:	61c2                	ld	gp,16(sp)
    800056d2:	7282                	ld	t0,32(sp)
    800056d4:	7322                	ld	t1,40(sp)
    800056d6:	73c2                	ld	t2,48(sp)
    800056d8:	6526                	ld	a0,72(sp)
    800056da:	65c6                	ld	a1,80(sp)
    800056dc:	6666                	ld	a2,88(sp)
    800056de:	7686                	ld	a3,96(sp)
    800056e0:	7726                	ld	a4,104(sp)
    800056e2:	77c6                	ld	a5,112(sp)
    800056e4:	7866                	ld	a6,120(sp)
    800056e6:	688a                	ld	a7,128(sp)
    800056e8:	6e6e                	ld	t3,216(sp)
    800056ea:	7e8e                	ld	t4,224(sp)
    800056ec:	7f2e                	ld	t5,232(sp)
    800056ee:	7fce                	ld	t6,240(sp)
    800056f0:	6111                	addi	sp,sp,256
    800056f2:	10200073          	sret
	...

00000000800056fe <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800056fe:	1141                	addi	sp,sp,-16
    80005700:	e422                	sd	s0,8(sp)
    80005702:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005704:	0c0007b7          	lui	a5,0xc000
    80005708:	4705                	li	a4,1
    8000570a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000570c:	0c0007b7          	lui	a5,0xc000
    80005710:	c3d8                	sw	a4,4(a5)
}
    80005712:	6422                	ld	s0,8(sp)
    80005714:	0141                	addi	sp,sp,16
    80005716:	8082                	ret

0000000080005718 <plicinithart>:

void
plicinithart(void)
{
    80005718:	1141                	addi	sp,sp,-16
    8000571a:	e406                	sd	ra,8(sp)
    8000571c:	e022                	sd	s0,0(sp)
    8000571e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005720:	994fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005724:	0085171b          	slliw	a4,a0,0x8
    80005728:	0c0027b7          	lui	a5,0xc002
    8000572c:	97ba                	add	a5,a5,a4
    8000572e:	40200713          	li	a4,1026
    80005732:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005736:	00d5151b          	slliw	a0,a0,0xd
    8000573a:	0c2017b7          	lui	a5,0xc201
    8000573e:	97aa                	add	a5,a5,a0
    80005740:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005744:	60a2                	ld	ra,8(sp)
    80005746:	6402                	ld	s0,0(sp)
    80005748:	0141                	addi	sp,sp,16
    8000574a:	8082                	ret

000000008000574c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000574c:	1141                	addi	sp,sp,-16
    8000574e:	e406                	sd	ra,8(sp)
    80005750:	e022                	sd	s0,0(sp)
    80005752:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005754:	960fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005758:	00d5151b          	slliw	a0,a0,0xd
    8000575c:	0c2017b7          	lui	a5,0xc201
    80005760:	97aa                	add	a5,a5,a0
  return irq;
}
    80005762:	43c8                	lw	a0,4(a5)
    80005764:	60a2                	ld	ra,8(sp)
    80005766:	6402                	ld	s0,0(sp)
    80005768:	0141                	addi	sp,sp,16
    8000576a:	8082                	ret

000000008000576c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000576c:	1101                	addi	sp,sp,-32
    8000576e:	ec06                	sd	ra,24(sp)
    80005770:	e822                	sd	s0,16(sp)
    80005772:	e426                	sd	s1,8(sp)
    80005774:	1000                	addi	s0,sp,32
    80005776:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005778:	93cfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000577c:	00d5151b          	slliw	a0,a0,0xd
    80005780:	0c2017b7          	lui	a5,0xc201
    80005784:	97aa                	add	a5,a5,a0
    80005786:	c3c4                	sw	s1,4(a5)
}
    80005788:	60e2                	ld	ra,24(sp)
    8000578a:	6442                	ld	s0,16(sp)
    8000578c:	64a2                	ld	s1,8(sp)
    8000578e:	6105                	addi	sp,sp,32
    80005790:	8082                	ret

0000000080005792 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005792:	1141                	addi	sp,sp,-16
    80005794:	e406                	sd	ra,8(sp)
    80005796:	e022                	sd	s0,0(sp)
    80005798:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000579a:	479d                	li	a5,7
    8000579c:	04a7ca63          	blt	a5,a0,800057f0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800057a0:	0001e797          	auipc	a5,0x1e
    800057a4:	10078793          	addi	a5,a5,256 # 800238a0 <disk>
    800057a8:	97aa                	add	a5,a5,a0
    800057aa:	0187c783          	lbu	a5,24(a5)
    800057ae:	e7b9                	bnez	a5,800057fc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800057b0:	00451693          	slli	a3,a0,0x4
    800057b4:	0001e797          	auipc	a5,0x1e
    800057b8:	0ec78793          	addi	a5,a5,236 # 800238a0 <disk>
    800057bc:	6398                	ld	a4,0(a5)
    800057be:	9736                	add	a4,a4,a3
    800057c0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800057c4:	6398                	ld	a4,0(a5)
    800057c6:	9736                	add	a4,a4,a3
    800057c8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800057cc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800057d0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800057d4:	97aa                	add	a5,a5,a0
    800057d6:	4705                	li	a4,1
    800057d8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800057dc:	0001e517          	auipc	a0,0x1e
    800057e0:	0dc50513          	addi	a0,a0,220 # 800238b8 <disk+0x18>
    800057e4:	f84fc0ef          	jal	80001f68 <wakeup>
}
    800057e8:	60a2                	ld	ra,8(sp)
    800057ea:	6402                	ld	s0,0(sp)
    800057ec:	0141                	addi	sp,sp,16
    800057ee:	8082                	ret
    panic("free_desc 1");
    800057f0:	00002517          	auipc	a0,0x2
    800057f4:	ef050513          	addi	a0,a0,-272 # 800076e0 <etext+0x6e0>
    800057f8:	f9dfa0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    800057fc:	00002517          	auipc	a0,0x2
    80005800:	ef450513          	addi	a0,a0,-268 # 800076f0 <etext+0x6f0>
    80005804:	f91fa0ef          	jal	80000794 <panic>

0000000080005808 <virtio_disk_init>:
{
    80005808:	1101                	addi	sp,sp,-32
    8000580a:	ec06                	sd	ra,24(sp)
    8000580c:	e822                	sd	s0,16(sp)
    8000580e:	e426                	sd	s1,8(sp)
    80005810:	e04a                	sd	s2,0(sp)
    80005812:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005814:	00002597          	auipc	a1,0x2
    80005818:	eec58593          	addi	a1,a1,-276 # 80007700 <etext+0x700>
    8000581c:	0001e517          	auipc	a0,0x1e
    80005820:	1ac50513          	addi	a0,a0,428 # 800239c8 <disk+0x128>
    80005824:	b50fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005828:	100017b7          	lui	a5,0x10001
    8000582c:	4398                	lw	a4,0(a5)
    8000582e:	2701                	sext.w	a4,a4
    80005830:	747277b7          	lui	a5,0x74727
    80005834:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005838:	18f71063          	bne	a4,a5,800059b8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000583c:	100017b7          	lui	a5,0x10001
    80005840:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005842:	439c                	lw	a5,0(a5)
    80005844:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005846:	4709                	li	a4,2
    80005848:	16e79863          	bne	a5,a4,800059b8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000584c:	100017b7          	lui	a5,0x10001
    80005850:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005852:	439c                	lw	a5,0(a5)
    80005854:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005856:	16e79163          	bne	a5,a4,800059b8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000585a:	100017b7          	lui	a5,0x10001
    8000585e:	47d8                	lw	a4,12(a5)
    80005860:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005862:	554d47b7          	lui	a5,0x554d4
    80005866:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000586a:	14f71763          	bne	a4,a5,800059b8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000586e:	100017b7          	lui	a5,0x10001
    80005872:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005876:	4705                	li	a4,1
    80005878:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000587a:	470d                	li	a4,3
    8000587c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000587e:	10001737          	lui	a4,0x10001
    80005882:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005884:	c7ffe737          	lui	a4,0xc7ffe
    80005888:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdad7f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000588c:	8ef9                	and	a3,a3,a4
    8000588e:	10001737          	lui	a4,0x10001
    80005892:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005894:	472d                	li	a4,11
    80005896:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005898:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000589c:	439c                	lw	a5,0(a5)
    8000589e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800058a2:	8ba1                	andi	a5,a5,8
    800058a4:	12078063          	beqz	a5,800059c4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800058a8:	100017b7          	lui	a5,0x10001
    800058ac:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800058b0:	100017b7          	lui	a5,0x10001
    800058b4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800058b8:	439c                	lw	a5,0(a5)
    800058ba:	2781                	sext.w	a5,a5
    800058bc:	10079a63          	bnez	a5,800059d0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800058c0:	100017b7          	lui	a5,0x10001
    800058c4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800058c8:	439c                	lw	a5,0(a5)
    800058ca:	2781                	sext.w	a5,a5
  if(max == 0)
    800058cc:	10078863          	beqz	a5,800059dc <virtio_disk_init+0x1d4>
  if(max < NUM)
    800058d0:	471d                	li	a4,7
    800058d2:	10f77b63          	bgeu	a4,a5,800059e8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800058d6:	a4efb0ef          	jal	80000b24 <kalloc>
    800058da:	0001e497          	auipc	s1,0x1e
    800058de:	fc648493          	addi	s1,s1,-58 # 800238a0 <disk>
    800058e2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800058e4:	a40fb0ef          	jal	80000b24 <kalloc>
    800058e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800058ea:	a3afb0ef          	jal	80000b24 <kalloc>
    800058ee:	87aa                	mv	a5,a0
    800058f0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800058f2:	6088                	ld	a0,0(s1)
    800058f4:	10050063          	beqz	a0,800059f4 <virtio_disk_init+0x1ec>
    800058f8:	0001e717          	auipc	a4,0x1e
    800058fc:	fb073703          	ld	a4,-80(a4) # 800238a8 <disk+0x8>
    80005900:	0e070a63          	beqz	a4,800059f4 <virtio_disk_init+0x1ec>
    80005904:	0e078863          	beqz	a5,800059f4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005908:	6605                	lui	a2,0x1
    8000590a:	4581                	li	a1,0
    8000590c:	bbcfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005910:	0001e497          	auipc	s1,0x1e
    80005914:	f9048493          	addi	s1,s1,-112 # 800238a0 <disk>
    80005918:	6605                	lui	a2,0x1
    8000591a:	4581                	li	a1,0
    8000591c:	6488                	ld	a0,8(s1)
    8000591e:	baafb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005922:	6605                	lui	a2,0x1
    80005924:	4581                	li	a1,0
    80005926:	6888                	ld	a0,16(s1)
    80005928:	ba0fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000592c:	100017b7          	lui	a5,0x10001
    80005930:	4721                	li	a4,8
    80005932:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005934:	4098                	lw	a4,0(s1)
    80005936:	100017b7          	lui	a5,0x10001
    8000593a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000593e:	40d8                	lw	a4,4(s1)
    80005940:	100017b7          	lui	a5,0x10001
    80005944:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005948:	649c                	ld	a5,8(s1)
    8000594a:	0007869b          	sext.w	a3,a5
    8000594e:	10001737          	lui	a4,0x10001
    80005952:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005956:	9781                	srai	a5,a5,0x20
    80005958:	10001737          	lui	a4,0x10001
    8000595c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005960:	689c                	ld	a5,16(s1)
    80005962:	0007869b          	sext.w	a3,a5
    80005966:	10001737          	lui	a4,0x10001
    8000596a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000596e:	9781                	srai	a5,a5,0x20
    80005970:	10001737          	lui	a4,0x10001
    80005974:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005978:	10001737          	lui	a4,0x10001
    8000597c:	4785                	li	a5,1
    8000597e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005980:	00f48c23          	sb	a5,24(s1)
    80005984:	00f48ca3          	sb	a5,25(s1)
    80005988:	00f48d23          	sb	a5,26(s1)
    8000598c:	00f48da3          	sb	a5,27(s1)
    80005990:	00f48e23          	sb	a5,28(s1)
    80005994:	00f48ea3          	sb	a5,29(s1)
    80005998:	00f48f23          	sb	a5,30(s1)
    8000599c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800059a0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800059a4:	100017b7          	lui	a5,0x10001
    800059a8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800059ac:	60e2                	ld	ra,24(sp)
    800059ae:	6442                	ld	s0,16(sp)
    800059b0:	64a2                	ld	s1,8(sp)
    800059b2:	6902                	ld	s2,0(sp)
    800059b4:	6105                	addi	sp,sp,32
    800059b6:	8082                	ret
    panic("could not find virtio disk");
    800059b8:	00002517          	auipc	a0,0x2
    800059bc:	d5850513          	addi	a0,a0,-680 # 80007710 <etext+0x710>
    800059c0:	dd5fa0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    800059c4:	00002517          	auipc	a0,0x2
    800059c8:	d6c50513          	addi	a0,a0,-660 # 80007730 <etext+0x730>
    800059cc:	dc9fa0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    800059d0:	00002517          	auipc	a0,0x2
    800059d4:	d8050513          	addi	a0,a0,-640 # 80007750 <etext+0x750>
    800059d8:	dbdfa0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    800059dc:	00002517          	auipc	a0,0x2
    800059e0:	d9450513          	addi	a0,a0,-620 # 80007770 <etext+0x770>
    800059e4:	db1fa0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    800059e8:	00002517          	auipc	a0,0x2
    800059ec:	da850513          	addi	a0,a0,-600 # 80007790 <etext+0x790>
    800059f0:	da5fa0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    800059f4:	00002517          	auipc	a0,0x2
    800059f8:	dbc50513          	addi	a0,a0,-580 # 800077b0 <etext+0x7b0>
    800059fc:	d99fa0ef          	jal	80000794 <panic>

0000000080005a00 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a00:	7159                	addi	sp,sp,-112
    80005a02:	f486                	sd	ra,104(sp)
    80005a04:	f0a2                	sd	s0,96(sp)
    80005a06:	eca6                	sd	s1,88(sp)
    80005a08:	e8ca                	sd	s2,80(sp)
    80005a0a:	e4ce                	sd	s3,72(sp)
    80005a0c:	e0d2                	sd	s4,64(sp)
    80005a0e:	fc56                	sd	s5,56(sp)
    80005a10:	f85a                	sd	s6,48(sp)
    80005a12:	f45e                	sd	s7,40(sp)
    80005a14:	f062                	sd	s8,32(sp)
    80005a16:	ec66                	sd	s9,24(sp)
    80005a18:	1880                	addi	s0,sp,112
    80005a1a:	8a2a                	mv	s4,a0
    80005a1c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a1e:	00c52c83          	lw	s9,12(a0)
    80005a22:	001c9c9b          	slliw	s9,s9,0x1
    80005a26:	1c82                	slli	s9,s9,0x20
    80005a28:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005a2c:	0001e517          	auipc	a0,0x1e
    80005a30:	f9c50513          	addi	a0,a0,-100 # 800239c8 <disk+0x128>
    80005a34:	9c0fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005a38:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005a3a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a3c:	0001eb17          	auipc	s6,0x1e
    80005a40:	e64b0b13          	addi	s6,s6,-412 # 800238a0 <disk>
  for(int i = 0; i < 3; i++){
    80005a44:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a46:	0001ec17          	auipc	s8,0x1e
    80005a4a:	f82c0c13          	addi	s8,s8,-126 # 800239c8 <disk+0x128>
    80005a4e:	a8b9                	j	80005aac <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005a50:	00fb0733          	add	a4,s6,a5
    80005a54:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005a58:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005a5a:	0207c563          	bltz	a5,80005a84 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005a5e:	2905                	addiw	s2,s2,1
    80005a60:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a62:	05590963          	beq	s2,s5,80005ab4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005a66:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005a68:	0001e717          	auipc	a4,0x1e
    80005a6c:	e3870713          	addi	a4,a4,-456 # 800238a0 <disk>
    80005a70:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005a72:	01874683          	lbu	a3,24(a4)
    80005a76:	fee9                	bnez	a3,80005a50 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005a78:	2785                	addiw	a5,a5,1
    80005a7a:	0705                	addi	a4,a4,1
    80005a7c:	fe979be3          	bne	a5,s1,80005a72 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005a80:	57fd                	li	a5,-1
    80005a82:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005a84:	01205d63          	blez	s2,80005a9e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005a88:	f9042503          	lw	a0,-112(s0)
    80005a8c:	d07ff0ef          	jal	80005792 <free_desc>
      for(int j = 0; j < i; j++)
    80005a90:	4785                	li	a5,1
    80005a92:	0127d663          	bge	a5,s2,80005a9e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005a96:	f9442503          	lw	a0,-108(s0)
    80005a9a:	cf9ff0ef          	jal	80005792 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a9e:	85e2                	mv	a1,s8
    80005aa0:	0001e517          	auipc	a0,0x1e
    80005aa4:	e1850513          	addi	a0,a0,-488 # 800238b8 <disk+0x18>
    80005aa8:	c74fc0ef          	jal	80001f1c <sleep>
  for(int i = 0; i < 3; i++){
    80005aac:	f9040613          	addi	a2,s0,-112
    80005ab0:	894e                	mv	s2,s3
    80005ab2:	bf55                	j	80005a66 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005ab4:	f9042503          	lw	a0,-112(s0)
    80005ab8:	00451693          	slli	a3,a0,0x4

  if(write)
    80005abc:	0001e797          	auipc	a5,0x1e
    80005ac0:	de478793          	addi	a5,a5,-540 # 800238a0 <disk>
    80005ac4:	00a50713          	addi	a4,a0,10
    80005ac8:	0712                	slli	a4,a4,0x4
    80005aca:	973e                	add	a4,a4,a5
    80005acc:	01703633          	snez	a2,s7
    80005ad0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005ad2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005ad6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ada:	6398                	ld	a4,0(a5)
    80005adc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005ade:	0a868613          	addi	a2,a3,168
    80005ae2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ae4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005ae6:	6390                	ld	a2,0(a5)
    80005ae8:	00d605b3          	add	a1,a2,a3
    80005aec:	4741                	li	a4,16
    80005aee:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005af0:	4805                	li	a6,1
    80005af2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005af6:	f9442703          	lw	a4,-108(s0)
    80005afa:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005afe:	0712                	slli	a4,a4,0x4
    80005b00:	963a                	add	a2,a2,a4
    80005b02:	058a0593          	addi	a1,s4,88
    80005b06:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b08:	0007b883          	ld	a7,0(a5)
    80005b0c:	9746                	add	a4,a4,a7
    80005b0e:	40000613          	li	a2,1024
    80005b12:	c710                	sw	a2,8(a4)
  if(write)
    80005b14:	001bb613          	seqz	a2,s7
    80005b18:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b1c:	00166613          	ori	a2,a2,1
    80005b20:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b24:	f9842583          	lw	a1,-104(s0)
    80005b28:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b2c:	00250613          	addi	a2,a0,2
    80005b30:	0612                	slli	a2,a2,0x4
    80005b32:	963e                	add	a2,a2,a5
    80005b34:	577d                	li	a4,-1
    80005b36:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005b3a:	0592                	slli	a1,a1,0x4
    80005b3c:	98ae                	add	a7,a7,a1
    80005b3e:	03068713          	addi	a4,a3,48
    80005b42:	973e                	add	a4,a4,a5
    80005b44:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b48:	6398                	ld	a4,0(a5)
    80005b4a:	972e                	add	a4,a4,a1
    80005b4c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b50:	4689                	li	a3,2
    80005b52:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b56:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b5a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005b5e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b62:	6794                	ld	a3,8(a5)
    80005b64:	0026d703          	lhu	a4,2(a3)
    80005b68:	8b1d                	andi	a4,a4,7
    80005b6a:	0706                	slli	a4,a4,0x1
    80005b6c:	96ba                	add	a3,a3,a4
    80005b6e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005b72:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005b76:	6798                	ld	a4,8(a5)
    80005b78:	00275783          	lhu	a5,2(a4)
    80005b7c:	2785                	addiw	a5,a5,1
    80005b7e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005b82:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005b86:	100017b7          	lui	a5,0x10001
    80005b8a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005b8e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005b92:	0001e917          	auipc	s2,0x1e
    80005b96:	e3690913          	addi	s2,s2,-458 # 800239c8 <disk+0x128>
  while(b->disk == 1) {
    80005b9a:	4485                	li	s1,1
    80005b9c:	01079a63          	bne	a5,a6,80005bb0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005ba0:	85ca                	mv	a1,s2
    80005ba2:	8552                	mv	a0,s4
    80005ba4:	b78fc0ef          	jal	80001f1c <sleep>
  while(b->disk == 1) {
    80005ba8:	004a2783          	lw	a5,4(s4)
    80005bac:	fe978ae3          	beq	a5,s1,80005ba0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005bb0:	f9042903          	lw	s2,-112(s0)
    80005bb4:	00290713          	addi	a4,s2,2
    80005bb8:	0712                	slli	a4,a4,0x4
    80005bba:	0001e797          	auipc	a5,0x1e
    80005bbe:	ce678793          	addi	a5,a5,-794 # 800238a0 <disk>
    80005bc2:	97ba                	add	a5,a5,a4
    80005bc4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005bc8:	0001e997          	auipc	s3,0x1e
    80005bcc:	cd898993          	addi	s3,s3,-808 # 800238a0 <disk>
    80005bd0:	00491713          	slli	a4,s2,0x4
    80005bd4:	0009b783          	ld	a5,0(s3)
    80005bd8:	97ba                	add	a5,a5,a4
    80005bda:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005bde:	854a                	mv	a0,s2
    80005be0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005be4:	bafff0ef          	jal	80005792 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005be8:	8885                	andi	s1,s1,1
    80005bea:	f0fd                	bnez	s1,80005bd0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005bec:	0001e517          	auipc	a0,0x1e
    80005bf0:	ddc50513          	addi	a0,a0,-548 # 800239c8 <disk+0x128>
    80005bf4:	898fb0ef          	jal	80000c8c <release>
}
    80005bf8:	70a6                	ld	ra,104(sp)
    80005bfa:	7406                	ld	s0,96(sp)
    80005bfc:	64e6                	ld	s1,88(sp)
    80005bfe:	6946                	ld	s2,80(sp)
    80005c00:	69a6                	ld	s3,72(sp)
    80005c02:	6a06                	ld	s4,64(sp)
    80005c04:	7ae2                	ld	s5,56(sp)
    80005c06:	7b42                	ld	s6,48(sp)
    80005c08:	7ba2                	ld	s7,40(sp)
    80005c0a:	7c02                	ld	s8,32(sp)
    80005c0c:	6ce2                	ld	s9,24(sp)
    80005c0e:	6165                	addi	sp,sp,112
    80005c10:	8082                	ret

0000000080005c12 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005c12:	1101                	addi	sp,sp,-32
    80005c14:	ec06                	sd	ra,24(sp)
    80005c16:	e822                	sd	s0,16(sp)
    80005c18:	e426                	sd	s1,8(sp)
    80005c1a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005c1c:	0001e497          	auipc	s1,0x1e
    80005c20:	c8448493          	addi	s1,s1,-892 # 800238a0 <disk>
    80005c24:	0001e517          	auipc	a0,0x1e
    80005c28:	da450513          	addi	a0,a0,-604 # 800239c8 <disk+0x128>
    80005c2c:	fc9fa0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c30:	100017b7          	lui	a5,0x10001
    80005c34:	53b8                	lw	a4,96(a5)
    80005c36:	8b0d                	andi	a4,a4,3
    80005c38:	100017b7          	lui	a5,0x10001
    80005c3c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005c3e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005c42:	689c                	ld	a5,16(s1)
    80005c44:	0204d703          	lhu	a4,32(s1)
    80005c48:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c4c:	04f70663          	beq	a4,a5,80005c98 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005c50:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c54:	6898                	ld	a4,16(s1)
    80005c56:	0204d783          	lhu	a5,32(s1)
    80005c5a:	8b9d                	andi	a5,a5,7
    80005c5c:	078e                	slli	a5,a5,0x3
    80005c5e:	97ba                	add	a5,a5,a4
    80005c60:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005c62:	00278713          	addi	a4,a5,2
    80005c66:	0712                	slli	a4,a4,0x4
    80005c68:	9726                	add	a4,a4,s1
    80005c6a:	01074703          	lbu	a4,16(a4)
    80005c6e:	e321                	bnez	a4,80005cae <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005c70:	0789                	addi	a5,a5,2
    80005c72:	0792                	slli	a5,a5,0x4
    80005c74:	97a6                	add	a5,a5,s1
    80005c76:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005c78:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c7c:	aecfc0ef          	jal	80001f68 <wakeup>

    disk.used_idx += 1;
    80005c80:	0204d783          	lhu	a5,32(s1)
    80005c84:	2785                	addiw	a5,a5,1
    80005c86:	17c2                	slli	a5,a5,0x30
    80005c88:	93c1                	srli	a5,a5,0x30
    80005c8a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005c8e:	6898                	ld	a4,16(s1)
    80005c90:	00275703          	lhu	a4,2(a4)
    80005c94:	faf71ee3          	bne	a4,a5,80005c50 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c98:	0001e517          	auipc	a0,0x1e
    80005c9c:	d3050513          	addi	a0,a0,-720 # 800239c8 <disk+0x128>
    80005ca0:	fedfa0ef          	jal	80000c8c <release>
}
    80005ca4:	60e2                	ld	ra,24(sp)
    80005ca6:	6442                	ld	s0,16(sp)
    80005ca8:	64a2                	ld	s1,8(sp)
    80005caa:	6105                	addi	sp,sp,32
    80005cac:	8082                	ret
      panic("virtio_disk_intr status");
    80005cae:	00002517          	auipc	a0,0x2
    80005cb2:	b1a50513          	addi	a0,a0,-1254 # 800077c8 <etext+0x7c8>
    80005cb6:	adffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
