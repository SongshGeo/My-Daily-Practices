#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
@Author  :   Shuang Song
Beijing Normal University
@Contact :   SongshGeo@Gmail.com
@Time    :   2020/3/18 17:30
"""

import numpy as np
import pandas as pd
import scipy.spatial.distance as dist
GAMMA = 1


def creat_test_data(number, length, mu=0, sigma=0.1, arange=False):
    df_dic = {}
    for n in range(number):
        if arange:
            df_dic[n] = np.arange(1, length+1)
        else:
            df_dic[n] = np.random.normal(mu, sigma, length)
    return pd.DataFrame(df_dic).set_index(np.arange(1, length+1))


def select_sub_records(data, n, m, q):
    length = len(data)
    result = []
    flag = n
    for var in data:
        subsets = []
        k = 0
        while k < flag:
            subset = []
            i = 1
            while (i <= m) and (k*q+m <= length):
                subset.append(data[var][k*q+i])
                i += 1
            subsets.append(subset)
            k += 1
        result.append(np.array(subsets))
    return np.array(result)


def judge_similar(alpha, beta):
    a, b = alpha.std(), beta.std()
    dis = GAMMA * max(a, b)
    eu_dis = dist.euclidean(alpha, beta)
    if eu_dis < dis:
        return True
    else:
        return False


def re_select_records(data, m, p):
    length = len(data)
    q = p
    m = m + p
    flag = (length - m) / p
    return select_sub_records(data, n=flag, m=m, q=q)


def inner_similar(data):
    s = []  # result
    shape = (data.shape[0]*data.shape[1], data.shape[2])
    subsets = np.reshape(data, shape)  # 将三维数组变二维
    for i in range(subsets.shape[0]):
        tmp_list = list(np.arange(subsets.shape[0]))
        tmp_list.remove(i)  # 临时列表使得同样的子数据集不会互相比
        for j in tmp_list:
            subset_a = subsets[i]
            subset_b = subsets[j]
            s.append(judge_similar(subset_a, subset_b))
    print(s)
    return np.array(s)


def system_sample_entropy(data_a, data_b):
    s_a = inner_similar(data_a)
    s_b = inner_similar(data_b)
    print("B数据集一共有{}个pairs，A数据集一共有{}个pairs".format(len(s_b), len(s_a)))
    return -np.log(s_a.sum()/s_b.sum())


if __name__ == '__main__':
    test = creat_test_data(2, 10, arange=True)
    r_b = select_sub_records(test, n=2, q=3, m=5)
    r_a = re_select_records(test, m=5, p=3)
    enthropy = system_sample_entropy(r_a, r_b)

# A和B本身就可能有差很远的pairs的数量区别，怎么办
