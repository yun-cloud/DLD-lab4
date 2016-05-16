# WARNING!!!
broken when `make syn` 

guessed reason: the circuit **latch**

---
# DLD-lab4 
## Greatest Common divisor (32-bit)

GCD by verilog using sub(from ALU)

component:
* divider (32-bit)
* suber(use a ALU) (64-bit)

### divider(32-bit):
* input: clk, start, dividend, divisor
* output: quotient, remainder, done

1. fill dividend and divisor to 64-bit, and left shift divisor 32 bits
2. right shift divisor for 1 bit
3. left shift quotient for 1 bit
4. compare dividend and divisor
5. `if dividend > divisor, quotient = quotient + 1, dividend = dividend - divisor`
6. and keep doing step2 ~ step5 for 32 times(so use 32 states, 5-bit)
7. pick rest dividend to be remainder, `remainder = dividend[31:0]`

### GCD(32-bit)
* input: clk, reset, start, A, B
* output: done, result, ERROR

ASM(Algorithm State Machine)
```python
# Pseudo Code use Python
def gcd(a,b):
    if a == 0 or b == 0:
        return -1 # means ERROR
    dividend = max(a,b)
    divisor  = min(a,b)
    while divisor not in [0,1]:
        quotient  = dividend // divisor;
        remainder = dividend %  divisor;
        dividend  = divisor
        divisor   = remainder
    if divisor == 1:
        # Coprime
        return 1
    return dividend
```

![Flow Chart](https://github.com/yun-cloud/DLD-lab4/blob/master/GCD_FlowChart.png)

