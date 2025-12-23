# Silicore: Advanced Out-of-Order Processor with ML Branch Prediction 
Silicore is a comprehensive processor design project developed for the JoSDC'24 competition which scored 3rd place nationally. It evolves from a standard single-cycle architecture into a high-performance **Out-of-Order (OOO) execution engine**. 

Beyond the hardware, this project features a custom-built software toolchain—including the **"Epsilon" Compiler**, a **Real-Time Cycle-Accurate Simulator**, and an **AI-driven Branch Predictor**—to demonstrate a complete hardware/software co-design approach.

## System Architecture 

### Advanced Out-of-Order Execution
To prove the performance gains, the project implements the processor in three distinct evolutionary stages:
<p align="center">
   <img src="https://github.com/user-attachments/assets/51fe9b8c-442a-489f-a1c1-4eac4cc5b9ab" alt="Stages" width=70%>
 </p>
 
The core of the project is a 32-bit MIPS processor built on Tomasulo’s Algorithm, designed to break the limits of sequential processing.It uses dynamic scheduling, speculative execution, hardware-based renaming and memory disamiguation. 

<p align="center">
   <img src="https://github.com/user-attachments/assets/d717e08f-224a-4f84-bc44-ea056122c5fa" alt="OOO" width=100%>
 </p>

 ### Custom Toolchain Software Ecosystem 
Integrating software into CPU development is essential for creating efficient and effective computing
systems. This process involves several key components, including building an assembler, a cycle-accurate
simulator, and a real-time cycle-accurate simulator.

<p align="center">
   <img src="https://github.com/user-attachments/assets/a6dfc715-1ed1-436f-bfe7-16e7bcfc5388" alt="Software" width=100%>
 </p>

 ### AI-Driven Optimization 
Traditionally, branch predictors relied on hardware-based heuristics, but Machine Learning (ML) offers a more adaptive and efficient approach by leveraging data-driven models to recognize complex patterns in branch behavior.

<p align="center">
   <img src="https://github.com/user-attachments/assets/0957614e-01cc-4e24-85e1-a4286793dae5" alt="MLBranch" width=100%>
 </p>

 ### C# Static Scheduling 
The algorithms used for scheduling aim to minimize stalls and maximize parallel execution. It takes user-defined instructions, organizes them and saves the output to specified text files. 

 <p align="center">
   <img src="https://github.com/user-attachments/assets/94108b9a-bed6-4aa1-9cb1-42db9f3dd348" alt="StatSched" width=70%>
 </p>

 ### Performance Benchmarks

 We evaluated the design using JoSDC and Silicore benchmarks (Sorting, Matrix Operations, Cryptography).
 | Metric | Single-Cycle | Pipelined | Out-of-Order (Silicore) |
| :--- | :--- | :--- | :--- |
| **Clock Freq** | 27.78 MHz | 82.99 MHz | **62.89 MHz** |
| **Throughput (BM5)** | 27.7 MIPS | 53.9 MIPS | **31.9 MIPS*** |
| **Avg Speedup** | 1.0x | 2.21x | **High IPC Efficiency** |

While the OOO design operates at a lower frequency due to logic complexity, it achieves significantly higher pipeline utilization and ILP for complex workloads.
