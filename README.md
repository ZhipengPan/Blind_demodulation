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
    - step1: 下变频到基带，函数`func_down_freq_cons`；
    - step2: 匹配滤波；
    - step3: 下采样，采样率变为符号速率的4倍，函数`func_downsample_cons`；
    - step4: 基于FFT的载波粗同步，函数`func_coarse_carrierSync_cons` ；
    - step5: 基于gardner的符号定时同步，函数`func_gardner_cons`；
    - step6: 基于Costas环的载波精同步，函数`func_carrierSync_Costas_cons`；
    - step7:基于判决反馈LMS算法和CMA算法的盲均衡，函数`func_DDLMS_CMA_cons`。

## 整体结构
![整体结构](https://github.com/ZhipengPan/Blind_demodulation/blob/main/figure/%E4%B8%BB%E4%BD%93%E6%9E%B6%E6%9E%84.png)

## 结果展示
1. 构造波形图与语谱图：
![16QAM波形图](https://github.com/ZhipengPan/Blind_demodulation/blob/main/figure/16QAM_波形.PNG)

![16QAM语谱图(https://github.com/ZhipengPan/Blind_demodulation/blob/main/figure/16QAM_语谱图.PNG)

2. 解调星座图
![16QAM解调后星座图](https://github.com/ZhipengPan/Blind_demodulation/blob/main/figure/result_16QAM.pdf)