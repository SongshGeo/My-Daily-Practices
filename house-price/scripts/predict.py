#!/usr/bin/env python 3.83
# -*-coding:utf-8 -*-
# @Author  : Shuang Song
# @Contact   : SongshGeo@gmail.com
# GitHub   : https://github.com/SongshGeo
# Research Gate: https://www.researchgate.net/profile/Song_Shuang9

from utility import *
import pickle

cur_path = os.path.dirname(os.path.realpath(__file__))
path2=os.path.dirname(cur_path)  # 获取文件夹的上一级目录路径，即 house-price
params = YamlLoad().load('predict')
input_model_path = path2+params['input_model']
test = pd.read_csv(path2+params['input_dataset'], index_col=0)
output_prediction_path = path2+params['output_prediction']

input_train_features = path2+params['input_train_features']
input_test_features = path2+params['input_test_features']

with open(input_train_features, 'rb') as f:
    train_features = pickle.load(f)

with open(input_test_features, 'rb') as f:
    test_features = pickle.load(f)

features = list(set(train_features) & set(test_features))

with open(input_model_path, 'rb') as f:
    lr = pickle.load(f)


prediction = lr.predict(test[features])
print(prediction.shape)
prediction_result = pd.DataFrame({
    'Id': test['Id'].astype(int),
    'SalePrice': prediction[:, 0],
})

prediction_result.to_csv(output_prediction_path, index=False)
