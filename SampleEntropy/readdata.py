#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun Mar  1 20:26:52 2020

@author: jingfang
jingfang@pik-potsdam.de
"""

from netCDF4 import Dataset
import numpy as np
import scipy.fftpack
from scipy.fftpack import fft


def download():
    import cdsapi
    
    c = cdsapi.Client()
    
    c.retrieve(
        'reanalysis-era5-pressure-levels',
        {
            'variable': 'temperature',
            'pressure_level': '1000',
            'product_type': 'reanalysis',
            'year': [
                '1979', '1980', '1981',
                '1982', '1983', '1984',
                '1985', '1986', '1987',
                '1988', '1989', '1990',
                '1991', '1992', '1993',
                '1994', '1995', '1996',
                '1997', '1998', '1999',
                '2000', '2001', '2002',
                '2003', '2004', '2005',
                '2006', '2007', '2008',
                '2009', '2010', '2011',
                '2012', '2013', '2014',
                '2015', '2016', '2017',
                '2018', '2019'
            ],
            'month': [
                '01', '02', '03',
                '04', '05', '06',
                '07', '08', '09',
                '10', '11', '12'
            ],
            'day': [
                '01', '02', '03',
                '04', '05', '06',
                '07', '08', '09',
                '10', '11', '12',
                '13', '14', '15',
                '16', '17', '18',
                '19', '20', '21',
                '22', '23', '24',
                '25', '26', '27',
                '28', '29', '30',
                '31'
            ],
            'time': '00:00',
            'format': 'netcdf',
            'grid': '2.5/2.5'
        },
        'ERA5_25D.nc')   


def readdata():
    
    a1 = "NINO34_ERA5.ano"
    YEAR_NUMBER2 = 41
    YEAR_NUMBER1 = 5
    data_del_idx = 31+29-1

    fileout = open(a1, "w")  # 写入的文件
    months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]  # 每个月的天数
    data = Dataset('ERA5_25D.nc', 'r', format='NETCDF4')  # 读取NetCDF数据
    air_data = data.variables['t'][:]

    for i in range(34, 39):  # 这应该是经度？？
        print(i)
        for j in range(76, 97):  # 这应该是纬度？？
            data1 = np.zeros(YEAR_NUMBER2*365)  # 41年*365天？
            n = 0
            days = 0
            for year in range(1979, 2020):

                # 判断是不是闰年，更改相应的月份和天数
                if(year % 4 == 0 and year % 100 != 0) or (year % 400 == 0):
                    months[1] = 29
                    d = 366
                else:
                    months[1] = 28
                    d = 365

                if year == 2019:
                    n_last_year = len(air_data)-days
                    d = n_last_year
                days += d
                s1 = days-d
                s2 = days
                data = air_data[s1:s2, i, j]
                if d == 366:
                    data = np.delete(data, data_del_idx)  # 删除2月29号的数据
                for x in data:
                    n += 1
                    data1[n-1] = x

    

            data1 = np.reshape(data1,(YEAR_NUMBER2,365))
            DAY = 365
            for year in range(YEAR_NUMBER2):
                if(year<5):                                     
                    for day in range(DAY):
                        day_x = data1[:,day][:5]
                        day_ave=np.average(day_x)
                        day_std = np.std(day_x)
                        fileout.write('%.6f\n' % ((data1[year][day] - day_ave)/day_std))
                else:
                    if(year == YEAR_NUMBER2 - 1):
                        DAY = n_last_year
                    else:
                        DAY = 365
                    for day in range(DAY):
                        day_x = data1[:, day][:year+1]
                        day_ave=np.average(day_x)
                        day_std = np.std(day_x)
                        fileout.write('%.6f\n' % ((data1[year][day] - day_ave)/day_std))
    fileout.close()
