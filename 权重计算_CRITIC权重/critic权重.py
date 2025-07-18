# -*- coding: utf-8 -*-
"""
Created on Sun Oct 17 09:53:05 2021

@author: DELL
"""

import numpy as np
import pandas as pd
import matplotlib as mpl
import seaborn as sns
sns.set_style("whitegrid")
mpl.rcParams['font.sans-serif'] = ['SimHei']  # 指定默认字体
#输入数据
data1 = pd.read_excel("指标.xlsx",header=0,usecols=range(1,7))
data2 = data1.values
def critic(X):
    n,m = X.shape
    #X[:,2] = min_best(X[:,2])  # 自己的数据根据实际情况
    Z = standard(X)  # 标准化X，去量纲
    R = np.array(pd.DataFrame(Z).corr())
    delta = np.zeros(m)
    c = np.zeros(m)
    for j in range(m):
        delta[j] = Z[:,j].std()
        c[j] = R.shape[0] - R[:,j].sum()
    C = delta * c
    w = C/sum(C)
    return np.round(w,4)

def min_best(X):
    for i in range(len(X)):
        X[i] = max(X)-X[i]
    return X

def standard(X):
    xmin = X.min(axis=0)
    xmax = X.max(axis=0)
    xmaxmin = xmax-xmin
    n, m = X.shape
    for i in range(n):
        for j in range(m):
            X[i,j] = (X[i,j]-xmin[j])/xmaxmin[j]
    return X

if __name__ == '__main__':
    X=data2

    print(critic(X))
