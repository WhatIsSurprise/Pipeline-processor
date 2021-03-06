# Pipeline-processor：基于Verilog HDL的五级流水线处理器

## 开发平台
VIVADO 16、xilinx FPGA开发板

## 设计要求
#### 设计一个 5 级流水线的 MIPS 处理器，采用如下方法解决竞争问题:
1.  采用完全的 forwarding 电路解决数据关联问题。
2.  对于 Load use 类竞争采取阻塞一个周期 + Forwarding 的方法解决。
3.  对于分支指令在 EX 阶段判断（提前判断也可以），在分支发生时刻取消 ID 和 IF 阶段的两条指令。
4.  对于 J 类指令在 ID 阶段判断，并取消 IF 阶段指令。

#### 分支和跳转指令做如下扩充：分支指令（ beq 、 bne 、 blez 、 bgtz 、 bltz) 和跳转指令 (j 、 jal 、 jr 、 jalr)
#### 该处理器支持未定义指令异常和中断的处理
#### 设计定时器外设，可以根据设定周期产生外部中断，通过该定时器触发

## 设计方案
#### 框图

![1](https://user-images.githubusercontent.com/75518712/111430067-cfd7af00-8734-11eb-9c56-b3249c76a7e2.png)

#### 功能说明
1.  取指阶段
    
    (1) PC 模块：给出指令地址，其中实现指令指针寄存器 PC ，该寄存器的值就是指令地址，对应 PC_reg.v 文件。
    
    (2) IF/ID 模块：实现取指与译码阶段之间的寄存器，将取指阶段的结果（取得的指令、指令地址等信息）在下一个时钟传递到译码阶段，对应IF_ID_rigister.v 文件。
2.  译码阶段
    
    (1) ID 模块：对指令进行译码，译码结果包括运算类型、运算所需的源操作数、要写入的目的寄存器地址等，对应 id_depart.v 文件。
    
    (2) Regfile 模块：实现了 32 个 32 位通用整数寄存器，可以同时进行两个寄存器的读操 作和一个寄存器的写操作，对应 Rigisterfile.v 文件。
    
    (3) ID/EX 模块：实现译码与执行阶段之间的寄存器，将译码阶段的结果在下一个时钟周期传递到执行阶段，对应 ID_EX_rigister.v 文件。
3.  执行阶段
    
    (1) EX 模块：依据译码阶段的结果，进行指定的运算，给出运算结果。对应EX_depart.v 文件。
    
    (2) EX/MEM 模块：实现执行与访存阶段之间的寄存器，将执行阶段的结果在下一个时钟周期传递到访存阶段，对 EX_MEM_rigister.v 文件。
4.  访存阶段

    (1) MEM 模块：如果是加载、存储指令，那么会对数据存储器进行访问。此外，还会在该模块进行异常判断。对应 MEM_depart.v 文件。
    (2) MEM/WB 模块：实现访存与回写阶段之间的寄存器，将访存阶段的结果在下一个时钟周期传递到回写阶段，对应 MEM_WB_rigister.v 文件。
5.  控制模块
    ctrl模块用于控制流水线的暂停、清除等动作， 产生 stall 信号， 对应ctrl.v 文件。
#### 测试说明
测试采用快速排序进行测试，如果排序结果正确则说明模拟处理器工作正常
