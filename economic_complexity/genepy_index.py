#!/usr/bin/env python 3.83
# -*-coding:utf-8 -*-
# @Author  : Shuang Song
# @Contact   : SongshGeo@gmail.com
# GitHub   : https://github.com/SongshGeo
# Research Gate: https://www.researchgate.net/profile/Song_Shuang9

def genepy_index(matrix, how='row'):
    """
    利用国家-产品贸易矩阵，计算经济复杂度指数。
    matrix: 一个矩阵，行和列可以是xx个区域分别在xx个产品的贸易进出量
    how: 是根据行来计算，还是决定列来计算
    """
    
    import numpy as np
    
    matrix = np.asmatrix(matrix)
    kc = matrix.sum(axis=1)
    rw = matrix / kc
    kp_1 = rw.sum(axis=0)
    den = np.dot(kc, kp_1)
    w = matrix / den
    
    # countries
    if how == 'row':
        p = w * w.T
    elif how == 'columns':
        p = w.T * w

    # 对角线元素设置为 0
    i = [range(len(p))]
    p[i, i] = 0

    evalues, evectors = np.linalg.eig(p)

    order_eig = np.lexsort((np.arange(len(evalues)), abs(evalues)))[::-1]  # 从大到小

    evectors = evectors[:, order_eig]
    evalues = evalues[order_eig]
    
    e = evectors[:, :2]
    theta = evalues[:2].reshape(2, 1)
    index = np.square(np.dot(np.square(e), theta)) + 2 * np.square(e) * np.square(theta)
    return np.array(e), np.array(index)

