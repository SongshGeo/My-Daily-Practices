#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
@Author  :   Shuang Song
Beijing Normal University
@Contact :   SongshGeo@Gmail.com
@Time    :   2020/4/26 8:23
"""
import requests
from bs4 import BeautifulSoup
import re
import os
from tqdm import tqdm
import http.client
import hashlib
import urllib
import random
import json

springer_url = "https://link.springer.com"
issue_url = r'https://link.springer.com/journal/13280/49/1'
output_path = os.getcwd()

parser = BeautifulSoup(requests.get(issue_url).content, 'html.parser')
article_list = parser.select("h3.title")  # All articles
item_list = parser.select(".toc-item")  # All items
issue = parser.select("h1#title")[0].text


def get_imformation(item):
    title = item.select("h3.title")[0].text.replace("\n", "")
    url = springer_url + item.select("h3.title")[0].a.get('href')
    catalogue = item.select(".content-type")[0].text
    authors = re.sub(", +", ", ", item.select(".authors")[0].text.replace("\n", ""))
    content = BeautifulSoup(requests.get(url).content, 'html.parser')
    abstracts = content.select("#Abs1-content")
    if len(abstracts) == 1:
        abstract = abstracts[0].text.replace("\n", "")
    else:
        abstract = "There is no accesible abstract of this article."
    dic = {
        "title": title,
        'url': url,
        'type': catalogue,
        'authors': authors,
        'abstract': abstract
    }
    return dic


def translator(q):
    appid = '20200426000430242'  # 填写你的appid
    secret_key = 'DFfxBwrUBX0aYzNmpCjZ'  # 填写你的密钥

    http_client = None
    myurl = '/api/trans/vip/translate'

    from_lang = 'auto'  # 原始语言自动选择
    to_lang = 'zh'  # 翻译为中文
    salt = random.randint(32768, 65536)  # 随机种子

    sign = appid + q + str(salt) + secret_key
    sign = hashlib.md5(sign.encode()).hexdigest()
    myurl = myurl + '?appid=' + appid + '&q=' + \
            urllib.parse.quote(q) + '&from=' + \
            from_lang + '&to=' + to_lang + '&salt=' + str(salt) + '&sign=' + sign

    try:
        http_client = http.client.HTTPConnection('api.fanyi.baidu.com')
        http_client.request('GET', myurl)

        # response是HTTPResponse对象
        response = http_client.getresponse()
        result_all = response.read().decode("utf-8")
        result = json.loads(result_all)
        return result['trans_result'][0]['dst']  # 返回翻译结果

    except Exception as e:
        print(e)
    finally:
        if http_client:
            http_client.close()


def write_to_markdown():
    markdown = """# {}\n\n""".format(issue)
    md_dic = {}

    for item in tqdm(item_list):
        dic = get_imformation(item)
        title, url, catalogue, authors, abstract = [dic[key] for key in ['title', 'url', 'type', 'authors', 'abstract']]
        title_ch = translator(title)
        abstract_ch = translator(abstract)
        info = """### {title}\n\n##### {title_ch}\n\n**作者**：{authors}\n\n**摘要**：{abstract_ch}\n\n**原文链接**：{url}\n\n"""
        info = info.format(title=title, title_ch=title_ch, authors=authors, abstract_ch=abstract_ch, url=url)

        if catalogue not in md_dic:
            md_dic[catalogue] = """## {}\n\n""".format(catalogue.title()) + info
        else:
            md_dic[catalogue] = md_dic[catalogue] + info

    for k in md_dic.keys():
        markdown += md_dic[k]

    os.chdir(path=output_path)
    with open(issue+".md", 'w+', encoding='utf-8') as f:
        f.write(markdown)


if __name__ == '__main__':
    write_to_markdown()
    pass
