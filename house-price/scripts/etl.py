#!/usr/bin/env python 3.83
# -*-coding:utf-8 -*-
# @Author  : Shuang Song
# @Contact   : SongshGeo@gmail.com
# GitHub   : https://github.com/SongshGeo
# Research Gate: https://www.researchgate.net/profile/Song_Shuang9

import pandas as pd
import pdpipe as pdp
import numpy as np

from utility import YamlLoad

import os
cur_path = os.path.dirname(os.path.realpath(__file__))
path2=os.path.dirname(cur_path)  # 获取文件夹的上一级目录路径，即 house-price

params = YamlLoad().load('etl')
# train = pd.read_csv(params['raw_data_file'])
train = pd.read_csv(path2+r"/data/train.csv")

# 根据上述大致划分，对每个变量有一个归类
locations = {
    'MSSubClass': 'house_class_cat',  # 售卖类型，分类
    'MSZoning': 'house_zoning_cat',  # 区位，分类
    'LotFrontage': 'adj_street_frontage_num',  # 与街角相连的长度，数字
    'Street': 'street_cat',  # 街道是石子路还是铺砌的，分类
    'Alley': 'alley_cat',  # 门口小路是石子还是铺砌，分类
    'LandContour': 'land_flatness_cat',  # 土地的平坦类型
    'LandSlope': 'land_slope_cat',  # 土地的坡度
    'Neighborhood': 'neighborhood_cat',  # 街道类型
    'Condition1': 'location_condition_1_cat',  # 区位状况1
    'Condition2': 'location_condition_2_cat',  # 区位状况2
}

config = {
    'LotArea': 'area_num',  # 房屋面积
    'LotShape': 'shape_cat',  # 房屋形状
    'LotConfig': 'config_cat',  # 房屋结构
    'BldgType': 'dwelling_type_cat',  # 户型
    'HouseStyle': 'house_style_cat',  # 房屋风格
    'RoofStyle': 'roof_style_cat',  # 屋顶的风格
    'MasVnrArea': 'masonry_veneer_area_num',  # 隔板面积
    'BsmtFinSF1': 'basement_finish_1_num',  # 完工的基地面积
    'BsmtFinSF2': 'basement_finish_2_num',  # 完工的基地面积
    'BsmtUnfSF': 'unfinished_basement_num',  # 未完工的面积
    'TotalBsmtSF': 'total_basement_num',  # 总面积
    '1stFlrSF': '1st_floor_num',  # 一楼面积
    '2ndFlrSF': '2nd_floor_num',  # 二楼面积
    'LowQualFinSF': 'low_quality_finished_num',  # 低质量完工的面积
    'GrLivArea': 'living_area_num',  # 居住面积
    'BsmtFullBath': 'basement_full_bathroom_num',  # 高档浴室
    'BsmtHalfBath': 'basement_half_bathroom_num',  # 浴室
    'FullBath': 'full_bathroom_num',  # 总共的高档浴室
    'HalfBath': 'half_bathroom_num',  # 总共的浴室
    'BedroomAbvGr': 'bedroom_num',  # 卧室数量
    'KitchenAbvGr': 'kitchen_num',  # 厨房数量
    'TotRmsAbvGrd': 'total_rooms_num',  # 总共的房间数量
    'OpenPorchSF': 'open_porch_num',  # 开放门廊的面积
    'EnclosedPorch': 'enclose_proch_num',  # 关闭门廊的面积
    '3SsnPorch': 'season_porch_num',  # 能用三个季节的门廊（应该是冬季不能用？）
    'ScreenPorch': 'screen_porch_num',  # 屏风门廊
    
}

facilities = {
    'Utilities': 'utility_cat',  # 水、电、油、汽等是否有
    'Heating': 'heating_cat',  # 加热设施
    'CentralAir': 'center_air_bool',  # 有没有中央空调
    'Electrical': 'electrical_cat',  # 供电情况
    'Fireplaces': 'fireplaces_num',  # 总共的壁炉数量
    'GarageType': 'garage_type_cat',  # 车库情况
    'GarageYrBlt': 'garage_built_date',  # 车库修建年份
    'GarageFinish': 'garage_finish_cat',  # 车库装修状况
    'GarageArea': 'garage_area_num',  # 车库面积
    'PavedDrive': 'paved_drive_cat',  # 车库路是否铺砌
    'PoolArea': 'pool_area_num',  # 泳池面积
    'Fence': 'fence_cat',  # 围栏情况
    'MiscFeature': 'miscellaneous_cat',  # 没有提到的一些额外杂项设施
    'MiscVal': 'miscellaneous_price_num',  # 没有提到的额外杂项设施的价格
}

sales = {
    'YearBuilt': 'built_date',  # 修建时间
    'YearRemodAdd': 'remod_date',  # 装修时间
    'Functional': 'functional_condition_cat',  # 大部分房屋都是典型功能
    'MoSold': 'sold_month_str',  # 出售月份
    'YrSold': 'sold_year_str',  # 出售年份
    'SaleType': 'sale_type_cat',  # 交易类型
    'SaleCondition': 'sale_condition_cat',  # 交易条件
    'sold_time': 'sold_time',  # 交易日期
    'SalePrice': 'SalePrice',  # 交易金额，预测对象
}

