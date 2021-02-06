#!/usr/bin/env python 3.83
# -*-coding:utf-8 -*-
# @Author  : Shuang Song
# @Contact   : SongshGeo@gmail.com
# GitHub   : https://github.com/SongshGeo
# Research Gate: https://www.researchgate.net/profile/Song_Shuang9

# 区分交叉验证和训练用
import pickle
from sklearn.model_selection import KFold
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error

from utility import YamlLoad
import os
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt


cur_path = os.path.dirname(os.path.realpath(__file__))
path2=os.path.dirname(cur_path)  # 获取文件夹的上一级目录路径，即 house-price
params = YamlLoad().load('train')
random_state = params['random_state']
output_model_path = path2+params['output_model_path']
train = pd.read_csv(path2+params['input_dataset'], index_col=0)

input_train_features = path2+params['input_train_features']
input_test_features = path2+params['input_test_features']

with open(input_train_features, 'rb') as f:
    train_features = pickle.load(f)

with open(input_test_features, 'rb') as f:
    test_features = pickle.load(f)

features = list(set(train_features) & set(test_features))

predictor = ['SalePrice']

# 学习曲线
def get_min_rmse_prediction_in_cv(data):
    cv = KFold(shuffle=True, random_state=random_state)
    rmse_train, rmse_test = [], []
    for k, (train_index, test_index) in enumerate(cv.split(data)):
        X_train, y_train = train[features].iloc[train_index, :], train[predictor].iloc[train_index]
        X_test, y_test = train[features].iloc[test_index], train[predictor].iloc[test_index]
        lr = LinearRegression()
        lr.fit(X_train, y_train)
        train_prediction = lr.predict(X_train)
        test_prediction = lr.predict(X_test)
        rmse_train.append(np.sqrt(mean_squared_error(y_train, train_prediction)))
        rmse_test.append(np.sqrt(mean_squared_error(y_test, test_prediction)))
    return min(rmse_train), min(rmse_test)


rmse_trains, rmse_tests = [], []
samples_len = list(range(100, len(train), 100))
for i in samples_len:
    rmse_train, rmse_test = get_min_rmse_prediction_in_cv(train.iloc[:i])
    rmse_tests.append(rmse_test)
    rmse_trains.append(rmse_train)

plt.plot(samples_len, rmse_trains, label='Train')
plt.plot(samples_len, rmse_tests, label='Test')
plt.legend()
plt.xlabel("Size of dataset")
plt.ylabel("RMSE")
plt.title("Learning curve")
plt.show()



def train_model(train_data, features, predictor):
    import pickle
    X_train, y_train = train_data[features], train_data[predictor]
    lr = LinearRegression()
    lr.fit(X_train, y_train)

    with open(output_model_path, 'wb') as f:
        pickle.dump(lr, f)
        print("The model saved in {}.".format(output_model_path))


if __name__ == '__main__':
    train_model(train, features=features, predictor=predictor)
