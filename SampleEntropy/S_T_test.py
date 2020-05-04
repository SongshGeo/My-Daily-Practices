#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun Mar  1 20:39:02 2020

@author: jingfang
jingfang@pik-potsdam.de
"""

import numpy as np
import matplotlib.pyplot as plt
import scipy.spatial.distance as dist



def Sample_En(Nnode,l,DATA,startpoint,times,m,sigma,jump,LL1,LL2):                  
            sA = 0.
            sB = 0.
            cA = 0.
            cB = 0.
#            rrrr=[]
#            for no1 in range(len(DATA)):
#                rrrr.append(times*np.std(DATA[no1]))
#            constr=np.mean(rrrr)
            for no1 in range(len(Nnode)):
                
                node1=Nnode[no1]
                dataV = DATA[node1][startpoint-l:startpoint]
                r = times * np.std(dataV)
                #r = constr
                #print np.std(dataV)*times, r
                tVecs30 = np.zeros((LL1, m))
                for j in range(tVecs30.shape[0]):
                      #print len(dataV),node1,j,sigma,tVecs30
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
                    dataU = DATA[node2][startpoint-l:startpoint]
                    r = max(times * np.std(dataV),times * np.std(dataU))
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
            if(cB+sB!=0):
                sn=np.log((cA+sA)/(cB+sB))
            else:
                sn=-10
            #print sn                                                                                    
            return sn                

def space():
 
  path='...'

  Length = 365
  m =30
  sigma = 15
  jump = sigma
  N_node=10512
  NN=22
  nnn = (Length-(m+jump))/sigma+1

    #r=6.0
    ##############################################DATA################
  DATA = np.loadtxt(path+'global_ERA5.ano')
  L = len(DATA)/N_node
  DATA = np.reshape(DATA,(N_node,L))
  Nnode=[]
    
  for i in range(N_node):
        if (np.where(np.isnan(DATA[i])))[0].shape[0]: 
            continue
            # print i
        else:
            Nnode.append(i)
            
  Nnode=np.array(Nnode)
  outfile1=open(path+'Accuracy_space_era5_3015','w')
  for kkk in range(nnn):
    LL1=nnn-kkk
    LL2=LL1
    
    
    months=[0,31,28,31,30,31,30,31,31,30,31,30,31]
    smonth=[0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]
    sds=np.arange(0,365,10)   
    l=Length
    NN=22
    for times in range(20):

        n=0
        aa=[]
        bb=[]
        m1=0.
        m2=0.
        xt1=0.
        for xt in range(1000):
          print xt
          nnode=[int(i) for i in Nnode]
          x1=np.random.choice(nnode)
          x0=x1-0
          x2=x1+1
          if(x0 in nnode and x2 in nnode):
            xt1+=1
            noderan=[]
            nn=0
            ax=0
            for kk in range(100):
                
                bx=np.random.choice(nnode)
                if(ax!=bx):
                    ax=bx
                    noderan.append(ax)
                    nn+=1
                    if(nn==NN):
                        break
           
            x1=np.random.choice(nnode)
#       
            noderan=[]
            nn=0
            ax=0
            for kk in range(100):
                
                bx=np.random.choice(nnode)
                if(ax!=bx):
                    ax=bx
                    noderan.append(ax)
                    nn+=1
                    if(nn==NN):
                        break
           
            zzz=[x0,x1,x2]
            nodenei=[]
            for kk in range(NN):
                nodenei.append(np.random.choice(zzz))
        
            ys=np.arange(1983,2018,1)
            year=np.random.choice(ys)
            startpoint=(year-1979)*365
#            nodenei=[x0,x1,x2]
#            noderan=[y0,y1,y2]
            snei=Sample_En(nodenei,Length,DATA,startpoint,times,m,sigma,jump,LL1,LL2)
            sran=Sample_En(noderan,Length,DATA,startpoint,times,m,sigma,jump,LL1,LL2)
            if(snei>0 and sran>0):
                n+=1
                print xt,snei,sran
                aa.append(snei)
                bb.append(sran)
          
                if(snei<sran):
                    m1+=1

           
        if(n==0):
            n=1
        #outfile.flush()
        m2=n*1.0
        m3=xt+1.0
        outfile1.write('%d %d %.6f %.6f\n'%(kkk,times,m1/m2,m1/m3))
        outfile1.flush()
  outfile1.close()



def time():
  path='...'

  N_node = 105#2664#10512#10512#325
 
  Length = 365
  m =30
  sigma = 15
  jump = sigma
  nnn= (Length-(m+jump))/sigma+1
  outfile1=open(path+'Accuracy_time_era5_3015','w')
  data = np.loadtxt(path+'nino34_ERA5.ano')
 # data=np.loadtxt(path1+'input4MIP_OMIP_JRA55_nino34.ano')
  for kk in range(10,15):
    LL1=nnn-kk
    LL2=LL1

    
    L = len(data)/N_node
    DATA = np.reshape(data,(N_node,L))
    stdx=[]
    meanx=[]
    for i in range(N_node):
        stdx.append(np.std(DATA[i]))
        meanx.append(np.mean(DATA[i]))
    consts=np.mean(stdx)
    constm=np.mean(meanx)
  
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
                
                
                
 
    for times in range(20):
        
       # times=3
       # outfile1=open(path+"n_accuracy_"+str(m)+""+str(sigma)+""+str(jump)+""+str(times)+"",'w')
         # outfile=open(path+"z"+str(kk)+"SampEn_5D_"+str(m)+""+str(sigma)+""+str(jump)+""+str(times)+"_neighber2_random3_"+str(n)+"",'wb')
          n=0
          aa=[]
          bb=[]
          m1=0.
          m2=0.
        

          for xt in range(100):


            
            ys=np.arange(1984,2019,1)
            #Snp.random.seed(xt)
            year=np.random.choice(ys)
            startpoint=(year-1979)*365
            funcx=[constm+consts*np.sin(40*2*np.pi*i/L) for i in range(L)]
            funcx=[consts*(np.random.choice(L)/(L*1.0)-0.5) for i in range(L)]
         
            DATA1=[]
            for i in range(N_node):
                y=[DATA[i][j]+funcx[j] for j in range(L)]
                DATA1.append(y)
                
#            nodenei=[x0,x1,x2]
#            noderan=[y0,y1,y2]
            stdx1=[]
            for i in range(N_node):
                stdx1.append(np.std(DATA1[i]))
            consts1=np.mean(stdx1)
            std=0.5*(consts1+consts)
            constr=times*std
            snei=Sample_En(Nnode,Length,DATA,startpoint,times,m,sigma,jump,LL1,LL2)
            sran=Sample_En(Nnode,Length,DATA1,startpoint,times,m,sigma,jump,LL1,LL2)
            if(snei>0 and sran>0 and consts<consts1):
                n+=1
                print m1,n,xt,snei,sran
                aa.append(snei)
                bb.append(sran)
                if(snei<sran):
                    m1+=1
                m2+=1

          if(n<1):
              n=1
          m2=n*1.0
          m3=xt+1.0
         
          outfile1.write('%d %d %.6f %.6f\n'%(kk,times,m1/m2,m1/m3))
          outfile1.flush()
  outfile1.close()
