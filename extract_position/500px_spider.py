#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
@Author  :   Shuang Song
Beijing Normal University
@Contact :   SongshGeo@Gmail.com
@Time    :   2020/5/1 18:03
"""

import requests
import pandas as pd

query = "Birds"
page = 1
api = r"https://api.500px.com/v1/photos/search?type=photos&term={}&rpp=200&page={}".format(query, page)
content = requests.get(api).json()
photos = pd.DataFrame(content['photos'])
# photo_dic = {}
# for photo in photos:
#     photo_id = photo['id']
#     lat = photo['latitude']
#     lon = photo['longitude']
#     date = dt.datetime.strftime(photo['created_at'][:10], '%Y-%m-%d')


if __name__ == '__main__':
    pass
