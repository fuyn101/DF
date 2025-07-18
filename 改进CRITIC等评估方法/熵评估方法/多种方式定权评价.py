# -*- coding: utf-8 -*-
"""
Created on Tue Apr 12 18:02:18 2022

@author: 22684
"""
#%%                                                熵权法

import pandas as pd
import numpy as np
data=pd.read_excel("D:\\lunwen\\结构加功能.xlsx", sheet_name=0,header=0,index_col=0)
m,n=data.shape  #获取行数m和列数n
#熵权法计算
def Y_ij(data1):   #矩阵标准化(min-max标准化)
    for i in data1.columns:
       print(i)
       for j in range(n+1):
           #if i == str(f'X{j}负'):  #负向指标
           if i == str('结构洞约束'):  #负向指标
             
               data1[i]=(np.max(data1[i])-data1[i])/(np.max(data1[i])-np.min(data1[i]))
           else:   #正向指标
              
               data1[i]=(data1[i]-np.min(data1[i]))/(np.max(data1[i])-np.min(data1[i]))
    return data1
Y_ij=Y_ij(data)  #标准化矩阵
None_ij = [[None] * n for i in range(m)]  #新建空矩阵
def E_j(data2):  #计算熵值
    data2 = np.array(data2)
    E = np.array(None_ij)
    for i in range(m):
        for j in range(n):
            if data2[i][j] == 0:
                e_ij = 0.0
            else:
                P_ij = data2[i][j] / data2.sum(axis=0)[j]  #计算比重
                e_ij = (-1 / np.log(m)) * P_ij * np.log(P_ij)
            E[i][j] = e_ij
    E_j=E.sum(axis=0)
    return E_j
E_j = E_j(Y_ij)  #熵值
G_j = 1 - E_j    #计算差异系数
W_j = G_j / sum(G_j)   #计算权重
print(W_j)#[0.023441692167666887 0.37051652086386283 0.06999149555638065  0.3705282192763032 0.16552207213578646]
WW= pd.Series(W_j, index=data.columns, name='指标权重')
print(WW)
#Y_ij.to_excel("D:\\Study\\Y_ij.xls",sheet_name='Y_ij') #标准化矩阵导出至Excel
#WW.to_excel("D:\\Study\\WW.xls",sheet_name='WW')  #指标权重导出至Excel

#TOPSIS计算
Y_ij = np.array(Y_ij)  #Y_ij为标准化矩阵
Z_ij = np.array(None_ij)  #空矩阵
for i in range(m):
    for j in range(n):
        Z_ij[i][j]=Y_ij[i][j]*W_j[j]  #计算加权标准化矩阵Z_ij
Imax_j=Z_ij.max(axis=0)  #最优解
Imin_j=Z_ij.min(axis=0)  #最劣解
Dmax_ij = np.array(None_ij)  #空矩阵
Dmin_ij = np.array(None_ij)  #空矩阵
for i in range(m):
    for j in range(n):
        Dmax_ij[i][j] = (Imax_j[j] - Z_ij[i][j]) ** 2
        Dmin_ij[i][j] = (Imin_j[j] - Z_ij[i][j]) ** 2
Dmax_i=Dmax_ij.sum(axis=1)**0.5  #最优解欧氏距离
Dmin_i=Dmin_ij.sum(axis=1)**0.5  #最劣解欧氏距离
C_i=Dmin_i/(Dmax_i+Dmin_i)  #综合评价值
Dmax_i= pd.Series(Dmax_i, index=data.index, name='最优解')
Dmin_i= pd.Series(Dmin_i, index=data.index, name='最劣解')
C_i= pd.Series(C_i, index=data.index, name='综合评价值')
print(C_i)
#pd.concat([Dmax_i, Dmin_i, C_i]).to_excel("D:\\Buhanrank\\C_i.xls") #最优解、最劣解、综合评价值导出至Excel
#pd.concat([C_i]).to_excel("D:\\lunwen\\熵权topsis综合评价值.xls") #最优解、最劣解、综合评价值导出至Excel






#%%                                                     CRITIC法
#完整代码
#导入相关库
import pandas as pd
import numpy as np
#导入数据
data=pd.read_excel('D:\\lunwen\\结构加功能.xlsx')
label_need=data.keys()[1:]
data1=data[label_need].values
#查看行数和列数
data2 = data1
[m,n]=data2.shape
#负向指标标准化
index=[2] #负向指标位置,注意python是从0开始计数，对应位置也要相应减1
for j in index:
    print('负向指标数据',data1[:,j])
    d_max=max(data1[:,j])
    d_min=min(data1[:,j])
    data2[:,j]=(d_max-data1[:,j])/(d_max-d_min)
