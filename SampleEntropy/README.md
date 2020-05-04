# Test method of System Sample Entropy
original paper: copyright by Dr. Jingfang Fan, jingfang@pik-potsdam.de
The python codes for our paper: 
Complexity-based approach for El Niño magnitude forecasting before the spring predictability barrier
https://www.pnas.org/content/117/1/177.short

- (1) readdata.py is used to data download and preprocessing. 
- (2) SampEn.py is used to calculated the System Sample Entropy.
- (3) S_T_test.py is used to Parameters Determination for the SysSampEn.

The python is based on 3.7

## Introduction of SysSampEn:
SysSampEn is a measure of the system complexity, 
to quantify simultaneously the mean temporal disorder degree of all the time series in a comple system,
as well as the asynchrony among them.

$ SysSampEn(m,p,l_{eff},\gamma) = -log(A/B) $