materials = {
    'RoofMatl': 'roof_material_cat',  # 屋顶材料
    'Exterior1st': 'exterior_1st_cat',  # 外部第一层材料
    'Exterior2nd': 'exterior_2st_cat',  # 外部第二层材料
    'MasVnrType': 'masonry_veneer_type_cat',   # 隔板材料
    'WoodDeckSF': 'wood_deck_num',  # 木地板面积
    'Foundation': 'foundation_cat',  # 地基面积
}

evaluates = {
    'OverallQual': 'house_quality_cat', 
    'OverallCond': 'house_condition_cat', 
    'ExterQual': 'exterior_material_quality_cat',  # 外部材料的质量
    'ExterCond': 'exterior_material_condition_cat',  # 外部材料的状况
    'BsmtQual': 'basement_quality_cat',  # 基地质量
    'BsmtCond': 'basement_condition_cat',  # 基地状况
    'BsmtExposure': 'basement_exposure_cat',  # 基地采光
    'BsmtFinType1': 'basement_finish_type_1_cat',  # 基地完工类型评级
    'BsmtFinType2': 'basement_finish_type_2_cat',  # 基地完工评级
    'HeatingQC': 'heating_quality_condition_cat',  # 加热质量评级
    'KitchenQual': 'kitchen_quality_cat',  # 厨房质量
    'FireplaceQu': 'fireplace_quality_cat',  # 壁炉质量
    'GarageQual': 'garage_quality_cat',  # 车库质量
    'GarageCond': 'garage_condition_cat',  # 车库情况
    'PoolQC': 'pool_quality_cat',  # 泳池质量
}

variable_types = [locations, config, facilities, sales, materials, evaluates]

# 新增一个列, datetime 类型，是聚合了售出年份和月份的
agg_years_built = lambda row: row['YrSold'] - row['YearBuilt']
agg_years_remod = lambda row: row['YrSold'] - row['YearRemodAdd']

choose_subset = pdp.PdPipeline([
    pdp.ApplyToRows(agg_years_built, colname='built_years'),  # 新增出售年月
    pdp.ApplyToRows(agg_years_remod, colname='remod_years'),
    pdp.ColDrop(['YrSold', 'MoSold', 'YearBuilt', 'YearRemodAdd']),  # 删除原先的年月
])

train = choose_subset(train, verbose=True)

# 生成定序变量，创建映射字典
level_dic = {
    # 用于大多数评估等级的变量
    'Ex': 5,
    'Gd': 4,
    'TA': 3,
    'Fa': 2,
    'Po': 1,
    
    # 用于变量: BsmtFinType
    'GLQ': 6,
    'ALQ': 5,
    'BLQ': 4,
    'Rec': 3,
    'LwQ': 2,
    'Unf': 1,

    # 用于变量: BsmtExposure
    'Av': 3,
    'Mn': 2,
    'No': 1,
}

# 创建 Pandas pipe
import numpy as np
clean_level_data = pdp.ApplyByCols(list(evaluates.keys()), lambda x: level_dic.get(x, np.nan))
# 生成哑变量
datatypes = {k: [] for k in ['ordinal', 'category', 'numeric', 'datetime', 'bool']}

for dic in variable_types:
    for k, v in dic.items():
        if k not in train.columns:
            print("{} not in dataset, please check it!".format(k))
            continue
        if v.endswith('cat') and k in evaluates.keys():
            datatypes['ordinal'].append(k)
        elif v.endswith('cat'):
            datatypes['category'].append(k)
        elif v.endswith('num'):
            datatypes['numeric'].append(k)
        elif v.endswith('date') or v.endswith('time'):
            datatypes['datetime'].append(k)
        elif v.endswith('bool'):
            datatypes['bool'].append(k)

def update_datatypes(data, old_datatypes):
    dtypes = ['ordinal', 'category', 'numeric', 'datetime', 'bool']
    new_datatypes = {k: [] for k in dtypes}
    for k in datatypes:
        for item in old_datatypes[k]:
            if item in data:
                new_datatypes[k].append(item)
    return new_datatypes
            
            
# 创建 pipeline
clean_category_data = pdp.OneHotEncode(columns=datatypes['category'], drop_first=False, drop=True)
clean_category_data += pdp.OneHotEncode(columns=datatypes['bool'], drop=True)


# 转换数据类型
transform_dtype = pdp.ApplyByCols(datatypes['numeric'], pd.to_numeric)
transform_dtype += pdp.ApplyByCols(datatypes['datetime'], pd.to_datetime)

# 重命名
rename_dict = {}
for dic in variable_types:
    rename_dict.update(dic)

# 重命名
rename_variable = pdp.PdPipeline([
    clean_category_data,
    clean_level_data,
    transform_dtype,
])

train = rename_variable(train, verbose=True)
train = pdp.ColRename({col: rename_dict.get(col, col) for col in train}).fit(train)


# 去掉太多缺失值的列
print("\nTop5 cols in missing values:\n")
train.isna().sum().sort_values(ascending=False).head()

print("\n去掉缺失值之前：")
train.shape

dropna_thresh = params['dropna_thresh']
dropna_values = pdp.DropNa(axis=1, thresh=dropna_thresh*len(train))
dropna_values += pdp.DropNa(axis=0, how='any')
train = dropna_values(train, verbose=True)

print("\n去掉缺失值超过{}之后：".format(dropna_thresh))
train.shape