# 正向指标标准化
#正向指标位置
index_all=np.arange(n)
index=np.delete(index_all,index) 
for j in index:
    print('正向指标数据',data1[:,j])
    d_max=max(data1[:,j])
    d_min=min(data1[:,j])
    data2[:,j]=(data1[:,j]-d_min)/(d_max-d_min)
#对比性
the=np.std(data2,axis=0)
print('各指标标准差:',the)#标准差
PJ=np.mean(data2,axis=0)
print('各指标平均值:',PJ)#平均值
BYXS=the/PJ
print('各指标变异系数:',BYXS)#变异系数
#矛盾性
data3=list(map(list,zip(*data2))) #矩阵转置

r=np.corrcoef(data3)   #求皮尔逊相关系数
f=np.sum(1-r,axis=1)
print('各指标相关冲突性:',f)
#信息承载量
c=the*f
#计算权重
w=c/sum(c)
print('未改进的CRITIC权重:',w)#CRITIC权重
GJCRITIC=BYXS*f
GJDQ=GJCRITIC/sum(GJCRITIC)
print('改进CRITIC指标权重:',GJDQ)#改进CRITIC权重
#未改进的CRITIC权重: [0.25406762 0.12726998 0.17933529 0.35667724 0.08264987]
#改进CRITIC指标权重: [0.06633426 0.38849006 0.02602513 0.25377576 0.26537479]
#计算得分
s=np.dot(data2,w)
#Score=100*s/max(s) #百分制
Score=s/max(s)
#print(Score)
print(s)
#for i in range(0,len(Score)):
   #print(f"{data['FID'][i]}银行百分制评分为：{Score[i]}")  
#s=pd.Series(s, index=data.index, name='综合评价值')
#pd.concat([s]).to_excel("D:\\lunwen\\线性加权.xls",sheet_name='topsis综合贴进度')
   
     
#%%                                                  TOPSIS法(改进定权)综合评价
import pandas as pd
import numpy as np
data=pd.read_excel('D:\\lunwen\\结构加功能.xlsx', sheet_name=0,header=0,index_col=0)
m,n=data.shape  #获取行数m和列数n
print('行列：',m,n)
#熵权法计算
def Y_ij(data1):   #矩阵标准化(min-max标准化)
    for i in data1.columns:
       for j in range(n+1):
           if i == str('结构洞约束'):  #负向指标
               data1[i]=(np.max(data1[i])-data1[i])/(np.max(data1[i])-np.min(data1[i]))
           else:   #正向指标
               data1[i]=(data1[i]-np.min(data1[i]))/(np.max(data1[i])-np.min(data1[i]))
    return data1
Y_ij=Y_ij(data)  #标准化矩阵
#print(Y_ij)
None_ij = [[None] * n for i in range(m)]  #新建空矩阵


#Y_ij.to_excel("D:\\xuemei\\Y_ij沧州数据标准化.xls",sheet_name='标准化') #标准化矩阵导出至Excel
#WW.to_excel("D:\\Study\\WW.xls",sheet_name='WW')  #指标权重导出至Excel


#TOPSIS计算(改进定权)
Y_ij = np.array(Y_ij)  #Y_ij为标准化矩阵
Z_ij = np.array(None_ij)  #空矩阵
for i in range(m):
    for j in range(n):
        Z_ij[i][j]=Y_ij[i][j]*GJDQ[j]  #计算加权标准化矩阵Z_ij
        #改进权重区别在这里
        #print(W_j[j])
Imax_j=Z_ij.max(axis=0)  #最优解
Imin_j=Z_ij.min(axis=0)  #最劣解
Dmax_ij = np.array(None_ij)  #空矩阵
Dmin_ij = np.array(None_ij)  #空矩阵
for i in range(m):
    for j in range(n):
        Dmax_ij[i][j] = (Imax_j[j] - Z_ij[i][j]) ** 2
        Dmin_ij[i][j] = (Imin_j[j] - Z_ij[i][j]) ** 2
