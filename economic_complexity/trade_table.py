#!/usr/bin/env python 3.83
# -*-coding:utf-8 -*-
# @Author  : Shuang Song
# @Contact   : SongshGeo@gmail.com
# GitHub   : https://github.com/SongshGeo
# Research Gate: https://www.researchgate.net/profile/Song_Shuang9

from pandas.core.base import DataError
from genepy_index import genepy_index
from typing import Optional
from numpy.matrixlib import matrix
import pandas as pd
from pandas import DataFrame
import numpy as np


class TradeTable(DataFrame):
    """
    为了方便分析地区/贸易表，创建一个继承自DataFrame的类
    """

    def data_validation(self):
        """
        检验数据的可行性：
        """
        pass

    def get_rca_matrix(self):
        """
        计算RCA矩阵，将贸易量与总贸易量相对比
        """
        up = self / self.sum()
        bottom = self.sum(axis=1) / self.sum().sum()
        rca_matrix = pd.DataFrame(index=self.index)
        for col in self:
            rca_matrix[col] = up[col] / bottom
        rca_matrix = rca_matrix.dropna(how='any', axis=0)
        return rca_matrix

    def get_bool_matrix(self):
        """
        利用RCA矩阵生成出口地区-出口商品的0-1矩阵
        """
        matrix = self.get_rca_matrix()
        index, columns = matrix.index, matrix.columns
        matrix[matrix < 1] = 0
        matrix[matrix >= 1] = 1
        return pd.DataFrame(matrix, index=index, columns=columns).astype(int)

    def calculate_genepy_index(self):
        """
        利用出口地区-出口商品的0-1矩阵，计算区域的经济复杂度指标
        """
        from trade_table import genepy_index
        matrix = self.get_bool_matrix()
        if matrix.shape[0] <= 1:
            raise DataError("No data in the bool matrix.")
        index = genepy_index(matrix)[1]
        return pd.Series(index.flatten(), index=matrix.index)
