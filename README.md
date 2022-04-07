# Blind_demodulation

------
本仓库致力于实现多种调制方式的盲解调【目前仅支持PSK、QAM、APSK调制方式的解调】，后续将继续对常用调制方式的解调算法进行补充。
代码结构如下：
> * main_gen_mod_wave：
仿真生成调制信号波形，目前只添加了AWGN噪声，后续可以根据实际情况继续补充
> * main_ana_carrier_freq:
载频估计
> * main_ana_symbol_rate:
调制速率估计
> * main_blind_demod:
盲解调主程序：

## 整体结构

![整体结构](https://github.com/ZhipengPan/Blind_demodulation/blob/main/figure/主体架构.png)