Dmax_i=Dmax_ij.sum(axis=1)**0.5  #最优解欧氏距离
Dmin_i=Dmin_ij.sum(axis=1)**0.5  #最劣解欧氏距离
C_i=Dmin_i/(Dmax_i+Dmin_i)  #综合评价值
Dmax_i= pd.Series(Dmax_i, index=data.index, name='最优解')
Dmin_i= pd.Series(Dmin_i, index=data.index, name='最劣解')
C_i= pd.Series(C_i, index=data.index, name='综合评价值')
#print(C_i)
#print("与最优解的距离",Dmax_i)
#print("与最劣解的距离",Dmin_i)
print("未改进TOPSIS综合贴进度",C_i)
#pd.concat([Dmax_i, Dmin_i, C_i]).to_excel("D:\\CRITIC\\Y_ij包括最优解最劣解距离贴进度.xls",sheet_name='topsis贴进度包括最优解最劣解距离、最后的是综合贴进度') #最优解、最劣解、综合评价值导出至Excel
#pd.concat([C_i]).to_excel("D:\\lunwen\\改进critic综合贴进度.xls",sheet_name='topsis综合贴进度') #最优解、最劣解、综合评价值导出至Excel




#%%
                                              #TOPSIS计算(未改进定权)
import pandas as pd
import numpy as np
data=pd.read_excel('D:\\lunwen\\结构加功能.xlsx', sheet_name=0,header=0,index_col=0)
m,n=data.shape  #获取行数m和列数n
print('行列：',m,n)
#熵权法计算
def Y_ij(data1):   #矩阵标准化(min-max标准化)
    for i in data1.columns:
       for j in range(n+1):
           if i == str('结构洞约束'):  #负向指标
               data1[i]=(np.max(data1[i])-data1[i])/(np.max(data1[i])-np.min(data1[i]))
           else:   #正向指标
               data1[i]=(data1[i]-np.min(data1[i]))/(np.max(data1[i])-np.min(data1[i]))
    return data1
Y_ij=Y_ij(data)  #标准化矩阵
#print(Y_ij)
None_ij = [[None] * n for i in range(m)]  #新建空矩阵


#Y_ij.to_excel("D:\\xuemei\\Y_ij沧州数据标准化.xls",sheet_name='标准化') #标准化矩阵导出至Excel
#WW.to_excel("D:\\Study\\WW.xls",sheet_name='WW')  #指标权重导出至Excel


#TOPSIS计算(改进定权)
Y_ij = np.array(Y_ij)  #Y_ij为标准化矩阵
Z_ij = np.array(None_ij)  #空矩阵
for i in range(m):
    for j in range(n):
        Z_ij[i][j]=Y_ij[i][j]*w[j]  #计算加权标准化矩阵Z_ij
        #改进权重区别在这里
        #print(W_j[j])
Imax_j=Z_ij.max(axis=0)  #最优解
Imin_j=Z_ij.min(axis=0)  #最劣解
Dmax_ij = np.array(None_ij)  #空矩阵
Dmin_ij = np.array(None_ij)  #空矩阵
for i in range(m):
    for j in range(n):
        Dmax_ij[i][j] = (Imax_j[j] - Z_ij[i][j]) ** 2
        Dmin_ij[i][j] = (Imin_j[j] - Z_ij[i][j]) ** 2
Dmax_i=Dmax_ij.sum(axis=1)**0.5  #最优解欧氏距离
Dmin_i=Dmin_ij.sum(axis=1)**0.5  #最劣解欧氏距离
C_i=Dmin_i/(Dmax_i+Dmin_i)  #综合评价值
Dmax_i= pd.Series(Dmax_i, index=data.index, name='最优解')
Dmin_i= pd.Series(Dmin_i, index=data.index, name='最劣解')
C_i= pd.Series(C_i, index=data.index, name='综合评价值')
#print(C_i)
#print("与最优解的距离",Dmax_i)
#print("与最劣解的距离",Dmin_i)
print("未改进TOPSIS综合贴进度",C_i)
#pd.concat([Dmax_i, Dmin_i, C_i]).to_excel("D:\\CRITIC\\Y_ij包括最优解最劣解距离贴进度.xls",sheet_name='topsis贴进度包括最优解最劣解距离、最后的是综合贴进度') #最优解、最劣解、综合评价值导出至Excel
#pd.concat([C_i]).to_excel("D:\\lunwen\\未改进critic综合贴进度.xls",sheet_name='topsis综合贴进度') #最优解、最劣解、综合评价值导出至Excel