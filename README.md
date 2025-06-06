# UART_Protocol
FSM-based UART implementation in Verilog with testbenches and simulation

Description:
This project implements a UART Transmitter and Receiver in Verilog using Finite State Machines (FSMs). It is intended to simulate a full UART loopback system, where transmitted data is looped back into the receiver.

Files Included:
uart_tx.v : FSM-based UART transmitter module
uart_rx.v : FSM-based UART receiver module
uart_top.v : Top-level module connecting transmitter and receiver
tb_uart_loopback.v : Testbench for the top module to simulate UART communication

Parameters:
Clock Frequency: 50 MHz
Baud Rate: 9600 bps

Features:
Start, data (8 bits), and stop bits transmission
Fully synchronous state-based control
Loopback simulation for end-to-end testing
FSM for both TX and RX

FSM States:-
1. UART Transmitter:
IDLE
START_BIT
DATA_BITS
STOP_BIT
CLEANUP

2. UART Receiver:
IDLE
START_BIT
DATA_BITS
STOP_BIT
DONE

Simulation:
Use Vivado to simulate the project:
Add all Verilog files into the project
Set tb_uart_loopback.v as the top module for simulation
Run behavioral simulation
Observe waveform to verify transmission and reception
