#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
@Author  :   Shuang Song
Beijing Normal University
@Contact :   SongshGeo@Gmail.com
@Time    :   2020/5/20 11:46
"""

from moviepy.editor import VideoFileClip, concatenate_videoclips
import os
import you_get
import sys


def download(url, path):
    os.chdir(path)
    sys.argv = ['you-get', url]
    you_get.main()


def merge(in_path, out_name):
    movie_list = []
    path_list = []
    for root, dirs, files in os.walk(in_path):
        # 按文件名排序
        files.sort()
        # 遍历所有文件
        for file in files:
            # 如果后缀名为 .mp4
            if os.path.splitext(file)[1] == '.mp4':
                # 拼接成完整路径
                file_path = os.path.join(root, file)
                # 载入视频
                video = VideoFileClip(file_path)
                # 添加到数组
                movie_list.append(video)
                path_list.append(file_path)
    # 拼接视频
    final_clip = concatenate_videoclips(movie_list)
    # 生成目标视频文件
    final_clip.to_videofile(out_name+".mp4", fps=24, remove_temp=False)
    return path_list


def download_and_merge(url, path, title='download_movie'):
    download(url, path)
    path_list = merge(in_path=path, out_name=title)
    for movie in path_list:
        if os.path.exists(movie):  # 如果文件存在
            os.remove(movie)  # 删除文件
    print("download and merged movie: {}".format(title))


if __name__ == '__main__':
    movie_url = "https://v.youku.com/v_show/id_XOTI3MTAzNDI0.html?spm=a2hbt.13141534.app.5~5!2~5!2~5~5~5!2~5~5!2~5!2~5!2~5~5!6~A"
    download_path = r"C:\Users\ssgg9240\downloads"
    name = "大一班级活动好声音导师视频"
    download_and_merge(movie_url, download_path, name)
    pass
