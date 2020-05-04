#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Oct  5 11:49:24 2018

@author: jingfang
jingfang@pik-potsdam.de
"""

import numpy as np
import scipy.spatial.distance as dist

N_node = 105  # 多少个时间序列（估计是105个pix？？）
Length = 365  # 每年的长度

DATA = np.loadtxt('NINO34_ERA5.ano')
L = int(len(DATA)/N_node)  # 这里我作了修改，增加了 int()，是41年总计的天数（去掉了闰年多的一天）
DATA = np.reshape(DATA, (N_node, L))  # 将数据重整 成为 N个时间序列，每个长度为L的形式

##################################################################
months = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]  # 每个月的天数
smonth = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]  # 每个月的累计天数
sds = np.arange(0, 365, 10)  # 这个sds是干什么用的？


nino3 = []  # 用来储存厄尔尼诺的图幅
latx = [-2.5, 2.5]  # 纬度范围
lonx = np.arange(215, 270, 5)  # 经度范围
n = 0
for i in range(73):  # 73和144分别是什么数字来的？
    ix = 90-i*2.5
    for j in range(144):
        jx=j*2.5
        n+=1
        if (ix in latx) and (jx in lonx):
            nino3.append(n-1)


nino4=[]
latx=[-2.5,2.5]
lonx=np.arange(160,211,5)
n=0
for i in range(73):
    ix=90-i*2.5
    for j in range(144):
        jx=j*2.5
        n+=1
        if(ix in latx and jx in lonx):
            nino4.append(n-1)


tron=[]
latx=[0]
lonx=np.arange(120,280,7.5)
n=0
for i in range(73):
    ix=90-i*2.5
    for j in range(144):
        jx=j*2.5
        n+=1
        if (ix in latx) and (jx in lonx):
            tron.append(n-1)

nino=[]
latx=[0]
lonx=np.arange(195,280,7.5)
n=0
for i in range(73):
    ix=90-i*2.5
    for j in range(144):
        jx=j*2.5
        n+=1
        if(ix in latx and jx in lonx):
            nino.append(n-1)
        if(ix==-2.5) and (jx==112.5 or jx==277.5):
            nino.append(n-1)

Nnode=[]
n=0
for i in range(21):        
    for j in range(101):
        n+=1
        if(i%10==0 and j%10==0):
            Nnode.append(n-1)



latx=[1,3]
lonx=np.arange(0,21,2)
#
Nnode=[]
n=0
for i in range(5):
    for j in range(21):
        n+=1
        if(i in latx and j in lonx):
            Nnode.append(n-1)
#latx=[2]
#lonx=np.arange(0,21,3)          
#Nnode=[]
#n=0
#for i in range(5):
#    for j in range(21):
#        n+=1
#        if(i in latx and j in lonx):
#            Nnode.append(n-1)          
#Nnode=np.arange(0,N_node,1)
ey=[1986,1991,1994,1997,2002,2004,2006,2009,2014,2018,2019,2020]

def Sample_En(outfile):
    startpoint=0
    rrrr=[]
    for no1 in range(len(DATA)):
        rrrr.append(times*np.std(DATA[no1][15:]))
    constr=np.mean(rrrr)
    for year in range(1983,2021):
        print(year)
    
        for mon in range(1):
            #
            #startpoint+=months[mon]
            #startpoint=(year-1979)*365+smonth[mon]        
            startpoint=(year-1979)*365+smonth[mon]

            if(startpoint>L):
                    break                
            sA = 0.
            sB = 0.
            cA = 0.
            cB = 0.
            for no1 in range(len(Nnode)):
                node1=Nnode[no1]
                dataV = DATA[node1][startpoint-Length:startpoint]
                #stdv=np.std(dataV)
                #dataV=[i/stdv for i in dataV]
                r = times * np.std(dataV)
                #r = times * np.std(DATA[node1])
                #r=constr
                tVecs30 = np.zeros((LL1, m))
                for j in range(tVecs30.shape[0]):
                      tVecs30[j, :] = dataV[j*sigma:j*sigma + tVecs30.shape[1]]
                tVecs45 = np.zeros((LL2, m+jump))
                for j in range(tVecs45.shape[0]):
                      tVecs45[j, :] = dataV[j*sigma:j*sigma + tVecs45.shape[1]]           
                
                for j in range(len(tVecs30) - 1):
                    for k in range(j+1,len(tVecs30)):
                        edis=dist.euclidean(tVecs30[j], tVecs30[k])
                        if(edis<r):
                            sA+=1
                for j in range(len(tVecs45) - 1):
                    for k in range(j+1,len(tVecs45)):
                        edis=dist.euclidean(tVecs45[j], tVecs45[k])
                        if(edis<r):
                            sB+=1
                for no2 in range(no1+1,len(Nnode)):
                    node2=Nnode[no2]
                    dataU = DATA[node2][startpoint-Length:startpoint]
                    #stdu=np.std(dataU)
                    #dataU=[i/stdu for i in dataU]
                    r = max(times * np.std(dataV),times * np.std(dataU))
                    #r = max(times * np.std(DATA[node1]),times*np.std(DATA[node2]))
                    #r=constr
                    tUecs30 = np.zeros((LL1, m))
                    for j in range(tUecs30.shape[0]):
                          tUecs30[j, :] = dataU[j*sigma:j*sigma + tUecs30.shape[1]]
                    tUecs45 = np.zeros((LL2, m+jump))
                    for j in range(tUecs45.shape[0]):
                          tUecs45[j, :] = dataU[j*sigma:j*sigma + tUecs45.shape[1]]  
                    
                    for j in range(len(tVecs30)):
                        for k in range(len(tUecs30)):
                            edis=dist.euclidean(tVecs30[j], tUecs30[k])
                            if(edis<r):
                                cA+=1
                    for j in range(len(tUecs45)):
                        for k in range(len(tUecs45)):
                            edis=dist.euclidean(tVecs45[j], tUecs45[k])
                            if(edis<r):
                                cB+=1                                                                                       

                                                                                                    
        
           # print m,sigma,times,year+1+mon/12.,np.log(sA/sB),np.log(cA/cB),np.log((cA+sA)/(cB+sB))
            if(sB==0):
                a=-100
            else:
                a=np.log(sA/sB)
            if(cB==0):
                b=-100
            else:
                b=np.log(cA/cB)
            if(sB+cB==0):
                c=-100
            else:
                c=np.log((cA+sA)/(cB+sB))
           # print year
            outfile.write('%.6f %.6f %.6f %.6f\n' %(year+mon/12.,a,b,c))
            outfile.flush()
           # print year+1,np.log((cA+sA)/(cB+sB))
    outfile.close()
            #for node2 in range(node1,N_node):


            
                
            

if __name__=="__main__":
    m =30
    sigma =30
    jump = sigma
    times=8
    nnn= int((Length-(m+jump))/sigma+1)

    Nnode=Nnode
    for kkk in range(nnn):
        LL1=nnn-kkk
        LL2=LL1
        for times in range(20):
          #if(times not in [7,8]):
            print(kkk, times)
        
            #times=times*0.1
        
            outfile=open("ERA5_SampEn_nino34_5D_"+str(m)+""+str(sigma)+""+str(jump)+""+str(times)+"_"+str(kkk)+"",'wb')
            Sample_En(outfile)
